"""Verifica se os originais de um conjunto de casos já apareceram noutro sítio do repositório.

Uso (na raiz do repositório):
    .venv/bin/python -m experiments.evaluation.check_overlap
    .venv/bin/python -m experiments.evaluation.check_overlap --cases experiments/evaluation/test.json

Procura cada original (ignorando maiúsculas e pontuação) no texto de todos os ficheiros do projeto,
exceto o próprio conjunto e os seus relatórios (test*.json). Avisa também de originais muito
parecidos e de termos de glossário já usados no desenvolvimento ou na calibração.
Termina com código 1 se encontrar alguma coincidência.
"""

import argparse
import json
import re
import sys
from pathlib import Path

from rapidfuzz import fuzz

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CASES = Path(__file__).with_name("test.json")
SUFFIXES = {".py", ".ts", ".tsx", ".json", ".md", ".txt", ".typ", ".csv", ".bib"}
SKIP_DIRS = {".git", ".venv", "node_modules", "dist", "output", "__pycache__"}
SKIP_NAMES = {"package-lock.json"}
GLOSSARY_SOURCES = [ROOT / "data" / "development.json", Path(__file__).with_name("calibration.json")]


def norm(text):
    return " ".join(re.sub(r"[\W_]+", " ", text.lower()).split())


def project_files(root, cases_path):
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix not in SUFFIXES or path.name in SKIP_NAMES:
            continue
        if SKIP_DIRS & set(path.relative_to(root).parts):
            continue
        if path.resolve() == cases_path.resolve() or (path.parent == cases_path.parent and path.name.startswith("test")):
            continue
        yield path


def glossary_terms(path):
    if not path.exists():
        return set()
    cases = json.loads(path.read_text(encoding="utf-8"))["cases"]
    return {norm(g["source_term"]) for c in cases for g in c["input"]["glossary"]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cases", type=Path, default=DEFAULT_CASES)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--threshold", type=int, default=90, help="Semelhança mínima (0-100) para avisar de originais parecidos.")
    args = parser.parse_args()

    cases = json.loads(args.cases.read_text(encoding="utf-8"))["cases"]
    sources = {}
    for case in cases:
        sources.setdefault(case["input"]["source"], case["source_id"])
    texts = {path: norm(path.read_text(encoding="utf-8", errors="ignore")) for path in project_files(args.root, args.cases)}

    problems = []
    for source, source_id in sources.items():
        needle = norm(source)
        for path, text in texts.items():
            where = path.relative_to(args.root)
            if f" {needle} " in f" {text} ":
                problems.append(f"EXATO     {source_id}: «{source}» aparece em {where}")
            else:
                score = fuzz.partial_ratio(needle, text)
                if score >= args.threshold:
                    problems.append(f"PARECIDO  {source_id}: «{source}» (semelhança {score:.0f}) em {where}")

    used_terms = set().union(*(glossary_terms(p) for p in GLOSSARY_SOURCES))
    for case in cases:
        for entry in case["input"]["glossary"]:
            if norm(entry["source_term"]) in used_terms:
                problems.append(f"GLOSSÁRIO {case['source_id']}: o termo «{entry['source_term']}» já foi usado no desenvolvimento ou na calibração")

    for line in dict.fromkeys(problems):
        print(line)
    if problems:
        print(f"\n{len(set(problems))} coincidência(s). Mudar os originais afetados antes de fixar o conjunto.")
        sys.exit(1)
    print(f"OK: {len(sources)} originais verificados em {len(texts)} ficheiros, sem coincidências.")


if __name__ == "__main__":
    main()
