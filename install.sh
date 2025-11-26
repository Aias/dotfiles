#!/bin/bash

# Dotfiles installation script
# Creates symlinks from dotfiles repo to home directory

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_and_link() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "Backing up existing $target"
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
    fi

    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    echo "Linking $source -> $target"
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
}

# Zsh
backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# Git
backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Agents
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"

# ─────────────────────────────────────────────────────────────
# Create dependent files if they don't exist
# ─────────────────────────────────────────────────────────────

create_if_missing() {
    local target="$1"
    local content="$2"

    if [[ ! -e "$target" ]]; then
        echo "Creating $target"
        mkdir -p "$(dirname "$target")"
        echo "$content" > "$target"
    fi
}

# Secrets file (sourced by .zprofile for API keys)
create_if_missing "$HOME/.secrets" "# ~/.secrets - API keys and tokens (not tracked in git)
# Example:
# export OPENAI_API_KEY=\"your-key-here\"
# export ANTHROPIC_API_KEY=\"your-key-here\""

# Local environment file (sourced by .zprofile)
create_if_missing "$HOME/.local/bin/env" "# ~/.local/bin/env - Machine-specific environment variables
# Example:
# export PATH=\"/custom/path:\$PATH\""

# Ensure ~/.local/bin directory exists for local scripts
mkdir -p "$HOME/.local/bin"

echo ""
echo "Done! Original files backed up to: $BACKUP_DIR"
