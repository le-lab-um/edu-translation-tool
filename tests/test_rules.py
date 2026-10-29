"""
Testes às regras determinísticas.
Testa a regra de texto vazio, conferência de números e termos do glossário.
"""

import unittest

from backend.rules import (
    check_empty_translation,
    check_numeric_mismatch,
    check_terminology,
    run_all_rules,
)


class EmptyTranslationTests(unittest.TestCase):
    def test_empty_text_returns_alert(self):
        issues = check_empty_translation("")
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0]["category"], "empty_translation")

    def test_whitespace_is_empty(self):
        for whitespace in (" ", "  ", "\t", "\n", "\r\n", " \t \n "):
            with self.subTest(whitespace=repr(whitespace)):
                issues = check_empty_translation(whitespace)
                self.assertEqual(len(issues), 1)
                self.assertEqual(issues[0]["category"], "empty_translation")

    def test_nonempty_content_does_not_trigger_alert(self):
        for text in ("a", ".", "Tradução válida.", "   conteúdo com espaços   "):
            with self.subTest(text=text):
                self.assertEqual(check_empty_translation(text), [])


class NumericMismatchTests(unittest.TestCase):
    def test_three_decimal_places_are_not_thousands(self):
        self.assertEqual(check_numeric_mismatch("Value: 0.125", "Valor: 0,125"), [])
        self.assertEqual(len(check_numeric_mismatch("Value: 0.125", "Valor: 125")), 1)

    def test_sign_is_preserved(self):
        self.assertEqual(check_numeric_mismatch("Temperature: -5", "Temperatura: −5"), [])
        self.assertEqual(len(check_numeric_mismatch("Temperature: -5", "Temperatura: 5")), 1)

    def test_repeated_numbers_require_repeated_occurrences(self):
        self.assertEqual(len(check_numeric_mismatch("5 boxes and 5 bags", "5 caixas e sacos")), 1)
        self.assertEqual(check_numeric_mismatch("5 boxes and 5 bags", "5 caixas e 5 sacos"), [])

    def test_large_integers_do_not_lose_precision(self):
        self.assertEqual(len(check_numeric_mismatch("9007199254740992", "9007199254740993")), 1)

    def test_alert_does_not_supply_missing_value(self):
        issue = check_numeric_mismatch("Discount: 15%", "Desconto: 50 %")[0]
        self.assertNotIn("15", issue["explanation"] + issue["hint"])

    def test_matching_numbers_different_format(self):
        # 1,000.50 em EN equivale a 1 000,50 ou 1000,50 em PT
        source = "The total cost is €1,000.50."
        target = "O custo total é de 1000,50 €."
        self.assertEqual(check_numeric_mismatch(source, target), [])

    def test_adjacent_numbers_separated_by_space_stay_separate(self):
        # "5 10" são dois números; só "1 000" (grupos de três dígitos) é um milhar
        source = "Chapter 5 10 pages"
        self.assertEqual(check_numeric_mismatch(source, "Capítulo 5, 10 páginas"), [])
        self.assertEqual(len(check_numeric_mismatch(source, "Capítulo 5 páginas")), 1)

    def test_thousands_with_space_and_nbsp(self):
        source = "The total is 1,000.50."
        for target in ("O total é 1 000,50.", "O total é 1\u00a0000,50."):
            with self.subTest(target=target):
                self.assertEqual(check_numeric_mismatch(source, target), [])

    def test_missing_number_returns_alert(self):
        source = "There are 42 items in room 101."
        target = "Existem quarenta e dois itens na sala."
        issues = check_numeric_mismatch(source, target)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0]["category"], "numeric_mismatch")

    def test_no_numbers_in_source_returns_no_issues(self):
        source = "Click here to proceed."
        target = "Clique aqui para avançar."
        self.assertEqual(check_numeric_mismatch(source, target), [])


class TerminologyTests(unittest.TestCase):
    def setUp(self):
        self.glossary = {
            "file": {"target": "ficheiro"},
            "save": {"target": "guardar", "variants": ["guarde", "gravar", "grave"]},
        }

    def test_prescribed_terms_present(self):
        source = "Save the file before closing."
        target = "Guarde o ficheiro antes de fechar."
        self.assertEqual(check_terminology(source, target, self.glossary), [])

    def test_missing_prescribed_term_triggers_alert(self):
        source = "Save the file before closing."
        target = "Guarde o documento antes de fechar."  # Falta 'ficheiro'
        issues = check_terminology(source, target, self.glossary)
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0]["category"], "terminology")
        self.assertIn("file", issues[0]["explanation"])

    def test_prefix_is_not_an_accepted_term(self):
        self.assertEqual(len(check_terminology("The file", "O ficheiroXYZ", self.glossary)), 1)

    def test_case_and_punctuation_do_not_trigger_alert(self):
        self.assertEqual(check_terminology("Open the file.", "Abra o FICHEIRO!", self.glossary), [])

    def test_source_substring_does_not_require_term(self):
        self.assertEqual(check_terminology("Update profile.", "Atualize o perfil.", self.glossary), [])

    def test_explicit_variant_is_accepted(self):
        self.assertEqual(check_terminology("Save", "Grave.", self.glossary), [])

    def test_terms_with_punctuation_are_literal(self):
        self.assertEqual(check_terminology("Use C++.", "Use C++.", {"C++": {"target": "C++"}}), [])

class RunAllRulesTests(unittest.TestCase):
    def test_empty_target_takes_priority(self):
        source = "Read all 5 instructions."
        issues = run_all_rules(source, "", {"instructions": {"target": "instruções"}})
        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0]["category"], "empty_translation")

    def test_multiple_issues_reported(self):
        source = "Read all 5 instructions."
        target = "Leia as orientações."  # Falta o número 5 e usou orientações em vez de instruções
        glossary = {"instructions": {"target": "instruções"}}
        issues = run_all_rules(source, target, glossary)
        categories = {i["category"] for i in issues}
        self.assertIn("numeric_mismatch", categories)
        self.assertIn("terminology", categories)


if __name__ == "__main__":
    unittest.main()
