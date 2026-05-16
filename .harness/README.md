# Harness — plumbing

Three dispatchers + a shared lib. Per-concern scripts live in `*.d/` drop-in directories. Each script is small and exits 0 (soft mode).

For *what* the harness checks (and how to extend each dimension), see the root docs:

- [MAINTAINABILITY.md](../MAINTAINABILITY.md) — `checks.d/`
- [BEHAVIOUR.md](../BEHAVIOUR.md) — `verify.d/tests.sh`, `verify.d/secrets.sh`
- [ARCHITECTURE.md](../ARCHITECTURE.md) — `verify.d/project-fitness.sh` + `.harness/fitness.d/`

This README is about the dispatch plumbing only.

## Layout

```
harness/
├── lib.sh                  # shared helpers (project_root, run, state_dir)
├── 01-context.sh           # UserPromptSubmit dispatcher → context.d/*
├── 02-checks.sh            # PostToolUse dispatcher → checks.d/<lang>
├── 03-verify.sh            # Stop dispatcher → verify.d/*
├── context.d/              # feedforward sensors (no args, stdout → prompt)
├── checks.d/               # maintainability sensors (one file path arg)
├── verify.d/               # behaviour + architecture sensors (no args, cwd = repo root)
└── templates/              # starter fitness functions seeded by /harness-vendor
```

## Activation

The dispatchers are inactive until a project has a `.harness/` directory. Vendor with:

    /harness-vendor

Copies all modules into `<repo>/.harness/`. Activates the harness for that project and makes the scripts runnable in CI and pre-commit. Commit `.harness/`. Deactivate with `rm -rf .harness/`.

## Conventions

| Layer       | Input                  | Output                                | Exit |
|-------------|------------------------|---------------------------------------|------|
| `context.d` | none                   | stdout (becomes prompt context)       | 0    |
| `checks.d`  | one file path argument | stderr; failures → `$HARNESS_ERR_LOG` | 0    |
| `verify.d`  | none (cwd = repo root) | stderr; failures → `$HARNESS_ERR_LOG` | 0    |

Scripts in `verify.d/` carry a `# Dimension: <name>` header so the file's role is greppable.

## State

State lives in `$HARNESS_STATE` (default: `${XDG_STATE_HOME:-~/.local/state}/harness`). Files:

- `last-errors.log` — written by `02-checks.sh` and `verify.d/tests.sh`, read by `context.d/errors.sh`.
- `last-tests.log` — full test output from the last `Stop`.
- `skip-tests` — touch to disable the test sensor (same pattern for `skip-drizzle`, `skip-e2e`, `skip-nuxt-dev`).

## Agent integration

The dispatcher names (`01-context.sh` / `02-checks.sh` / `03-verify.sh`) map to Claude Code's `UserPromptSubmit` / `PostToolUse` / `Stop` hook events but the scripts themselves are agent-agnostic. Wire them into whichever hook system your agent provides (Codex, etc.), or run them from CI / pre-commit / by hand.

`02-checks.sh` takes file paths from (in order): CLI args, JSON on stdin, or the `HARNESS_FILE_PATHS` env var (newline-separated). The JSON parser (requires `jq`) accepts any of these shapes:

```jsonc
{"file_paths": ["a.ts", "b.go"]}       // generic
{"files":      ["a.ts"]}               // generic
{"file_path":  "a.ts"}                 // generic, single
{"tool_input": {"file_path": "a.ts"}}  // Claude Code hook payload
{"tool_input": {"file_paths": [...]}}  // Claude Code multi
{"tool_input": {"edits": [{"file_path": "a.ts"}]}} // Claude Code edits
```

Agents that don't emit one of these shapes should set `HARNESS_FILE_PATHS` or pass paths as CLI args from their hook glue.

## Portability

Targets Linux + macOS with `bash` (3.2+) and `git`. The dispatchers, `checks.d/*`, `context.d/*`, and `verify.d/{tests,secrets,project-fitness}.sh` work anywhere those exist. The optional sensors degrade gracefully when their tooling is missing:

- `verify.d/tests.sh` uses `timeout` or `gtimeout` (macOS Homebrew `coreutils`); skips if neither is present.
- `verify.d/{nuxt-dev,e2e}.sh` and `templates/e2e.sh` use `setsid` for clean process-group teardown when present, otherwise fall back to `pkill -P` to take down child processes (macOS path).
- `verify.d/e2e.sh` also requires `docker` and `pnpm`; it self-skips otherwise.

## Test

    .harness/test/run.sh        # from a vendored project
    harness/test/run.sh         # from this source repo

Each module is also testable standalone, e.g.:

    .harness/checks.d/python.sh /tmp/foo.py
    .harness/verify.d/secrets.sh
    .harness/context.d/git.sh
