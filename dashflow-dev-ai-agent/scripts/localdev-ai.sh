#!/usr/bin/env bash
# AI Dataflow Developer — local stack (Ollama + API + UI)
#
# Usage:
#   ./scripts/localdev.sh start
#   ./scripts/localdev.sh stop
#   ./scripts/localdev.sh status
#
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHAT_MODEL="${CHAT_MODEL:-llama3.2:1b}"
CODE_MODEL="${CODE_MODEL:-qwen2.5-coder:1.5b}"
API_URL="${API_URL:-http://localhost:8090}"
UI_URL="${UI_URL:-http://localhost:5174}"

log() { printf '==> %s\n' "$*"; }

cmd="${1:-start}"
case "$cmd" in
  start)
    log "Starting Ollama + API + UI"
    (cd "$ROOT" && docker compose up -d --build)
    for i in $(seq 1 120); do
      curl -sf "$API_URL/health" >/dev/null 2>&1 && break
      sleep 1
    done
    log "Pulling chat model $CHAT_MODEL and code model $CODE_MODEL"
    docker exec aidfd-ollama ollama pull "$CHAT_MODEL" || log "warn: chat model pull failed"
    docker exec aidfd-ollama ollama pull "$CODE_MODEL" || log "warn: code model pull failed"
    log "API:  $API_URL"
    log "UI:   $UI_URL"
    ;;
  stop)
    (cd "$ROOT" && docker compose down)
    ;;
  status)
    curl -sf "$API_URL/health" && log "API healthy" || log "API not reachable"
    curl -sf "$UI_URL" >/dev/null && log "UI reachable" || log "UI not reachable"
    ;;
  *)
    echo "Usage: $0 {start|stop|status}" >&2
    exit 1
    ;;
esac
