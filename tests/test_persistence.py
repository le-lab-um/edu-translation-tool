"""
Testes à persistência de dados.
Usa uma base de dados em memória para testar se grava e lê segmentos sem estragar a base real.
"""

import unittest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from backend.database import Base, get_db
from backend.main import app

# Base de dados SQLite em memória para testes
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


class TestPersistence(unittest.TestCase):
    def setUp(self):
        Base.metadata.create_all(bind=engine)
        self.client = TestClient(app)

    def tearDown(self):
        Base.metadata.drop_all(bind=engine)

    def test_get_nonexistent_segment_returns_empty(self):
        res = self.client.get("/api/segments/dev-001")
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json(), {"id": "dev-001", "target": ""})

    def test_save_and_retrieve_segment(self):
        text = "Tradução com acentos, tabs \t e quebras \n."
        # Guardar
        res = self.client.put("/api/segments/dev-001", json={"target": text})
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json()["target"], text)

        # Recuperar
        res_get = self.client.get("/api/segments/dev-001")
        self.assertEqual(res_get.status_code, 200)
        self.assertEqual(res_get.json()["target"], text)

    def test_update_segment_does_not_duplicate(self):
        self.client.put("/api/segments/dev-001", json={"target": "Primeira versão"})
        self.client.put("/api/segments/dev-001", json={"target": "Segunda versão"})

        res = self.client.get("/api/segments/dev-001")
        self.assertEqual(res.json()["target"], "Segunda versão")