"""
Testes da memória de tradução (RapidFuzz) e dos registos de utilização com exportação.
Usam uma base de dados SQLite em memória.
"""

import csv
import io
import json
import unittest

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from backend.database import Base, get_db
from backend.main import app
from backend.translation_memory import find_matches

engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False}, poolclass=StaticPool)
Session = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = Session()
    try:
        yield db
    finally:
        db.close()


class FindMatchesTests(unittest.TestCase):
    ENTRIES = [("Open the file.", "Abra o ficheiro."), ("Save the file in the folder.", "Guarde o ficheiro na pasta.")]

    def test_exact_match_ignores_case_and_spacing(self):
        result = find_matches("  open   THE file. ", self.ENTRIES)
        self.assertEqual(result[0], {"source": "Open the file.", "target": "Abra o ficheiro.", "score": 100})

    def test_fuzzy_match_and_threshold(self):
        result = find_matches("Open the files.", self.ENTRIES, threshold=80)
        self.assertEqual([m["source"] for m in result], ["Open the file."])
        self.assertTrue(80 <= result[0]["score"] < 100)
        self.assertEqual(find_matches("Completely different sentence", self.ENTRIES), [])

    def test_empty_query_and_limit(self):
        self.assertEqual(find_matches("   ", self.ENTRIES), [])
        self.assertEqual(len(find_matches("Open the file.", self.ENTRIES, threshold=0, limit=1)), 1)


class MemoryAndEventsApiTests(unittest.TestCase):
    def setUp(self):
        app.dependency_overrides[get_db] = override_get_db
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)
        self.client = TestClient(app)

    def tearDown(self):
        app.dependency_overrides.clear()

    def test_memory_save_dedupes_and_search_finds_similar(self):
        pair = {"source": " Open the file. ", "target": "Abra o ficheiro."}
        self.assertEqual(self.client.post("/api/memory", json=pair).json(), {"created": True})
        self.assertEqual(self.client.post("/api/memory", json=pair).json(), {"created": False})
        found = self.client.post("/api/memory/search", json={"source": "Open the files."}).json()["matches"]
        self.assertEqual(len(found), 1)
        self.assertEqual(found[0]["target"], "Abra o ficheiro.")

    def test_memory_pair_can_be_removed_without_touching_others(self):
        keep = {"source": "Open the file.", "target": "Abra o ficheiro."}
        wrong = {"source": "Open the file.", "target": "mamsdmade"}
        for pair in (keep, wrong):
            self.client.post("/api/memory", json=pair)
        self.client.put("/api/segments/e0123456789ab-27f61286-1", json={"target": "mamsdmade"})
        self.assertEqual(self.client.post("/api/memory/remove", json=wrong).json(), {"removed": True})
        self.assertEqual(self.client.post("/api/memory/remove", json=wrong).json(), {"removed": False})
        found = self.client.post("/api/memory/search", json={"source": "Open the file."}).json()["matches"]
        self.assertEqual([m["target"] for m in found], ["Abra o ficheiro."])
        self.assertEqual(self.client.get("/api/segments/e0123456789ab-27f61286-1").json()["target"], "mamsdmade")
        self.assertEqual(self.client.post("/api/memory/remove", json={"source": "x"}).status_code, 422)

    def test_memory_rejects_blank_or_unknown_fields(self):
        for body in ({"source": " ", "target": "x"}, {"source": "x", "target": ""}, {"source": "x", "target": "y", "z": 1}):
            with self.subTest(body=body):
                self.assertEqual(self.client.post("/api/memory", json=body).status_code, 422)
        self.assertEqual(self.client.post("/api/memory/search", json={"source": "x", "threshold": 101}).status_code, 422)

    def test_events_logged_and_exported_as_json_and_csv(self):
        events = [
            {"session_id": "s1", "type": "check_run", "segment_id": "custom-1", "payload": {"issues": 2}},
            {"session_id": "s1", "type": "hint_requested", "payload": {"llm_status": "ok", "ç": "ã"}},
            {"session_id": "s2", "type": "segment_saved"},
        ]
        for event in events:
            self.assertEqual(self.client.post("/api/events", json=event).status_code, 201)

        rows = self.client.get("/api/events/export").json()
        self.assertEqual([r["type"] for r in rows], ["check_run", "hint_requested", "segment_saved"])
        self.assertEqual(rows[0]["payload"], {"issues": 2})

        response = self.client.get("/api/events/export", params={"format": "csv"})
        self.assertIn("text/csv", response.headers["content-type"])
        parsed = list(csv.DictReader(io.StringIO(response.text)))
        self.assertEqual(len(parsed), 3)
        self.assertEqual(json.loads(parsed[1]["payload"])["ç"], "ã")

        summary = self.client.get("/api/events/summary").json()
        self.assertEqual(summary["total"], 3)
        self.assertEqual(summary["sessions"], 2)
        self.assertEqual(summary["by_type"]["check_run"], 1)

    def test_invalid_events_are_rejected(self):
        for body in (
            {"session_id": "s", "type": "desconhecido"}, {"type": "check_run"},
            {"session_id": "", "type": "check_run"}, {"session_id": "s", "type": "check_run", "x": 1},
        ):
            with self.subTest(body=body):
                self.assertEqual(self.client.post("/api/events", json=body).status_code, 422)

    def test_exercise_timeline_returns_only_its_segments_in_order(self):
        ex, other = "e0123456789ab", "e000000000001"
        events = [
            {"session_id": "s1", "type": "segment_saved", "segment_id": f"{ex}-27f61286-1", "payload": {"chars": 5}},
            {"session_id": "s2", "type": "check_run", "segment_id": f"{other}-27f61286-1"},
            {"session_id": "s1", "type": "session_started"},
            {"session_id": "s1", "type": "check_run", "segment_id": f"{ex}-0a0b0c0d-1", "payload": {"categories": ["terminology"]}},
            {"session_id": "s1", "type": "check_run", "segment_id": "custom-1"},
        ]
        for event in events:
            self.client.post("/api/events", json=event)
        body = self.client.get(f"/api/exercises/{ex}/events").json()
        self.assertEqual(body["exercise_id"], ex)
        self.assertEqual([(e["type"], e["segment_id"]) for e in body["events"]],
                         [("segment_saved", f"{ex}-27f61286-1"), ("check_run", f"{ex}-0a0b0c0d-1")])
        self.assertEqual(body["events"][1]["payload"], {"categories": ["terminology"]})
        self.assertTrue(body["events"][0]["created_at"])

    def test_exercise_start_without_segment_appears_in_timeline_and_export(self):
        ex = "e0123456789ab"
        start = {"session_id": "s1", "type": "session_started", "exercise_id": ex, "payload": {"segments": 2}}
        other = {"session_id": "s2", "type": "session_started", "exercise_id": "e000000000001"}
        save = {"session_id": "s1", "type": "segment_saved", "segment_id": f"{ex}-0a0b0c0d", "exercise_id": ex}
        for event in (start, other, save):
            self.assertEqual(self.client.post("/api/events", json=event).status_code, 201)
        events = self.client.get(f"/api/exercises/{ex}/events").json()["events"]
        self.assertEqual([(e["type"], e["segment_id"]) for e in events],
                         [("session_started", None), ("segment_saved", f"{ex}-0a0b0c0d")])
        exported = self.client.get("/api/events/export").json()
        self.assertEqual([r["exercise_id"] for r in exported], [ex, "e000000000001", ex])
        csv_rows = list(csv.DictReader(io.StringIO(self.client.get("/api/events/export", params={"format": "csv"}).text)))
        self.assertEqual(csv_rows[0]["exercise_id"], ex)

    def test_event_exercise_id_is_validated(self):
        bad = {"session_id": "s", "type": "session_started", "exercise_id": "x%"}
        self.assertEqual(self.client.post("/api/events", json=bad).status_code, 422)

    def test_exercise_timeline_rejects_invalid_ids(self):
        for bad in ("custom", "e123", "E0123456789ab", "e0123456789a%"):
            with self.subTest(bad=bad):
                self.assertEqual(self.client.get(f"/api/exercises/{bad}/events").status_code, 422)

    def test_version_restored_event_is_accepted(self):
        body = {"session_id": "s", "type": "version_restored", "segment_id": "e0123456789ab-27f61286-1", "payload": {"version": 1}}
        self.assertEqual(self.client.post("/api/events", json=body).status_code, 201)

    def test_invalid_export_format_is_rejected(self):
        self.assertEqual(self.client.get("/api/events/export", params={"format": "xml"}).status_code, 422)

    def test_oversized_payload_is_truncated(self):
        self.client.post("/api/events", json={"session_id": "s", "type": "check_run", "payload": {"a": "x" * 3000}})
        self.assertEqual(self.client.get("/api/events/export").json()[0]["payload"], {"truncated": True})


if __name__ == "__main__":
    unittest.main()
