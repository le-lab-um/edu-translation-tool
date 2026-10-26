"""
Tabela da base de dados para guardar os segmentos.
Guarda o ID do segmento, o texto da tradução e a data da última edição.
"""

from datetime import datetime
from sqlalchemy import Column, DateTime, String, Text
from backend.database import Base


class Segment(Base):
    __tablename__ = "segments"

    id = Column(String(50), primary_key=True, index=True)
    target = Column(Text, nullable=False, default="")
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)