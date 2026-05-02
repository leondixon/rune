#!/usr/bin/env bash
# Dimension: schema-integrity
# If a Drizzle setup is present (server/db/schema.ts + drizzle.config.ts),
# verify two things:
#   1. `drizzle-kit check` passes (no migration collisions / snapshot drift)
#   2. The schema matches the latest snapshot — i.e. running generate against
#      a copy of drizzle/ would not produce a new migration file.
# Disable with `touch ~/.claude/state/skip-drizzle`.
set -u
_DIR="$(dirname "$(readlink -f "$0")")"
source "${HARNESS_LIB:-$_DIR/../lib.sh}"
STATE="$(harness_state_dir)"
[ -f "$STATE/skip-drizzle" ] && { echo "[verify:drizzle] skipped (skip-drizzle flag)" >&2; exit 0; }
[ -f "server/db/schema.ts" ] || exit 0
[ -f "drizzle.config.ts" ] || exit 0
command -v pnpm >/dev/null 2>&1 || { echo "[verify:drizzle] pnpm not found; skipping" >&2; exit 0; }

# 1. integrity check
if ! out="$(pnpm drizzle-kit check 2>&1)"; then
  echo "[verify:drizzle] FAIL (drizzle-kit check)" >&2
  echo "$out" >&2
  [ -n "${HARNESS_ERR_LOG:-}" ] && { printf '[verify:drizzle] FAIL (drizzle-kit check)\n%s\n' "$out" >> "$HARNESS_ERR_LOG"; }
  exit 0
fi

# 2. drift check: copy drizzle/ to a temp dir inside the project (drizzle-kit
# prefixes --out with './' so absolute paths break), run generate against it,
# fail if the SQL file count grows (= schema diverged from snapshot).
tmp="$(mktemp -d -p . .harness-drizzle-drift.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
cp -a drizzle/. "$tmp/"
before="$(find "$tmp" -maxdepth 1 -name '*.sql' | wc -l | tr -d ' ')"
pnpm drizzle-kit generate \
  --schema ./server/db/schema.ts \
  --dialect postgresql \
  --out "${tmp#./}" \
  --name harness_drift_check >/dev/null 2>&1 || true
after="$(find "$tmp" -maxdepth 1 -name '*.sql' | wc -l | tr -d ' ')"

if [ "$after" -gt "$before" ]; then
  new_sql="$(find "$tmp" -maxdepth 1 -name '*harness_drift_check*.sql' | head -1)"
  echo "[verify:drizzle] FAIL: schema.ts diverges from snapshot — run \`pnpm db:generate\` and commit the new migration" >&2
  [ -n "$new_sql" ] && { echo "--- generated SQL ---" >&2; cat "$new_sql" >&2; }
  [ -n "${HARNESS_ERR_LOG:-}" ] && printf '[verify:drizzle] FAIL: schema.ts diverges from snapshot — run pnpm db:generate\n' >> "$HARNESS_ERR_LOG"
  exit 0
fi

echo "[verify:drizzle] pass (check + drift)" >&2
exit 0
