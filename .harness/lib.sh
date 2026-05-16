# Shared helpers for harness modules. Source, don't execute.

harness_state_dir() {
  echo "${HARNESS_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/harness}"
}

# Echo "timeout" or "gtimeout" if either is on PATH (macOS Homebrew coreutils
# ships `gtimeout`). Empty if neither — caller should skip.
harness_timeout_cmd() {
  if command -v timeout  >/dev/null 2>&1; then echo timeout
  elif command -v gtimeout >/dev/null 2>&1; then echo gtimeout
  fi
}

# Echo "setsid" if available, else empty. Used as `$(harness_setsid) cmd &`
# so the child gets its own session/group when possible (Linux). macOS lacks
# setsid; callers should also use `harness_kill_tree` to take down descendants.
harness_setsid() {
  command -v setsid >/dev/null 2>&1 && echo setsid
}

# Kill a backgrounded process and its descendants, portably.
# Uses negative pid (process-group kill) when setsid was available; otherwise
# walks children via pkill -P.
harness_kill_tree() {
  local pid="$1" sig="${2:-TERM}"
  if command -v setsid >/dev/null 2>&1; then
    kill "-${sig}" "-$pid" 2>/dev/null || true
  else
    command -v pkill >/dev/null 2>&1 && pkill "-${sig}" -P "$pid" 2>/dev/null || true
    kill "-${sig}" "$pid" 2>/dev/null || true
  fi
}

# Emit the project .harness directory if present in the current git repo.
# Returns nothing when outside a git repo or no .harness/ exists.
harness_module_bases() {
  local root
  if root="$(git rev-parse --show-toplevel 2>/dev/null)" && [ -d "$root/.harness" ]; then
    echo "$root/.harness"
  fi
}

# Walk up from a file or dir to the nearest project root marker.
harness_project_root() {
  local d="$1"
  [ -d "$d" ] || d="$(dirname "$d")"
  while [ "$d" != "/" ] && [ -n "$d" ]; do
    for m in package.json pyproject.toml go.mod Cargo.toml pubspec.yaml; do
      [ -f "$d/$m" ] && { echo "$d"; return 0; }
    done
    d="$(dirname "$d")"
  done
  return 1
}

# Run a command. On failure, print to stderr AND append to $HARNESS_ERR_LOG (if set).
# $1 = label (e.g. "lint:ruff"), rest = command.
harness_run() {
  local label="$1"; shift
  local out rc
  out="$("$@" 2>&1)"; rc=$?
  if [ $rc -ne 0 ]; then
    printf '[%s] FAIL\n%s\n' "$label" "$out" >&2
    [ -n "${HARNESS_ERR_LOG:-}" ] && printf '[%s] FAIL\n%s\n' "$label" "$out" >> "$HARNESS_ERR_LOG"
  elif [ -n "$out" ]; then
    printf '[%s]\n%s\n' "$label" "$out" >&2
  fi
  return 0
}
