#!/usr/bin/env bash
# Dimension: schema-integrity
# If a Drizzle setup is present (server/db/schema.ts + drizzle.config.ts),
# verify the schema can be serialized by drizzle-kit. This project uses
# `drizzle-kit push` for local schema sync, not generated migrations.
# Disable with `touch <HARNESS_STATE>/skip-drizzle` (default: ~/.local/state/harness/skip-drizzle).
set -u
_DIR="$(cd "$(dirname "$0")" && pwd -P)"
source "${HARNESS_LIB:-$_DIR/../lib.sh}"
STATE="$(harness_state_dir)"
[ -f "$STATE/skip-drizzle" ] && { echo "[verify:drizzle] skipped (skip-drizzle flag)" >&2; exit 0; }
[ -f "server/db/schema.ts" ] || exit 0
command -v pnpm >/dev/null 2>&1 || { echo "[verify:drizzle] pnpm not found; skipping" >&2; exit 0; }

# Generate into a temp dir to validate schema syntax without committing
# migration files or requiring a live database.
tmp="$(mktemp -d "./.harness-drizzle-generate.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

if ! out="$(pnpm drizzle-kit generate \
  --schema ./server/db/schema.ts \
  --dialect postgresql \
  --out "${tmp#./}" \
  --name harness_schema_check 2>&1)"; then
  echo "[verify:drizzle] FAIL (drizzle-kit generate)" >&2
  echo "$out" >&2
  [ -n "${HARNESS_ERR_LOG:-}" ] && { printf '[verify:drizzle] FAIL (drizzle-kit generate)\n%s\n' "$out" >> "$HARNESS_ERR_LOG"; }
  exit 0
fi

echo "[verify:drizzle] pass (schema serializes)" >&2
exit 0
