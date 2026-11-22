---
name: dependabot-triage
description: Triage open dependency-update PRs: merge safe ones, fix or park the rest, and file tasks for major bumps. Use for the dependency routine or when asked to "triage dependabot". Reads .claude/repo.config.json.
---

# dependabot-triage

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `board.createTask`, `board.listTasks`, `ops.dependabot.prCommand`.

1. List open dependency-update PRs with `ops.dependabot.prCommand` (a command that prints them, one per line with number, title, CI state). Under `FACTORY_JOB` there is no network: report that and stop.
2. Classify each: patch/minor with green CI = safe; major, or red CI = needs work; same package bumped twice = superseded (close the older one).
3. Safe PRs: merge them one at a time (`ops.dependabot.mergeCommand` if set, otherwise tell the user which to merge), rebasing between merges since each changes the lockfile.
4. Needs work: search `board.listTasks` for an existing task, else file one (`board.createTask`, label `chore`) with the package, version range, changelog link and the failing check.
5. Report merged / closed / tasks filed / left alone.
