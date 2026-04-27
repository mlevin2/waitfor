#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"

token="waitfor_test_token_$RANDOM"

python3 -c 'import time; time.sleep(2)' "$token" &
pid=$!

# Ensure the token is visible in ps before invoking waitfor (avoids races).
seen=0
for _ in $(seq 1 40); do
  cmdline="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  if [[ "$cmdline" == *"$token"* ]]; then
    seen=1
    break
  fi
  sleep 0.05
done

if [[ "$seen" -ne 1 ]]; then
  echo "Token not visible in ps for pid=$pid" >&2
  ps -p "$pid" -o pid=,stat=,command= >&2 || true
  exit 1
fi

"$WAITFOR" "$token" --interval 0.05 --settle 0

if ps -p "$pid" >/dev/null 2>&1; then
  # It can briefly be a zombie depending on timing; either way we shouldn't still be running.
  stat="$(ps -p "$pid" -o stat= 2>/dev/null | tr -d ' ' || true)"
  [[ "$stat" == *Z* ]] || {
    echo "Expected process to be gone (or zombie), but still running: pid=$pid stat=$stat" >&2
    exit 1
  }
fi
