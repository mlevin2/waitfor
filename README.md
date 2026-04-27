# waitfor

Small, shell-agnostic CLI to wait for an existing process (by PID or by `ps` substring match) to exit, then optionally run another command.

This is meant for the cross-terminal use case where `wait` can’t help because the process isn’t a child of your current shell.

## Requirements

- `ps`
- [`ripgrep` (`rg`)](https://github.com/BurntSushi/ripgrep)
- Optional: [`fzf`](https://github.com/junegunn/fzf) (used only when a query matches multiple processes)

## Install

```bash
chmod +x "$HOME/software/waitfor/waitfor"
ln -sf "$HOME/software/waitfor/waitfor" "$HOME/bin/waitfor"
```

## Shell completions

`waitfor` supports **fish** and **zsh** completions (options are derived from `--help` via a small Python helper; same pattern as `pdf-extract-pages`).

- `waitfor --print-completion fish|zsh` — print a snippet to stdout
- `waitfor install-completion fish|zsh` — write the completion file under `~/.config/fish/completions` or `~/.zsh/completions`

Requires `python3` for these subcommands. Implementation: `tools/cli_completion.py` in this repo.

**zsh:** add `fpath` before `compinit` if needed, e.g. `fpath=("$HOME/.zsh/completions" $fpath)`.

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

```bash
bash tests/run.sh
```
