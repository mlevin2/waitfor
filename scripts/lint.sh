#!/usr/bin/env bash
# ShellCheck all shell in this project (main entrypoint, scripts/, tests/ including fixtures).
# Requires: shellcheck (https://github.com/koalaman/shellcheck) on PATH.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd -P)"
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "lint: shellcheck not found. Install: https://github.com/koalaman/shellcheck#installing" >&2
  echo "  e.g. brew install shellcheck  OR  apt install shellcheck" >&2
  exit 1
fi
echo "shellcheck: $ROOT/waitfor"
shellcheck -x "$ROOT/waitfor"
while IFS= read -r f; do
  echo "shellcheck: $f"
  shellcheck -x "$f"
done < <(find "$ROOT/scripts" "$ROOT/tests" -type f -name '*.sh' | sort)

echo "lint: ok"
