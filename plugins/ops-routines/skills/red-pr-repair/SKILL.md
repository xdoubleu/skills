---
name: red-pr-repair
description: Find open PRs with failing CI and repair them: reproduce the failure, fix, and push. Use for the red-PR routine or when asked to "fix red PRs". Reads .claude/repo.config.json.
---

# red-pr-repair

## Config

Read `.claude/repo.config.json` at the repo root first (schema: this plugin's README). If the file is missing, is not valid JSON, or lacks a key this skill needs, stop and say exactly `repo.config.json: missing key "<dotted.path>"` (or `repo.config.json: invalid JSON` / `not found`). Never guess a default or a tool name. A configured tool that is not available in this session counts as not configured: say so and stop, with no partial run. Required keys here: `repoId`, `defaultBranch`, `areas`, `prWaitCommand`, `ops.redPr.listCommand`.

1. List PRs with failing checks using `ops.redPr.listCommand` (prints number, branch, failing check names). Under `FACTORY_JOB` there is no network: report that and stop.
2. For each, in its own worktree on the PR branch: read the failing check log, map the failing check to an area in `areas[].gates`, and reproduce it locally with that gate command.
3. Fix the smallest cause. If the branch is behind `defaultBranch` and the failure is a conflict or stale lockfile, rebase. Re-run the gate until green, commit, push, then block on `prWaitCommand`.
4. Never touch a PR whose failure you cannot reproduce or whose fix needs a decision: comment with the evidence instead. Never force-push to the default branch. Report fixed / commented / skipped.
