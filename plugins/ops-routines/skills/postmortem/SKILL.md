---
name: postmortem
description: Write a blameless postmortem for an incident from alerts, metrics, errors and git history, and file follow-up tasks. Use after an outage or when asked to "write a postmortem". Reads .claude/repo.config.json.
---

# postmortem

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.createTask`, `ops.postmortem.dir`.

1. Establish the window (start, detection, mitigation, resolution) from the user or the triggering alert. Gather evidence only through the configured tools: `ops.tools.alerts`, `ops.tools.metrics`, `ops.tools.errors` (skip any not configured and say which), plus `git log` and the deploys in the window.
2. Write `<ops.postmortem.dir>/<YYYY-MM-DD>-<slug>.md`: summary, impact (who, how long, how much), timeline (UTC), root cause, what went well/badly, and action items. Blameless: name systems and decisions, not people.
3. File each action item as a task (`board.createTask`, `repoId`, label from `labels.types`) and list the ids in the document.
4. Commit the document. State anything you could not establish rather than inferring it.
