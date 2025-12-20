# dotfiles

Personal configuration files and environment setup.

## Structure

```
dotfiles/
├── zsh/
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
│   ├── AGENTS.md    # Shared AI assistant guidelines
│   └── skills/      # AI agent skills (symlinked individually)
│       ├── changelog/
│       ├── deslop/
│       ├── diagrams/
│       ├── diary/
│       ├── merge-conflicts/
│       ├── pr-review/
│       └── reflect/
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
2. Update `install.sh` to create the symlink
3. Run `./install.sh` to link it

## Managing Skills

Skills are symlinked individually into `~/.claude/skills/` and `~/.codex/skills/` to preserve system skills that may exist in those directories. (Cursor uses workspace-level `.cursor/rules/` instead of global skills.)

**Adding a skill:**
1. Create a new folder in `agents/skills/<skill-name>/` with a `SKILL.md` file
2. Run `./install.sh` to create the symlinks

**Removing a skill:**
1. Delete the folder from `agents/skills/`
2. Remove stale symlinks: `rm ~/.claude/skills/<name> ~/.codex/skills/<name>`

**Verifying symlinks:**
```bash
make check
```
