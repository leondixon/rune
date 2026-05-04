# ADR-0001: Nuxt 4 + Tailwind v4 via Vite plugin

**Status:** Accepted

## Context

RUNE is a server-rendered SPA. We need a full-stack Vue framework (routing, SSR, server API routes) and a utility-first CSS approach. Nuxt 4 was in active development at project start; Tailwind v4 dropped the PostCSS pipeline in favour of a first-class Vite plugin.

## Decision

Use `nuxt` with `future.compatibilityVersion: 4` and `@tailwindcss/vite` as a Vite plugin instead of the PostCSS integration. Tailwind is imported as a single CSS layer in `app/assets/css/main.css`.

## Consequences

- Nuxt 4 file conventions apply (`app/` directory layout, `shared/` for isomorphic utilities).
- No `tailwind.config.js` — all design tokens are defined in CSS via `@theme {}`.
- `pnpm` is the package manager; do not use npm or yarn scripts.
