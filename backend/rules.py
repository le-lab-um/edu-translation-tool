"""Verificações determinísticas de traduções, independentes da API e do LLM."""


def check_empty_translation(target: str) -> list[dict[str, str]]:
    """Devolve um alerta se a tradução contiver apenas whitespace ou for vazia.

    Recebe o texto da tradução. A presença de qualquer carácter que não seja
    removido por str.strip() impede este alerta, sem avaliar a qualidade do texto.
    """
    if target.strip():
        return []

    return [{
        "category": "empty_translation",
        "explanation": "O segmento ainda não contém uma tradução com texto.",
        "hint": "Como traduzirias este segmento para português europeu?",
    }]
