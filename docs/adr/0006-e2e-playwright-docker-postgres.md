# ADR-0006: E2E tests via Playwright against an isolated Docker Postgres

**Status:** Accepted

## Context

E2E tests need a real Postgres instance (not mocked) to exercise the full auth and FSRS stack. The harness must be runnable locally and in CI without a persistent DB.

## Decision

`.harness/verify.d/e2e.sh` orchestrates a full E2E run: boots a throwaway `postgres:18.3` container, starts `pnpm dev`, waits for readiness, runs all `*.spec.ts` files under `.harness/playwright/`, then tears down container and dev server. Each spec runs against the live Nuxt server. Screenshots land in `~/.claude/state/last-e2e/<spec>/`.

## Consequences

- Docker must be available in the environment; CI must have a Docker daemon.
- Each E2E run is hermetic — no shared DB state between runs.
- New features get a spec alongside the implementation; the orchestrator stays generic.
- E2e state (`.harness-state/`, `test-results/`) is gitignored; only specs and the orchestrator are committed.
