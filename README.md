# RUNE

AI-guided self-learning for developers. Feynman technique, interleaved practice, gamified loop.

Stack: Nuxt 4 · Drizzle ORM · PostgreSQL · Tailwind v4 · Zod.

## Quick start

```bash
pnpm install
pnpm db:up                                                # local Postgres in Docker
echo 'NUXT_DATABASE_URL=postgres://postgres:dev@127.0.0.1:5433/rune' > .env
pnpm dev                                                  # http://localhost:3000
```

Migrations and the 19 seeded top-level domains run automatically on the first
DB request — no separate migrate/seed step.

`pnpm db:up` is idempotent (no-op if already running). The container has
`--restart unless-stopped` so it survives reboots, and the named volume
`rune-dev-pgdata` keeps your accounts across image upgrades.

## Scripts

| Command | What it does |
|---|---|
| `pnpm dev` | Nuxt dev server |
| `pnpm build` / `pnpm preview` | production build / preview |
| `pnpm verify` | lint + typecheck + fitness checks (run before pushing) |
| `pnpm lint:fix` | auto-fix lint |
| `pnpm db:up` / `db:down` / `db:reset` / `db:status` | dev Postgres lifecycle |
| `pnpm db:generate` | create a new Drizzle migration after editing `server/db/schema.ts` |
| `bash .harness/verify.d/e2e.sh` | full e2e (boots an isolated DB; doesn't touch dev) |

`scripts/dev-db.sh` also exposes `logs` and `psql` for debugging:

```bash
scripts/dev-db.sh logs    # tail postgres logs
scripts/dev-db.sh psql    # interactive psql shell into the running container
```

Override defaults via env: `RUNE_DB_PORT`, `RUNE_DB_PASSWORD`, `RUNE_DB_NAME`.

## E2E testing

`.harness/verify.d/e2e.sh` boots a throwaway Postgres 18 container on a
random port, runs `pnpm dev` on a random port, runs every Playwright spec
under `.harness/playwright/`, and tears it all down. Screenshots land in
`.harness-state/last-e2e/<spec>/`. The `auth-flow` spec validates
register → cookie → `/api/auth/me` → logout → login → `/api/learn/new`.

First-time setup:

```bash
pnpm exec playwright install chromium
```

Run it:

```bash
bash .harness/verify.d/e2e.sh
```

Add a new spec by dropping a file at `.harness/playwright/<feature>.spec.ts`
— it'll be picked up automatically. The orchestrator stays generic.

Soft-fails (skips with a log line) when Docker, Playwright browsers, or
`nuxt.config.ts` are missing. Disable entirely with
`touch ~/.claude/state/skip-e2e`.

## Project layout

```
app/                Vue SFCs, composables, plugins, pages
server/api/         Nitro route handlers (auth/, learn/)
server/db/          Drizzle schema + seed data
server/utils/       db, password, session helpers
shared/utils/       Zod schemas + shared types
drizzle/            generated migrations + snapshots
.harness/           verify.d, fitness.d, playwright specs
scripts/            dev tooling (dev-db.sh)
```
