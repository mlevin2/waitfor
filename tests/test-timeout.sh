#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"

sleep 10 &
pid=$!

set +e
"$WAITFOR" "$pid" --timeout 1 --interval 0.1 --settle 0
rc=$?
set -e

kill "$pid" 2>/dev/null || true

[[ "$rc" -eq 124 ]]
