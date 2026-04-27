#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

sleep 0.4 &
pid=$!

"$WAITFOR" "$pid" --interval 0.05 --settle 0 -- sh -c "echo ok > '$tmp/out'"

[[ "$(cat "$tmp/out")" == "ok" ]]
