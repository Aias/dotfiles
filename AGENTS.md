# Dotfiles

Personal dotfiles repo — shell config, git, editor settings, and AI agent configuration.

## Structure

- `agents/GLOBAL.md` — Global agent instructions (symlinked to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, Cursor rules)
- `agents/skills/` — Personal agent skills
- `agents/claude.settings.json` — Claude Code settings
- `.agents/skills/` — External skills (from skills.sh, gitignored)
- `install.sh` — Symlink installer (reads `links.txt`)
- `Makefile` — Common tasks (`make link`, `make check`, `make update-skills`)

## Conventions

- Edit config in this repo, not in `~/` — symlinks propagate changes automatically
- For agent config, dotfiles is source of truth; check symlink mapping before editing
- Skills: personal in `agents/skills/`, external in `.agents/skills/`
