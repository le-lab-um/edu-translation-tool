"""
Regras de verificação de qualidade da tradução.
Aqui verificamos se o texto está vazio, se faltam números do original
e se os termos obrigatórios do glossário foram respeitados.
"""

import re
from typing import Any, Dict, List


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
        r"\b\d{1,3}(?:[ \u00a0\u202f]\d{3})+(?:[.,]\d+)?\b|\b\d+(?:[.,]\d+)*\b", text
    )
    normalized = []
    for n in raw_numbers:
        # Remove espaços interiores se for separador de milhar (ex: '1 000')
        clean = n.replace(" ", "").replace("\u00a0", "").replace("\u202f", "")
        normalized.append(clean)
    return normalized


def _normalize_num_value(num_str: str) -> str:
    """Normaliza um número para formato padrão float string para comparação de valor."""
    s = num_str.strip()
    # Se tiver vírgula e ponto, ex: 1,000.50 ou 1.000,50
    if "," in s and "." in s:
        if s.rfind(".") > s.rfind(","):
            # Formato EN: 1,000.50 -> 1000.50
            s = s.replace(",", "")
        else:
            # Formato PT: 1.000,50 -> 1000.50
            s = s.replace(".", "").replace(",", ".")
    elif "," in s:
        # Se tem só vírgula: pode ser decimal PT (10,5) ou milhar EN (1,000)
        parts = s.split(",")
        if len(parts) == 2 and len(parts[1]) != 3:
            s = s.replace(",", ".")
        else:
            s = s.replace(",", "")
    elif "." in s:
        # Se tem só ponto: pode ser decimal EN (10.5) ou milhar PT (1.000)
        parts = s.split(".")
        if len(parts) == 2 and len(parts[1]) != 3:
            pass
        else:
            s = s.replace(".", "")
    try:
        val = float(s)
        # Devolve inteiro se não tiver decimais reais para simplificar comparação
        return str(int(val)) if val.is_integer() else str(val)
    except ValueError:
        return num_str


def check_numeric_mismatch(source: str, target: str) -> List[Dict[str, str]]:
    """Deteta se números presentes no original estão em falta na tradução."""
    if not target.strip() or not source.strip():
        return []

    source_nums = _extract_numbers(source)
    if not source_nums:
        return []

    target_nums = _extract_numbers(target)
    target_values = {_normalize_num_value(n) for n in target_nums}

    missing_nums = []
    for s_num in source_nums:
        norm_val = _normalize_num_value(s_num)
        if norm_val not in target_values:
            missing_nums.append(s_num)

    if missing_nums:
        nums_str = ", ".join(missing_nums)
        return [
            {
                "category": "numeric_mismatch",
                "explanation": f"O valor numérico ({nums_str}) presente no original não foi identificado na tradução.",
                "hint": "Verifique se preservou todos os números e quantidades do segmento original e se adaptou o formato para português.",
            }
        ]
    return []


def check_terminology(
    source: str, target: str, glossary: Dict[str, Any]
) -> List[Dict[str, str]]:
    """Verifica se os termos do glossário presentes no original são respeitados na tradução."""
    if not target.strip() or not source.strip() or not glossary:
        return []

    issues = []
    target_lower = target.lower()

    for term, entry in glossary.items():
        # Verifica se o termo está no original (com fronteira de palavra)
        pattern = r"\b" + re.escape(term.lower()) + r"\b"
        if re.search(pattern, source.lower()):
            # Extrai os equivalentes e variantes aceites
            accepted = []
            if isinstance(entry, dict):
                if "target" in entry:
                    accepted.append(entry["target"])
                if "variants" in entry and isinstance(entry["variants"], list):
                    accepted.extend(entry["variants"])
            elif isinstance(entry, list):
                accepted = entry
            elif isinstance(entry, str):
                accepted = [entry]

            # Verifica se pelo menos um equivalente ou variante está no target
            found = False
            for cand in accepted:
                # Permite correspondência exata de palavra ou início da forma verbal (stem)
                cand_lower = cand.lower().strip()
                cand_pattern = r"\b" + re.escape(cand_lower)
                if re.search(cand_pattern, target_lower):
                    found = True
                    break

            if not found and accepted:
                issues.append(
                    {
                        "category": "terminology",
                        "explanation": f"O termo prescrito para '{term}' não foi identificado na tradução.",
                        "hint": f"Consulte o glossário da tarefa para verificar a tradução recomendada de '{term}'.",
                    }
                )

    return issues


def run_all_rules(
    source: str, target: str, glossary: Dict[str, Any] = None
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