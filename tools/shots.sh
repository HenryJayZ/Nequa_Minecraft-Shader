#!/usr/bin/env bash
# Frame-deterministic screenshot sequence for Neoqua regression shots.
# Uses `horizon-ctl screenshot-sequence FRAMES STEP_MS PATH` under HORIZON_STILL
# (see docs/api/shaders.md, "Testing a pack frame by frame").
set -euo pipefail
FRAMES="${1:-60}"
STEP_MS="${2:-16.666667}"   # 60 fps
OUT="${3:-shots/neoqua.png}"
cd "$(dirname "$0")/.."

if ! command -v horizon-ctl >/dev/null 2>&1; then
  echo "error: horizon-ctl not found on PATH." >&2
  exit 127
fi

mkdir -p "$(dirname "${OUT}")"
export HORIZON_STILL=1
echo "==> screenshot-sequence frames=${FRAMES} step_ms=${STEP_MS} out=${OUT}"
horizon-ctl screenshot-sequence "${FRAMES}" "${STEP_MS}" "${OUT}"
