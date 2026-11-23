---
name: mobile-review
description: Review the web UI at phone viewport sizes: screenshot key pages, find layout and touch problems, and file or fix them. Use for the mobile routine or when asked to "review mobile". Reads .claude/repo.config.json.
---

# mobile-review

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.createTask`, `ops.web.dir`, `ops.web.viewport`, `ops.web.startCommand`.

1. Start the app with `ops.web.startCommand` (from `ops.web.dir`) and open it in a headless browser at `ops.web.viewport` (`{width, height}`). `ops.web.pages` (optional) lists routes; otherwise discover them from the router in `ops.web.dir`. If no browser tool is available, say so and stop.
2. For each page, check horizontal overflow, text clipped or under 12px, tap targets under 44px, fixed elements covering content, and unreadable tables.
3. Group findings per page. Fix trivial CSS issues in `ops.web.dir` when the task is a PR job; otherwise file one task per page (`board.createTask`, label `bug`, scope from `labels.scopes` for the web area) with screenshot path and the failing check.
4. Stop the app. Report pages reviewed, findings, fixes.
