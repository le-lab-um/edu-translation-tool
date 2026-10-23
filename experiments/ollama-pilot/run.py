import argparse
import hashlib
import json
import platform
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


MODEL = "qwen3:4b-instruct-2507-q4_K_M"
BASE_URL = "http://localhost:11434"

def api(path, payload=None):
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    request = Request(
        BASE_URL + path, data=body,
        headers={"Content-Type": "application/json"},
    )
    with urlopen(request, timeout=180) as response:
        return json.load(response)


def validate_answer(answer, categories):
    if not isinstance(answer, dict) or set(answer) != {"issues"}:
        raise ValueError("A resposta deve conter apenas o campo issues.")
    if not isinstance(answer["issues"], list):
        raise ValueError("issues deve ser uma lista.")
    for issue in answer["issues"]:
        if not isinstance(issue, dict) or set(issue) != {"category", "explanation", "hint"}:
            raise ValueError("Alerta com campos inválidos.")
        if not all(isinstance(value, str) and value.strip() for value in issue.values()):
            raise ValueError("Os campos do alerta devem ser textos não vazios.")
        if issue["category"] not in categories:
            raise ValueError("Categoria desconhecida.")


def main():
    parser = argparse.ArgumentParser(description="Experiência local com os exemplos de desenvolvimento.")
    parser.add_argument("dataset", type=Path)
    parser.add_argument("--prompt", choices=("v1", "v2"), required=True,
                        help="Versão do prompt da experiência original.")
    args = parser.parse_args()
    prompt = Path(__file__).with_name(f"prompt-{args.prompt}.txt").read_text(encoding="utf-8")
    dataset_bytes = args.dataset.read_bytes()
    dataset = json.loads(dataset_bytes)
    if dataset.get("split") != "development":
        raise ValueError("Este script destina-se apenas ao conjunto de desenvolvimento.")
    categories = list(dataset["categories"])
    schema = {
        "type": "object",
        "properties": {
            "issues": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "category": {"type": "string", "enum": categories},
                        "explanation": {"type": "string"},
                        "hint": {"type": "string"},
                    },
                    "required": ["category", "explanation", "hint"],
                    "additionalProperties": False,
                },
            },
        },
        "required": ["issues"],
        "additionalProperties": False,
    }
    settings = {
        "model": MODEL, "stream": False, "format": schema,
        "keep_alive": "10m",
        "options": {"temperature": 0, "seed": 42, "num_ctx": 4096, "num_predict": 768},
    }
    version = api("/api/version")
    installed = api("/api/tags")["models"]
    model_info = next((item for item in installed if item["name"] == MODEL), None)
    if model_info is None:
        raise ValueError(f"Modelo não encontrado: {MODEL}")
    report = {
        "started_at": datetime.now(timezone.utc).isoformat(),
        "dataset_path": str(args.dataset.resolve()),
        "dataset_sha256": hashlib.sha256(dataset_bytes).hexdigest(),
        "dataset_annotation_status": dataset.get("annotation_status"),
        "ollama_version": version, "model_metadata": model_info,
        "model_configuration": api("/api/show", {"model": MODEL}),
        "platform": platform.platform(), "python_version": sys.version,
        "prompt": prompt, "settings": settings, "results": [],
    }
    with tempfile.NamedTemporaryFile(prefix="translation-ollama-results-", suffix=".json", delete=False) as f:
        output = Path(f.name)

    def save():
        output.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    save()
    print(f"Resultados: {output}", flush=True)
    for case in dataset["cases"]:
        # Apenas dados de entrada: as anotações nunca entram no pedido.
        input_data = {
            "source_language": dataset["source_language"],
            "target_language": dataset["target_language"],
            **case["input"],
        }
        result = {
            "id": case["id"], "source_id": case["source_id"],
            "input": input_data, "expected_issues": case["expected_issues"],
        }
        print(f"\nA analisar {case['id']}...", flush=True)
        started = time.perf_counter()
        try:
            response = api("/api/chat", {
                **settings,
                "messages": [
                    {"role": "system", "content": prompt},
                    {"role": "user", "content": json.dumps(input_data, ensure_ascii=False)},
                ],
            })
            result["raw_response"] = response
            if not response.get("done") or response.get("done_reason") != "stop":
                raise ValueError(f"Resposta não concluída normalmente: {response.get('done_reason')}")
            answer = json.loads(response["message"]["content"])
            result["parsed_response"] = answer
            validate_answer(answer, categories)
            expected = sorted({issue["category"] for issue in case["expected_issues"]})
            predicted = sorted({issue["category"] for issue in answer["issues"]})
            result["category_match"] = expected == predicted
            result["status"] = "ok"
        except (URLError, TimeoutError, OSError, ValueError, KeyError, TypeError) as error:
            result["status"] = "error"
            result["error"] = str(error)
            if isinstance(error, HTTPError):
                result["http_error_body"] = error.read().decode("utf-8", errors="replace")
        result["elapsed_seconds"] = round(time.perf_counter() - started, 3)
        report["results"].append(result)
        save()
        print(f"Tempo: {result['elapsed_seconds']} s | Estado: {result['status']}")
        if result["status"] == "ok":
            print(f"Categorias esperadas: {expected} | Obtidas: {predicted}")
            print(json.dumps(answer, ensure_ascii=False, indent=2), flush=True)
        else:
            print(f"Falha: {result['error']}", flush=True)

    report["finished_at"] = datetime.now(timezone.utc).isoformat()
    save()
    print(f"\nExperiência terminada. Resultados: {output}")
    print("A coincidência de categorias não valida a qualidade das explicações e pistas.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        raise SystemExit(f"Não foi possível iniciar a experiência: {error}")
