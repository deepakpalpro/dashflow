# AI Dataflow Developer

AI assistant for **Dataflow platform development** — design pipelines (pipelet sequences) and generate **Python pipelets** with **Dockerfiles** and **Kubernetes** manifests.

## Purpose

Support developers building on Dataflow:

| Capability | What it does |
|------------|--------------|
| **Pipeline Guide** | Propose linear Source → Processor → Destination pipelines using catalog pipelet ids |
| **Pipelet Developer** | Generate `logic.py`, `main.py`, `Dockerfile`, `pipelet.json`, K8s Job YAML |

Runs on a **16 GB Mac** with containerized **Ollama** (default models: `llama3.2:1b` for pipelines, `qwen2.5-coder:1.5b` for code).

## Quick start

```bash
./scripts/localdev.sh start
# UI:  http://localhost:5174
# API: http://localhost:8090
```

## API

```bash
curl -s http://localhost:8090/api/v1/models | jq .

curl -s -X POST http://localhost:8090/api/v1/pipeline-guide \
  -H 'Content-Type: application/json' \
  -d '{"message":"Manual trigger that writes JSON to S3"}' | jq .

curl -s -X POST http://localhost:8090/api/v1/python-developer \
  -H 'Content-Type: application/json' \
  -d '{"requirement":"Pipelet that uppercases a JSON record field named title"}' | jq -r .plain_text
```

## Stack

- **API** — Python 3.12 + FastAPI + **LangChain** + **LangGraph** (`8090`)
- **UI** — React + Vite (`5174`)
- **LLM** — Ollama (`11434`); optional OpenAI/Anthropic via LangChain integrations

## Environment

| Variable | Default |
|----------|---------|
| `OLLAMA_BASE_URL` | `http://localhost:11434` |
| `CHAT_MODEL` | `llama3.2:1b` |
| `CODE_MODEL` | `qwen2.5-coder:1.5b` |
| `OPENAI_API_KEY` | (optional) |
| `ANTHROPIC_API_KEY` | (optional) |

## Relation to Dashflow

This project is **standalone** for AI generation. To operate the live control plane (run pipelines, debug executions, import/export), use the **[Dashflow MCP server](../dashflow/dashflow-mcp)** in Cursor — it proxies `dashflow-api` with tools for pipelines, executions, connectors, and pipelets.

Export pipeline JSON from this UI and import via MCP `import_pipeline` or manually in the Dashflow builder.
