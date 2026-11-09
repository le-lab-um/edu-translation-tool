"""
Memória de tradução: procura de segmentos anteriores iguais ou parecidos.
Usa a distância de edição normalizada (RapidFuzz) sobre texto em minúsculas e com
espaços normalizados; pontuação e maiúsculas pesam pouco, números pesam como qualquer carácter.
"""

import re

from rapidfuzz import fuzz


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip().lower())


def find_matches(
    source: str, entries: list[tuple[str, str]], threshold: int = 70, limit: int = 3
) -> list[dict]:
    query = normalize(source)
    if not query:
        return []
    scored = {}
    for entry_source, entry_target in entries:
        score = round(fuzz.ratio(query, normalize(entry_source)))
        if score >= threshold:
            scored[(entry_source, entry_target)] = score
    ranked = sorted(scored.items(), key=lambda item: (-item[1], item[0][0], item[0][1]))
    return [{"source": s, "target": t, "score": score} for (s, t), score in ranked[:limit]]
