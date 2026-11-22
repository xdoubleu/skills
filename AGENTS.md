# AGENTS.md

A marketplace of Claude Code plugins (`plugins/<name>/`, listed in `.claude-plugin/marketplace.json`), also installable with `npx skills add xdoubleu/skills`. Skills must stay generic: anything repo-specific comes from the consuming repo's config.

## Gates

```bash
make lint   # JSON parses; shell scripts are executable and shellcheck-clean
make test   # shell scripts parse; marketplace.json lists exactly plugins/*, names match
make docs   # every SKILL.md has frontmatter whose name is its directory, plus a description
make check  # all three
```

CI runs them on every PR; `ci-pass` is the required check.

## Adding a plugin

Create `plugins/<name>/.claude-plugin/plugin.json` with `"name": "<name>"`, add it to `marketplace.json` with `"source": "./plugins/<name>"`, and run `make check`.
