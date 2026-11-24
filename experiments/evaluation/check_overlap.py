"""Verifica se os originais de um conjunto de casos já apareceram noutro sítio do repositório.

Uso (na raiz do repositório):
    .venv/bin/python -m experiments.evaluation.check_overlap                      # test.json
    .venv/bin/python -m experiments.evaluation.check_overlap --cases experiments/evaluation/diagnostico.json

Procura cada original (ignorando maiúsculas e pontuação) no texto de todos os ficheiros do projeto,
incluindo os outros conjuntos de casos e os prompts. Ignora o próprio conjunto e os ficheiros feitos
com ele (relatórios de recolha e folhas de anotação, reconhecidos pelo nome do ficheiro do conjunto
ou pelos identificadores dos casos). Avisa também de originais muito parecidos e de termos de glossário já usados
noutros conjuntos. Termina com código 1 se encontrar alguma coincidência.
"""

import argparse
import json
import re
import sys
from pathlib import Path

from rapidfuzz import fuzz

ROOT = Path(__file__).resolve().parents[2]
EVALUATION_DIR = Path(__file__).resolve().parent
DEFAULT_CASES = EVALUATION_DIR / "test.json"
SUFFIXES = {".py", ".ts", ".tsx", ".json", ".md", ".txt", ".typ", ".csv", ".bib"}
SKIP_DIRS = {".git", ".venv", "node_modules", "dist", "output", "__pycache__"}
SKIP_NAMES = {"package-lock.json"}


def norm(text):
    return " ".join(re.sub(r"[\W_]+", " ", text.lower()).split())


def project_files(root, cases_path):
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix not in SUFFIXES or path.name in SKIP_NAMES:
            continue
        if SKIP_DIRS & set(path.relative_to(root).parts) or path.resolve() == cases_path.resolve():
            continue
        yield path


def derived_from(raw_text, cases_path, case_ids):
    """Relatórios e folhas de anotação do próprio conjunto: citam o ficheiro ou os identificadores dos casos."""
    if f'"cases_file": "{cases_path.name}"' in raw_text:
        return True
    return any(re.search(rf"(?<![\w-]){re.escape(case_id)}(?![\w-])", raw_text) for case_id in case_ids)


def other_glossary_terms(root, cases_path):
    terms = set()
    candidates = [root / "data" / "development.json", *sorted(EVALUATION_DIR.glob("*.json"))]
    for path in candidates:
        if not path.exists() or path.resolve() == cases_path.resolve():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        for case in data.get("cases", []) if isinstance(data, dict) else []:
            terms |= {norm(g["source_term"]) for g in case["input"]["glossary"]}
    return terms


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--cases", type=Path, default=DEFAULT_CASES)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--threshold", type=int, default=90, help="Semelhança mínima (0-100) para avisar de originais parecidos.")
    args = parser.parse_args()

    cases = json.loads(args.cases.read_text(encoding="utf-8"))["cases"]
    case_ids = [case["id"] for case in cases]
    sources = {}
    for case in cases:
        sources.setdefault(case["input"]["source"], case["source_id"])
    texts = {}
    for path in project_files(args.root, args.cases):
        raw = path.read_text(encoding="utf-8", errors="ignore")
        if not derived_from(raw, args.cases, case_ids):
            texts[path] = norm(raw)

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

    used_terms = other_glossary_terms(args.root, args.cases)
    for case in cases:
        for entry in case["input"]["glossary"]:
            if norm(entry["source_term"]) in used_terms:
                problems.append(f"GLOSSÁRIO {case['source_id']}: o termo «{entry['source_term']}» já foi usado noutro conjunto")

    unique = list(dict.fromkeys(problems))
    for line in unique:
        print(line)
    if unique:
        print(f"\n{len(unique)} coincidência(s). Mudar os originais afetados antes de fixar o conjunto.")
        sys.exit(1)
    print(f"OK: {len(sources)} originais verificados em {len(texts)} ficheiros, sem coincidências.")


if __name__ == "__main__":
    main()
