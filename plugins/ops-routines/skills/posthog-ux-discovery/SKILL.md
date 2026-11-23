---
name: posthog-ux-discovery
description: Mine product analytics for UX friction (drop-offs, rage clicks, dead flows) and file evidence-backed improvement tasks. Use for the UX routine or when asked to "find UX problems". Reads .claude/repo.config.json.
---

# posthog-ux-discovery

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.createTask`, `board.listTasks`, `ops.tools.analytics`.

1. Using `ops.tools.analytics`, pull funnels, drop-off steps, and error or rage-click events for the last 14 days. `ops.analytics.funnels` (optional list of names) narrows which funnels.
2. Rank findings by users affected times severity. Keep only those with a number behind them.
3. Dedupe against `board.listTasks`; file a task for each remaining top finding (`board.createTask`, label `feature` or `chore`, never `bug` unless it is broken) with the metric, the step, the date range and a suggested change.
4. Report findings filed and discarded. Do not change any analytics configuration.
