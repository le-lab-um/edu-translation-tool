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

    def test_invalid_export_format_is_rejected(self):
        self.assertEqual(self.client.get("/api/events/export", params={"format": "xml"}).status_code, 422)

    def test_oversized_payload_is_truncated(self):
        self.client.post("/api/events", json={"session_id": "s", "type": "check_run", "payload": {"a": "x" * 3000}})
        self.assertEqual(self.client.get("/api/events/export").json()[0]["payload"], {"truncated": True})


if __name__ == "__main__":
    unittest.main()
