"""Recolhe respostas para calibrar a grelha de pistas com o prompt da aplicação."""

import argparse
import asyncio
import hashlib
import json
import platform
import time
from datetime import datetime, timezone
from pathlib import Path

import httpx

from backend.hybrid import merge_issues
from backend.llm import GENERATION_OPTIONS, PROMPT_PATH, LLMError, OllamaClient
from backend.rules import run_all_rules


CASES_PATH = Path(__file__).with_name("calibration.json")


async def collect_case(case, llm):
    inputs = case["input"]
    source, target = inputs["source"], inputs["target"]
    glossary = {}
    for entry in inputs["glossary"]:
        target_term, *variants = entry["accepted_targets"]
        glossary[entry["source_term"]] = {"target": target_term, "variants": variants}

    rules = run_all_rules(source=source, target=target, glossary=glossary)
    llm_raw = []
    llm_status = "skipped"
    elapsed_ms = None
    if not any(issue["category"] == "empty_translation" for issue in rules):
        started = time.perf_counter()
        try:
            llm_raw = await llm.review(source, target, glossary, inputs["context"])
            llm_status = "ok"
        except LLMError as error:
            llm_status = error.status
        elapsed_ms = round((time.perf_counter() - started) * 1000)

    hybrid, sanitized = merge_issues(rules, llm_raw, source, glossary)
    return {
        **case,
        "rule_issues": rules,
        "llm_issues_before_fusion": llm_raw,
        "hybrid_issues_shown": hybrid,
        "llm_status": llm_status,
        "llm_elapsed_ms": elapsed_ms,
        "sanitized": sanitized,
    }


async def collect_report():
    dataset = CASES_PATH.read_bytes()
    llm = OllamaClient(enabled=True)
    async with httpx.AsyncClient(base_url=llm.base_url, timeout=llm.timeout) as http:
        version = (await http.get("/api/version")).raise_for_status().json()["version"]
        models = (await http.get("/api/tags")).raise_for_status().json()["models"]
    model = next((model for model in models if model["name"] == llm.model), None)
    if model is None:
        raise ValueError(f"Modelo {llm.model} indisponível no Ollama.")
    report = {
        "split": "calibration",
        "annotation_status": "pending_author_review",
        "started_at": datetime.now(timezone.utc).isoformat(),
        "prompt": PROMPT_PATH.name,
        "prompt_sha256": hashlib.sha256(PROMPT_PATH.read_bytes()).hexdigest(),
        "dataset_sha256": hashlib.sha256(dataset).hexdigest(),
        "ollama_version": version,
        "model": model["name"],
        "model_digest": model["digest"],
        "generation_options": GENERATION_OPTIONS,
        "timeout_seconds": llm.timeout,
        "platform": platform.platform(),
        "results": [],
    }
    for case in json.loads(dataset)["cases"]:
        result = await collect_case(case, llm)
        report["results"].append(result)
        print(f"{case['id']}: {result['llm_status']}", flush=True)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True, help="Caminho para um novo relatório JSON.")
    args = parser.parse_args()
    if args.output.exists():
        parser.error(f"O ficheiro já existe: {args.output}")
    try:
        report = asyncio.run(collect_report())
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("x", encoding="utf-8") as output:
            json.dump(report, output, ensure_ascii=False, indent=2)
            output.write("\n")
    except (httpx.HTTPError, OSError, ValueError, KeyError) as error:
        raise SystemExit(f"Falha na recolha de calibração: {error}") from error
    print(f"Relatório de calibração: {args.output}")


if __name__ == "__main__":
    main()
