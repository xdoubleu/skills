---
name: sentry-triage
description: Triage unresolved production errors: group, rank, and file or update a board task per distinct root cause. Use for the error-triage routine or when asked to "triage Sentry"/"check errors". Reads .claude/repo.config.json.
---

# sentry-triage

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.createTask`, `board.listTasks`, `board.commentTask`, `ops.tools.errors`.

1. Call `ops.tools.errors` for unresolved issues from the last 24h (or since the previous run if the tool supports it). Group by root cause, not by event.
2. For each group, search `board.listTasks` (all statuses, query = the error title or culprit) so no duplicate is filed. If a task exists, comment the new count and first/last seen with `board.commentTask`; if it is done and the error recurs, say so in the comment and reopen it via `board.moveTask` when configured.
3. Otherwise file a task with `board.createTask` (`repoId`, label `bug`, a scope from `labels.scopes` when configured, priority by `priorityRule` when configured): title = the error, body = stack summary, affected release, event and user counts, a link to the issue.
4. Report: groups seen, tasks filed, tasks commented, noise ignored (with reason). Never resolve or ignore an error in the tracker yourself.
