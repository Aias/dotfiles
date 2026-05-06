# dotfiles

Personal configuration files and environment setup.

## Structure

```
dotfiles/
├── zsh/
│   ├── .zshenv        # Global zsh env (all shell modes)
│   ├── .zshrc         # Interactive shell config
│   └── .zprofile      # Login shell config (PATH, env vars)
├── git/
│   ├── .gitconfig     # Git configuration
│   └── .gitignore_global
├── node/
│   └── .default-npm-packages  # Global npm packages (installed by mise)
├── mise/
│   └── config.toml   # mise version manager config
├── starship/
│   └── starship.toml  # Starship prompt configuration
├── ghostty/
│   └── config         # Ghostty terminal configuration
├── cursor/
│   ├── settings.json    # Cursor editor settings
│   ├── keybindings.json # Cursor keybindings
│   ├── cli-config.json  # Cursor CLI config
│   └── mcp.json         # MCP server config
├── agents/
│   ├── GLOBAL.md      # Shared AI guidelines + compiled @> skill index block
│   ├── claude.settings.json     # Claude Code settings
│   ├── codex.config.toml        # Codex settings
│   ├── conductor.settings.json  # Conductor managed settings
│   ├── claude.statusline-command.sh
│   ├── hooks/         # Claude Code hooks (e.g. PR guideline check)
│   ├── compile-global.ts        # Annotation compiler
│   ├── .build/skills/ # Cleaned skill files (annotations stripped, gitignored)
│   ├── skills/        # [P] Personal skills (hand-written)
│   │   ├── conductor/       # Conductor worktrees / CONDUCTOR_* / target branch
│   │   ├── git-workflows/
│   │   ├── code-quality/
│   │   ├── write/
│   │   ├── skills-manager/
│   │   └── .../
│   └── skills.local/  # [L] Local-only skills (not committed)
├── local/
│   ├── env.template       # Machine-specific env vars template
│   └── secrets.template   # API keys/tokens template
├── git-hooks/
│   └── pre-commit         # Auto-compiles GLOBAL.md annotations
├── .agents/
│   └── skills/        # [E] External skills (from skills.sh)
│       ├── next-best-practices/
│       ├── skill-creator/
│       └── .../
├── install.sh         # Symlink installation script
├── setup.sh           # Repo-local setup (git hooks)
├── Brewfile           # Homebrew dependencies
├── skills-lock.json   # External skill version tracking
├── links.txt          # Symlink mappings
├── Makefile           # Common tasks (install, check, etc.)
└── README.md
```

## Installation

```bash
make install    # Full install (compile annotations + symlink + sync skills)
make setup      # Repo-local setup (git hooks) — run once per clone/worktree
make link       # Same as install but skip brew/mise dependency install (faster iteration)
make update     # git pull + brew bundle + full install (refresh from remote)
```

After this repo is on your machine and zsh is sourced, the **`dotup`** alias runs `make update` from `~/Code/dotfiles` (see `zsh/.zshrc`).

`make install` will:

1. Compile `@>` annotations from skills into GLOBAL.md
2. Back up any existing files to `~/.dotfiles-backup/`
3. Create symlinks from this repo to `~/` (based on `links.txt`)
4. Copy Cursor global rule with `.mdc` frontmatter
5. Sync all skills (personal, external, local) to `~/.claude/skills/` and `~/.codex/skills/`
6. Discover and symlink MCP server configs across Claude, Codex, and Cursor

`make link` sets `SKIP_DEPENDENCY_INSTALL=1` so Homebrew/mise steps are skipped; use it when deps are already satisfied. `make update` is for pulling latest dotfiles and re-running a full install.

## Usage

Edit files in this repo, changes apply immediately via symlinks. After pulling:

```bash
source ~/.zshrc
```

## Adding New Configs

1. Add the config file to the appropriate directory
2. Add mapping to `links.txt`
3. Run `make link` to sync

## Managing Skills

Authoring details: [agents/skills/README.md](agents/skills/README.md).

Skills come in three types:

- **[P] Personal** — Hand-written, tracked in `agents/skills/`
- **[L] Local** — Machine-specific, gitignored in `agents/skills.local/`
- **[E] External** — Installed from GitHub via [skills.sh](https://skills.sh) in `.agents/skills/`

`make link` / `install.sh` **rsync each skill folder into** `~/.claude/skills/` and `~/.codex/skills/` — they **do not delete** directories you removed or renamed in the repo. After dropping or renaming a skill, remove the stale folder from those home paths too (compare `ls agents/skills` / `.agents/skills` / `agents/skills.local` with `ls ~/.claude/skills`). See the **skills-manager** skill (`agents/skills/skills-manager/`) for the full cleanup checklist.

### Adding a Personal Skill

1. Create `agents/skills/<skill-name>/SKILL.md`
2. Run `make link` (and `make compile` if the skill uses `global_category` + `@>` annotations)

### Adding an External Skill

```bash
# Install (downloads to .agents/skills/)
npx skills add OWNER/REPO --skill SKILL-NAME -a claude-code -y

# Remove the symlink it creates (we deploy via make link instead)
rm -f .claude/skills/SKILL-NAME

# Deploy
make link
```

### Updating External Skills

```bash
make update-skills
```

### Removing a Skill

1. Delete the skill directory under `agents/skills/`, `agents/skills.local/`, or `.agents/skills/`
2. Remove any matching entry from `skills-lock.json` (external skills)
3. Delete the same skill name under `~/.claude/skills/` and `~/.codex/skills/` (not done automatically)

### Verifying Sync Status

```bash
make check
```

Shows a table of all skills with sync status for each agent:

```
skill                        type  claude  codex
changelog                    [P]   ✓       ✓
skill-creator                [E]   ✓       ✓
react-best-practices         [P]   ✓       ✓
```
