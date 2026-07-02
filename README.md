# skills-repo

A versioned collection of [Cursor Agent Skills](https://cursor.com/docs/agent/skills) — reusable instructions that teach the AI how to perform specialized workflows across projects.

## Skills

### Published skills

These live at the repository root and can be copied into `~/.cursor/skills/` or referenced as project skills.

| Skill | Description |
|-------|-------------|
| [`dark-neon-graph-ux`](dark-neon-graph-ux/) | Builds dark neon observability dashboards and chart/graph UIs with the Mission Control visual system — semantic glow surfaces, Recharts dark theme, SVG radial gauges, and collapsible app shell. |

### Project skills

These live under `.cursor/skills/` and are specific to maintaining this repository. They are **not** synced from `~/.cursor/skills/`.

| Skill | Description |
|-------|-------------|
| [`sync-local-skills`](.cursor/skills/sync-local-skills/) | Mirrors personal skills from `~/.cursor/skills/` into this repo so they can be versioned and shared. |

## Repository layout

```
skills-repo/
├── README.md
├── <skill-name>/              # Published skills (synced from ~/.cursor/skills)
│   ├── SKILL.md               # Required — main skill instructions
│   ├── examples.md              # Optional — usage examples
│   └── reference.md             # Optional — detailed reference
└── .cursor/skills/
    └── sync-local-skills/     # Project-only maintenance skills
        ├── SKILL.md
        └── scripts/
            └── sync.sh
```

Only directories containing a `SKILL.md` file are treated as skills.

## Using skills in Cursor

### Personal (all projects)

Copy a published skill into your personal skills directory:

```bash
cp -R dark-neon-graph-ux ~/.cursor/skills/
```

Cursor loads skills from `~/.cursor/skills/` automatically.

### Project-scoped

Clone this repo into your workspace. Cursor picks up skills from `.cursor/skills/` when the project is open.

### Invoking a skill

Ask the agent to use a skill by name or describe the task it covers. For example:

- *"Use the dark-neon-graph-ux skill to build a metrics dashboard"*
- *"Sync my local skills"*

## Syncing local skills

When you develop or update skills in `~/.cursor/skills/`, sync them into this repo before committing:

```bash
bash .cursor/skills/sync-local-skills/scripts/sync.sh
```

The script will:

- **Add** new skills found locally
- **Update** skills that changed
- **Skip** skills already in sync
- **Remove** repo skills that no longer exist locally

Or ask the agent: *"sync my local skills"* — it will run the script and report the results.

## Adding a new skill

1. Create the skill in `~/.cursor/skills/<skill-name>/` with a `SKILL.md` file.
2. Run the sync script (or ask the agent to sync).
3. Review the changes with `git status`.
4. Commit and push.

### SKILL.md requirements

Every skill needs YAML frontmatter with at least `name` and `description`:

```markdown
---
name: my-skill
description: What the skill does and when the agent should use it.
---

# My Skill

## Instructions
...
```

See [Cursor's skill documentation](https://cursor.com/docs/agent/skills) for the full authoring guide.

## Contributing

1. Sync your local skills into the repo.
2. Commit with a clear message describing what was added or changed.
3. Open a pull request on [GitHub](https://github.com/PKrespo/skills-repo).
