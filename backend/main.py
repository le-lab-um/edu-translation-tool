"""
API em FastAPI para a aplicação de tradução.
Liga os endpoints para guardar e ler segmentos da base de dados local
e corre as regras de verificação de tradução (vazio, números e glossário).
"""

from typing import Any, Dict, Literal

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field, StrictStr
from sqlalchemy.orm import Session

from backend.database import Base, engine, get_db
from backend.models import Segment
from backend.rules import run_all_rules

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Educational Translation Tool API", version="0.2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class CheckRequest(BaseModel):
    """Tradução obrigatória; original e glossário opcionais para suporte de QA alargado."""

    model_config = ConfigDict(extra="forbid")

    target: StrictStr = Field(description="Tradução a verificar, sem normalização.")
    source: str = Field(default="", description="Texto do segmento original em inglês.")
    glossary: Dict[str, Any] = Field(
        default_factory=dict, description="Glossário de termos prescritos para o exercício."
    )


class Issue(BaseModel):
    """Formato do alerta partilhado entre motor determinístico e LLM."""

    category: Literal["empty_translation", "numeric_mismatch", "terminology"]
    explanation: str
    hint: str


class CheckResponse(BaseModel):
    issues: list[Issue]


class SegmentUpdateRequest(BaseModel):
    """Corpo do pedido de gravação; preserva o texto exato."""

    model_config = ConfigDict(extra="forbid")

    target: StrictStr = Field(description="Texto exato da tradução a guardar.")


class SegmentResponse(BaseModel):
    """Resposta com o identificador e o texto do segmento."""

    id: str
    target: str


@app.post("/api/check", response_model=CheckResponse)
def check_translation(request: CheckRequest) -> CheckResponse:
    """Executa as regras determinísticas (vazio, números e terminologia)."""
    issues = run_all_rules(
        source=request.source,
        target=request.target,
        glossary=request.glossary,
    )
    return CheckResponse(issues=[Issue(**issue) for issue in issues])


@app.get("/api/segments/{segment_id}", response_model=SegmentResponse)
def get_segment(segment_id: str, db: Session = Depends(get_db)) -> SegmentResponse:
    """Recupera o texto guardado de um segmento ou devolve vazio se não existir."""
    segment = db.query(Segment).filter(Segment.id == segment_id).first()
    if not segment:
        return SegmentResponse(id=segment_id, target="")
    return SegmentResponse(id=segment.id, target=segment.target)


@app.put("/api/segments/{segment_id}", response_model=SegmentResponse)
def save_segment(
    segment_id: str,
    request: SegmentUpdateRequest,
    db: Session = Depends(get_db),
) -> SegmentResponse:
    """Guarda ou atualiza o texto de um segmento existente."""
    segment = db.query(Segment).filter(Segment.id == segment_id).first()
    if not segment:
        segment = Segment(id=segment_id, target=request.target)
        db.add(segment)
    else:
        segment.target = request.target

    db.commit()
    db.refresh(segment)
    return SegmentResponse(id=segment.id, target=segment.target)