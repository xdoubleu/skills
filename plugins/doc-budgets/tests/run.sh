#!/usr/bin/env bash
# Tests for the doc-budgets scripts. Usage: bash tests/run.sh
set -uo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp" && git init -q . && mkdir -p .claude docs
cat > .claude/doc-budgets.json <<'J'
{"budgets":[{"glob":"docs/big-*.md","maxLines":10},{"glob":"*.md","maxLines":3}],
 "pathCheck":["*.md"],"pathIgnore":["ignored/path.txt"]}
J
pass=0; failn=0
check() { # name expected-status cmd...
  local n=$1 want=$2; shift 2
  "$@" >/dev/null 2>&1; local got=$?
  if [ "$got" = "$want" ]; then pass=$((pass+1)); else failn=$((failn+1)); echo "FAIL $n: want $want got $got"; fi
}
printf 'a\nb\nc\n' > ok.md
printf 'a\nb\nc\nd\n' > long.md
seq 1 8 > docs/big-x.md
seq 1 11 > docs/big-y.md
check within-budget 0 "$here/scripts/lint_docs.sh" ok.md
check over-budget 1 "$here/scripts/lint_docs.sh" long.md
check first-match-wins 0 "$here/scripts/lint_docs.sh" docs/big-x.md
check first-match-over 1 "$here/scripts/lint_docs.sh" docs/big-y.md
check unmatched-ignored 0 "$here/scripts/lint_docs.sh" .claude/doc-budgets.json
check no-config 0 "$here/scripts/lint_docs.sh" --config nope.json ok.md
printf 'see `docs/big-x.md`\n' > refs.md
check path-exists 0 "$here/scripts/lint_doc_paths.sh" refs.md
printf 'see `docs/missing.md`\n' > refs.md
check path-missing 1 "$here/scripts/lint_doc_paths.sh" refs.md
printf 'see `ignored/path.txt` `http://x/y` `a/<b>`\n' > refs.md
check path-ignored 0 "$here/scripts/lint_doc_paths.sh" refs.md
hook() { echo "{\"tool_input\":{\"file_path\":\"$1\"}}" | CLAUDE_PROJECT_DIR="$tmp" "$here/scripts/post-edit-lint-docs.sh"; }
check hook-ok 0 hook "$tmp/ok.md"
check hook-over 2 hook "$tmp/long.md"
check hook-no-path 0 bash -c "echo '{}' | '$here/scripts/post-edit-lint-docs.sh'"
echo "doc-budgets tests: $pass passed, $failn failed"
[ "$failn" -eq 0 ]
