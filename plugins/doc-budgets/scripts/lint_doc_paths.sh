#!/usr/bin/env bash
# Fail when a doc names a repo path in backticks that does not exist.
# Checks files matched by the config's "pathCheck" globs (default: none).
# Only backticked tokens containing a "/" and no spaces, wildcards, URLs or
# placeholders (<>{}$) are treated as paths; entries in "pathIgnore" are skipped.
# Usage: lint_doc_paths.sh [--config FILE] [FILE...]
set -euo pipefail

config=".claude/doc-budgets.json"
files=()
while [ $# -gt 0 ]; do
  case "$1" in
    --config) config="$2"; shift 2 ;;
    *) files+=("$1"); shift ;;
  esac
done

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"
[ -f "$config" ] || { echo "doc-budgets: no config at $config" >&2; exit 0; }

globs=$(jq -r '.pathCheck[]? ' "$config")
[ -n "$globs" ] || exit 0
ignore=$(jq -r '.pathIgnore[]? ' "$config")

if [ ${#files[@]} -eq 0 ]; then
  while IFS= read -r f; do files+=("$f"); done < <(git ls-files 2>/dev/null || find . -type f | sed 's|^\./||')
fi

fail=0
for f in "${files[@]}"; do
  f=${f#"$root"/}
  [ -f "$f" ] || continue
  match=0
  while IFS= read -r g; do
    # shellcheck disable=SC2254
    case "$f" in $g) match=1; break ;; esac
  done <<< "$globs"
  [ $match -eq 1 ] || continue
  while IFS= read -r p; do
    case "$p" in *://*|*[\<\>\{\}\$\*\ ]*|/*|~*) continue ;; esac
    if [ -n "$ignore" ] && grep -qxF -- "$p" <<< "$ignore"; then continue; fi
    p=${p%%#*}
    [ -e "$p" ] || [ -e "$(dirname "$f")/$p" ] || { echo "doc-budgets: $f references missing path $p" >&2; fail=1; }
  done < <(grep -o '`[^`]*/[^`]*`' "$f" | tr -d '`' | sort -u)
done
exit $fail
