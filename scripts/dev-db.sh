#!/usr/bin/env bash
# Manage the local dev Postgres for rune. Idempotent.
# Usage: scripts/dev-db.sh [up|down|reset|push|logs|psql|status]
set -euo pipefail

NAME="rune-dev-db"
VOLUME="rune-dev-pgdata"
IMAGE="postgres:18.3-alpine"
PORT="${RUNE_DB_PORT:-5433}"
PASSWORD="${RUNE_DB_PASSWORD:-dev}"
DB_PREFIX="${RUNE_DB_PREFIX:-rune_}"

worktree_db_name() {
  local base sanitized max_base_len
  base="$(basename "$PWD")"
  sanitized="$(printf '%s' "$base" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9_]+/_/g; s/^_+//; s/_+$//')"
  sanitized="${sanitized:-worktree}"
  max_base_len=$((63 - ${#DB_PREFIX}))
  printf '%s%s' "$DB_PREFIX" "${sanitized:0:max_base_len}"
}

DB="${RUNE_DB_NAME:-$(worktree_db_name)}"
if [[ ! "$DB" =~ ^[a-z0-9_]+$ ]] || [ "${#DB}" -gt 63 ]; then
  echo "[dev-db] invalid database name: $DB" >&2
  echo "[dev-db] use lowercase letters, digits, underscores, and at most 63 characters" >&2
  exit 2
fi

URL="postgres://postgres:${PASSWORD}@127.0.0.1:${PORT}/${DB}"

cmd="${1:-up}"

container_state() {
  local state
  state="$(docker inspect -f '{{.State.Status}}' "$NAME" 2>/dev/null || true)"
  state="${state//[$'\t\r\n ']/}"
  echo "${state:-missing}"
}

psql_admin() {
  docker exec "$NAME" psql -U postgres -d postgres -v ON_ERROR_STOP=1 "$@"
}

database_exists() {
  [ "$(psql_admin -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB'")" = "1" ]
}

ensure_database() {
  if database_exists; then
    echo "[dev-db] database exists: $DB"
    return
  fi

  echo "[dev-db] creating database: $DB"
  docker exec "$NAME" createdb -U postgres "$DB"
}

write_env() {
  local tmp
  tmp="$(mktemp .env.XXXXXX)"

  if [ -f .env ]; then
    grep -v '^NUXT_DATABASE_URL=' .env > "$tmp" || true
  fi

  printf 'NUXT_DATABASE_URL=%s\n' "$URL" >> "$tmp"
  mv "$tmp" .env
  echo "[dev-db] wrote .env"
}

push_schema() {
  local push_url="${NUXT_DATABASE_URL:-$URL}"
  echo "[dev-db] pushing schema"
  NUXT_DATABASE_URL="$push_url" pnpm drizzle-kit push
}

up() {
  case "$(container_state)" in
    running)
      echo "[dev-db] already running on :$PORT"
      ;;
    exited|created|paused)
      echo "[dev-db] starting existing container"
      docker start "$NAME" >/dev/null
      ;;
    missing)
      echo "[dev-db] creating $NAME ($IMAGE) on :$PORT"
      docker run -d \
        --name "$NAME" \
        --restart unless-stopped \
        -v "$VOLUME:/var/lib/postgresql" \
        -e POSTGRES_PASSWORD="$PASSWORD" \
        -e POSTGRES_DB=postgres \
        -p "127.0.0.1:$PORT:5432" \
        "$IMAGE" >/dev/null
      ;;
    *)
      echo "[dev-db] unexpected state: $(container_state)" >&2
      exit 1
      ;;
  esac

  for _ in $(seq 1 30); do
    if docker exec "$NAME" pg_isready -U postgres -d postgres >/dev/null 2>&1; then
      echo "[dev-db] ready"
      ensure_database
      write_env
      push_schema
      echo "  NUXT_DATABASE_URL=$URL"
      return
    fi
    sleep 1
  done
  echo "[dev-db] FAIL: postgres did not become ready in 30s" >&2
  exit 1
}

down() {
  if [ "$(container_state)" = "missing" ]; then
    echo "[dev-db] not present"
    return
  fi
  docker stop "$NAME" >/dev/null
  echo "[dev-db] stopped"
}

reset() {
  local up_container_state
  up_container_state="$(container_state)"
  if [ "$up_container_state" = "missing" ]; then
    up
    return
  fi

  if [ "$up_container_state" != "running" ]; then
    docker start "$NAME" >/dev/null
  fi

  for _ in $(seq 1 30); do
    docker exec "$NAME" pg_isready -U postgres -d postgres >/dev/null 2>&1 && break
    sleep 1
  done

  if database_exists; then
    echo "[dev-db] dropping database: $DB"
    psql_admin -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB';" >/dev/null
    docker exec "$NAME" dropdb -U postgres "$DB"
  else
    echo "[dev-db] database not present: $DB"
  fi

  up
}

push() { push_schema; }
logs() { docker logs -f "$NAME"; }
psql() { docker exec -it "$NAME" psql -U postgres -d "$DB"; }
status() {
  echo "container: $(container_state)"
  echo "database:  $DB"
  echo "url:       $URL"
}

case "$cmd" in
  up|down|reset|push|logs|psql|status) "$cmd" ;;
  *) echo "usage: $0 {up|down|reset|push|logs|psql|status}" >&2; exit 2 ;;
esac
