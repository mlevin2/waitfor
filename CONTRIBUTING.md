# Contributing

## Before you commit

Install [ShellCheck](https://github.com/koalaman/shellcheck#installing), then from the repo root run:

```bash
make check
```

That runs `scripts/lint.sh` and `tests/run.sh` (the same headless tests as [CI](.github/workflows/tests.yml)). Optional: [enable the Git pre-commit hook](README.md#development) so `git commit` runs the same checks automatically.

## Workflows

| Area | What runs where |
|------|-------------------|
| ShellCheck + `tests/test-*.sh` | `make check`, pre-commit (if enabled), and the **tests** GitHub Actions workflow on push/PR |
| Homebrew tap install | [Brew smoke](.github/workflows/brew-smoke.yml) and `make brew-smoke` / `make brew-smoke-host` (see [README](README.md)) |

## Homebrew

The formula is in [Formula/waitfor.rb](Formula/waitfor.rb). A longer-term improvement list is in [README](README.md#todo-homebrew-workflow).
