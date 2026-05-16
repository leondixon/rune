# ADR-0005: Seed on first DB connection

**Status:** Superseded by per-worktree `drizzle-kit push` for schema sync

## Context

Running a separate migration step in CI/CD adds deployment surface. Earlier versions coupled migration to startup. The project now uses `drizzle-kit push` during `pnpm db:up` / `pnpm db:push` so each worktree's database is provisioned before Nuxt starts.

## Decision

`useDb()` (`server/utils/db.ts`) is a lazy singleton. On first call it opens the normal connection pool, calls `seedDomains()` to idempotently upsert the topic tree, and returns the cached pool. Schema changes are pushed before runtime with `drizzle-kit push`.

## Consequences

- Startup no longer depends on committed migration files.
- A missing schema surfaces as a DB error on first request; run `pnpm db:up` or `pnpm db:push` before `pnpm dev`.
- Revisit before production deployment; `drizzle-kit push` is a dev-stage workflow, not a migration history.
