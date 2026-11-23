---
name: monitoring-sweep
description: Sweep alerts and metrics for anything firing or trending badly, and file a task or start a postmortem. Use for the monitoring routine or when asked to "check monitoring"/"any alerts?". Reads .claude/repo.config.json.
---

# monitoring-sweep

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.createTask`, `board.listTasks`, `ops.tools.alerts`, `ops.tools.metrics`.

1. Call `ops.tools.alerts` for firing and recently resolved alerts.
2. Run each query in `ops.sweepQueries` (list of `{name, query, threshold}`, optional) through `ops.tools.metrics`; flag any over its threshold. With no `sweepQueries`, only alerts are swept; say so.
3. Per finding, search `board.listTasks` for an existing task; comment on it, or file one (`board.createTask`, label `bug`). An outage or data loss (see `priorityRule`) is p0: also run `postmortem`.
4. Report: alerts firing, metrics flagged, tasks filed or commented, and an explicit "all clear" when nothing was found. Read-only against the monitoring systems: never silence or edit an alert.
