import json
import unittest
from pathlib import Path

from backend.rules import check_empty_translation


class EmptyTranslationTests(unittest.TestCase):
    def test_empty_text_returns_one_alert(self):
        issues = check_empty_translation("")

        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0]["category"], "empty_translation")
        self.assertEqual(set(issues[0]), {"category", "explanation", "hint"})
        self.assertTrue(issues[0]["explanation"].strip())
        self.assertTrue(issues[0]["hint"].strip())

    def test_whitespace_is_empty(self):
        for target in ("   ", "\t", "\n", "\r\n", " \t\n ", "\u00a0", "\u202f"):
            with self.subTest(target=repr(target)):
                issues = check_empty_translation(target)
                self.assertEqual([issue["category"] for issue in issues], ["empty_translation"])

    def test_nonempty_content_does_not_trigger_alert(self):
        for target in ("Abra o ficheiro.", "Abra o FICHEIRO.", " \tTexto\n ", "x", "0", "."):
            with self.subTest(target=target):
                self.assertEqual(check_empty_translation(target), [])

    def test_development_examples_for_empty_translation_only(self):
        dataset_path = Path(__file__).resolve().parents[1] / "data" / "development.json"
        dataset = json.loads(dataset_path.read_text(encoding="utf-8"))

        for case in dataset["cases"]:
            with self.subTest(case=case["id"]):
                # As outras categorias ainda não são implementadas por esta regra.
                expected = [
                    issue["category"] for issue in case["expected_issues"]
                    if issue["category"] == "empty_translation"
                ]
                issues = check_empty_translation(case["input"]["target"])
                self.assertEqual([issue["category"] for issue in issues], expected)


if __name__ == "__main__":
    unittest.main()
