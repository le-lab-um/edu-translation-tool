"""
Fusão das pistas determinísticas com as do LLM local.
- As regras têm prioridade: se uma categoria já foi detetada por regra, a do LLM é descartada.
- Um alerta do LLM nunca é mostrado se o texto revelar a solução (filtro anti-solução);
  nesse caso é substituído por uma pista genérica da categoria.
- Cada alerta indica a origem ("rules" ou "llm"), para o aluno saber o que é verificação
  exata e o que é sugestão do modelo.
"""

import re

from backend.rules import _extract_numbers

GENERIC = {
    "empty_translation": ("A tradução está vazia.", "O que falta escrever neste segmento?"),
    "numeric_mismatch": (
        "Os números ou unidades podem não corresponder ao original.",
        "Compara, um a um, os valores do original com os da tua tradução.",
    ),
    "terminology": (
        "Um termo do glossário pode não estar a ser usado.",
        "Consulta o glossário da tarefa: algum termo do original ficou por traduzir como indicado?",
    ),
}


def _contains_word(text: str, term: str) -> bool:
    return re.search(rf"(?<!\w){re.escape(term)}(?!\w)", text, re.IGNORECASE) is not None


def reveals_solution(issue: dict, source: str, glossary: dict[str, dict]) -> bool:
    """Verdadeiro se o alerta citar uma proposta entre aspas, um equivalente do glossário ou um número do original."""
    text = f"{issue['explanation']} {issue['hint']}"
    # Texto entre aspas ou «» costuma ser uma tradução proposta: tratado como possível solução.
    if re.search(r"«[^»]+»|\"[^\"]+\"|“[^”]+”", text):
        return True
    for entry in glossary.values():
        if any(_contains_word(text, option) for option in [entry["target"], *entry.get("variants", [])]):
            return True
    if issue["category"] == "numeric_mismatch":
        digits = {re.sub(r"\D", "", token) for token in _raw_numbers(source)}
        if any(d and d in re.sub(r"\D", "", text) for d in digits):
            return True
    return False


def _raw_numbers(text: str) -> list[str]:
    return re.findall(r"\d[\d.,\s]*\d|\d", text)


def merge_issues(
    rule_issues: list[dict], llm_issues: list[dict], source: str, glossary: dict[str, dict]
) -> tuple[list[dict], int]:
    """Devolve (alertas finais, nº de alertas do LLM reescritos pelo filtro anti-solução)."""
    merged = [{**issue, "source": "rules"} for issue in rule_issues]
    seen = {issue["category"] for issue in merged}
    sanitized = 0
    for issue in llm_issues:
        if issue["category"] in seen:
            continue
        seen.add(issue["category"])
        if reveals_solution(issue, source, glossary):
            explanation, hint = GENERIC[issue["category"]]
            issue = {**issue, "explanation": explanation, "hint": hint}
            sanitized += 1
        merged.append({**issue, "source": "llm"})
    return merged, sanitized
