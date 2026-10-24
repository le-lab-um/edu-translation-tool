"""API local para executar as verificações de tradução."""

from typing import Literal

from fastapi import FastAPI
from pydantic import BaseModel, ConfigDict, Field, StrictStr

from backend.rules import check_empty_translation


class CheckRequest(BaseModel):
    """A tradução é obrigatória, mas pode estar vazia ou conter só espaços."""

    model_config = ConfigDict(extra="forbid")

    target: StrictStr = Field(description="Tradução a verificar, sem normalização.")


class Issue(BaseModel):
    """Formato do alerta, partilhado com a experiência local."""

    category: Literal["empty_translation"]
    explanation: str
    hint: str


class CheckResponse(BaseModel):
    issues: list[Issue]


app = FastAPI(title="Educational Translation Tool API", version="0.1.0")


@app.post("/api/check", response_model=CheckResponse)
def check_translation(request: CheckRequest) -> CheckResponse:
    """Verifica apenas se a tradução está vazia; não guarda nem envia o texto ao LLM."""
    issues = check_empty_translation(request.target)
    return CheckResponse(issues=[Issue(**issue) for issue in issues])
