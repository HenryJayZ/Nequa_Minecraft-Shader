#!/usr/bin/env bash
# Benchmark harness for Neoqua via horizon-ctl.
# NOTE: the exact `horizon-ctl bench` argument syntax is unverified against the
# current Horizon CLI docs; adjust if the subcommand differs.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v horizon-ctl >/dev/null 2>&1; then
  echo "error: horizon-ctl not found on PATH." >&2
  exit 127
fi

# Target rig: Intel HD 4600, DDR3 shared memory, 768p, 60 fps budget.
echo "==> horizon-ctl bench 5"
horizon-ctl bench 5
