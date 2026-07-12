#!/usr/bin/env python3
"""plet-unit-converter — generated runnable pipelet."""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "_common"))

from config_merge import log, resolve_from_env  # noqa: E402
from io_transport import read_message, write_message  # noqa: E402
from logic import run  # noqa: E402

REQUIRED_DEPLOYMENT = ("region",)
REQUIRED_EXECUTION = ()


def _connector() -> dict:
    raw = os.environ.get("CONNECTOR_CONFIG") or "{}"
    data = json.loads(raw) if isinstance(raw, str) else raw
    return data if isinstance(data, dict) else {}


def main() -> int:
    log("plet-unit-converter starting")
    deployment, execution, _ = resolve_from_env(
        required_deployment=REQUIRED_DEPLOYMENT,
        required_execution=REQUIRED_EXECUTION,
    )
    # Sources with SOURCE_TRIGGER=once may have empty stdin / no kickoff
    try:
        message = read_message(source=False)
    except SystemExit:
        message = {}
    if not isinstance(message, dict):
        message = {}
    # Ignore orchestrator kickoffs for sources
    payload = message.get("payload")
    if isinstance(payload, str) and payload.startswith("run-"):
        message = {}
    out = run(message, execution, _connector(), "plet-unit-converter")
    out["deployment"] = deployment
    write_message(out)
    log(f"done recordCount={out.get('recordCount', 0)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
