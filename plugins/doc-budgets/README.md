# doc-budgets

Keeps docs short: per-file line budgets plus a dead-path check, run on
every edit (Claude Code hook, OpenCode port) and in CI.

## Config

A consuming repo needs only `.claude/doc-budgets.json`:

```json
{
  "budgets": [
    { "glob": "docs/adr/*.md", "maxLines": 60 },
    { "glob": "AGENTS.md", "maxLines": 120 },
    { "glob": "*.md", "maxLines": 200 }
  ],
  "pathCheck": ["AGENTS.md", "docs/*.md"],
  "pathIgnore": ["config/example.yml"]
}
```

- `budgets`: ordered; the first `glob` (shell `case` pattern, `*` crosses `/`)
  matching a repo-relative path sets its `maxLines`. Put specific globs first.
- `pathCheck`: files whose backticked repo paths (a token with a `/`, no
  spaces, wildcards, URLs or `<>{}$`) must exist.
- `pathIgnore`: exact tokens to skip.

No config means no checks.

## Writing standard

Docs and comments state what a reader cannot get from the code: the why,
the constraint, the decision. Cut restatement, changelog prose and
narration. When a file hits its budget, delete or move content rather
than raising the budget.

## Use

- **Claude Code**: `/plugin install doc-budgets@xdoubleu-skills`. The
  `PostToolUse` hook on `Edit|Write|MultiEdit` exits 2 with the violations.
- **OpenCode**: copy `opencode/doc-budgets.js` to `.opencode/plugins/` and
  set `DOC_BUDGETS_DIR` to the plugin directory.
- **CI at a pinned version** (needs `jq`, preinstalled on GitHub runners):

  ```
  git clone --depth 1 --branch doc-budgets-v1.0.0 https://github.com/xdoubleu/skills /tmp/skills
  /tmp/skills/plugins/doc-budgets/scripts/lint_docs.sh
  /tmp/skills/plugins/doc-budgets/scripts/lint_doc_paths.sh
  ```

  Releases are tags `doc-budgets-vX.Y.Z`.

## Tests

`bash plugins/doc-budgets/tests/run.sh`
