# ADR-0003: DB-backed cookie sessions (not JWT)

**Status:** Accepted

## Context

The app is a single Nuxt server talking to Postgres. Every authenticated request already touches the database, so the usual JWT win — avoiding a session lookup — doesn't apply. JWT's real payoff comes with multi-service or edge auth, stateless horizontal scaling, and cross-domain token passing. None of that is in scope here.

JWT would also add signing-key management, larger cookies, and clock-skew handling, with no offsetting benefit. Revocability is a minor bonus rather than the driver: if instant logout ever matters, sessions give it for free.

## Decision

Sessions are stored as rows in the `sessions` table (random 32-byte base64url token as PK). The token is set as an `httpOnly`, `sameSite: lax` cookie (`rune_session`). Every authenticated request does a single DB join to resolve the session to a user. Session TTL is 30 days.

## Consequences

- No key/secret rotation surface — the token is opaque random bytes.
- Logout is a hard delete of the session row, should it ever be needed.
- Horizontal scaling requires a shared Postgres instance (already assumed).
- Expired session pruning is not yet automated; stale rows accumulate until a future cleanup job is added.
