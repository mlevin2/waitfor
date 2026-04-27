#!/usr/bin/env bash
# Shared by docker-compose.brew.yml, docker/Dockerfile.homebrew-smoke, and
# .github/workflows/brew-smoke.yml. Run in the official Homebrew Linux image
# (or any environment where brew works).
set -euo pipefail

if [[ -n "${WAITFOR_TAP_DIR:-}" && -f "${WAITFOR_TAP_DIR}/Formula/waitfor.rb" ]]; then
  brew tap mlevin2/waitfor "$WAITFOR_TAP_DIR"
else
  brew tap mlevin2/waitfor https://github.com/mlevin2/waitfor
fi
brew install --head mlevin2/waitfor/waitfor
waitfor --help >/dev/null
brew test mlevin2/waitfor/waitfor
