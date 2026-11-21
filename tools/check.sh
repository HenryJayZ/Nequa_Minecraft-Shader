#!/usr/bin/env bash
# Validate Neoqua: offline contract check first, then Horizon's real API 0.2 check.
# The real check needs `horizon-shader` on PATH (from a Horizon build:
# cargo build --release -p horizon-shader).
set -euo pipefail
PACK="${1:-neoqua}"
cd "$(dirname "$0")/.."

if command -v python3 >/dev/null 2>&1; then
  echo "==> static contract check (tools/validate_pack.py)"
  python3 tools/validate_pack.py
fi

if ! command -v horizon-shader >/dev/null 2>&1; then
  echo "error: horizon-shader not found on PATH." >&2
  echo "hint: build it from a Horizon checkout: cargo build --release -p horizon-shader" >&2
  echo "hint: or set PATH to include its target/release directory." >&2
  exit 127
fi

echo "==> horizon-shader check ${PACK} (--json)"
horizon-shader check "${PACK}" --json
