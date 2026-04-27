#!/usr/bin/env bash
# --notify with WAITFOR_NOTIFY_CMD: one line when no post-wait command, two when a command is run.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
WAITFOR="$ROOT/waitfor"
LOGNOTIFY="$ROOT/tests/fixtures/notify_log.sh"
chmod +x "$LOGNOTIFY" 2>/dev/null || true

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export NOTIFY_LOG="$tmp/notify.log"
export WAITFOR_NOTIFY_CMD="$LOGNOTIFY"

sleep 0.4 &
pid=$!

# No command: one notification (body includes pid and command name from ps)
"$WAITFOR" "$pid" --interval 0.05 --settle 0 --notify
lines=$(wc -l <"$NOTIFY_LOG" | tr -d ' ')
[[ "$lines" -eq 1 ]]
head -1 "$NOTIFY_LOG" | rg -q "Finished waiting: $pid .*\("
head -1 "$NOTIFY_LOG" | rg -qi 'sleep'

# With command: two notifications
: >"$NOTIFY_LOG"
sleep 0.4 &
pid=$!
"$WAITFOR" "$pid" --interval 0.05 --settle 0 --notify -- sh -c "echo x > '$tmp/x'"
lines=$(wc -l <"$NOTIFY_LOG" | tr -d ' ')
[[ "$lines" -eq 2 ]]
head -1 "$NOTIFY_LOG" | rg -q "Finished waiting: $pid .*\("
sed -n '2p' "$NOTIFY_LOG" | rg -Fq 'Command "sh" finished'
[[ "$(cat "$tmp/x")" == "x" ]]
