"""
Tabelas da base de dados: segmentos e as suas versões, memória de tradução e registos.
"""

from datetime import UTC, datetime
from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from backend.database import Base


def utc_now() -> datetime:
    """Hora UTC sem fuso associado: o mesmo formato que as colunas já guardavam (utcnow está obsoleto)."""
    return datetime.now(UTC).replace(tzinfo=None)


class Segment(Base):
    """Versão atual de cada segmento: tradução, justificação do aluno e data da última edição."""

    __tablename__ = "segments"

    id = Column(String(50), primary_key=True, index=True)
    target = Column(Text, nullable=False, default="")
    justification = Column(Text, nullable=False, default="")
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)


class SegmentVersion(Base):
    """Histórico: cada gravação que altera a tradução ou a justificação acrescenta uma versão."""

    __tablename__ = "segment_versions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    segment_id = Column(String(50), ForeignKey("segments.id"), nullable=False, index=True)
    number = Column(Integer, nullable=False)
    target = Column(Text, nullable=False, default="")
    justification = Column(Text, nullable=False, default="")
    created_at = Column(DateTime, default=utc_now)
    __table_args__ = (UniqueConstraint("segment_id", "number", name="uq_segment_version"),)

class MemoryEntry(Base):
    """Memória de tradução: par original/tradução guardado pelo aluno (nível 1)."""

    __tablename__ = "memory_entries"

    id = Column(Integer, primary_key=True, autoincrement=True)
    source = Column(Text, nullable=False)
    target = Column(Text, nullable=False)
    created_at = Column(DateTime, default=utc_now)
    __table_args__ = (UniqueConstraint("source", "target", name="uq_memory_pair"),)


class Event(Base):
    """Registo de eventos de utilização (indicadores OE4/OP3); sem texto completo."""

    __tablename__ = "events"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String(64), nullable=False, index=True)
    type = Column(String(40), nullable=False)
    segment_id = Column(String(50), nullable=True)
    exercise_id = Column(String(13), nullable=True, index=True)
    payload = Column(Text, nullable=False, default="{}")
    created_at = Column(DateTime, default=utc_now)
