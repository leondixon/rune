# ADR-0005: Migrate and seed on first DB connection

**Status:** Accepted

## Context

Running a separate migration step in CI/CD adds deployment surface. For a solo project with a single Postgres instance, coupling migration to startup simplifies the deploy path.

## Decision

`useDb()` (`server/utils/db.ts`) is a lazy singleton. On first call it: (1) runs Drizzle migrations against a short-lived single-connection client, (2) calls `seedDomains()` to idempotently upsert the topic tree, then (3) opens the normal connection pool. Subsequent calls return the cached pool.

## Consequences

- Startup is slower on first request after a new deployment (migration cost).
- Migration failures surface as a 500 on the first inbound request — acceptable for a dev-stage product.
- Revisit before multi-instance horizontal scaling: concurrent startup races could run migrations twice (Drizzle's migrator uses a lock, so this is safe but worth noting).
