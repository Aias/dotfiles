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
│   ├── GLOBAL.md      # Shared AI assistant guidelines
│   ├── claude.settings.json     # Claude Code settings
│   ├── codex.config.toml        # Codex settings
│   ├── claude.statusline-command.sh
│   ├── hooks/         # Claude Code hooks (e.g. PR guideline check)
│   ├── compile-global.ts        # Annotation compiler
│   ├── vault-template/          # Template for ~/Code/vault
│   ├── .build/skills/ # Cleaned skill files (annotations stripped, gitignored)
│   ├── skills/        # [P] Personal skills (hand-written)
│   │   ├── git-workflows/
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
│       ├── dogfood/
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
```

`make install` will:

1. Compile `@>` annotations from skills into GLOBAL.md
2. Back up any existing files to `~/.dotfiles-backup/`
3. Create symlinks from this repo to `~/` (based on `links.txt`)
4. Copy Cursor global rule with `.mdc` frontmatter
5. Sync all skills (personal, external, local) to `~/.claude/skills/` and `~/.codex/skills/`
6. Discover and symlink MCP server configs across Claude, Codex, and Cursor

Use `make link` to skip dependency installation (brew). Use `make update` to pull, install brew deps, and reinstall.

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

Skills come in three types:
- **[P] Personal** — Hand-written, tracked in `agents/skills/`
- **[L] Local** — Machine-specific, gitignored in `agents/skills.local/`
- **[E] External** — Installed from GitHub via [skills.sh](https://skills.sh) in `.agents/skills/`

All types are synced to `~/.claude/skills/` and `~/.codex/skills/` by `make link`.

### Adding a Personal Skill

1. Create `agents/skills/<skill-name>/SKILL.md`
2. Run `make link`

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

Delete the folder from the appropriate directory, remove any `skills-lock.json` entry, then clean up orphaned deployments from `~/.claude/skills/` and `~/.codex/skills/`.

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
