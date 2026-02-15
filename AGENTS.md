# Dotfiles

Personal dotfiles repo — shell config, git, editor settings, and AI agent configuration.

## Structure

- `agents/GLOBAL.md` — Global agent instructions (symlinked to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, Cursor rules)
- `agents/skills/` — Personal agent skills
- `agents/compile-global.ts` — Compiles `@>` annotations from skills into GLOBAL.md's dense index
- `agents/.build/skills/` — Cleaned skill files (annotations stripped), gitignored
- `agents/claude.settings.json` — Claude Code settings
- `.agents/skills/` — External skills (from skills.sh)
- `install.sh` — Symlink installer (reads `links.txt`), copies skills + cleaned overlays
- `Makefile` — Common tasks (`make link`, `make check`, `make compile`, `make update-skills`)

## Conventions

- Edit config in this repo, not in `~/` — symlinks propagate changes automatically
- For agent config, dotfiles is source of truth; check symlink mapping before editing
- Skills: personal in `agents/skills/`, external in `.agents/skills/`

## Annotation Compilation

Skills with `global_category` in their SKILL.md frontmatter contribute to GLOBAL.md's compiled block via `<!-- @> summary -->` annotations. The compiler (`bun agents/compile-global.ts` or `make compile`) extracts these into a dense pipe-delimited index that's always in context.

- Annotations: `<!-- @> summary text -->` above the relevant section in any `.md` file within a skill
- Output format: `Category|skills/skill-name|summary:L{n}|summary:subpath:L{n}`
- Cleaned files (annotations stripped) go to `agents/.build/skills/` and are overlaid during `install.sh`
- Run `make compile` after adding/editing annotations, or use `--check` to verify staleness
