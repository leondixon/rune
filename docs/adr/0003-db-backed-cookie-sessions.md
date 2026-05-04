# ADR-0003: DB-backed cookie sessions (not JWT)

**Status:** Accepted

## Context

Auth tokens need to be revocable (logout must immediately invalidate). JWTs are stateless and cannot be revoked without a denylist, which adds the same DB round-trip that sessions already require.

## Decision

Sessions are stored as rows in the `sessions` table (random 32-byte base64url token as PK). The token is set as an `httpOnly`, `sameSite: lax` cookie (`rune_session`). Every authenticated request does a single DB join to resolve the session to a user. Session TTL is 30 days.

## Consequences

- Logout is a hard delete of the session row — no token leakage window.
- Horizontal scaling requires a shared Postgres instance (already assumed).
- Expired session pruning is not yet automated; stale rows accumulate until a future cleanup job is added.
