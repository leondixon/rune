# ADR-0002: PostgreSQL + Drizzle ORM

**Status:** Accepted

## Context

RUNE needs a relational store for users, sessions, topics (tree), attempts, and mastery FSRS state. The ORM must support TypeScript-first schema definition and migration generation without a separate daemon.

## Decision

Use PostgreSQL (>= 16) with `drizzle-orm` and `drizzle-kit`. Schema lives in `server/db/schema.ts`; local schema sync is done with `drizzle-kit push`. The connection string is injected via `NUXT_DATABASE_URL`, which `pnpm db:up` writes into `.env` for the current worktree.

## Consequences

- Schema changes are applied locally with `pnpm db:push` or implicitly through `pnpm db:up`; migration files are not generated or committed.
- `.harness/verify.d/drizzle.sh` checks that the schema serializes with drizzle-kit.
- The local dev DB is managed by `scripts/dev-db.sh` (Docker-based lifecycle, one logical database per git worktree).
