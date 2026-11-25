"""
Testes à persistência de dados.
Usa uma base de dados em memória para testar se grava e lê segmentos, o histórico de versões
e a justificação do aluno, sem estragar a base real.
"""

import unittest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from backend.database import Base, get_db, upgrade_schema
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


class TestPersistence(unittest.TestCase):
    def setUp(self):
        app.dependency_overrides[get_db] = override_get_db
        Base.metadata.create_all(bind=engine)
        self.client = TestClient(app)

    def tearDown(self):
        self.client.close()
        app.dependency_overrides.pop(get_db, None)
        Base.metadata.drop_all(bind=engine)

    def test_get_nonexistent_segment_returns_empty(self):
        res = self.client.get("/api/segments/dev-001")
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json(), {"id": "dev-001", "target": "", "justification": ""})

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

    def versions(self, segment_id="dev-001"):
        res = self.client.get(f"/api/segments/{segment_id}/versions")
        self.assertEqual(res.status_code, 200)
        return res.json()["versions"]

    def test_each_change_adds_a_version_in_order(self):
        self.client.put("/api/segments/dev-001", json={"target": "Primeira versão"})
        self.client.put("/api/segments/dev-001", json={"target": "Segunda versão"})
        versions = self.versions()
        self.assertEqual([(v["number"], v["target"]) for v in versions], [(1, "Primeira versão"), (2, "Segunda versão")])
        self.assertTrue(all(v["created_at"] for v in versions))

    def test_saving_the_same_text_does_not_add_a_version(self):
        self.client.put("/api/segments/dev-001", json={"target": "Igual"})
        self.client.put("/api/segments/dev-001", json={"target": "Igual"})
        self.assertEqual(len(self.versions()), 1)

    def test_versions_are_kept_per_segment(self):
        self.client.put("/api/segments/ex-a-1", json={"target": "Um"})
        self.client.put("/api/segments/ex-b-1", json={"target": "Outro"})
        self.assertEqual([v["target"] for v in self.versions("ex-a-1")], ["Um"])
        self.assertEqual(self.versions("sem-registo"), [])

    def test_justification_is_saved_and_versioned(self):
        res = self.client.put("/api/segments/dev-001", json={"target": "Texto", "justification": "Mantive o registo formal."})
        self.assertEqual(res.json()["justification"], "Mantive o registo formal.")
        self.client.put("/api/segments/dev-001", json={"target": "Texto", "justification": "Registo formal, como no original."})
        self.assertEqual(self.client.get("/api/segments/dev-001").json()["justification"], "Registo formal, como no original.")
        self.assertEqual([v["justification"] for v in self.versions()],
                         ["Mantive o registo formal.", "Registo formal, como no original."])

    def test_omitted_justification_keeps_the_current_one(self):
        self.client.put("/api/segments/dev-001", json={"target": "Texto", "justification": "Porque sim."})
        res = self.client.put("/api/segments/dev-001", json={"target": "Texto novo"})
        self.assertEqual(res.json()["justification"], "Porque sim.")
        self.assertEqual(self.versions()[-1]["justification"], "Porque sim.")

    def test_rejects_invalid_justification_and_long_ids(self):
        self.assertEqual(self.client.put("/api/segments/dev-001", json={"target": "T", "justification": 3}).status_code, 422)
        self.assertEqual(self.client.put("/api/segments/" + "x" * 51, json={"target": "T"}).status_code, 422)


class TestSchemaUpgrade(unittest.TestCase):
    def test_adds_justification_column_to_an_old_database(self):
        old = create_engine("sqlite:///:memory:", poolclass=StaticPool)
        with old.begin() as connection:
            connection.execute(text("CREATE TABLE segments (id VARCHAR(50) PRIMARY KEY, target TEXT NOT NULL, updated_at DATETIME)"))
            connection.execute(text("INSERT INTO segments (id, target) VALUES ('custom-1', 'Antiga')"))
        upgrade_schema(old)
        upgrade_schema(old)  # repetir não falha
        self.assertIn("justification", {c["name"] for c in inspect(old).get_columns("segments")})
        with old.connect() as connection:
            row = connection.execute(text("SELECT target, justification FROM segments")).one()
        self.assertEqual(tuple(row), ("Antiga", ""))
