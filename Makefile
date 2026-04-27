#   make lint  / make test  / make check  — same checks as .githooks/pre-commit
.PHONY: lint test check brew-smoke brew-smoke-host brew-smoke-image

lint:
	bash scripts/lint.sh

test:
	bash tests/run.sh

# lint + headless tests (CI runs the same, plus matrix OS)
check: lint test

# Homebrew smoke — .github/workflows/brew-smoke.yml
#   make brew-smoke         — Docker (ghcr.io/homebrew/brew), matches GHA
#   make brew-smoke-host    — native `brew` on this machine, no Docker
#   make brew-smoke-image   — baked image (taps from GitHub; see docker/Dockerfile.homebrew-smoke)

brew-smoke:
	bash scripts/test-homebrew-docker.sh

# Same inner script as CI, using the checkout as the tap (macOS or Linux with Homebrew).
brew-smoke-host:
	WAITFOR_TAP_DIR="$(CURDIR)" bash scripts/homebrew-smoke-inner.sh

brew-smoke-image:
	docker build -f docker/Dockerfile.homebrew-smoke -t waitfor-brew-smoke .
