#!/usr/bin/env bash
# The repo's gates: `check.sh lint|test|docs`. Each prints what failed and exits 1.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
bad() { echo "FAIL: $*" >&2; fail=1; }

lint() {
  # Every JSON file parses; every shell script is executable and shellcheck-clean.
  while IFS= read -r f; do
    jq empty "$f" 2>/dev/null || bad "$f is not valid JSON"
  done < <(git ls-files '*.json')
  scripts=$(git ls-files '*.sh')
  for f in $scripts; do
    [ -x "$f" ] || bad "$f is not executable"
  done
  if [ -n "$scripts" ]; then
    # shellcheck disable=SC2086 # one path per word; repo paths have no spaces
    shellcheck -S warning $scripts || bad "shellcheck"
  fi
}

test_() {
  # Every shell script parses, and the marketplace lists exactly the plugins on disk,
  # each with a plugin.json whose name is its directory.
  while IFS= read -r f; do
    bash -n "$f" || bad "$f does not parse"
  done < <(git ls-files '*.sh')
  listed=$(jq -r '.plugins[] | .name + " " + .source' .claude-plugin/marketplace.json)
  while read -r name source; do
    [ "$source" = "./plugins/$name" ] || bad "marketplace: $name has source $source"
    manifest="plugins/$name/.claude-plugin/plugin.json"
    [ -f "$manifest" ] || { bad "marketplace: $name has no $manifest"; continue; }
    [ "$(jq -r .name "$manifest")" = "$name" ] || bad "$manifest: name is not $name"
  done <<< "$listed"
  for dir in plugins/*/; do
    name=$(basename "$dir")
    grep -qx "$name ./plugins/$name" <<< "$listed" || bad "$name is not in marketplace.json"
  done
}

docs() {
  # Every SKILL.md opens with frontmatter naming its directory and describing it.
  while IFS= read -r f; do
    dir=$(basename "$(dirname "$f")")
    front=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$f")
    [ -n "$front" ] || { bad "$f has no frontmatter"; continue; }
    name=$(sed -n 's/^name:[[:space:]]*//p' <<< "$front")
    [ "$name" = "$dir" ] || bad "$f: name is '$name', not '$dir'"
    grep -q '^description:[[:space:]]*[^[:space:]]' <<< "$front" || bad "$f has no description"
  done < <(git ls-files '*SKILL.md')
}

case "${1:-}" in
  lint) lint ;;
  test) test_ ;;
  docs) docs ;;
  *) echo "usage: $0 lint|test|docs" >&2; exit 2 ;;
esac
exit "$fail"
