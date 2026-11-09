"""
Testes do nível 3 inicial: adaptador Ollama (servidor simulado), fusão e filtro anti-solução.
Não é necessário ter o Ollama instalado: o servidor é simulado com httpx.MockTransport.
"""

import json
import unittest

import httpx
from fastapi.testclient import TestClient

from backend.hybrid import merge_issues, reveals_solution
from backend.llm import LLMError, OllamaClient, validate_answer
from backend.main import app, get_llm_client

GLOSSARY = {"file": {"target": "ficheiro", "variants": []}, "folder": {"target": "pasta", "variants": ["diretório"]}}


def fake_ollama(content, done_reason="stop", status=200, capture=None):
    def handler(request: httpx.Request) -> httpx.Response:
        if capture is not None:
            capture.append(json.loads(request.content))
        if isinstance(content, Exception):
            raise content
        body = {"done": True, "done_reason": done_reason, "message": {"content": content}}
        return httpx.Response(status, json=body)

    return OllamaClient(transport=httpx.MockTransport(handler), enabled=True)


def answer(*issues):
    return json.dumps({"issues": list(issues)})


ISSUE = {"category": "terminology", "explanation": "Termo em falta.", "hint": "Consulta o glossário."}


class ValidateTests(unittest.TestCase):
    def test_accepts_valid_answer(self):
        self.assertEqual(validate_answer({"issues": [ISSUE]}), [ISSUE])

    def test_rejects_invalid_answers(self):
        bad = [
            [], {"issues": "x"}, {"issues": [], "extra": 1},
            {"issues": [{**ISSUE, "category": "style"}]},
            {"issues": [{**ISSUE, "hint": " "}]},
            {"issues": [{"category": "terminology", "explanation": "x"}]},
        ]
        for value in bad:
            with self.subTest(value=value), self.assertRaises(LLMError):
                validate_answer(value)


class MergeTests(unittest.TestCase):
    def test_rules_win_over_llm_for_same_category(self):
        rules = [{"category": "terminology", "explanation": "regra", "hint": "regra"}]
        merged, _ = merge_issues(rules, [ISSUE], "Open the file.", GLOSSARY)
        self.assertEqual([(i["category"], i["source"]) for i in merged], [("terminology", "rules")])

    def test_llm_adds_other_categories_and_dedupes_itself(self):
        numeric = {"category": "numeric_mismatch", "explanation": "Valores diferentes.", "hint": "Compara os valores."}
        merged, _ = merge_issues([], [ISSUE, numeric, ISSUE], "Open the file.", GLOSSARY)
        self.assertEqual([(i["category"], i["source"]) for i in merged],
                         [("terminology", "llm"), ("numeric_mismatch", "llm")])

    def test_solution_guard_detects_glossary_target(self):
        leak = {**ISSUE, "hint": "Devias usar «ficheiro»."}
        self.assertTrue(reveals_solution(leak, "Open the file.", GLOSSARY))
        self.assertFalse(reveals_solution(ISSUE, "Open the file.", GLOSSARY))

    def test_solution_guard_detects_quoted_proposals_without_glossary(self):
        for text in ("Não seria melhor «desconto»?", 'Tenta "desconto".', "Usa “redução”."):
            with self.subTest(text=text):
                self.assertTrue(reveals_solution({**ISSUE, "hint": text}, "A discount.", {}))

    def test_solution_guard_ignores_substrings(self):
        issue = {**ISSUE, "hint": "Revê a pastagem."}
        self.assertFalse(reveals_solution(issue, "Open the folder.", GLOSSARY))

    def test_solution_guard_detects_numbers_for_numeric_category(self):
        leak = {"category": "numeric_mismatch", "explanation": "Falta 1.000,50.", "hint": "Usa 15."}
        self.assertTrue(reveals_solution(leak, "The total is €1,000.50.", GLOSSARY))

    def test_leaking_llm_issue_is_replaced_by_generic_hint(self):
        leak = {**ISSUE, "hint": "Escreve ficheiro."}
        merged, sanitized = merge_issues([], [leak], "Open the file.", GLOSSARY)
        self.assertEqual(sanitized, 1)
        self.assertNotIn("ficheiro", merged[0]["hint"])
        self.assertEqual(merged[0]["source"], "llm")


class HintEndpointTests(unittest.TestCase):
    def tearDown(self):
        app.dependency_overrides.clear()

    def post(self, client, **body):
        app.dependency_overrides[get_llm_client] = lambda: client
        payload = {"source": "Open the file.", "target": "Abra o documento.", "glossary": GLOSSARY, **body}
        return TestClient(app).post("/api/hint", json=payload)

    def test_hybrid_combines_rules_and_llm(self):
        numeric = {"category": "numeric_mismatch", "explanation": "Valores diferentes.", "hint": "Compara."}
        data = self.post(fake_ollama(answer(ISSUE, numeric))).json()
        self.assertEqual(data["llm_status"], "ok")
        self.assertEqual({(i["category"], i["source"]) for i in data["issues"]},
                         {("terminology", "rules"), ("numeric_mismatch", "llm")})

    def test_llm_receives_data_prompt_and_deterministic_settings(self):
        captured = []
        self.post(fake_ollama(answer(), capture=captured), context="Manual de ajuda.")
        request = captured[0]
        self.assertEqual(request["options"]["temperature"], 0)
        self.assertEqual(request["options"]["seed"], 42)
        self.assertIn("format", request)
        user = json.loads(request["messages"][1]["content"])
        self.assertEqual(user["source"], "Open the file.")
        self.assertEqual(user["context"], "Manual de ajuda.")
        self.assertEqual(user["glossary"][1],
                         {"source_term": "folder", "accepted_targets": ["pasta", "diretório"]})

    def test_hybrid_returns_technical_alerts_as_rules_without_expanding_model_schema(self):
        captured = []
        response = self.post(
            fake_ollama(answer(), capture=captured),
            source="Hello {name}, select <b>Save</b>.", target="Olá, selecione Guardar.", glossary={},
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            [(issue["category"], issue["source"]) for issue in response.json()["issues"]],
            [("placeholder_mismatch", "rules"), ("inline_tag_mismatch", "rules")],
        )
        self.assertEqual(
            captured[0]["format"]["properties"]["issues"]["items"]["properties"]["category"]["enum"],
            ["empty_translation", "numeric_mismatch", "terminology"],
        )

    def test_falls_back_to_rules_when_ollama_is_down(self):
        down = fake_ollama(httpx.ConnectError("recusada"))
        data = self.post(down).json()
        self.assertEqual(data["llm_status"], "unavailable")
        self.assertEqual([i["source"] for i in data["issues"]], ["rules"])

    def test_timeout_invalid_json_and_http_errors_fall_back(self):
        cases = {
            "timeout": fake_ollama(httpx.ReadTimeout("lento")),
            "invalid": fake_ollama("não é json"),
            "unavailable": fake_ollama("{}", status=500),
        }
        for expected, client in cases.items():
            with self.subTest(expected=expected):
                data = self.post(client).json()
                self.assertEqual(data["llm_status"], expected)
                self.assertTrue(all(i["source"] == "rules" for i in data["issues"]))

    def test_incomplete_generation_is_invalid(self):
        data = self.post(fake_ollama(answer(), done_reason="length")).json()
        self.assertEqual(data["llm_status"], "invalid")

    def test_disabled_llm_returns_rules_only(self):
        client = OllamaClient(enabled=False)
        self.assertEqual(self.post(client).json()["llm_status"], "disabled")

    def test_empty_translation_skips_llm(self):
        captured = []
        data = self.post(fake_ollama(answer(), capture=captured), target="  ").json()
        self.assertEqual(data["llm_status"], "skipped")
        self.assertEqual(captured, [])
        self.assertEqual(data["issues"][0]["category"], "empty_translation")

    def test_invalid_request_is_rejected(self):
        app.dependency_overrides[get_llm_client] = lambda: fake_ollama(answer())
        response = TestClient(app).post("/api/hint", json={"target": "x", "extra": 1})
        self.assertEqual(response.status_code, 422)


if __name__ == "__main__":
    unittest.main()
