"""
Nível 3 (versão inicial): adaptador para o modelo local servido pelo Ollama.
Envia o original, a tradução, o contexto e o glossário (como dados, nunca como instruções)
e valida a resposta JSON. Qualquer falha é devolvida como LLMError e nunca rompe a verificação:
o motor de regras continua a ser a base do sistema.
"""

import json
import os
from pathlib import Path
from typing import Any

import httpx

CATEGORIES = ("empty_translation", "numeric_mismatch", "terminology", "meaning_context")
PROMPT_PATH = Path(__file__).with_name("prompts") / "hint-v3.txt"

# Configuração de geração herdada do piloto (experiments/ollama-pilot).
DEFAULT_MODEL = "qwen3:4b-instruct-2507-q4_K_M"
DEFAULT_URL = "http://localhost:11434"
DEFAULT_TIMEOUT = 30.0
GENERATION_OPTIONS = {"temperature": 0, "seed": 42, "num_ctx": 4096, "num_predict": 768}

SCHEMA = {
    "type": "object",
    "properties": {
        "issues": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "category": {"type": "string", "enum": list(CATEGORIES)},
                    "explanation": {"type": "string"},
                    "hint": {"type": "string"},
                },
                "required": ["category", "explanation", "hint"],
                "additionalProperties": False,
            },
        }
    },
    "required": ["issues"],
    "additionalProperties": False,
}


class LLMError(Exception):
    """O modelo local não está disponível ou devolveu uma resposta inutilizável."""

    def __init__(self, status: str, detail: str = ""):
        super().__init__(detail or status)
        self.status = status  # "unavailable" | "timeout" | "invalid"


def validate_answer(answer: Any) -> list[dict[str, str]]:
    """Valida a estrutura e as categorias do prompt em uso."""
    if not isinstance(answer, dict) or set(answer) != {"issues"} or not isinstance(answer["issues"], list):
        raise LLMError("invalid", "A resposta deve conter apenas a lista issues.")
    issues = []
    for item in answer["issues"]:
        if not isinstance(item, dict) or set(item) != {"category", "explanation", "hint"}:
            raise LLMError("invalid", "Alerta com campos inválidos.")
        if not all(isinstance(value, str) and value.strip() for value in item.values()):
            raise LLMError("invalid", "Campos do alerta vazios ou não textuais.")
        if item["category"] not in CATEGORIES:
            raise LLMError("invalid", "Categoria desconhecida.")
        issues.append(dict(item))
    return issues


class OllamaClient:
    def __init__(
        self,
        base_url: str | None = None,
        model: str | None = None,
        timeout: float | None = None,
        transport: httpx.AsyncBaseTransport | None = None,
        enabled: bool | None = None,
    ):
        self.base_url = (base_url or os.getenv("OLLAMA_URL", DEFAULT_URL)).rstrip("/")
        self.model = model or os.getenv("OLLAMA_MODEL", DEFAULT_MODEL)
        self.timeout = timeout or float(os.getenv("OLLAMA_TIMEOUT", DEFAULT_TIMEOUT))
        self.enabled = enabled if enabled is not None else os.getenv("LLM_ENABLED", "1") != "0"
        self.transport = transport

    async def review(
        self, source: str, target: str, glossary: dict[str, dict], context: str = ""
    ) -> list[dict[str, str]]:
        if not self.enabled:
            raise LLMError("disabled")
        user_input = {
            "source_language": "en",
            "target_language": "pt-PT",
            "source": source,
            "target": target,
            "context": context,
            "glossary": [
                {"source_term": term, "accepted_targets": [entry["target"], *entry.get("variants", [])]}
                for term, entry in glossary.items()
            ],
        }
        payload = {
            "model": self.model,
            "stream": False,
            "format": SCHEMA,
            "keep_alive": "10m",
            "options": GENERATION_OPTIONS,
            "messages": [
                {"role": "system", "content": PROMPT_PATH.read_text(encoding="utf-8")},
                {"role": "user", "content": json.dumps(user_input, ensure_ascii=False)},
            ],
        }
        try:
            async with httpx.AsyncClient(timeout=self.timeout, transport=self.transport) as client:
                response = await client.post(f"{self.base_url}/api/chat", json=payload)
            response.raise_for_status()
            data = response.json()
            if not isinstance(data, dict):
                raise LLMError("invalid", "A resposta do Ollama deve ser um objeto JSON.")
            if data.get("done_reason") != "stop":
                raise LLMError("invalid", "Resposta não concluída normalmente.")
            return validate_answer(json.loads(data["message"]["content"]))
        except httpx.TimeoutException as error:
            raise LLMError("timeout", str(error)) from error
        except httpx.HTTPError as error:
            raise LLMError("unavailable", str(error)) from error
        except (ValueError, KeyError, TypeError) as error:
            raise LLMError("invalid", str(error)) from error
