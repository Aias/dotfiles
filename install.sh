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

install_bun() {
    if ! command -v bun >/dev/null 2>&1; then
        echo "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
}

install_cursor_agent() {
    if ! command -v cursor-agent >/dev/null 2>&1; then
        echo "Installing cursor-agent..."
        curl -fsSL https://cursor.com/install | bash
    fi
}

install_beads() {
    if ! command -v bd >/dev/null 2>&1; then
        echo "Installing beads (bd)..."
        brew tap steveyegge/beads 2>/dev/null || true
        brew install bd
    fi
}

install_cursor_cli() {
    # Official method: Cursor > Cmd+Shift+P > "Shell Command: Install 'cursor' command in PATH"
    # This creates /usr/local/bin/cursor. As fallback, symlink to ~/.local/bin
    local cursor_bin="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
    if ! command -v cursor >/dev/null 2>&1; then
        if [[ -x "$cursor_bin" ]]; then
            echo "Linking cursor CLI to ~/.local/bin/cursor"
            ln -sf "$cursor_bin" "$HOME/.local/bin/cursor"
        else
            echo "Note: Cursor.app not found. Install from https://cursor.com then run 'cursor' from Command Palette."
        fi
    fi
}

install_dependencies() {
    echo "Ensuring required CLI tools are installed..."
    ensure_homebrew
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
    install_bun
    install_cursor_agent
    install_cursor_cli
    install_beads
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
backup_and_link "$DOTFILES_DIR/agents/claude.statusline-command.sh" "$HOME/.claude/statusline-command.sh"
backup_and_link "$DOTFILES_DIR/agents/claude.settings.json" "$HOME/.claude/settings.json"
backup_and_link "$DOTFILES_DIR/agents/codex.config.toml" "$HOME/.codex/config.toml"

# Cursor
backup_and_link "$DOTFILES_DIR/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
backup_and_link "$DOTFILES_DIR/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
backup_and_link "$DOTFILES_DIR/cursor/cli-config.json" "$HOME/.cursor/cli-config.json"
backup_and_link "$DOTFILES_DIR/cursor/mcp.json" "$HOME/.cursor/mcp.json"

# Agent skills (shared between Cursor and Claude)
backup_and_link "$DOTFILES_DIR/agents/skills" "$HOME/.cursor/skills"
backup_and_link "$DOTFILES_DIR/agents/skills" "$HOME/.claude/skills"

# ─────────────────────────────────────────────────────────────
# Create dependent files if they don't exist
# ─────────────────────────────────────────────────────────────

create_from_template() {
    local target="$1"
    local template="$2"

    # Remove broken symlinks
    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    if [[ ! -e "$target" ]]; then
        echo "Creating $target from template"
        mkdir -p "$(dirname "$target")"
        if [[ -f "$template" ]]; then
            cat "$template" > "$target"
        else
            echo "Warning: Template $template not found, skipping $target"
            return 1
        fi
    fi
}

# Secrets file (sourced by .zprofile for API keys)
create_from_template "$HOME/.secrets" "$DOTFILES_DIR/local/secrets.template"

# Local environment file (sourced by .zprofile)
create_from_template "$HOME/.local/bin/env" "$DOTFILES_DIR/local/env.template"

# Claude API key file (NOT tracked in git)
create_from_template "$HOME/.claude/key.sh" "$DOTFILES_DIR/local/claude-key.template"
chmod +x "$HOME/.claude/key.sh" 2>/dev/null || true

# Ensure ~/.local/bin directory exists for local scripts
mkdir -p "$HOME/.local/bin"

# Vault (cross-session memory for agents)
if [[ ! -d "$HOME/Code/vault" ]]; then
    echo "Creating vault directory at ~/Code/vault"
    mkdir -p "$HOME/Code/vault/sessions"
    cp "$DOTFILES_DIR/agents/vault-template/CLAUDE.md" "$HOME/Code/vault/"
    cp "$DOTFILES_DIR/agents/vault-template/scratch.md" "$HOME/Code/vault/"
fi

# ─────────────────────────────────────────────────────────────
# Cleanup old backups (keep last 10)
# ─────────────────────────────────────────────────────────────
cleanup_old_backups() {
    local backup_root="$HOME/.dotfiles-backup"
    local keep=10
    local count=$(ls -1d "$backup_root"/*/ 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt "$keep" ]]; then
        local to_delete=$((count - keep))
        echo "Cleaning up $to_delete old backup(s)..."
        ls -1d "$backup_root"/*/ | head -n "$to_delete" | xargs rm -rf
    fi
}

cleanup_old_backups

echo ""
echo "Done! Original files backed up to: $BACKUP_DIR"
