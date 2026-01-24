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
│   └── skills/      # AI agent skills (synced via rsync)
│       ├── skill-abc/
│       ├── skill-def/
│       ├── .../
│       ├── skill-xyz/
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

Skills are synced via rsync into `~/.claude/skills/` and `~/.codex/skills/`. The sync removes files deleted from source while preserving other directories in the target.

**Adding a skill:**

1. Create a new folder in `agents/skills/<skill-name>/` with a `SKILL.md` file
2. Run `./install.sh` to sync the skills

**Removing a skill:**

1. Delete the folder from `agents/skills/`
2. Run `./install.sh` to remove it from target directories

**Verifying sync status:**

```bash
make check
```
