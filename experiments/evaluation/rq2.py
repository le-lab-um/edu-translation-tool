"""Resume a anotação da RQ2 (qualidade do feedback) por prompt, depois de revista.

Uso (na raiz do repositório):
    .venv/bin/python -m experiments.evaluation.rq2 \
        experiments/evaluation/anotacao-teste-folha.csv experiments/evaluation/anotacao-teste-chave.csv

Só se corre depois de a folha estar revista: é aqui que se abre a chave.

Para cada prompt, separa dois conjuntos de alertas do modelo:
- versão do modelo: o que o modelo devolveu (linhas `modelo` e `modelo=apresentada`);
- versão apresentada: o que o aluno vê depois do filtro (linhas `apresentada` e `modelo=apresentada`).
As linhas das regras e os casos sem alerta ficam de fora. Conta cada critério, a revelação
(`parcial` e `total` à parte), as linhas `incerto` e as etiquetas das notas.
"""

import argparse
import csv
import json
from collections import Counter
from pathlib import Path

CRITERIA = ("correcao", "fundamentacao", "clareza", "utilidade", "revelacao")
TAGS = ("[binária]", "[afirmação]", "[inventa]", "[língua]")
VIEWS = {
    "modelo": {"modelo", "modelo=apresentada"},
    "apresentada": {"apresentada", "modelo=apresentada"},
}


def read(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f, delimiter=";"))


def summarise(rows):
    out = {"alertas": len(rows)}
    for criterion in CRITERIA:
        out[criterion] = dict(Counter(r[criterion] for r in rows))
    out["incerto"] = sum(1 for r in rows if any(r[c] == "incerto" for c in CRITERIA))
    out["etiquetas"] = {tag: sum(1 for r in rows if tag in r["nota"]) for tag in TAGS}
    out["por_categoria"] = dict(Counter(r["categoria"] for r in rows))
    return out


def run(sheet_path, key_path):
    sheet = {r["row_id"]: r for r in read(sheet_path)}
    key = read(key_path)
    for k in key:
        k.setdefault("prompt", "")
    prompts = sorted({k["prompt"] for k in key})
    result = {}
    for prompt in prompts:
        result[prompt] = {}
        for view, versions in VIEWS.items():
            rows = [sheet[k["row_id"]] for k in key
                    if k["prompt"] == prompt and k["origem"] == "llm" and k["versao"] in versions]
            result[prompt][view] = summarise(rows)
    return result


def pct(n, total):
    return f"{n} ({n / total * 100:.1f}%)" if total else str(n)


def print_result(result):
    for prompt, views in result.items():
        print(f"\n=== {prompt} ===")
        for view, s in views.items():
            n = s["alertas"]
            rev = s["revelacao"]
            print(f"\nVersão {view}: {n} alertas do modelo {s['por_categoria']}")
            print(f"  Revelação: nenhuma {pct(rev.get('nenhuma', 0), n)}, parcial {pct(rev.get('parcial', 0), n)}, "
                  f"total {pct(rev.get('total', 0), n)}; linhas com incerto: {s['incerto']}")
            for criterion in CRITERIA[:-1]:
                values = s[criterion]
                print(f"  {criterion:<14} " + ", ".join(f"{v} {pct(values.get(v, 0), n)}" for v in ("sim", "parcial", "não", "incerto") if values.get(v)))
            print("  Etiquetas: " + ", ".join(f"{t} {c}" for t, c in s["etiquetas"].items()))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("sheet", type=Path)
    parser.add_argument("key", type=Path)
    parser.add_argument("--json", type=Path, help="Grava também o resultado em JSON.")
    args = parser.parse_args()
    result = run(args.sheet, args.key)
    print_result(result)
    if args.json:
        args.json.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
