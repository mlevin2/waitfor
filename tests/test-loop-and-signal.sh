#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"

fixture="$ROOT/tests/fixtures/loop_until_term.sh"

bash "$fixture" &
pid=$!

# Kill it after a short delay, while waitfor is waiting.
( sleep 0.4; kill -TERM "$pid" 2>/dev/null || true ) &

"$WAITFOR" "$pid" --interval 0.05 --settle 0

if ps -p "$pid" >/dev/null 2>&1; then
  echo "Expected loop process to have exited: pid=$pid" >&2
  exit 1
fi
