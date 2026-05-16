# ADR-0004: FSRS as the spaced-repetition algorithm

**Status:** Accepted

## Context

RUNE's core loop is interleaved spaced-repetition practice across a CS topic tree. The algorithm must produce a `dueAt` timestamp and update per-card memory state (stability, difficulty) after each attempt.

## Decision

Use FSRS (Free Spaced Repetition Scheduler). Per-user, per-topic state (`stability`, `difficulty`, `dueAt`, `reps`, `lapses`) is stored in the `mastery` table. Attempts are logged in the `attempts` table with a `grade` (0–3 scale). The due queue is served by `GET /api/learn/due`; new (unseen) topics by `GET /api/learn/new`.

## Consequences

- FSRS state is computed server-side; the client only submits a grade.
- Topics without a `mastery` row are considered new.
- The topic tree is seeded once at startup (`seed-domains.ts`) and extended by future schema changes -- never deleted at runtime.
