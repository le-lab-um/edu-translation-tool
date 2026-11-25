"""Testes do resumo da anotação da RQ2 (experiments/evaluation/rq2.py), com folhas sintéticas."""

import csv
import tempfile
import unittest
from pathlib import Path

from experiments.evaluation.rq2 import run

SHEET_FIELDS = ["row_id", "caso", "categoria", "correcao", "fundamentacao", "clareza", "utilidade", "revelacao", "nota"]


def write(path, fields, rows):
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields, delimiter=";")
        writer.writeheader()
        writer.writerows(rows)


class Rq2Test(unittest.TestCase):
    def test_views_and_counts_per_prompt(self):
        with tempfile.TemporaryDirectory() as tmp:
            sheet, key = Path(tmp) / "folha.csv", Path(tmp) / "chave.csv"
            judged = dict(correcao="sim", fundamentacao="sim", clareza="sim", utilidade="sim")
            write(sheet, SHEET_FIELDS, [
                {"row_id": "r1", "caso": "a", "categoria": "meaning_context", **judged, "revelacao": "total", "nota": "[binária]"},
                {"row_id": "r2", "caso": "a", "categoria": "meaning_context", **judged, "revelacao": "nenhuma", "nota": ""},
                {"row_id": "r3", "caso": "b", "categoria": "numeric_mismatch", **judged, "revelacao": "nenhuma", "nota": ""},
                {"row_id": "r4", "caso": "c", "categoria": "", "correcao": "", "fundamentacao": "", "clareza": "",
                 "utilidade": "", "revelacao": "", "nota": ""},
                {"row_id": "r5", "caso": "a", "categoria": "meaning_context", **judged, "revelacao": "parcial", "nota": ""},
            ])
            write(key, ["row_id", "caso", "versao", "origem", "prompt"], [
                {"row_id": "r1", "caso": "a", "versao": "modelo", "origem": "llm", "prompt": "v3"},
                {"row_id": "r2", "caso": "a", "versao": "apresentada", "origem": "llm", "prompt": "v3"},
                {"row_id": "r3", "caso": "b", "versao": "regra", "origem": "rules", "prompt": "v3"},
                {"row_id": "r4", "caso": "c", "versao": "sem_alerta", "origem": "", "prompt": "v3"},
                {"row_id": "r5", "caso": "a", "versao": "modelo=apresentada", "origem": "llm", "prompt": "v4"},
            ])
            result = run(sheet, key)
        self.assertEqual(result["v3"]["modelo"]["alertas"], 1)
        self.assertEqual(result["v3"]["modelo"]["revelacao"], {"total": 1})
        self.assertEqual(result["v3"]["modelo"]["etiquetas"]["[binária]"], 1)
        self.assertEqual(result["v3"]["apresentada"]["revelacao"], {"nenhuma": 1})
        self.assertEqual(result["v4"]["modelo"]["alertas"], 1)
        self.assertEqual(result["v4"]["apresentada"]["revelacao"], {"parcial": 1})


if __name__ == "__main__":
    unittest.main()
