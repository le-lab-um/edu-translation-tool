"""Calcula as métricas de deteção (RQ1) a partir de um ou dois relatórios de recolha.

Uso (na raiz do repositório):
    .venv/bin/python -m experiments.evaluation.metrics output/teste-v3.json
    .venv/bin/python -m experiments.evaluation.metrics output/teste-v3.json output/teste-v4.json
    .venv/bin/python -m experiments.evaluation.metrics relatorio.json --scope all --json output/metricas.json

Unidade de contagem: o par caso-categoria. Para cada caso e cada categoria analisada, a categoria
é esperada se estiver em `expected_categories` e é emitida se o método devolver pelo menos um alerta
dessa categoria. Esperada e emitida = VP; emitida e não esperada = FP; esperada e não emitida = FN.

Métodos: Regras (`rule_issues`), LLM isolado (`llm_issues_before_fusion`) e Híbrido
(`hybrid_issues_shown`). Os três usam o mesmo subconjunto de casos: os que têm `llm_status` igual a
`ok` (em todos os relatórios comparados). Os casos excluídos são indicados.

Análise principal: âmbito `rq1_main` e as categorias comuns `empty_translation`, `numeric_mismatch`
e `terminology`. O âmbito `robustness` é reportado à parte. Os alertas `meaning_context` são
descritos separadamente (RQ2) e não entram na micro-média.
"""

import argparse
import json
from pathlib import Path

MAIN_CATEGORIES = ("empty_translation", "numeric_mismatch", "terminology")
MEANING = "meaning_context"
METHODS = {
    "Regras": "rule_issues",
    "LLM isolado": "llm_issues_before_fusion",
    "Híbrido": "hybrid_issues_shown",
}
HEADER_FIELDS = ("dataset_sha256", "model", "model_digest", "ollama_version", "generation_options")


def expected(case):
    """Categorias de referência do caso (aceita também o formato antigo `expected_issues`)."""
    if "expected_categories" in case:
        return set(case["expected_categories"])
    return {issue["category"] for issue in case.get("expected_issues", [])}


def emitted(case, field):
    return {issue["category"] for issue in case[field]}


def ratio(num, den):
    """Devolve None quando o denominador é nulo (métrica indefinida)."""
    return num / den if den else None


def scores(tp, fp, fn):
    precision = ratio(tp, tp + fp)
    recall = ratio(tp, tp + fn)
    if precision is None or recall is None or precision + recall == 0:
        f1 = None if precision is None or recall is None else 0.0
    else:
        f1 = 2 * precision * recall / (precision + recall)
    return {"vp": tp, "fp": fp, "fn": fn, "precisao": precision, "recall": recall, "f1": f1}


def count(cases, field, categories):
    """VP, FP e FN por categoria e a micro-média (soma dos pares caso-categoria)."""
    per_category = {}
    for category in categories:
        tp = fp = fn = 0
        for case in cases:
            exp = category in expected(case)
            got = category in emitted(case, field)
            tp += exp and got
            fp += got and not exp
            fn += exp and not got
        per_category[category] = scores(tp, fp, fn)
    micro = scores(*(sum(per_category[c][k] for c in categories) for k in ("vp", "fp", "fn")))
    return {"por_categoria": per_category, "micro": micro}


def false_alerts_on_acceptable(cases, field, categories):
    """Casos aceitáveis (sem categorias esperadas) com pelo menos um alerta."""
    acceptable = [c for c in cases if not expected(c)]
    in_categories = sum(1 for c in acceptable if emitted(c, field) & set(categories))
    any_alert = sum(1 for c in acceptable if c[field])
    return {"aceitaveis": len(acceptable), "com_alerta_nas_categorias": in_categories, "com_qualquer_alerta": any_alert}


def select_scope(cases, scope):
    if scope == "all":
        return list(cases)
    return [c for c in cases if c.get("analysis_scope") == scope]


def analyse(cases, categories):
    return {
        "casos": len(cases),
        "metodos": {
            name: {**count(cases, field, categories), "aceitaveis": false_alerts_on_acceptable(cases, field, categories)}
            for name, field in METHODS.items()
        },
    }


def meaning_summary(cases):
    """Descrição dos alertas de significado (RQ2): não entra na micro-média."""
    out = {}
    for name in ("LLM isolado", "Híbrido"):
        out[name] = count(cases, METHODS[name], (MEANING,))["micro"]
    out["alertas_sanitizados"] = sum(c.get("sanitized", 0) for c in cases)
    return out


def load(path):
    report = json.loads(Path(path).read_text(encoding="utf-8"))
    return report, {c["id"]: c for c in report["results"]}


def header_differences(reports):
    first = reports[0]
    return [f for f in HEADER_FIELDS if any(r.get(f) != first.get(f) for r in reports[1:])]


def run(paths, scope):
    loaded = [load(p) for p in paths]
    reports = [r for r, _ in loaded]
    ids = [set(by_id) for _, by_id in loaded]
    if any(i != ids[0] for i in ids[1:]):
        raise SystemExit("Os relatórios não têm os mesmos casos: não é possível compará-los.")
    order = [c["id"] for c in reports[0]["results"]]
    excluded = sorted(i for i in order if any(by_id[i]["llm_status"] != "ok" for _, by_id in loaded))
    valid = [i for i in order if i not in excluded]

    result = {
        "relatorios": [
            {"ficheiro": str(p), "prompt": r.get("prompt"), "prompt_sha256": r.get("prompt_sha256")}
            for p, r in zip(paths, reports)
        ],
        "diferencas_no_cabecalho": header_differences(reports),
        "ambito": scope,
        "casos_excluidos": excluded,
        "analises": [],
    }
    for (report, by_id) in loaded:
        cases = [by_id[i] for i in valid]
        main_scope = "all" if scope == "all" else scope
        entry = {
            "prompt": report.get("prompt"),
            "principal": analyse(select_scope(cases, main_scope), MAIN_CATEGORIES),
            "significado": meaning_summary(select_scope(cases, "all")),
        }
        if scope != "all":
            robustness = select_scope(cases, "robustness")
            if robustness:
                entry["robustez"] = analyse(robustness, MAIN_CATEGORIES)
        result["analises"].append(entry)
    return result


def fmt(value):
    return "indef." if value is None else f"{value * 100:.1f}%"


def print_analysis(title, analysis):
    print(f"\n{title} ({analysis['casos']} casos)")
    print(f"  {'Método':<12} {'VP':>3} {'FP':>3} {'FN':>3} {'Precisão':>9} {'Recall':>8} {'F1':>8}   Aceitáveis com alerta")
    for name, data in analysis["metodos"].items():
        m, a = data["micro"], data["aceitaveis"]
        print(f"  {name:<12} {m['vp']:>3} {m['fp']:>3} {m['fn']:>3} {fmt(m['precisao']):>9} {fmt(m['recall']):>8} "
              f"{fmt(m['f1']):>8}   {a['com_alerta_nas_categorias']}/{a['aceitaveis']} "
              f"(qualquer categoria: {a['com_qualquer_alerta']})")
    for name, data in analysis["metodos"].items():
        cells = "; ".join(f"{c}: {v['vp']}/{v['fp']}/{v['fn']}" for c, v in data["por_categoria"].items())
        print(f"    {name} por categoria (VP/FP/FN) — {cells}")


def print_report(result):
    for r in result["relatorios"]:
        print(f"Relatório: {r['ficheiro']} (prompt {r['prompt']}, sha256 {str(r['prompt_sha256'])[:12]})")
    if result["diferencas_no_cabecalho"]:
        print("ATENÇÃO: os relatórios diferem em " + ", ".join(result["diferencas_no_cabecalho"]))
    print(f"Âmbito principal: {result['ambito']}. Casos excluídos (chamada inválida): "
          f"{len(result['casos_excluidos'])} {result['casos_excluidos'] or ''}".rstrip())
    for entry in result["analises"]:
        print(f"\n=== Prompt {entry['prompt']} ===")
        print_analysis("Análise principal", entry["principal"])
        if "robustez" in entry:
            print_analysis("Robustez (à parte)", entry["robustez"])
        s = entry["significado"]
        print("\nSignificado e contexto (RQ2, descritivo, todos os âmbitos)")
        for name in ("LLM isolado", "Híbrido"):
            m = s[name]
            print(f"  {name:<12} VP {m['vp']}  FP {m['fp']}  FN {m['fn']}")
        print(f"  Alertas reescritos pelo filtro: {s['alertas_sanitizados']}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("reports", nargs="+", type=Path, help="Um relatório, ou dois para comparar (v3 e v4).")
    parser.add_argument("--scope", default="rq1_main", help="Âmbito da análise principal (rq1_main por omissão; all para todos).")
    parser.add_argument("--json", type=Path, help="Grava também o resultado em JSON.")
    args = parser.parse_args()
    result = run(args.reports, args.scope)
    print_report(result)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
