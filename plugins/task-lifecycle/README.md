# task-lifecycle

Generic start / finish / refine skills for repos whose tasks live on the
factory board (the `factory_*` MCP tools). No skill hard-codes a repo: a repo
with only `.claude/repo.config.json` can run `start-task` and `finish-task`.
There is no GitHub-issue mode.

| Skill | Wraps | Does |
|---|---|---|
| `start-task` | `task-worktree` | Read the task, move it to In progress, fresh worktree, plan. |
| `finish-task` | `ship-pr`, `session-retro` | Run the gates for the changed areas, ship, wait for CI, retro, move the task. |
| `refine-task` | `grilling` | Grill one task's scope, then write its body/labels/priority. |
| `refine-feature` | `grilling` | Same for a feature: slice it into tasks that each fit one job. |

Install `git-task-flow`, `session-retro` and `mattpocock-skills` (for
`grilling`) alongside this plugin. OpenCode: `npx skills add xdoubleu/skills -a opencode --skill start-task --skill finish-task --skill refine-task --skill refine-feature`.

## Config: `.claude/repo.config.json`

```json
{
  "repoId": "tools",
  "defaultBranch": "main",
  "board": {
    "getTask": "mcp__board__factory_get_task",
    "listTasks": "mcp__board__factory_list_tasks",
    "createTask": "mcp__board__factory_create_task",
    "updateTask": "mcp__board__factory_update_task",
    "moveTask": "mcp__board__factory_move_task",
    "commentTask": "mcp__board__factory_comment_task"
  },
  "labels": {
    "types": ["bug", "feature", "chore", "spike"],
    "scopes": ["api", "web"],
    "fallbackScope": "platform"
  },
  "priorityRule": "p0 = outage or data loss; p1 = blocks users or other tasks; p2 = everything else",
  "areas": [
    {
      "name": "api",
      "paths": ["api/**"],
      "gates": {
        "lint": "make -C api lint",
        "test": "make -C api test",
        "coverage": "make -C api test/cov/diff",
        "build": "make -C api build",
        "docs": "make docs/budget"
      }
    }
  ],
  "prWaitCommand": "scripts/pr_wait.sh",
  "factory": { "finishCommand": "make factory/finish" }
}
```

| Key | Required | Meaning |
|---|---|---|
| `repoId` | yes | Repo id passed to the board's `createTask`/`listTasks`. |
| `defaultBranch` | no | Default `main`. |
| `board.getTask`, `board.moveTask`, `board.commentTask` | yes | Board tool names the skills call. |
| `board.listTasks`, `board.createTask`, `board.updateTask` | for `refine-*` | Needed to search, slice and rewrite tasks. |
| `labels.types`, `labels.scopes` | yes | Allowed labels. `fallbackScope` is used when no scope fits. |
| `priorityRule` | yes | One line telling `refine-*` how to choose p0/p1/p2. |
| `areas[]` | yes | One entry per changed area: `name`, `paths` (globs), `gates`. |
| `areas[].gates` | yes | Command per gate: `lint`, `test`, `coverage`, `build`, `docs`. Omit a gate the area lacks; a listed gate always runs. |
| `prWaitCommand` | yes (outside factory jobs) | Command that blocks until the PR's CI is green or fails. |
| `factory.finishCommand` | no | Single command that runs every gate offline and prints the `Checks:` line. If absent, the skill runs each area's gates itself. |

A missing file, invalid JSON, or a missing required key stops the skill with
`repo.config.json: missing key "<dotted.path>"` (or `invalid JSON`). The skill
never guesses a default for a required key.

## Factory jobs

When `FACTORY_JOB` is set, `finish-task` runs the gates offline, never calls
`gh` or `prWaitCommand`, and does not push: it commits, writes the outcome to
`$FACTORY_OUTCOME_PATH` (first line = PR title) and ends it with a single
`Checks: lint=pass, test=pass, ...` line the runner parses.

## Spikes

A spike is settled interactively during refinement and never moves to Ready.
`refine-task` and `refine-feature` keep spikes in Backlog / Needs you.
