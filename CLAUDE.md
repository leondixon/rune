## Agent skills

### Issue tracker

Linear issues on the `Personal` team. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical defaults (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### Harness

This repo vendors `leondixon/harness` under `.harness/`. The vendored copy is project-owned and runs in soft mode: checks surface findings but do not block.

- Add upstream harness starters with `/sync`; do not overwrite existing `.harness/**/*.sh` files unless explicitly asked.
- Starter architecture rules live under `.harness/fitness.d/<group>/`; delete or `chmod -x` rules that do not fit this project.
- Keep project-specific sensors such as `verify.d/drizzle.sh`, `verify.d/e2e.sh`, and the Playwright templates unless the task is specifically to remove them.
- Run `.harness/test/run.sh` after changing harness mechanics.
