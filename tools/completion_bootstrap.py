#!/usr/bin/env python3
"""Run shell-completion helpers; exit 125 if argv does not use completion (unused when gated in bash)."""

from __future__ import annotations

import os
import sys

# tools/ is next to this file
_HERE = os.path.dirname(os.path.abspath(__file__))
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)
from cli_completion import maybe_handle  # noqa: E402


def main() -> int:
    if len(sys.argv) < 2:
        return 125
    script = os.path.abspath(sys.argv[1])
    try:
        maybe_handle(script, [script, *sys.argv[2:]])
    except SystemExit as e:
        return int(e.code) if e.code is not None else 0
    return 125


if __name__ == "__main__":
    raise SystemExit(main())
