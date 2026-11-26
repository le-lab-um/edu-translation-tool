"""
API em FastAPI para a aplicação de tradução.
Liga os endpoints para guardar e ler segmentos (com histórico de versões e justificação)
na base de dados local e corre as regras de verificação da tradução.
"""

import csv
import io
import json
import time
from typing import Annotated, Any, Dict, Literal

from fastapi import Depends, FastAPI, Path, Query
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field, StrictStr, StringConstraints
from sqlalchemy import or_
from sqlalchemy.orm import Session

from backend.database import Base, engine, get_db, upgrade_schema
from backend.hybrid import merge_issues
from backend.llm import LLMError, OllamaClient
from backend.models import Event, MemoryEntry, Segment, SegmentVersion
from backend.rules import run_all_rules
from backend.translation_memory import find_matches

upgrade_schema(engine)
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Educational Translation Tool API", version="0.4.0")

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


SegmentId = Annotated[str, StringConstraints(min_length=1, max_length=50)]


class SegmentUpdateRequest(BaseModel):
    """Corpo do pedido de gravação; preserva o texto exato."""

    model_config = ConfigDict(extra="forbid")

    target: StrictStr = Field(description="Texto exato da tradução a guardar.")
    justification: Annotated[str, StringConstraints(strict=True, max_length=5000)] | None = Field(
        default=None, description="Justificação do aluno; se omitida, mantém-se a atual."
    )


class SegmentResponse(BaseModel):
    """Resposta com o identificador, o texto e a justificação do segmento."""

    id: str
    target: str
    justification: str = ""


class SegmentVersionResponse(BaseModel):
    number: int
    target: str
    justification: str
    created_at: str | None


class SegmentVersionsResponse(BaseModel):
    id: str
    versions: list[SegmentVersionResponse]


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
def get_segment(segment_id: SegmentId, db: Session = Depends(get_db)) -> SegmentResponse:
    """Recupera o texto guardado de um segmento ou devolve vazio se não existir."""
    segment = db.query(Segment).filter(Segment.id == segment_id).first()
    if not segment:
        return SegmentResponse(id=segment_id, target="")
    return SegmentResponse(id=segment.id, target=segment.target, justification=segment.justification)


@app.put("/api/segments/{segment_id}", response_model=SegmentResponse)
def save_segment(
    segment_id: SegmentId,
    request: SegmentUpdateRequest,
    db: Session = Depends(get_db),
) -> SegmentResponse:
    """Guarda a versão atual e acrescenta-a ao histórico quando o texto ou a justificação mudam."""
    segment = db.query(Segment).filter(Segment.id == segment_id).first()
    justification = request.justification
    if not segment:
        segment = Segment(id=segment_id, target=request.target, justification=justification or "")
        db.add(segment)
        changed = True
    else:
        if justification is None:
            justification = segment.justification
        changed = segment.target != request.target or segment.justification != justification
        segment.target = request.target
        segment.justification = justification

    if changed:
        db.flush()
        last = (
            db.query(SegmentVersion.number)
            .filter(SegmentVersion.segment_id == segment_id)
            .order_by(SegmentVersion.number.desc())
            .first()
        )
        db.add(SegmentVersion(
            segment_id=segment_id, number=(last[0] if last else 0) + 1,
            target=segment.target, justification=segment.justification,
        ))

    db.commit()
    db.refresh(segment)
    return SegmentResponse(id=segment.id, target=segment.target, justification=segment.justification)


@app.get("/api/segments/{segment_id}/versions", response_model=SegmentVersionsResponse)
def segment_versions(segment_id: SegmentId, db: Session = Depends(get_db)) -> SegmentVersionsResponse:
    """Histórico das versões guardadas de um segmento, da mais antiga para a mais recente."""
    rows = (
        db.query(SegmentVersion)
        .filter(SegmentVersion.segment_id == segment_id)
        .order_by(SegmentVersion.number)
        .all()
    )
    return SegmentVersionsResponse(
        id=segment_id,
        versions=[
            SegmentVersionResponse(
                number=v.number, target=v.target, justification=v.justification,
                created_at=v.created_at.isoformat() if v.created_at else None,
            )
            for v in rows
        ],
    )


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


class MemoryRemoveRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    source: StrictStr
    target: StrictStr


@app.post("/api/memory/remove")
def remove_memory(request: MemoryRemoveRequest, db: Session = Depends(get_db)) -> dict[str, bool]:
    """Remove um par da memória (por exemplo, uma tradução de teste ou errada); não toca nos segmentos."""
    entry = db.query(MemoryEntry).filter_by(source=request.source, target=request.target).first()
    if entry:
        db.delete(entry)
        db.commit()
    return {"removed": entry is not None}


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
    "hint_shown", "memory_suggestion_used", "version_restored",
)


class EventRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    session_id: Annotated[str, StringConstraints(strict=True, min_length=1, max_length=64)]
    type: Literal[EVENT_TYPES]  # type: ignore[valid-type]
    segment_id: Annotated[str, StringConstraints(strict=True, max_length=50)] | None = None
    exercise_id: Annotated[str, StringConstraints(strict=True, pattern=r"^e[0-9a-f]{12}$")] | None = None
    payload: Dict[str, Any] = Field(default_factory=dict)


@app.post("/api/events", status_code=201)
def log_event(request: EventRequest, db: Session = Depends(get_db)) -> dict[str, int]:
    payload = json.dumps(request.payload, ensure_ascii=False)
    if len(payload) > 2000:
        payload = json.dumps({"truncated": True})
    event = Event(
        session_id=request.session_id, type=request.type,
        segment_id=request.segment_id, exercise_id=request.exercise_id, payload=payload,
    )
    db.add(event)
    db.commit()
    return {"id": event.id}


def _event_rows(db: Session) -> list[dict[str, Any]]:
    return [
        {
            "id": e.id, "session_id": e.session_id, "type": e.type,
            "segment_id": e.segment_id, "exercise_id": e.exercise_id, "payload": json.loads(e.payload),
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
        buffer, fieldnames=["id", "session_id", "type", "segment_id", "exercise_id", "payload", "created_at"]
    )
    writer.writeheader()
    for row in rows:
        writer.writerow({**row, "payload": json.dumps(row["payload"], ensure_ascii=False)})
    return Response(
        buffer.getvalue(), media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": 'attachment; filename="events.csv"'},
    )


ExerciseId = Annotated[str, Path(pattern=r"^e[0-9a-f]{12}$")]


class TimelineEvent(BaseModel):
    type: str
    segment_id: str | None
    payload: Dict[str, Any]
    created_at: str | None


class TimelineResponse(BaseModel):
    exercise_id: str
    events: list[TimelineEvent]


@app.get("/api/exercises/{exercise_id}/events", response_model=TimelineResponse)
def exercise_timeline(exercise_id: ExerciseId, db: Session = Depends(get_db)) -> TimelineResponse:
    """Percurso de um exercício: os eventos dele, por ordem cronológica.

    Inclui os eventos marcados com o identificador do exercício (como o início) e, para registos
    anteriores a essa coluna, os dos segmentos cujo identificador começa por ele. O identificador
    é aleatório e fica no browser do aluno; por isso cada aluno vê apenas o percurso dos seus exercícios.
    """
    rows = (
        db.query(Event)
        .filter(or_(Event.exercise_id == exercise_id, Event.segment_id.like(f"{exercise_id}-%")))
        .order_by(Event.id)
        .all()
    )
    return TimelineResponse(
        exercise_id=exercise_id,
        events=[
            TimelineEvent(
                type=e.type, segment_id=e.segment_id, payload=json.loads(e.payload),
                created_at=e.created_at.isoformat() if e.created_at else None,
            )
            for e in rows
        ],
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
