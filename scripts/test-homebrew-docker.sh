#!/usr/bin/env bash
# Homebrew install smoke in Docker (official Homebrew image). No host install.
#
#   bash scripts/test-homebrew-docker.sh
#   make brew-smoke
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd -P)"
cd "$ROOT"
exec docker compose -f docker-compose.brew.yml run --rm homebrew-smoke
