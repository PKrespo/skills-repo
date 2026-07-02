---
name: sync-local-skills
description: >-
  Syncs Cursor agent skills from ~/.cursor/skills into this repository root.
  Use when the user asks to sync, copy, update, refresh, or mirror local skills
  into this project.
---

# Sync Local Skills

Copy personal skills from `~/.cursor/skills/` into this repo so they can be versioned and shared.

## Layout

| Path | Role |
|------|------|
| `~/.cursor/skills/<name>/` | Local source (personal skills) |
| `<repo-root>/<name>/` | Synced destination (published skills) |
| `.cursor/skills/sync-local-skills/` | This maintenance skill (not synced) |

Only directories containing `SKILL.md` are treated as skills.

## Workflow

1. Run the sync script from the repo root:

```bash
bash .cursor/skills/sync-local-skills/scripts/sync.sh
```

2. Read the script output and report:
   - **added** — new skills copied into the repo
   - **updated** — existing skills overwritten with local changes
   - **unchanged** — already in sync
   - **removed** — repo skills deleted because they no longer exist locally

3. Run `git status` and summarize untracked or modified files.

4. Do **not** commit unless the user explicitly asks.

## Sync rules

- Copy each skill directory from `~/.cursor/skills/<name>/` to `<repo-root>/<name>/`
- Use `rsync -a --delete` so the repo mirror matches the local copy
- Skip hidden directories (e.g. `.DS_Store`)
- Remove repo skill directories that were deleted from `~/.cursor/skills`
- Never sync into or modify `.cursor/skills/` (project-only skills stay here)

## Examples

**User:** "Sync my local skills into this repo"

```bash
bash .cursor/skills/sync-local-skills/scripts/sync.sh
git status
```

**User:** "Copy skills from ~/.cursor/skills to this project"

Same workflow — run the script, report results, show `git status`.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `source directory not found` | Create `~/.cursor/skills/` or add skills there first |
| `rsync: command not found` | Install rsync (macOS: `xcode-select --install`) |
| Skill missing after sync | Confirm the folder contains `SKILL.md` |
| Wrong files removed | Restore from git; only skill dirs with `SKILL.md` at repo root are removed |
