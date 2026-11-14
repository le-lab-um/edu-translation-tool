"""
API em FastAPI para a aplicação de tradução.
Liga os endpoints para guardar e ler segmentos da base de dados local
e corre as regras de verificação da tradução.
"""

import csv
import io
import json
import time
from typing import Annotated, Any, Dict, Literal

from fastapi import Depends, FastAPI, Query
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field, StrictStr, StringConstraints
from sqlalchemy.orm import Session

from backend.database import Base, engine, get_db
from backend.hybrid import merge_issues
from backend.llm import LLMError, OllamaClient
from backend.models import Event, MemoryEntry, Segment
from backend.rules import run_all_rules
from backend.translation_memory import find_matches

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Educational Translation Tool API", version="0.3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


GlossaryText = Annotated[str, StringConstraints(strict=True, strip_whitespace=True, min_length=1)]


class GlossaryEntry(BaseModel):
    """Contrato único, usado pelo formulário e pelas regras; rejeita valores inválidos."""

    model_config = ConfigDict(extra="forbid")
    target: GlossaryText
    variants: list[GlossaryText] = Field(default_factory=list)


class CheckRequest(BaseModel):
    """Tradução obrigatória; original e glossário opcionais para suporte de QA alargado."""

    model_config = ConfigDict(extra="forbid")

    target: StrictStr = Field(description="Tradução a verificar, sem normalização.")
    source: StrictStr = Field(default="", description="Texto do segmento original em inglês.")
    glossary: Dict[GlossaryText, GlossaryEntry] = Field(
        default_factory=dict, description="Glossário de termos prescritos para o exercício."
    )


RuleCategory = Literal[
    "empty_translation", "numeric_mismatch", "terminology", "placeholder_mismatch", "inline_tag_mismatch"
]


class IssueText(BaseModel):
    explanation: str
    hint: str


class Issue(IssueText):
    category: RuleCategory


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
    """Executa as regras determinísticas."""
    issues = run_all_rules(
        source=request.source,
        target=request.target,
        glossary={term: entry.model_dump() for term, entry in request.glossary.items()},
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


# ---------------------------------------------------------------------------
# Nível 3 (inicial): pistas híbridas = regras + LLM local
# ---------------------------------------------------------------------------

_llm_client = OllamaClient()


def get_llm_client() -> OllamaClient:
    """Dependência substituível nos testes por um cliente com servidor simulado."""
    return _llm_client


class HintRequest(CheckRequest):
    context: StrictStr = Field(default="", description="Contexto opcional do exercício.")


class HintIssue(IssueText):
    category: RuleCategory | Literal["meaning_context"]
    source: Literal["rules", "llm"]


class HintResponse(BaseModel):
    issues: list[HintIssue]
    llm_status: Literal["ok", "disabled", "unavailable", "timeout", "invalid", "skipped"]
    sanitized: int = 0
    elapsed_ms: int = 0


@app.post("/api/hint", response_model=HintResponse)
async def hint(request: HintRequest, llm: OllamaClient = Depends(get_llm_client)) -> HintResponse:
    """Regras determinísticas + sugestões do LLM local. Se o LLM falhar, devolve só as regras."""
    started = time.perf_counter()
    glossary = {term: entry.model_dump() for term, entry in request.glossary.items()}
    rule_issues = run_all_rules(source=request.source, target=request.target, glossary=glossary)
    llm_issues: list[dict] = []
    status = "ok"
    if any(issue["category"] == "empty_translation" for issue in rule_issues):
        status = "skipped"  # não vale a pena consultar o modelo sem tradução
    else:
        try:
            llm_issues = await llm.review(request.source, request.target, glossary, request.context)
        except LLMError as error:
            status = error.status
    merged, sanitized = merge_issues(rule_issues, llm_issues, request.source, glossary)
    return HintResponse(
        issues=[HintIssue(**issue) for issue in merged],
        llm_status=status,
        sanitized=sanitized,
        elapsed_ms=int((time.perf_counter() - started) * 1000),
    )


# ---------------------------------------------------------------------------
# Nível 1: memória de tradução
# ---------------------------------------------------------------------------


class MemorySaveRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    source: Annotated[str, StringConstraints(strict=True, strip_whitespace=True, min_length=1, max_length=5000)]
    target: Annotated[str, StringConstraints(strict=True, strip_whitespace=True, min_length=1, max_length=5000)]


class MemorySearchRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    source: StrictStr
    threshold: int = Field(default=70, ge=0, le=100)
    limit: int = Field(default=3, ge=1, le=10)


class MemoryMatch(BaseModel):
    source: str
    target: str
    score: int


class MemorySearchResponse(BaseModel):
    matches: list[MemoryMatch]


@app.post("/api/memory", status_code=201)
def save_memory(request: MemorySaveRequest, db: Session = Depends(get_db)) -> dict[str, bool]:
    """Guarda um par original/tradução na memória (sem duplicar pares idênticos)."""
    exists = db.query(MemoryEntry).filter_by(source=request.source, target=request.target).first()
    if not exists:
        db.add(MemoryEntry(source=request.source, target=request.target))
        db.commit()
    return {"created": exists is None}


@app.post("/api/memory/search", response_model=MemorySearchResponse)
def search_memory(request: MemorySearchRequest, db: Session = Depends(get_db)) -> MemorySearchResponse:
    """Procura traduções anteriores de segmentos iguais ou parecidos (correspondência difusa)."""
    entries = db.query(MemoryEntry).all()
    matches = find_matches(
        request.source, [(e.source, e.target) for e in entries], request.threshold, request.limit
    )
    return MemorySearchResponse(matches=[MemoryMatch(**m) for m in matches])


# ---------------------------------------------------------------------------
# Registos de utilização e exportação (OE4/OP3)
# ---------------------------------------------------------------------------

EVENT_TYPES = (
    "session_started", "segment_saved", "check_run", "hint_requested",
    "hint_shown", "memory_suggestion_used",
)


class EventRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    session_id: Annotated[str, StringConstraints(strict=True, min_length=1, max_length=64)]
    type: Literal[EVENT_TYPES]  # type: ignore[valid-type]
    segment_id: Annotated[str, StringConstraints(strict=True, max_length=50)] | None = None
    payload: Dict[str, Any] = Field(default_factory=dict)


@app.post("/api/events", status_code=201)
def log_event(request: EventRequest, db: Session = Depends(get_db)) -> dict[str, int]:
    payload = json.dumps(request.payload, ensure_ascii=False)
    if len(payload) > 2000:
        payload = json.dumps({"truncated": True})
    event = Event(
        session_id=request.session_id, type=request.type,
        segment_id=request.segment_id, payload=payload,
    )
    db.add(event)
    db.commit()
    return {"id": event.id}


def _event_rows(db: Session) -> list[dict[str, Any]]:
    return [
        {
            "id": e.id, "session_id": e.session_id, "type": e.type,
            "segment_id": e.segment_id, "payload": json.loads(e.payload),
            "created_at": e.created_at.isoformat() if e.created_at else None,
        }
        for e in db.query(Event).order_by(Event.id).all()
    ]


@app.get("/api/events/export")
def export_events(format: Literal["json", "csv"] = Query("json"), db: Session = Depends(get_db)) -> Response:
    """Exporta todos os registos em JSON ou CSV, para análise fora da aplicação."""
    rows = _event_rows(db)
    if format == "json":
        return Response(
            json.dumps(rows, ensure_ascii=False, indent=2), media_type="application/json",
            headers={"Content-Disposition": 'attachment; filename="events.json"'},
        )
    buffer = io.StringIO()
    writer = csv.DictWriter(
        buffer, fieldnames=["id", "session_id", "type", "segment_id", "payload", "created_at"]
    )
    writer.writeheader()
    for row in rows:
        writer.writerow({**row, "payload": json.dumps(row["payload"], ensure_ascii=False)})
    return Response(
        buffer.getvalue(), media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": 'attachment; filename="events.csv"'},
    )


@app.get("/api/events/summary")
def events_summary(db: Session = Depends(get_db)) -> dict[str, Any]:
    """Resumo simples: eventos por tipo e taxa de pistas por verificação."""
    rows = _event_rows(db)
    counts: dict[str, int] = {}
    for row in rows:
        counts[row["type"]] = counts.get(row["type"], 0) + 1
    return {
        "total": len(rows),
        "sessions": len({r["session_id"] for r in rows}),
        "by_type": counts,
    }
