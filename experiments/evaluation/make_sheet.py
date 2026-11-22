"""Gera as folhas de anotação (cega) a partir de um relatório de recolha.

Uso (na raiz do repositório):
    .venv/bin/python -m experiments.evaluation.make_sheet \
        experiments/evaluation/calibration-2026-11-14.json --out output/anotacao

Cria dois ficheiros:
- folha.csv: uma linha por alerta, sem indicar a versão (modelo ou apresentada). É a folha a anotar (proposta e revisão).
- chave.csv: liga cada row_id ao caso e à versão. Não abrir durante a anotação.
"""

import argparse
import csv
import json
import random
from pathlib import Path

CRITERIA = ["correcao", "fundamentacao", "clareza", "utilidade", "revelacao", "nota"]


def rows_for_case(result):
    inputs = result["input"]
    base = {
        "caso": result["id"],
        "original": inputs["source"],
        "traducao": inputs["target"],
        "contexto": inputs["context"],
        "glossario": "; ".join(
            f"{g['source_term']} = {' | '.join(g['accepted_targets'])}" for g in inputs["glossary"]
        ),
    }
    model = result["llm_issues_before_fusion"]
    shown = result["hybrid_issues_shown"]
    shown_llm = [i for i in shown if i.get("source") == "llm"]
    out = []
    for issue in model:
        same = any(
            s["category"] == issue["category"]
            and s["explanation"] == issue["explanation"]
            and s["hint"] == issue["hint"]
            for s in shown_llm
        )
        out.append((base, issue, "modelo=apresentada" if same else "modelo"))
    for issue in shown:
        if issue.get("source") == "llm" and not any(v == "modelo=apresentada" and i is issue for _, i, v in out):
            is_dup = any(
                m["category"] == issue["category"]
                and m["explanation"] == issue["explanation"]
                and m["hint"] == issue["hint"]
                for m in model
            )
            if not is_dup:
                out.append((base, issue, "apresentada"))
        elif issue.get("source") == "rules":
            out.append((base, issue, "regra"))
    if not out:
        out.append((base, None, "sem_alerta"))
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    parser.add_argument("--out", type=Path, required=True, help="Prefixo dos ficheiros de saída.")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    report = json.loads(args.report.read_text(encoding="utf-8"))
    entries = [row for result in report["results"] for row in rows_for_case(result)]
    random.Random(args.seed).shuffle(entries)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    sheet_fields = ["row_id", "caso", "original", "traducao", "contexto", "glossario",
                    "categoria", "explicacao", "pista", *CRITERIA, "problema_omitido"]
    with args.out.with_name(args.out.name + "-folha.csv").open("x", encoding="utf-8", newline="") as f_sheet, \
         args.out.with_name(args.out.name + "-chave.csv").open("x", encoding="utf-8", newline="") as f_key:
        sheet = csv.DictWriter(f_sheet, fieldnames=sheet_fields)
        key = csv.writer(f_key)
        sheet.writeheader()
        key.writerow(["row_id", "caso", "versao", "origem"])
        for n, (base, issue, version) in enumerate(entries, start=1):
            row_id = f"r{n:02d}"
            sheet.writerow({
                "row_id": row_id, **base,
                "categoria": issue["category"] if issue else "",
                "explicacao": issue["explanation"] if issue else "",
                "pista": issue["hint"] if issue else "",
            })
            key.writerow([row_id, base["caso"], version, issue.get("source", "llm") if issue else ""])
    print(f"{len(entries)} linhas em {args.out}-folha.csv e {args.out}-chave.csv")


if __name__ == "__main__":
    main()
