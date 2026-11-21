#!/usr/bin/env bash
# Run Horizon's shader-pack check over Neoqua (API 0.2).
# Requires `horizon-shader` on PATH (from a Horizon build: cargo build --release -p horizon-shader).
set -euo pipefail
PACK="${1:-neoqua}"
cd "$(dirname "$0")/.."

if ! command -v horizon-shader >/dev/null 2>&1; then
  echo "error: horizon-shader not found on PATH." >&2
  echo "hint: build it from a Horizon checkout: cargo build --release -p horizon-shader" >&2
  echo "hint: or set PATH to include its target/release directory." >&2
  exit 127
fi

echo "==> horizon-shader check ${PACK} (--json)"
horizon-shader check "${PACK}" --json
