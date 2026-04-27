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
