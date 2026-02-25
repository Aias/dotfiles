# dotfiles

Personal configuration files and environment setup.

## Structure

```
dotfiles/
├── zsh/
│   ├── .zshenv      # Global zsh env (all shell modes)
│   ├── .zshrc       # Interactive shell config
│   └── .zprofile    # Login shell config (PATH, env vars)
├── git/
│   └── .gitconfig   # Git configuration
├── starship/
│   └── starship.toml # Starship prompt configuration
├── ghostty/
│   └── config       # Ghostty terminal configuration
├── cursor/
│   ├── settings.json    # Cursor editor settings
│   ├── keybindings.json # Cursor keybindings
│   ├── cli-config.json  # Cursor CLI config
│   └── mcp.json         # MCP server config
├── agents/
│   ├── GLOBAL.md    # Shared AI assistant guidelines
│   ├── skills/      # [P] Personal skills (hand-written)
│   │   ├── council/
│   │   ├── skills-manager/
│   │   └── .../
│   └── ...
├── .agents/
│   ├── skills/      # [E] External skills (from skills.sh)
│   │   ├── repomix/
│   │   ├── skill-creator/
│   │   └── .../
│   └── skills.json  # Metadata tracking for external skills
├── install.sh       # Symlink installation script
├── Makefile         # Common tasks (install, check, etc.)
└── README.md
```

## Installation

```bash
./install.sh
```

This will:

1. Back up any existing files to `~/.dotfiles-backup/`
2. Create symlinks from this repo to your home directory

## Usage

Edit files in this repo, changes apply immediately via symlinks.

To update after pulling changes:

```bash
source ~/.zshrc
```

## Adding New Configs

1. Add the config file to the appropriate directory
2. Add mapping to `links.txt`
3. Run `./install.sh` to link it

## Managing Skills

Skills come in two types:
- **[P] Personal skills** - Hand-written skills in `agents/skills/`
- **[E] External skills** - Installed from [skills.sh](https://skills.sh) in `.agents/skills/`

Both types are synced via rsync to `~/.claude/skills/` and `~/.codex/skills/`.

### Adding a Personal Skill

1. Create a new folder in `agents/skills/<skill-name>/` with a `SKILL.md` file
2. Run `make link` to sync the skills

### Adding an External Skill

```bash
# Install from skills.sh (downloads to .agents/skills/)
npx skills add <source> --skill <skill-name>

# Track metadata
COMMIT_HASH=$(cd .agents/skills/<skill-name> && git rev-parse HEAD)
agents/skills/skills-manager/manage-skills.sh add \
  <skill-name> \
  <source-repo> \
  "$COMMIT_HASH"

# Deploy via rsync
make link
```

See `agents/skills/skills-manager/README.md` for full documentation.

### Updating External Skills

```bash
make update-skills
```

This runs `npx skills update` and redeploys all skills via rsync.

### Removing a Skill

**Personal skill:**
1. Delete the folder from `agents/skills/`
2. Run `make link` to remove it from target directories

**External skill:**
1. Delete the folder from `.agents/skills/`
2. Remove entry from `.agents/skills.json`
3. Run `make link` to remove it from target directories

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
