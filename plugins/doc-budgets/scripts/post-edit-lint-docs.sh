#!/usr/bin/env bash
# Claude Code PostToolUse hook: run the doc checks on the edited file.
# Exit 2 feeds the violations back to the model; silent otherwise.
set -uo pipefail
dir=$(cd "$(dirname "$0")" && pwd)
file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0
[ -n "${CLAUDE_PROJECT_DIR:-}" ] && cd "$CLAUDE_PROJECT_DIR"
out=$({ "$dir/lint_docs.sh" "$file"; "$dir/lint_doc_paths.sh" "$file"; } 2>&1 >/dev/null)
if [ -n "$out" ]; then
  echo "$out" >&2
  exit 2
fi
