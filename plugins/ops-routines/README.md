# ops-routines

Generic versions of eight ops routine skills. No skill names a repo, app, path
or MCP tool: all of it comes from `.claude/repo.config.json`, the same file
`task-lifecycle` reads (this plugin adds the `ops` block). A skill whose keys
or tools are not configured says `repo.config.json: missing key "<path>"` and
stops.

| Skill | Needs (`ops.*`) | Does |
|---|---|---|
| `sentry-triage` | `tools.errors` | Group unresolved errors, file/comment one task per root cause. |
| `dependabot-triage` | `dependabot.prCommand` | Merge safe dependency PRs, task the rest. |
| `monitoring-sweep` | `tools.alerts`, `tools.metrics` | Sweep alerts and metrics, file tasks, escalate to postmortem. |
| `postmortem` | `postmortem.dir` | Blameless postmortem document plus action-item tasks. |
| `posthog-ux-discovery` | `tools.analytics` | Mine analytics for UX friction, file evidence-backed tasks. |
| `mobile-review` | `web.dir`, `web.viewport`, `web.startCommand` | Review the web UI at phone size. |
| `factory-retro` | board keys only | Find recurring job failures, file smallest fixes. |
| `red-pr-repair` | `redPr.listCommand`, `areas`, `prWaitCommand` | Reproduce and fix failing PRs. |

All also need `repoId` and the `board.*` tools they call (see the
`task-lifecycle` README). OpenCode: `npx skills add xdoubleu/skills -a opencode --skill sentry-triage --skill dependabot-triage --skill monitoring-sweep --skill postmortem --skill posthog-ux-discovery --skill mobile-review --skill factory-retro --skill red-pr-repair`.

## Added config keys

```json
"ops": {
  "tools": {
    "errors": "mcp__sentry__get_sentry_issues",
    "alerts": "mcp__grafana__get_grafana_alerts",
    "metrics": "mcp__grafana__prom_query",
    "analytics": "mcp__posthog__query"
  },
  "sweepQueries": [{ "name": "api 5xx rate", "query": "sum(rate(http_5xx[5m]))", "threshold": 1 }],
  "dependabot": { "prCommand": "gh pr list --author app/dependabot", "mergeCommand": "gh pr merge --squash" },
  "postmortem": { "dir": "docs/postmortems" },
  "analytics": { "funnels": ["signup"] },
  "web": { "dir": "web", "viewport": { "width": 390, "height": 844 }, "startCommand": "npm run dev", "pages": ["/"] },
  "redPr": { "listCommand": "scripts/red_prs.sh" },
  "routines": {
    "sentryTriage": "sentry-triage",
    "dependabotTriage": "dependabot-triage",
    "monitoringSweep": "monitoring-sweep",
    "posthogUxDiscovery": "posthog-ux-discovery",
    "mobileReview": "mobile-review",
    "factoryRetro": "factory-retro",
    "redPrRepair": "red-pr-repair"
  }
}
```

| Key | Required by | Meaning |
|---|---|---|
| `ops.tools.errors` / `alerts` / `metrics` / `analytics` | see table | Full MCP tool name for each signal. Unavailable in the session counts as not configured. |
| `ops.sweepQueries[]` | optional | Metric queries `monitoring-sweep` runs, flagged over `threshold`. |
| `ops.dependabot.prCommand` | `dependabot-triage` | Prints open dependency PRs (number, title, CI state). |
| `ops.dependabot.mergeCommand` | optional | Merges one PR; without it the skill only reports. |
| `ops.postmortem.dir` | `postmortem` | Where documents are written. |
| `ops.analytics.funnels` | optional | Funnel names to focus on. |
| `ops.web.dir`, `viewport`, `startCommand` | `mobile-review` | Web app dir, `{width, height}`, dev-server command. `pages` optional. |
| `ops.redPr.listCommand` | `red-pr-repair` | Prints PRs with failing checks (number, branch, check names). |
| `ops.routines.*` | the runner | Routine name per skill, so a routine schedule can point at it. |

Skills that need network (`dependabot-triage`, `red-pr-repair`) stop under
`FACTORY_JOB`; the rest only use the configured MCP tools.
