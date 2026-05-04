#!/usr/bin/env bash
# Manage the local dev Postgres for rune. Idempotent.
# Usage: scripts/dev-db.sh [up|down|reset|logs|psql|status]
set -euo pipefail

NAME="rune-dev-db"
VOLUME="rune-dev-pgdata"
IMAGE="postgres:18.3-alpine"
PORT="${RUNE_DB_PORT:-5433}"
PASSWORD="${RUNE_DB_PASSWORD:-dev}"
DB="${RUNE_DB_NAME:-rune}"
URL="postgres://postgres:${PASSWORD}@127.0.0.1:${PORT}/${DB}"

cmd="${1:-up}"

container_state() {
  local state
  state="$(docker inspect -f '{{.State.Status}}' "$NAME" 2>/dev/null || true)"
  state="${state//[$'\t\r\n ']/}"
  echo "${state:-missing}"
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
        -e POSTGRES_DB="$DB" \
        -p "127.0.0.1:$PORT:5432" \
        "$IMAGE" >/dev/null
      ;;
    *)
      echo "[dev-db] unexpected state: $(container_state)" >&2
      exit 1
      ;;
  esac

  for _ in $(seq 1 30); do
    if docker exec "$NAME" pg_isready -U postgres -d "$DB" >/dev/null 2>&1; then
      echo "[dev-db] ready"
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
  if [ "$(container_state)" != "missing" ]; then
    docker rm -f "$NAME" >/dev/null
  fi
  docker volume rm "$VOLUME" >/dev/null 2>&1 || true
  echo "[dev-db] wiped — run \`up\` to recreate"
}

logs() { docker logs -f "$NAME"; }
psql() { docker exec -it "$NAME" psql -U postgres -d "$DB"; }
status() {
  echo "container: $(container_state)"
  echo "url:       $URL"
}

case "$cmd" in
  up|down|reset|logs|psql|status) "$cmd" ;;
  *) echo "usage: $0 {up|down|reset|logs|psql|status}" >&2; exit 2 ;;
esac
