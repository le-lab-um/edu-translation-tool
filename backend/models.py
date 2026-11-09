"""
Tabela da base de dados para guardar os segmentos.
Guarda o ID do segmento, o texto da tradução e a data da última edição.
"""

from datetime import datetime
from sqlalchemy import Column, DateTime, Integer, String, Text, UniqueConstraint
from backend.database import Base


class Segment(Base):
    __tablename__ = "segments"

    id = Column(String(50), primary_key=True, index=True)
    target = Column(Text, nullable=False, default="")
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class MemoryEntry(Base):
    """Memória de tradução: par original/tradução guardado pelo aluno (nível 1)."""

    __tablename__ = "memory_entries"

    id = Column(Integer, primary_key=True, autoincrement=True)
    source = Column(Text, nullable=False)
    target = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    __table_args__ = (UniqueConstraint("source", "target", name="uq_memory_pair"),)


class Event(Base):
    """Registo de eventos de utilização (indicadores OE4/OP3); sem texto completo."""

    __tablename__ = "events"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String(64), nullable=False, index=True)
    type = Column(String(40), nullable=False)
    segment_id = Column(String(50), nullable=True)
    payload = Column(Text, nullable=False, default="{}")
    created_at = Column(DateTime, default=datetime.utcnow)
