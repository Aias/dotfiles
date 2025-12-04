#!/bin/bash

# Dotfiles installation script
# Creates symlinks from dotfiles repo to home directory

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────────────────────
# Ensure required tools are installed (system-wide)
# ─────────────────────────────────────────────────────────────

ensure_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install dependencies. Install from https://brew.sh and rerun."
        exit 1
    fi
}

install_dependencies() {
    echo "Ensuring required CLI tools are installed..."
    ensure_homebrew
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
    echo "Dependency installation complete."
}

if [[ "${SKIP_DEPENDENCY_INSTALL:-0}" != "1" ]]; then
    install_dependencies
fi

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

# Starship
backup_and_link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Ghostty
backup_and_link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# Agents
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/Code/.cursor/rules/global.mdc"
backup_and_link "$DOTFILES_DIR/agents/claude-statusline.sh" "$HOME/.claude/statusline-command.sh"

# Cursor
backup_and_link "$DOTFILES_DIR/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
backup_and_link "$DOTFILES_DIR/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"

# ─────────────────────────────────────────────────────────────
# Create dependent files if they don't exist
# ─────────────────────────────────────────────────────────────

create_from_template() {
    local target="$1"
    local template="$2"

    if [[ ! -e "$target" ]]; then
        echo "Creating $target from template"
        mkdir -p "$(dirname "$target")"
        cp "$template" "$target"
    fi
}

# Secrets file (sourced by .zprofile for API keys)
create_from_template "$HOME/.secrets" "$DOTFILES_DIR/local/secrets.template"

# Local environment file (sourced by .zprofile)
create_from_template "$HOME/.local/bin/env" "$DOTFILES_DIR/local/env.template"

# Ensure ~/.local/bin directory exists for local scripts
mkdir -p "$HOME/.local/bin"

echo ""
echo "Done! Original files backed up to: $BACKUP_DIR"
