# ADR-0002: PostgreSQL + Drizzle ORM

**Status:** Accepted

## Context

RUNE needs a relational store for users, sessions, topics (tree), attempts, and mastery FSRS state. The ORM must support TypeScript-first schema definition and migration generation without a separate daemon.

## Decision

Use PostgreSQL (≥ 16) with `drizzle-orm` and `drizzle-kit`. Schema lives in `server/db/schema.ts`; migrations are generated into `drizzle/` and applied at runtime. The connection string is injected via `NUXT_DATABASE_URL`.

## Consequences

- Schema changes require `pnpm drizzle-kit generate` followed by committing the migration file.
- `.harness/verify.d/drizzle.sh` detects schema-vs-migration drift in CI.
- The local dev DB is managed by `scripts/dev-db.sh` (Docker-based lifecycle).
