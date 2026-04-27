# waitfor

[![tests](https://github.com/mlevin2/waitfor/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/mlevin2/waitfor/actions/workflows/tests.yml?query=branch%3Amain) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Small, shell-agnostic CLI to wait for an existing process (by PID or by `ps` substring match) to exit, then optionally run another command.

This is meant for the cross-terminal use case where `wait` can’t help because the process isn’t a child of your current shell.

## Requirements

- `ps`
- [`ripgrep` (`rg`)](https://github.com/BurntSushi/ripgrep)
- Optional: [`fzf`](https://github.com/junegunn/fzf) (used only when a query matches multiple processes)
- **Desktop notifications (optional):** for `--notify`, a notifier is found automatically, or you can set `WAITFOR_NOTIFY_CMD` (it receives the title as `$1` and the body as `$2`).

## Install

### From git / tarball

```bash
chmod +x "$HOME/software/waitfor/waitfor"
ln -sf "$HOME/software/waitfor/waitfor" "$HOME/bin/waitfor"
```

### [Homebrew](https://brew.sh) (this repo is a [tap](https://docs.brew.sh/Taps))

[Homebrew](https://formulae.brew.sh) requires a local install of [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg` on `PATH`); the formula depends on the `ripgrep` keg. `waitfor` and `tools/` (for shell completions) are installed under the formula prefix with `waitfor` in `$(brew --prefix)/bin`.

```bash
brew tap mlevin2/waitfor https://github.com/mlevin2/waitfor
brew install --head mlevin2/waitfor/waitfor
```

The formula is **head-only** (it tracks the `main` branch). A stable `url`+`sha256` can be added later for a tagged release. Submitting to **homebrew-core** is a separate process.

## Shell completions

`waitfor` supports **fish**, **zsh**, and **bash** completions (options are derived from `--help` via a small Python helper; same pattern as `pdf-extract-pages`).

- `waitfor --print-completion fish|zsh|bash` — print a snippet to stdout
- `waitfor install-completion fish|zsh|bash` — write the completion file to:
  - **fish:** `~/.config/fish/completions/waitfor.fish`
  - **zsh:** `~/.zsh/completions/_waitfor`
  - **bash:** `~/.local/share/bash-completion/completions/waitfor` (XDG user path used by [bash-completion](https://github.com/scop/bash-completion))

Requires `python3` for these subcommands. Implementation: `tools/cli_completion.py` in this repo.

**zsh:** add `fpath` before `compinit` if needed, e.g. `fpath=("$HOME/.zsh/completions" $fpath)`.

**bash:** if completions are not picked up, ensure `bash_completion` is loaded (e.g. Homebrew: `source /opt/homebrew/etc/profile.d/bash_completion.sh` in `~/.bash_profile` / `~/.bashrc`), or add a one-liner to `source` files under `~/.local/share/bash-completion/completions/`.

## Finding a target PID (no TTY)

`tty` only works in a real terminal; a shell spawned by a GUI (or `!` in an agent UI) may report `not a tty`, so you cannot use `tty` to map “this window” to a `ps` row.

Ways to pick a `--pid` or query string for `waitfor` anyway:

- **Known command line:** run `ps ax -o pid,etime,command= | rg -F 'opencode'` (or another distinctive substring) and use that string as a `waitfor` query, or the PID if unambiguous.
- **Known working directory (macOS):** `lsof -a -p <pid> -d cwd` to confirm which `node`/`opencode` instance is using a given project folder, then `waitfor <that-pid>`.
- **Distinguish multiple matches:** if the substring is ambiguous, install `fzf` so `waitfor` can open an interactive picker, or pass an explicit numeric PID from `ps`.

## Usage

```bash
waitfor [options] <pid|query>... [-- <command> [args...]]
```

Useful options:

- `--all` wait for all targets (default)
- `--any` wait for the first target to exit
- `--timeout N|Nm|Nh|Nd` fail after a timeout (default: no timeout)
- `--settle N` sleep N seconds after the wait completes
- `--interval N` polling interval in seconds
- `--notify` when supported, show a **desktop notification** after the wait and settle (and, if you pass a command, another when that command ends). This is best effort: the right notifier depends on the OS (see below). If nothing is available, `waitfor` prints a one-line warning unless you use `--quiet`—or set `WAITFOR_NOTIFY_CMD` to a script to handle notifications yourself.

### Notifications and OS support

`waitfor` does not add dependencies; it looks for a notifier in a fixed order.

| OS / context | What we try (first match wins) |
|----------------|--------------------------------|
| **macOS** | `osascript` (`display notification`) |
| **Linux (typical desktop)** | `notify-send` (e.g. libnotify) |
| **Windows (Git Bash, MSYS, Cygwin)**, and **`OS=Windows_NT`** | A short `powershell` script using `System.Windows.Forms.NotifyIcon` (balloon tip) |
| **WSL (Linux, `powershell.exe` available)** | The same Windows PowerShell path, so a toast on the Windows desktop |

`WAITFOR_NOTIFY_CMD` overrides this entirely: the command is invoked with **two arguments** (title, body). Example:

```bash
export WAITFOR_NOTIFY_CMD="$HOME/bin/my-notify"
# my-notify: printf or call notify-send, gntp, etc.
```

When `--notify` is set and a wait **times out**, a single timeout notification (or the same warning) is used; the **post-wait command is not run** (same as before).

Notification text includes a **snapshot of each target PID and its `ps` command line** (taken right before the wait) so the message still makes sense after the process has exited. The “command finished” notification includes the first token of the post-wait command in quotes, the exit code, and an abbreviated full command line.

Examples:

```bash
waitfor 12345 -- cp file1 /var/www/files/file1
waitfor "python myjob.py" -- rsync -av out/ /var/www/files/out/
waitfor node postgres --any --settle 3 -- echo "something finished"
```

## Notes / Caveats

- Query matching is a plain substring match against `ps -ax ... command`. This is intentionally fuzzy and can behave differently across platforms and `ps` implementations.
- If a query matches multiple processes, `waitfor` uses `fzf` to prompt you to pick one or more processes. In non-interactive contexts (stdin/stdout not a TTY), `waitfor` refuses to prompt and exits non-zero.
- Some platforms can leave a short-lived zombie (`Z`) entry after a process exits. `waitfor` treats zombies as "done".

## Tests

On every push to `main`, [GitHub Actions](https://github.com/mlevin2/waitfor/actions/workflows/tests.yml) runs the same headless suite on **Ubuntu 22.04/24.04** and **macOS 14/15** (installs `ripgrep` first). GUI-only demos (e.g. `tests/manual-mac-notify-demo.sh`) are not part of CI.

```bash
bash tests/run.sh
```
