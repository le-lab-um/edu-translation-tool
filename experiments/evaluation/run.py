"""Recolhe as respostas do modelo local para calibrar a grelha ou executar a avaliação.

Uso (na raiz do repositório, com o Ollama a correr):
    .venv/bin/python -m experiments.evaluation.run --output output/calibracao.json
    .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --output output/teste.json
    .venv/bin/python -m experiments.evaluation.run --cases experiments/evaluation/test.json --prompt backend/prompts/hint-v4.txt --output output/teste-v4.json

Sem --cases usa o conjunto de calibração e, sem --prompt, o prompt da aplicação. Faz um pedido de aquecimento antes do primeiro caso
(desativável com --no-warmup) e uma única chamada ao modelo por caso. Nas traduções vazias a
chamada é experimental: serve só para a condição «LLM isolado», e o híbrido devolve apenas a regra.
"""

import argparse
import asyncio
import hashlib
import json
import platform
import subprocess
import time
from datetime import datetime, timezone
from importlib import metadata
from pathlib import Path

import httpx

from backend import llm as llm_module
from backend.hybrid import merge_issues
from backend.llm import GENERATION_OPTIONS, LLMError, OllamaClient
from backend.rules import run_all_rules


ROOT = Path(__file__).resolve().parents[2]
CASES_PATH = Path(__file__).with_name("calibration.json")
PACKAGES = ("fastapi", "pydantic", "uvicorn", "starlette", "httpx", "sqlalchemy", "rapidfuzz")
WARMUP_INPUT = {"source": "Hello.", "target": "Olá.", "glossary": {}, "context": ""}


class RecordingTransport(httpx.AsyncBaseTransport):
    """Guarda a resposta completa do Ollama a cada pedido a /api/chat, sem alterar o adaptador."""

    def __init__(self):
        self.inner = httpx.AsyncHTTPTransport()
        self.responses = []

    async def handle_async_request(self, request):
        response = await self.inner.handle_async_request(request)
        body = await response.aread()
        if request.url.path == "/api/chat":
            try:
                self.responses.append(json.loads(body))
            except ValueError:
                self.responses.append({"unparsed": body.decode("utf-8", "replace")})
        headers = [
            (key, value)
            for key, value in response.headers.items()
            if key.lower() not in {"content-encoding", "content-length", "transfer-encoding"}
        ]
        return httpx.Response(response.status_code, headers=headers, content=body, request=request)

    async def aclose(self):
        await self.inner.aclose()


def code_revision():
    def git(*args):
        return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=True).stdout.strip()

    try:
        return {"commit": git("rev-parse", "HEAD"), "uncommitted_changes": bool(git("status", "--porcelain"))}
    except (OSError, subprocess.CalledProcessError):
        return {"commit": None, "uncommitted_changes": None}


def dependency_versions():
    versions = {}
    for name in PACKAGES:
        try:
            versions[name] = metadata.version(name)
        except metadata.PackageNotFoundError:
            versions[name] = None
    return versions


async def warm_up(llm):
    started = time.perf_counter()
    try:
        await llm.review(**WARMUP_INPUT)
        status = "ok"
    except LLMError as error:
        status = error.status
    return {"performed": True, "status": status, "elapsed_ms": round((time.perf_counter() - started) * 1000)}


async def collect_case(case, llm, transport):
    inputs = case["input"]
    source, target = inputs["source"], inputs["target"]
    glossary = {}
    for entry in inputs["glossary"]:
        target_term, *variants = entry["accepted_targets"]
        glossary[entry["source_term"]] = {"target": target_term, "variants": variants}

    rules = run_all_rules(source=source, target=target, glossary=glossary)
    is_empty = any(issue["category"] == "empty_translation" for issue in rules)
    llm_raw = []
    llm_status = "ok"
    seen = len(transport.responses)
    started = time.perf_counter()
    try:
        llm_raw = await llm.review(source, target, glossary, inputs["context"])
    except LLMError as error:
        llm_status = error.status
    elapsed_ms = round((time.perf_counter() - started) * 1000)
    ollama_response = transport.responses[-1] if len(transport.responses) > seen else None

    # Comportamento operacional: numa tradução vazia o híbrido devolve só a regra.
    hybrid, sanitized = merge_issues(rules, [] if is_empty else llm_raw, source, glossary)
    return {
        **case,
        "rule_issues": rules,
        "llm_issues_before_fusion": llm_raw,
        "hybrid_issues_shown": hybrid,
        "llm_status": llm_status,
        "llm_attempts": 1,
        "llm_experimental_call_on_empty": is_empty,
        "llm_elapsed_ms": elapsed_ms,
        "ollama_response": ollama_response,
        "sanitized": sanitized,
    }


async def collect_report(cases_path, warmup):
    dataset = cases_path.read_bytes()
    data = json.loads(dataset)
    transport = RecordingTransport()
    llm = OllamaClient(enabled=True, transport=transport)
    async with httpx.AsyncClient(base_url=llm.base_url, timeout=llm.timeout) as http:
        version = (await http.get("/api/version")).raise_for_status().json()["version"]
        models = (await http.get("/api/tags")).raise_for_status().json()["models"]
    model = next((model for model in models if model["name"] == llm.model), None)
    if model is None:
        raise ValueError(f"Modelo {llm.model} indisponível no Ollama.")
    report = {
        "split": data.get("split", "unknown"),
        "annotation_status": data.get("annotation_status", "unknown"),
        "cases_file": cases_path.name,
        "started_at": datetime.now(timezone.utc).isoformat(),
        "prompt": llm_module.PROMPT_PATH.name,
        "prompt_sha256": hashlib.sha256(llm_module.PROMPT_PATH.read_bytes()).hexdigest(),
        "dataset_sha256": hashlib.sha256(dataset).hexdigest(),
        "code_revision": code_revision(),
        "python_version": platform.python_version(),
        "dependencies": dependency_versions(),
        "ollama_version": version,
        "model": model["name"],
        "model_digest": model["digest"],
        "generation_options": GENERATION_OPTIONS,
        "timeout_seconds": llm.timeout,
        "platform": platform.platform(),
        "warmup": await warm_up(llm) if warmup else {"performed": False},
        "results": [],
    }
    for case in data["cases"]:
        result = await collect_case(case, llm, transport)
        report["results"].append(result)
        print(f"{case['id']}: {result['llm_status']}", flush=True)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--cases", type=Path, default=CASES_PATH, help="Conjunto de casos (por omissão, a calibração).")
    parser.add_argument("--output", type=Path, required=True, help="Caminho para um novo relatório JSON.")
    parser.add_argument("--prompt", type=Path, help="Prompt a usar nesta recolha (por omissão, o da aplicação).")
    parser.add_argument("--no-warmup", action="store_true", help="Não fazer o pedido de aquecimento.")
    args = parser.parse_args()
    if args.output.exists():
        parser.error(f"O ficheiro já existe: {args.output}")
    if args.prompt is not None:
        if not args.prompt.is_file():
            parser.error(f"Prompt inexistente: {args.prompt}")
        llm_module.PROMPT_PATH = args.prompt.resolve()
    try:
        report = asyncio.run(collect_report(args.cases, warmup=not args.no_warmup))
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("x", encoding="utf-8") as output:
            json.dump(report, output, ensure_ascii=False, indent=2)
            output.write("\n")
    except (httpx.HTTPError, OSError, ValueError, KeyError) as error:
        raise SystemExit(f"Falha na recolha: {error}") from error
    print(f"Relatório: {args.output}")


if __name__ == "__main__":
    main()
