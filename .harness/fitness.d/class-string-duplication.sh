#!/usr/bin/env bash
# Fitness: flag long Tailwind/CSS class strings that appear in 2+ files.
# Tailwind heuristic (Adam Wathan, official docs): build with utilities, but
# extract once duplication emerges. A long class string in two files = a
# component, design token, or shared util waiting to be born.
set -u
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

THRESHOLD=50

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Pull all string literals declared as consts/lets/vars across vue/ts/tsx/js.
# Each line of $tmp is one candidate string content.
git grep -hE "(const|let|var)[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*['\"\`][^'\"\`]{${THRESHOLD},}['\"\`]" \
  -- '*.vue' '*.tsx' '*.ts' '*.jsx' '*.js' 2>/dev/null \
  | sed -E "s/.*['\"\`]([^'\"\`]+)['\"\`].*/\1/" \
  | sort -u > "$tmp"

violations=0
while IFS= read -r str; do
  [ -z "$str" ] && continue
  files="$(git grep -l -F -- "$str" '*.vue' '*.tsx' '*.ts' '*.jsx' '*.js' 2>/dev/null || true)"
  count="$(printf '%s\n' "$files" | grep -c . 2>/dev/null || echo 0)"
  if [ "$count" -ge 2 ]; then
    if [ "$violations" -eq 0 ]; then
      echo "Long class strings duplicated across 2+ files — extract to a component, theme token, or shared util:" >&2
    fi
    short="$(printf '%.70s' "$str")"
    echo "  (×$count) ${short}..." >&2
    printf '%s\n' "$files" | sed 's/^/    /' >&2
    violations=$((violations + 1))
  fi
done < "$tmp"

[ "$violations" -gt 0 ] && exit 1
exit 0
