# Educational Translation Tool

An educational web application for practicing translation from English into European Portuguese (EN → PT-PT). Students translate segmented text, use a translation memory and a glossary, run rule-based checks and request hints from a local language model. The hints aim to guide revision without giving away the solution.

A project by Diogo Pinto (PG61515) and Mariana Pinto (PG61534), MSc in Informatics Engineering, University of Minho. The paper describing the tool and its evaluation is in [`paper/main.typ`](paper/main.typ). The project page is in [`docs/`](docs/index.html) and is published at <https://le-lab-um.github.io/edu-translation-tool/>.

## Features

The interface is in Portuguese; button names are given below as they appear in the application.

- **Segmented editor:** type or paste text, upload a `.txt` file of up to 200 KiB or pick an example. Each non-empty line is a segment, up to 200 per exercise. The context is shown to the student, and the glossary takes one entry per line (`folder = pasta | diretório`).
- **Persistence:** the translation is saved in SQLite when the student clicks **Guardar** (Save), moves to another segment or returns to the exercise setup, and it is restored when the segment is reopened. A failed save keeps the text on screen and blocks navigation.
- **Translation memory:** each confirmed translation is stored as a source–target pair. When a segment is opened, similar segments are suggested (RapidFuzz, threshold 70%) with a **Usar** (Use) button.
- **Five deterministic rules** (**Verificar**, Check): empty translation, changed or missing numbers, missing glossary terms, placeholders (`{name}`) and formatting tags (`<b>`, `<i>`, …).
- **Hybrid hints** (**Pedir pista**, Ask for a hint): the rules are combined with a local Qwen model (`qwen3:4b-instruct-2507-q4_K_M`, served by Ollama), which adds a **meaning and context** category. Each issue shows its origin (rule or local model). Rules take priority when categories overlap, and a heuristic filter generalizes hints that seem to reveal the solution. If Ollama fails, the application returns the rule issues only.
- **Usage logs:** the interface logs usage events (start, save, check, hints, memory) without the translation text, exportable as JSON and CSV.

## Evaluation results

We evaluated the tool on 40 test cases (21 sources) that were not used during development, with two prompts: v3, the application's original prompt, and v4, revised after a diagnostic phase. Based on these results, the application now uses v4.

| Method (main scope, 18 cases) | TP/FP/FN v3 | F1 v3 | TP/FP/FN v4 | F1 v4 |
| --- | --- | --- | --- | --- |
| Rules | 10/0/0 | 100% | 10/0/0 | 100% |
| LLM-only | 6/2/4 | 66.7% | 6/1/4 | 70.6% |
| Hybrid | 10/2/0 | 90.9% | 10/1/0 | 95.2% |

- **Detection (RQ1):** the rules detect every problem within their scope. The model alone misses all glossary violations but complements the rules on units and added numbers. The hybrid approach keeps the recall of the rules.
- **Hint quality (RQ2):** with v3, 15 of the 20 hints returned by the model disclosed part or all of the correction. With v4, only 1 of 19 did, with the same correctness and greater clarity. None of the hints shown to the student with v4 disclosed the solution.

The full results and discussion are in Section 5 of the paper.

## Repository structure

| Path | Contents |
| --- | --- |
| `frontend/` | React 19 + TypeScript + Vite interface: `src/App.tsx` (editor), `src/exercise.ts` (segmentation and glossary), `src/api.ts` (HTTP client) and Vitest tests. |
| `backend/` | FastAPI API: `main.py` (endpoints), `rules.py` (rules), `llm.py` (Ollama adapter), `hybrid.py` (merging and filter), `translation_memory.py`, `database.py` and `models.py` (SQLite). |
| `backend/prompts/` | `hint-v4.txt` (the application's prompt, revised after the evaluation) and `hint-v3.txt` (the original prompt, kept to reproduce the evaluation). |
| `tests/` | Backend tests: rules, API, persistence, memory and logging, merging and the evaluation metrics. |
| `data/development.json` | Ten development examples used in the pilot. |
| `experiments/ollama-pilot/` | 23 October pilot with prompts v1 and v2 (script, prompts, reports and notes). |
| `experiments/evaluation/` | Case sets, scripts, reports and annotation sheets of the evaluation (see below). |
| `paper/` | Typst paper and figures. |
| `docs/` | Static project page (GitHub Pages). |

## Running locally

Requirements: Python 3.11 or later, Node 20.19+ (or 22.12+, 24+) and, for the model hints, [Ollama](https://ollama.com) with the Qwen model:

```bash
ollama pull qwen3:4b-instruct-2507-q4_K_M
```

Backend, from the repository root:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r backend/requirements.txt
.venv/bin/python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
```

Frontend, in another terminal:

```bash
cd frontend
npm ci
npm run dev
```

Open the address shown by Vite (usually `http://localhost:5173`). The API documentation is at `http://127.0.0.1:8000/docs`, and the database is stored in `data/app.db`, outside Git. Without Ollama, **Pedir pista** returns the rule issues only.

Model environment variables: `OLLAMA_URL` (default `http://localhost:11434`), `OLLAMA_MODEL`, `OLLAMA_TIMEOUT` (30 s) and `LLM_ENABLED=0` to disable the model.

## Tests

```bash
.venv/bin/python -m unittest discover -s tests
```

```bash
cd frontend && npm test && npm run build
```

There are 79 backend tests and 26 frontend tests. The Ollama integration is tested against a simulated server (`httpx.MockTransport`), so the model is not required.

## API

| Endpoint | Purpose |
| --- | --- |
| `POST /api/check` | Runs the rules on `source`, `target` and `glossary`. Returns `issues` with `category`, `explanation` and `hint`. |
| `POST /api/hint` | Like `/api/check`, plus `context`. Merges rule and model issues and also returns `source` for each issue, `llm_status`, `sanitized` and `elapsed_ms`. |
| `GET` · `PUT /api/segments/{id}` | Retrieve and save the translation of a segment. |
| `POST /api/memory` · `POST /api/memory/search` | Store a pair and search for similar segments. |
| `POST /api/events` · `GET /api/events/export` · `GET /api/events/summary` | Log events, export them (JSON or CSV) and summarize them. |

The glossary uses the format `{"folder": {"target": "pasta", "variants": ["diretório"]}}`.

Scope of the rules:
- **Numbers:** compares source values using EN and PT-PT conventions (`1,000.50` = `1 000,50`). It does not interpret units, numbers written in words, times or ranges, and it does not flag numbers that appear only in the translation.
- **Glossary:** looks for whole terms, ignoring case.
- **Placeholders and tags:** compare names and counts, without checking position or nesting.

The absence of issues does not certify the quality of a translation.

## Evaluation

All commands run from the repository root, with Ollama running. New reports go to `output/`, which is excluded from Git.

### Case sets

| File | Cases | Use |
| --- | --- | --- |
| `data/development.json` | 10 | Pilot with prompts v1 and v2 (development). |
| `experiments/evaluation/calibration.json` | 8 | Calibration of the annotation grid (development). |
| `experiments/evaluation/diagnostico.json` | 20 | Diagnosis of v3 and refinement of v4, meaning and context only (development). |
| `experiments/evaluation/test.json` | 40 | Final test: 18 cases in the main RQ1 scope, 12 meaning and context cases and 10 robustness cases. Reference reviewed by the authors. |

Each case has an `input` (source, translation, context and glossary), `expected_categories` (empty if the translation is acceptable), `analysis_scope` and `annotation_note`. Only the `input` is passed to the methods.

### Steps

1. **Check that no test source appears in other files or in the prompts:**

   ```bash
   .venv/bin/python -m experiments.evaluation.check_overlap
   ```

2. **Collect the responses** with v3 and with v4, one after the other, on the same machine:

   ```bash
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --prompt backend/prompts/hint-v3.txt --output output/teste-v3.json
   .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --prompt backend/prompts/hint-v4.txt --output output/teste-v4.json
   ```

   For each case, the report keeps the rule issues, the model issues before merging, the hybrid issues and the full Ollama response. It also records the code revision, the hashes of the case set and of the prompt, the model and its digest, and the Ollama version. For empty translations, the model call is used only for the LLM-only condition.

3. **RQ1, detection metrics:**

   ```bash
   .venv/bin/python -m experiments.evaluation.metrics output/teste-v3.json output/teste-v4.json
   ```

   Counts TP, FP and FN per case–category pair for Rules, LLM-only and Hybrid. The main analysis uses the `rq1_main` scope and the empty translation, number and glossary categories. Robustness and meaning and context are reported separately.

4. **RQ2, annotation sheet:**

   ```bash
   .venv/bin/python -m experiments.evaluation.make_sheet output/teste-v3.json output/teste-v4.json --out output/anotacao-teste
   ```

   Shuffles the hints of both prompt versions into a single sheet (`-folha.csv`). The version of each row is kept only in the key (`-chave.csv`), which is not opened during annotation.

5. **RQ2 summary, once the sheet has been reviewed:**

   ```bash
   .venv/bin/python -m experiments.evaluation.rq2 output/anotacao-teste-folha.csv output/anotacao-teste-chave.csv
   ```

### Annotation grid

Each row of the sheet is an explanation–hint pair. The values are recorded in Portuguese, as in the sheets: `sim` (yes), `parcial` (partial), `não` (no) and `incerto` (uncertain, used when there is a concrete ambiguity).

| Criterion | Values |
| --- | --- |
| Correctness | `sim` if it identifies a real discrepancy; `não` if it flags an acceptable translation or describes the problem incorrectly. |
| Grounding | `sim` if it is supported by the source, translation, context or glossary; `parcial` if it is vague; `não` if it invents or contradicts information. |
| Clarity | `sim` if it is understood on first reading; `parcial` if it requires interpretation; `não` if it is confusing. |
| Usefulness | `sim` if it leads to a concrete comparison; `parcial` if it only asks for a general review; `não` if it points to the wrong problem. |
| Disclosure | `nenhuma` (none) if it only guides; `parcial` if it gives an equivalent, value or interpretation that solves part of the problem; `total` (full) if it gives the correction. |

In the notes, the tags `[binária]`, `[afirmação]`, `[inventa]` and `[língua]` mark, respectively, a question with two options, a hint that states what the source says, an explanation that invents facts and language errors. The first version of each sheet in the Git history is the initial proposal; later commits are the consensus review by both authors.

### Files in `experiments/evaluation/`

| File | Contents |
| --- | --- |
| `run.py`, `check_overlap.py`, `make_sheet.py`, `metrics.py`, `rq2.py` | Scripts for the steps above. |
| `calibration-2026-11-14.json`, `calibration-2026-11-23.json` | Calibration runs with v3. The second reproduces the responses of the first with another Ollama version. |
| `anotacao-folha.csv`, `anotacao-chave.csv` | Calibration annotation. |
| `desenvolvimento-v3-2026-11-23.json` | Run with v3 on the development examples. |
| `diagnostico-v3-2026-11-23.json`, `anotacao-diagnostico-*.csv` | Diagnosis of v3 and its reviewed annotation. |
| `diagnostico-v3-2026-11-24.json` | Repetition of v3 on the diagnostic set on the machine used for the final runs: 14 of 20 identical responses, with the same detection. |
| `diagnostico-v4-2026-11-24.json`, `diagnostico-v4-ajustado-2026-11-24.json`, `anotacao-diagnostico-v4-*.csv` | Diagnosis of the v4 draft and of the final v4, and the annotation of the latter. |
| `teste-v3-2026-11-25.json`, `teste-v4-2026-11-25.json` | Final test runs (MacBook Air M4, 16 GB, macOS 15.5, Ollama 0.14.3). |
| `metricas-teste-2026-11-25.json` | RQ1 results. |
| `anotacao-teste-folha.csv`, `anotacao-teste-chave.csv`, `rq2-teste-2026-11-25.json` | Reviewed RQ2 annotation and its summary. |

The CSV files use `;` as separator and UTF-8 with BOM, so that they open correctly in Excel with Portuguese settings. Reports record the commit in which they were produced; the hash of `test.json` recorded in the final runs matches the file at commit `7668938`, before a later change to its descriptive `provenance` field.

## Limitations

- **Segment identity:** translations are associated with the source text, so identical segments share their translation, even across exercises. Memory and logs are shared by the whole instance.
- **Local use only:** no authentication, permissive CORS and open export endpoints.
- **Not yet implemented:** version history, student justifications and a chronological view of the logs.
- **Evaluation:** internal, on small synthetic sets, and it does not measure learning effects.
