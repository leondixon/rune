#!/usr/bin/env bash
# Post-edit dispatcher. Routes a file to .harness/checks.d/<lang>.sh.
# Exits 0 silently when no project .harness/ exists.
# Accepts file paths via (in order): CLI args; agent hook JSON payload on stdin
# (Claude Code's `tool_input.file_path[s]` shape); or $HARNESS_FILE_PATHS env.
#
# Test:  ./02-checks.sh path/to/file.py
#        HARNESS_FILE_PATHS=/tmp/foo.py ./02-checks.sh < /dev/null
#        echo '{"tool_input":{"file_path":"/tmp/foo.py"}}' | ./02-checks.sh
set -u
DIR="$(cd "$(dirname "$0")" && pwd -P)"
source "${HARNESS_LIB:-$DIR/lib.sh}"
STATE="$(harness_state_dir)"; mkdir -p "$STATE"
ERR_LOG="$STATE/last-errors.log"
TMP_LOG="$ERR_LOG.tmp"; : > "$TMP_LOG"
export HARNESS_ERR_LOG="$TMP_LOG"

if [ "$#" -gt 0 ]; then
  paths="$(printf '%s\n' "$@")"
else
  paths=""
  if command -v jq >/dev/null 2>&1; then
    payload="$(cat)"
    paths="$(printf '%s' "$payload" | jq -r '
      [ .file_paths[]? // empty,
        .files[]?      // empty,
        .file_path?    // empty,
        .tool_input.file_path?            // empty,
        (.tool_input.edits[]?.file_path?  // empty),
        (.tool_input.file_paths[]?        // empty)
      ] | unique | .[]' 2>/dev/null)"
  fi
  [ -z "$paths" ] && paths="${HARNESS_FILE_PATHS:-}"
fi
[ -z "$paths" ] && exit 0

resolve_module() {
  local mod="$1"
  local base
  while IFS= read -r base; do
    [ -x "$base/checks.d/$mod.sh" ] && { echo "$base/checks.d/$mod.sh"; return 0; }
  done < <(harness_module_bases)
  return 1
}

dispatch() {
  local f="$1"
  [ -f "$f" ] || return 0
  case "$f" in *.g.dart|*.freezed.dart|*_pb.go|*.pb.go|*/generated/*) return 0 ;; esac
  local mod=""
  case "$f" in
    *.py)                              mod=python ;;
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) mod=node ;;
    *.go)                              mod=go ;;
    *.dart)                            mod=dart ;;
    *.rs)                              mod=rust ;;
    *) return 0 ;;
  esac
  local script base
  script="$(resolve_module "$mod")" || return 0
  base="$(dirname "$(dirname "$script")")"
  export HARNESS_LIB="$base/lib.sh"
  "$script" "$f"
}

while IFS= read -r p; do [ -n "$p" ] && dispatch "$p"; done <<< "$paths"

if [ -s "$TMP_LOG" ]; then mv "$TMP_LOG" "$ERR_LOG"; else rm -f "$TMP_LOG" "$ERR_LOG"; fi
exit 0
