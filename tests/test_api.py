"""
Testes da API FastAPI.
Garante que o endpoint de verificação responde bem e rejeita pedidos mal formados.
"""

import unittest

from fastapi.testclient import TestClient

from backend.main import app


class TranslationApiTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_empty_translation_returns_alert(self):
        for target in ("", " \t\r\n\u00a0"):
            with self.subTest(target=repr(target)):
                response = self.client.post("/api/check", json={"target": target})

                self.assertEqual(response.status_code, 200)
                body = response.json()
                self.assertEqual(set(body), {"issues"})
                self.assertEqual(len(body["issues"]), 1)
                issue = body["issues"][0]
                self.assertEqual(set(issue), {"category", "explanation", "hint"})
                self.assertEqual(issue["category"], "empty_translation")
                self.assertTrue(issue["explanation"].strip())
                self.assertTrue(issue["hint"].strip())

    def test_nonempty_translation_returns_no_alerts(self):
        for target in ("Abra o FICHEIRO.", " \nTradução com acentos.\t ", "."):
            with self.subTest(target=target):
                response = self.client.post("/api/check", json={"target": target})

                self.assertEqual(response.status_code, 200)
                self.assertEqual(response.json(), {"issues": []})

    def test_missing_target_is_rejected(self):
        response = self.client.post("/api/check", json={})

        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()["detail"][0]["loc"], ["body", "target"])

    def test_non_string_target_is_rejected(self):
        for target in (None, 0, 1.5, False, [], {}):
            with self.subTest(target=target):
                response = self.client.post("/api/check", json={"target": target})

                self.assertEqual(response.status_code, 422)
                self.assertEqual(response.json()["detail"][0]["loc"], ["body", "target"])

    def test_unknown_fields_are_rejected(self):
        response = self.client.post(
            "/api/check", json={"target": "Texto", "expected_issues": []}
        )

        self.assertEqual(response.status_code, 422)
        self.assertEqual(response.json()["detail"][0]["loc"], ["body", "expected_issues"])

    def test_missing_body_is_rejected(self):
        response = self.client.post("/api/check")

        self.assertEqual(response.status_code, 422)

    def test_malformed_json_is_rejected(self):
        response = self.client.post(
            "/api/check", content='{"target":', headers={"Content-Type": "application/json"}
        )

        self.assertEqual(response.status_code, 422)

    def test_invalid_glossary_is_rejected_without_server_error(self):
        for glossary in (
            {"file": {"target": 123}}, {"file": {"target": " "}},
            {"file": {"target": "ficheiro", "variants": [None]}},
            {"file": {"target": "ficheiro", "typo": []}},
            {"file": ["ficheiro"]}, {" ": {"target": "ficheiro"}},
        ):
            with self.subTest(glossary=glossary):
                response = self.client.post("/api/check", json={
                    "source": "Open the file", "target": "Abra o documento", "glossary": glossary,
                })
                self.assertEqual(response.status_code, 422)

    def test_valid_glossary_reaches_rules(self):
        response = self.client.post("/api/check", json={
            "source": "Open the folder", "target": "Abra o diretório",
            "glossary": {"folder": {"target": " pasta ", "variants": [" diretório "]}},
        })
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"issues": []})

    def test_non_string_source_is_rejected(self):
        response = self.client.post("/api/check", json={"source": 123, "target": "Texto"})
        self.assertEqual(response.status_code, 422)


if __name__ == "__main__":
    unittest.main()
