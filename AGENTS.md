# Dotfiles

Personal dotfiles repo — shell config, git, editor settings, and AI agent configuration.

## Structure

- `agents/GLOBAL.md` — Global agent instructions + compiled `@>` skill index (symlinked to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, Cursor rules). Conductor-specific detail lives in the `/conductor` skill; GLOBAL keeps a short pointer and compiled reminders.
- `agents/skills/` — Personal agent skills (tracked)
- `agents/skills.local/` — Machine-specific skills (gitignored)
- `agents/compile-global.ts` — Compiles `@>` annotations from skills into GLOBAL.md's dense index
- `agents/.build/skills/` — Cleaned skill files (annotations stripped), gitignored
- `agents/claude.settings.json` — Claude Code settings
- `agents/codex.config.toml` — Codex settings
- `agents/hooks/` — Claude Code hooks (e.g. PR guideline checks)
- `.agents/skills/` — External skills (from skills.sh)
- `skills-lock.json` — External skill version tracking
- `install.sh` — Symlink installer (reads `links.txt`), syncs skills, discovers MCP servers
- `setup.sh` — Repo-local setup (git hooks)
- `git-hooks/pre-commit` — Auto-compiles GLOBAL.md annotations before each commit
- `local/` — Templates for machine-specific env vars and secrets (not tracked)
- `Makefile` — Common tasks (`make install`, `make link`, `make check`, `make compile`, `make setup`, `make update`, `make update-skills`). Shell alias **`dotup`** (in `zsh/.zshrc`) runs `make update` from `~/Code/dotfiles`. There's also `dotcheck` and `dotlink` for checking for config drift and linking the config to `~/`.

## Conventions

- Edit config in this repo, not in `~/` — symlinks propagate changes automatically
- This repo is public. Never commit private information, credentials, machine-specific secrets, personal data, or internal-only notes here, even temporarily. Use ignored local files or tracked templates instead.
- For agent config, dotfiles is source of truth; check symlink mapping before editing
- Skills: personal in `agents/skills/`, machine-specific in `agents/skills.local/` (gitignored), external in `.agents/skills/`
- Skill deploy **does not prune** `~/.claude/skills/` or `~/.codex/skills/`: removing or renaming a skill in the repo leaves old directories in home until you delete them (see README _Managing Skills_ / `/skills-manager`)

## Annotation Compilation

Skills with `global_category` in their SKILL.md frontmatter contribute to GLOBAL.md's compiled block via `<!-- @> summary -->` annotations. The compiler (`bun agents/compile-global.ts` or `make compile`) extracts these into a dense pipe-delimited index that's always in context.

- Annotations: `<!-- @> summary text -->` above the relevant section in any `.md` file within a skill
- Output format: `Category|skills/skill-name|summary:L{n}|summary:subpath:L{n}`
- Cleaned files (annotations stripped) go to `agents/.build/skills/` and are overlaid during `install.sh`
- Run `make compile` after adding/editing annotations, or use `--check` to verify staleness
