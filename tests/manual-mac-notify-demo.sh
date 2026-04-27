#!/usr/bin/env bash
# Manual demo: two macOS notifications — after target exits, then after the post-wait command.
# Run from any directory:  bash tests/manual-mac-notify-demo.sh
# Requires: waitfor on PATH or set WAITFOR to the script path.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
WAITFOR="${WAITFOR:-$ROOT/waitfor}"

# macOS: mktemp -t PREFIX creates a file with a unique name under $TMPDIR.
DEMO_TARGET="$(mktemp -t waitfor-demo)"
trap 'rm -f "$DEMO_TARGET"' EXIT

{
  echo "#!/bin/bash"
  echo "# 5s target (phase 1 — what we wait for)"
  echo "sleep 5"
} >"$DEMO_TARGET"
chmod +x "$DEMO_TARGET"

echo "Starting 5s target in background: $DEMO_TARGET"
"$DEMO_TARGET" &
first_pid=$!
cl="$(ps -p "$first_pid" -o command= 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
echo "Target PID=$first_pid"
echo "Command line from ps: $cl"
echo "waitfor lists the same in stderr as 'Targets: <pid> (command)…' and in the first notification."
echo "Running waitfor with --notify; post-wait command: sleep 5 (phase 2)"
echo "(Expect two notifications: when the target sleep ends, when post-wait sleep 5 ends.)"
echo ""
"$WAITFOR" "$first_pid" --notify --interval 1 --settle 0 -- sleep 5
echo "Done."
