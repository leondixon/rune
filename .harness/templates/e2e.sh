#!/usr/bin/env bash
# Dimension: behaviour
# Boots an isolated Postgres in Docker, boots `pnpm dev` against it, then runs
# every Playwright spec under .harness/playwright/. Specs assert behaviour and
# capture screenshots into <project>/.harness-state/last-e2e/<spec>/. Soft-fail:
# never returns non-zero — failures appended to $HARNESS_ERR_LOG.
# Disable with `touch ~/.claude/state/skip-e2e`.
set -u
_DIR="$(dirname "$(readlink -f "$0")")"
source "${HARNESS_LIB:-$_DIR/../lib.sh}"
GLOBAL_STATE="$(harness_state_dir)"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

PROJECT_ROOT="$ROOT"
PLAYWRIGHT_DIR="$PROJECT_ROOT/.harness/playwright"
PROJECT_STATE="$PROJECT_ROOT/.harness-state"
SCREENSHOT_DIR="$PROJECT_STATE/last-e2e"
SERVER_LOG="$PROJECT_STATE/last-e2e-server.log"
PG_LOG="$PROJECT_STATE/last-e2e-postgres.log"
PW_LOG="$PROJECT_STATE/last-e2e-playwright.log"
PG_NAME="rune-harness-pg-$$"

[ -f "$GLOBAL_STATE/skip-e2e" ] && { echo "[verify:e2e] skipped (skip-e2e flag)" >&2; exit 0; }
[ -f "$PROJECT_ROOT/nuxt.config.ts" ] || exit 0
ls "$PLAYWRIGHT_DIR"/*.spec.ts >/dev/null 2>&1 || exit 0

for tool in pnpm setsid docker curl; do
  command -v "$tool" >/dev/null 2>&1 || { echo "[verify:e2e] skipped ($tool not found)" >&2; exit 0; }
done

docker info >/dev/null 2>&1 || { echo "[verify:e2e] skipped (docker daemon not reachable)" >&2; exit 0; }

cd "$PROJECT_ROOT"

if ! pnpm exec playwright --version >/dev/null 2>&1; then
  echo "[verify:e2e] skipped (run: pnpm install && pnpm exec playwright install chromium)" >&2
  exit 0
fi

pw_cache="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
if ! ls "$pw_cache"/chromium-* >/dev/null 2>&1; then
  echo "[verify:e2e] skipped (run: pnpm exec playwright install chromium)" >&2
  exit 0
fi

mkdir -p "$SCREENSHOT_DIR"
rm -rf "$SCREENSHOT_DIR"/* 2>/dev/null || true
: > "$SERVER_LOG"
: > "$PG_LOG"
: > "$PW_LOG"

# Find a free TCP port in the given range. Echoes the port; returns 1 if none.
pick_port() {
  local start="$1" end="$2" port
  for port in $(seq "$start" "$end"); do
    (exec 9<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null && { exec 9<&-; exec 9>&-; continue; }
    echo "$port"; return 0
  done
  return 1
}

PG_PORT="$(pick_port 54320 54399)" || { echo "[verify:e2e] FAIL: no free port for postgres" >&2; exit 0; }
APP_PORT="$(pick_port 3100 3199)" || { echo "[verify:e2e] FAIL: no free port for dev server" >&2; exit 0; }

server_pid=""
fail() {
  local msg="$1"
  echo "[verify:e2e] FAIL: $msg" >&2
  [ -n "${HARNESS_ERR_LOG:-}" ] && printf '[verify:e2e] FAIL: %s\n' "$msg" >> "$HARNESS_ERR_LOG"
}

cleanup() {
  if [ -n "$server_pid" ] && kill -0 "$server_pid" 2>/dev/null; then
    kill -TERM "-$server_pid" 2>/dev/null || true
    sleep 1
    kill -KILL "-$server_pid" 2>/dev/null || true
  fi
  docker rm -f "$PG_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# 1. Boot Postgres
if ! docker run -d --rm \
      --name "$PG_NAME" \
      -e POSTGRES_PASSWORD=harness \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_DB=rune \
      -p "127.0.0.1:$PG_PORT:5432" \
      postgres:18.3-alpine >"$PG_LOG" 2>&1; then
  fail "docker run postgres:18.3-alpine"
  tail -n 20 "$PG_LOG" >&2
  [ -n "${HARNESS_ERR_LOG:-}" ] && tail -n 20 "$PG_LOG" >> "$HARNESS_ERR_LOG"
  exit 0
fi

pg_ready=0
for _ in $(seq 1 30); do
  if docker exec "$PG_NAME" pg_isready -U postgres -d rune >/dev/null 2>&1; then
    pg_ready=1; break
  fi
  sleep 1
done
[ "$pg_ready" = 1 ] || { fail "postgres did not become ready in 30s"; exit 0; }

DATABASE_URL="postgres://postgres:harness@127.0.0.1:$PG_PORT/rune"

# 2. Boot dev server
PORT="$APP_PORT" NUXT_PORT="$APP_PORT" \
NUXT_DATABASE_URL="$DATABASE_URL" \
  setsid pnpm dev >"$SERVER_LOG" 2>&1 < /dev/null &
server_pid=$!

WAIT="${NUXT_DEV_WAIT_SECS:-60}"
ready=0
for _ in $(seq 1 "$WAIT"); do
  kill -0 "$server_pid" 2>/dev/null || break
  if grep -qE 'Local: +https?://|Nuxt .* ready|Listening on https?://' "$SERVER_LOG" 2>/dev/null; then
    ready=1; break
  fi
  sleep 1
done
if [ "$ready" != 1 ]; then
  fail "pnpm dev did not signal ready in ${WAIT}s — tail of $SERVER_LOG:"
  tail -n 20 "$SERVER_LOG" >&2
  [ -n "${HARNESS_ERR_LOG:-}" ] && tail -n 20 "$SERVER_LOG" >> "$HARNESS_ERR_LOG"
  exit 0
fi

# 3. Run all Playwright specs
spec_count="$(ls "$PLAYWRIGHT_DIR"/*.spec.ts | wc -l | tr -d ' ')"

if BASE_URL="http://localhost:$APP_PORT" \
   SCREENSHOT_DIR="$SCREENSHOT_DIR" \
   pnpm exec playwright test --config "$PLAYWRIGHT_DIR/playwright.config.ts" \
       >"$PW_LOG" 2>&1; then
  echo "[verify:e2e] pass ($spec_count spec(s), screenshots in $SCREENSHOT_DIR/)" >&2
else
  fail "playwright test failed — tail of $PW_LOG:"
  tail -n 40 "$PW_LOG" >&2
  [ -n "${HARNESS_ERR_LOG:-}" ] && tail -n 40 "$PW_LOG" >> "$HARNESS_ERR_LOG"
fi

exit 0
