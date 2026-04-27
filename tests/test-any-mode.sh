#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"

sleep 0.3 &
pid1=$!
sleep 5 &
pid2=$!

start=$(date +%s)
"$WAITFOR" "$pid1" "$pid2" --any --interval 0.05 --settle 0
end=$(date +%s)

elapsed=$((end - start))
if [[ "$elapsed" -ge 3 ]]; then
  echo "Expected --any to return quickly, elapsed=${elapsed}s" >&2
  kill "$pid2" 2>/dev/null || true
  exit 1
fi

kill "$pid2" 2>/dev/null || true
