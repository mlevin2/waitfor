#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"

token="waitfor_ambig_$RANDOM"

python3 -c 'import time; time.sleep(5)' "$token" &
pid1=$!
python3 -c 'import time; time.sleep(5)' "$token" &
pid2=$!

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"; kill "$pid1" "$pid2" 2>/dev/null || true' EXIT

set +e
# Force non-interactive so we don't pop fzf in a real terminal test run.
"$WAITFOR" "$token" --interval 0.05 --settle 0 -- sh -c "echo SHOULD_NOT_RUN > '$tmp/out'" </dev/null >/dev/null 2>&1
rc=$?
set -e

[[ "$rc" -ne 0 ]]
[[ ! -f "$tmp/out" ]]
