"""Testes do cálculo de métricas de deteção (experiments/evaluation/metrics.py), com relatórios sintéticos."""

import json
import tempfile
import unittest
from pathlib import Path

from experiments.evaluation.metrics import run, scores


def issue(category):
    return {"category": category, "explanation": "", "hint": ""}


def case(case_id, scope, expected, rules=(), llm=(), hybrid=None, status="ok", sanitized=0):
    return {
        "id": case_id,
        "analysis_scope": scope,
        "expected_categories": list(expected),
        "rule_issues": [issue(c) for c in rules],
        "llm_issues_before_fusion": [issue(c) for c in llm],
        "hybrid_issues_shown": [issue(c) for c in (hybrid if hybrid is not None else sorted(set(rules) | set(llm)))],
        "llm_status": status,
        "sanitized": sanitized,
    }


def header(prompt="hint-v3.txt", **extra):
    return {"prompt": prompt, "prompt_sha256": "x", "dataset_sha256": "d", "model": "m", "model_digest": "g",
            "ollama_version": "1", "generation_options": {"temperature": 0}, **extra}


class MetricsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)

    def write(self, name, results, **head):
        path = Path(self.tmp.name) / name
        path.write_text(json.dumps({**header(**head), "results": results}), encoding="utf-8")
        return path

    def main_micro(self, result, method, index=0):
        return result["analises"][index]["principal"]["metodos"][method]["micro"]

    def test_counts_case_category_pairs(self):
        path = self.write("r.json", [
            case("a", "rq1_main", ["numeric_mismatch"], rules=["numeric_mismatch"], llm=["numeric_mismatch"]),
            case("b", "rq1_main", [], llm=["numeric_mismatch"]),
            case("c", "rq1_main", ["terminology"], rules=["terminology"]),
            case("d", "rq1_main", ["empty_translation"], rules=["empty_translation"], llm=["empty_translation"]),
        ])
        result = run([path], "rq1_main")
        self.assertEqual(self.main_micro(result, "Regras"), scores(3, 0, 0))
        llm = self.main_micro(result, "LLM isolado")
        self.assertEqual((llm["vp"], llm["fp"], llm["fn"]), (2, 1, 1))
        self.assertAlmostEqual(llm["f1"], 2 / 3)
        accept = result["analises"][0]["principal"]["metodos"]["LLM isolado"]["aceitaveis"]
        self.assertEqual(accept, {"aceitaveis": 1, "com_alerta_nas_categorias": 1, "com_qualquer_alerta": 1})

    def test_undefined_when_denominator_is_zero(self):
        self.assertEqual(scores(0, 0, 0), {"vp": 0, "fp": 0, "fn": 0, "precisao": None, "recall": None, "f1": None})
        self.assertEqual(scores(0, 2, 0)["recall"], None)
        self.assertEqual(scores(0, 1, 1)["f1"], 0.0)

    def test_meaning_context_kept_out_of_main_analysis(self):
        path = self.write("r.json", [
            case("a", "rq1_main", [], llm=["meaning_context"]),
            case("b", "rq2_meaning", ["meaning_context"], llm=["meaning_context"], sanitized=1),
        ])
        result = run([path], "rq1_main")
        entry = result["analises"][0]
        self.assertEqual(entry["principal"]["casos"], 1)
        self.assertEqual(self.main_micro(result, "LLM isolado")["fp"], 0)
        accept = entry["principal"]["metodos"]["LLM isolado"]["aceitaveis"]
        self.assertEqual((accept["com_alerta_nas_categorias"], accept["com_qualquer_alerta"]), (0, 1))
        meaning = entry["significado"]["LLM isolado"]
        self.assertEqual((meaning["vp"], meaning["fp"]), (1, 1))
        self.assertEqual(entry["significado"]["alertas_sanitizados"], 1)

    def test_robustness_reported_separately(self):
        path = self.write("r.json", [
            case("a", "rq1_main", ["numeric_mismatch"], rules=["numeric_mismatch"]),
            case("b", "robustness", ["numeric_mismatch"]),
        ])
        entry = run([path], "rq1_main")["analises"][0]
        self.assertEqual(entry["principal"]["metodos"]["Regras"]["micro"]["fn"], 0)
        self.assertEqual(entry["robustez"]["metodos"]["Regras"]["micro"]["fn"], 1)

    def test_invalid_calls_excluded_from_all_methods_and_reports(self):
        v3 = self.write("v3.json", [
            case("a", "rq1_main", ["numeric_mismatch"], rules=["numeric_mismatch"]),
            case("b", "rq1_main", ["numeric_mismatch"], rules=["numeric_mismatch"]),
        ])
        v4 = self.write("v4.json", [
            case("a", "rq1_main", ["numeric_mismatch"], rules=["numeric_mismatch"]),
            case("b", "rq1_main", ["numeric_mismatch"], rules=["numeric_mismatch"], status="timeout"),
        ], prompt="hint-v4.txt")
        result = run([v3, v4], "rq1_main")
        self.assertEqual(result["casos_excluidos"], ["b"])
        for index in (0, 1):
            self.assertEqual(result["analises"][index]["principal"]["casos"], 1)
            self.assertEqual(self.main_micro(result, "Regras", index)["vp"], 1)
        self.assertEqual(result["diferencas_no_cabecalho"], [])

    def test_header_differences_are_flagged(self):
        v3 = self.write("v3.json", [case("a", "rq1_main", [])])
        v4 = self.write("v4.json", [case("a", "rq1_main", [])], prompt="hint-v4.txt", ollama_version="2")
        self.assertEqual(run([v3, v4], "rq1_main")["diferencas_no_cabecalho"], ["ollama_version"])

    def test_reports_with_different_cases_are_rejected(self):
        v3 = self.write("v3.json", [case("a", "rq1_main", [])])
        v4 = self.write("v4.json", [case("b", "rq1_main", [])])
        with self.assertRaises(SystemExit):
            run([v3, v4], "rq1_main")

    def test_old_expected_issues_format(self):
        old = case("a", None, [], rules=["terminology"])
        del old["expected_categories"]
        old["expected_issues"] = [{"category": "terminology"}]
        result = run([self.write("r.json", [old])], "all")
        self.assertEqual(self.main_micro(result, "Regras")["vp"], 1)


if __name__ == "__main__":
    unittest.main()
