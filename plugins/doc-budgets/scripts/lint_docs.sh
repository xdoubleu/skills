#!/usr/bin/env bash
# Enforce per-file line budgets from the doc-budgets config.
# Usage: lint_docs.sh [--config FILE] [FILE...]
# With no FILEs, checks every tracked file matched by a budget glob.
# Run from (or with CWD inside) the consuming repo. Exit 1 on any violation.
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

if [ ${#files[@]} -eq 0 ]; then
  while IFS= read -r f; do files+=("$f"); done < <(git ls-files 2>/dev/null || find . -type f | sed 's|^\./||')
fi

fail=0
for f in "${files[@]}"; do
  f=${f#"$root"/}
  [ -f "$f" ] || continue
  # First matching budget wins (most specific entries go first in the config).
  budget=""
  while IFS=$'\t' read -r glob max; do
    # shellcheck disable=SC2254
    case "$f" in $glob) budget=$max; break ;; esac
  done < <(jq -r '.budgets[] | [.glob, .maxLines] | @tsv' "$config")
  [ -n "$budget" ] || continue
  lines=$(wc -l < "$f" | tr -d ' ')
  if [ "$lines" -gt "$budget" ]; then
    echo "doc-budgets: $f has $lines lines, budget is $budget" >&2
    fail=1
  fi
done
exit $fail
