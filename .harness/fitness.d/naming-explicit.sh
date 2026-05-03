#!/usr/bin/env bash
# Fitness: flag cryptic 1-2 char names AND known abbreviations.
# Applies to both identifiers (let/const/var/function decls) and filenames.
# Loop indices (i, j, k, n, idx, _) are allowed in identifiers. Tune the lists below.
set -u
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

allow='^(i|j|k|n|idx|_|db|r|p|me|id|ok|to|by)$'
abbrev='^(btn|hdr|ftr|cls|img|pwd|usr|msg|nav|cfg|ctx|cmd|env)$'

# 1. Identifier check
id_hits="$(git grep -nE \
  '((let|const|var|final)[[:space:]]+(mut[[:space:]]+)?[a-z_]+[[:space:]]*[:=]|^[[:space:]]*[a-z_]+[[:space:]]*:=|(function|func|fn)[[:space:]]+[a-z_]+[[:space:]]*[(<])' -- \
  '*.go' '*.ts' '*.tsx' '*.js' '*.jsx' '*.vue' '*.dart' '*.rs' 2>/dev/null \
  | awk -v allow="$allow" -v abbrev="$abbrev" '
      {
        src = $0
        p = index(src, ":"); if (!p) next; src = substr(src, p+1)
        p = index(src, ":"); if (!p) next; src = substr(src, p+1)

        name = ""
        if (match(src, /(let|const|var|final)[[:space:]]+(mut[[:space:]]+)?[a-z_]+/)) {
          name = substr(src, RSTART, RLENGTH); sub(/.*[[:space:]]/, "", name)
        } else if (match(src, /(function|func|fn)[[:space:]]+[a-z_]+/)) {
          name = substr(src, RSTART, RLENGTH); sub(/.*[[:space:]]/, "", name)
        } else if (match(src, /^[[:space:]]*[a-z_]+[[:space:]]*:=/)) {
          name = substr(src, RSTART, RLENGTH)
          sub(/[[:space:]]*:=.*/, "", name); sub(/^[[:space:]]*/, "", name)
        } else next

        lower = tolower(name)
        if ((length(name) <= 2 && name !~ allow) || lower ~ abbrev) print
      }' || true)"

# 2. Filename check — splits CamelCase and kebab/snake into segments,
# flags any segment that is cryptic (≤ 2 chars, not allowlisted) or a known abbrev.
file_hits="$(git ls-files -- '*.go' '*.ts' '*.tsx' '*.js' '*.jsx' '*.vue' '*.dart' '*.rs' 2>/dev/null \
  | awk -v allow="$allow" -v abbrev="$abbrev" '
      {
        path = $0
        n = split(path, parts, "/")
        base = parts[n]
        sub(/\.[^.]+$/, "", base)
        if (base ~ /^[._]/) next

        # Split CamelCase by inserting "-" before each uppercase, then lowercase.
        gsub(/[A-Z]/, "-&", base)
        sub(/^-/, "", base)
        lower = tolower(base)

        n2 = split(lower, segs, /[-_.]/)
        for (i = 1; i <= n2; i++) {
          seg = segs[i]
          if (length(seg) == 0) continue
          if ((length(seg) <= 2 && seg !~ allow) || seg ~ abbrev) {
            print path "  (segment: " seg ")"
            break
          }
        }
      }' || true)"

rc=0
if [ -n "$id_hits" ]; then
  echo "Cryptic / abbreviated identifiers — prefer explicit (e.g. 'button' not 'btn'):" >&2
  printf '%s\n' "$id_hits" | head -n 10 >&2
  rc=1
fi
if [ -n "$file_hits" ]; then
  echo "Cryptic / abbreviated filenames — prefer explicit (e.g. 'Button.vue' not 'Btn.vue'):" >&2
  printf '%s\n' "$file_hits" | head -n 10 >&2
  rc=1
fi

exit $rc
