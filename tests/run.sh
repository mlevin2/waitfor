#!/usr/bin/env bash
# Run every tests/test-*.sh script and report a combined result.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

pass_files=0
fail_files=0
found_files=0

while IFS= read -r f; do
  [[ -n "$f" ]] || continue
  ((++found_files)) || true
  bn="$(basename "$f")"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $bn"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if bash "$f"; then
    ((++pass_files)) || true
  else
    ((++fail_files)) || true
  fi
done < <(find "$ROOT/tests" -maxdepth 1 -type f -name 'test-*.sh' | sort)

if [[ "$found_files" -eq 0 ]]; then
  echo "waitfor tests: no tests/test-*.sh files under $ROOT/tests" >&2
  exit 1
fi

echo ""
if [[ "$fail_files" -eq 0 ]]; then
  echo "waitfor tests: all ${pass_files} file(s) passed."
  exit 0
fi

echo "waitfor tests: ${fail_files} file(s) failed, ${pass_files} file(s) passed." >&2
exit 1
