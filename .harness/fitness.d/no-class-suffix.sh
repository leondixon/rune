#!/usr/bin/env bash
# Fitness: flag class-string variables suffixed with Cls/Class/ClassName.
# In Vue/JSX/TS, the `:class` (or `className`) binding already says it's a
# class — `const navLinkCls = '...'` should be `const navLink = '...'`.
# Restricted to lowercase-leading identifiers to avoid catching real class
# definitions like `const MyClass = class { ... }`.
set -u
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

hits="$(git grep -nE \
  '\b(let|const|var)[[:space:]]+[a-z][a-zA-Z0-9_]*(Cls|Class|ClassName)[[:space:]]*=' \
  -- '*.vue' '*.ts' '*.tsx' '*.js' '*.jsx' 2>/dev/null || true)"

[ -z "$hits" ] && exit 0
echo "Class-string variables shouldn't carry a Cls/Class/ClassName suffix — :class binding already implies it. Drop the suffix:" >&2
printf '%s\n' "$hits" | head -n 20 >&2
exit 1
