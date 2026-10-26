# Educational Translation Tool

Ferramenta educativa aberta concebida para apoiar a prática reflexiva da tradução (inglês → português europeu), combinando edição segmentada, verificações de qualidade assistidas por regras determinísticas e geração de pistas pedagógicas via modelo de linguagem local.

Este projeto culmina num protótipo funcional e num artigo científico para submissão académica até 30 de novembro de 2026.

---

## Estado Atual do Projeto

O sistema concluiu o percurso funcional do **Nível 1 (CAT Básico com Persistência)** e as três regras determinísticas centrais do **Nível 2 (QA Determinístico)**:

1. **Editor Segmentado React (Frontend):**
   - Apresentação do segmento original em inglês (`dev-001`), contexto pedagógico, glossário ativo e campo de edição em português europeu.
   - **Persistência Integrada:** Carregamento automático da tradução guardada ao iniciar e botão dedicado **Guardar** com feedback visual (`A guardar...`, `Tradução guardada.`, `Falha ao guardar.`).
   - **Prevenção de Condições de Corrida:** Controlo por identificadores de versão (`requestVersion` e `saveVersion`), assegurando que respostas assíncronas antigas da rede nunca sobrepõem edições mais recentes.
   - **Resiliência de Rede:** Cliente HTTP com temporizador estrito de 10 segundos (`CheckTimeoutError`) suportado por `AbortController`.
   - **Feedback de QA Alargado:** Exibição estruturada de alertas por categoria com respetiva pista formativa (*scaffolding*).

2. **Motor de Regras e API FastAPI (Backend):**
   - **Persistência Relacional com SQLite e SQLAlchemy:**
     - `GET /api/segments/{id}`: Recupera a tradução guardada ou devolve texto vazio se ainda não iniciada.
     - `PUT /api/segments/{id}`: Cria ou atualiza o registo de forma idempotente, preservando o texto exato (espaços, quebras de linha e Unicode).
   - **Motor de Regras Determinístico (`backend/rules.py`):**
     - `empty_translation`: Deteta ausência de conteúdo após normalização de espaços em branco.
     - `numeric_mismatch`: Extrai valores numéricos do original e tradução através de expressões regulares, normalizando separadores de milhar e decimais para distinguir o valor numérico do formato linguístico.
     - `terminology`: Valida a presença de equivalentes prescritos do glossário através de fronteiras de palavras (`\b`), suportando correspondência insensível a maiúsculas/minúsculas e variantes morfológicas/verbais.
   - **Endpoint de Verificação (`POST /api/check`):** Recebe `{ target, source, glossary }` e orquestra a execução das regras determinísticas por ordem de prioridade.

3. **Verificação e Testes:**
   - **20 testes de backend** (`unittest`): Cobertura exaustiva de texto vazio, equivalências numéricas entre convenções EN/PT, termos de glossário com variantes, orquestração de regras múltiplas, esquemas Pydantic e persistência isolada com base de dados SQLite em memória (`:memory:`).
   - **6 testes de frontend** (`Vitest`): Validação de timeouts, leitura do corpo JSON com payload alargado, tratamento de erros de rede e nova tentativa.

---

## Arquitetura da Solução

- **Frontend:** React 19, TypeScript, Vite.
- **Backend:** Python 3.9+ / 3.11, FastAPI, Pydantic v2.
- **Persistência:** SQLite local via SQLAlchemy 2.0 (armazenado em `data/app.db`, excluído do Git).
- **QA & Linguística:** Motor de regras determinísticas em Python puro e suite exploratória com LLM local (`qwen3:4b-instruct-2507-q4_K_M` via Ollama).

---

## Como Executar Localmente

São necessários dois terminais em paralelo (um para a API e outro para o editor Vite).

### 1. Terminal do Backend (API)
A partir da raiz do repositório:

```bash
# Criar e ativar o ambiente virtual (se ainda não existir)
python3 -m venv .venv

# Instalar dependências
.venv/bin/python -m pip install -r backend/requirements.txt

# Iniciar servidor Uvicorn
.venv/bin/python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
```

A API fica disponível em http://127.0.0.1:8000 (documentação Swagger interativa em /docs).

### 2. Terminal do Frontend (Editor React)
A partir da raiz do repositório:

```bash
cd frontend

# Instalar dependências fixadas
npm ci

# Iniciar servidor Vite
npm run dev
```

Abre a aplicação no navegador através do endereço indicado (normalmente http://localhost:5173).

---

## Execução da Suite de Testes

### Testes do Backend

Na raiz do repositório:

```bash 
.venv/bin/python -m unittest discover -s tests -v 
```

### Testes e Compilação do Frontend

Dentro da pasta frontend/:

```bash
npm test
npm run build
```

## Próximos Passos

### Integração do Adaptador LLM:

- Ligação do Ollama local ao backend para geração de explicações pedagógicas dinâmicas e pistas a pedido (scaffolding).
- Implementação da estratégia de deduplicação e combinação de alertas entre o motor determinístico e o modelo de linguagem.

### Avaliação Experimental e Artigo:

- Fecho das anotações em data/development.json e preparação do conjunto de teste final.

- Execução do protocolo experimental comparativo (Regras vs. LLM vs. Híbrido) para reporte de Precisão, Recall e F1 no artigo científico (paper/main.typ).

---