"""
Configuração da ligação ao SQLite com SQLAlchemy.
Cria o ficheiro app.db na pasta data e fornece a sessão para os endpoints.
"""

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Cria o ficheiro app.db na pasta data/ ou localmente
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data")
os.makedirs(DATA_DIR, exist_ok=True)
DB_PATH = os.path.join(DATA_DIR, "app.db")

DATABASE_URL = f"sqlite:///{DB_PATH}"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    """Dependency para obter a sessão da BD por pedido."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()