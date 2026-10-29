"""
Regras de verificação de qualidade da tradução.
Aqui verificamos se o texto está vazio, se faltam números do original
e se os termos obrigatórios do glossário foram respeitados.
"""

import re
from collections import Counter
from decimal import Decimal
from typing import Dict, List, Optional, TypedDict, Union


class GlossaryEntry(TypedDict, total=False):
    """Formato interno: equivalente prescrito e variantes explicitamente aceites."""

    target: str
    variants: List[str]


def check_empty_translation(target: str) -> List[Dict[str, str]]:
    """Verifica se a tradução não contém texto após remover espaços."""
    if not target.strip():
        return [
            {
                "category": "empty_translation",
                "explanation": "O segmento ainda não contém uma tradução com texto.",
                "hint": "Como traduzirias este segmento para português europeu?",
            }
        ]
    return []


def _extract_numbers(text: str) -> List[str]:
    """Extrai números inteiros e decimais, ignorando pontuação adjacente."""
    # Apanha sequências numéricas com separadores de milhar/decimais (, ou .).
    # Um espaço só conta como separador de milhares se for seguido de exatamente
    # três dígitos (1 000,50); assim "Chapter 5 10 pages" continua a ter dois números.
    raw_numbers = re.findall(
        r"(?<!\w)[+\-−]?(?:\d{1,3}(?:[ \u00a0\u202f]\d{3})+(?:[.,]\d+)?|\d+(?:[.,]\d+)*)(?!\w)", text
    )
    normalized = []
    for n in raw_numbers:
        # Remove espaços interiores se for separador de milhar (ex: '1 000')
        clean = n.replace(" ", "").replace("\u00a0", "").replace("\u202f", "")
        normalized.append(clean)
    return normalized


def _normalize_num_value(num_str: str, *, english: bool) -> Union[Decimal, str]:
    """Interpreta EN no original e PT-PT na tradução, sem arredondar via float.

    Aceita agrupamentos de milhares com três dígitos. Uma sequência mal
    formatada conserva a sua representação, sem tentar adivinhar o valor.
    Datas, intervalos e unidades não são interpretados por esta regra.
    """
    s = num_str.replace("−", "-")
    grouping, decimal = (",", ".") if english else (".", ",")
    pattern = rf"[+-]?(?:\d+|\d{{1,3}}(?:{re.escape(grouping)}\d{{3}})+)(?:{re.escape(decimal)}\d+)?"
    if not re.fullmatch(pattern, s):
        return s
    return Decimal(s.replace(grouping, "").replace(decimal, "."))


def check_numeric_mismatch(source: str, target: str) -> List[Dict[str, str]]:
    """Deteta se números presentes no original estão em falta na tradução."""
    if not target.strip() or not source.strip():
        return []

    source_nums = _extract_numbers(source)
    if not source_nums:
        return []

    target_nums = _extract_numbers(target)
    # Contar ocorrências evita aceitar apenas um número quando o original o repete.
    source_values = Counter(_normalize_num_value(n, english=True) for n in source_nums)
    target_values = Counter(_normalize_num_value(n, english=False) for n in target_nums)
    if source_values - target_values:
        return [
            {
                "category": "numeric_mismatch",
                "explanation": "Pelo menos um valor numérico do original não foi preservado com o mesmo número de ocorrências na tradução.",
                "hint": "Verifique se preservou todos os números e quantidades do segmento original e se adaptou o formato para português.",
            }
        ]
    return []


def check_terminology(
    source: str, target: str, glossary: Dict[str, GlossaryEntry]
) -> List[Dict[str, str]]:
    """Verifica se os termos do glossário presentes no original são respeitados na tradução."""
    if not target.strip() or not source.strip() or not glossary:
        return []

    issues = []
    for term, entry in glossary.items():
        pattern = r"(?<!\w)" + re.escape(term) + r"(?!\w)"
        if re.search(pattern, source, re.IGNORECASE):
            accepted = [entry["target"], *entry.get("variants", [])]
            # A flexão deve constar das variantes; um prefixo não prova equivalência.
            found = any(
                re.search(r"(?<!\w)" + re.escape(candidate) + r"(?!\w)", target, re.IGNORECASE)
                for candidate in accepted
            )
            if not found:
                issues.append(
                    {
                        "category": "terminology",
                        "explanation": f"O termo prescrito para '{term}' não foi identificado na tradução.",
                        "hint": f"Consulte o glossário da tarefa para verificar a tradução recomendada de '{term}'.",
                    }
                )

    return issues


def run_all_rules(
    source: str, target: str, glossary: Optional[Dict[str, GlossaryEntry]] = None
) -> List[Dict[str, str]]:
    """Executa todas as verificações determinísticas por ordem de prioridade."""
    # 1. Se estiver vazio, não avalia outras regras
    empty_issues = check_empty_translation(target)
    if empty_issues:
        return empty_issues

    issues = []
    # 2. Números
    issues.extend(check_numeric_mismatch(source, target))
    # 3. Terminologia
    if glossary:
        issues.extend(check_terminology(source, target, glossary))

    return issues
