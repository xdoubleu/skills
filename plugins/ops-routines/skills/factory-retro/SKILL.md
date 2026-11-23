---
name: factory-retro
description: Review recent factory jobs and tasks for recurring failures and file the smallest fixes. Use for the retro routine or when asked to "run the factory retro". Reads .claude/repo.config.json.
---

# factory-retro

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.listTasks`, `board.getTask`, `board.createTask`, `board.commentTask`.

1. List tasks updated since the last retro (`ops.routines.factoryRetro` run history if available, else 7 days) via `board.listTasks`; read each with `board.getTask`, including its jobs and outcomes.
2. Look for patterns, not one-offs: the same gate failing, tasks sent back by CI, "Blocked:" outcomes, timeouts, sandbox gaps, tasks that were too large.
3. For each pattern seen twice or more, search `board.listTasks` first; comment on an existing task, else file one (`board.createTask`, label `factory-retro`) naming the evidence task ids and the smallest fix (a doc line, a script, a gate, a Containerfile change).
4. Report patterns found and tasks filed. File nothing when nothing recurred.
