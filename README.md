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
├── agents/
│   └── AGENTS.md    # Shared AI assistant guidelines
├── install.sh       # Symlink installation script
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
