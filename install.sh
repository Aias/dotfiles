#!/bin/bash

# Dotfiles installation script
# Creates symlinks from dotfiles repo to home directory

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────────────────────
# Output helpers
# ─────────────────────────────────────────────────────────────

section() {
    echo ""
    echo "$1"
}

success() {
    printf "  ✓ %s\n" "$1"
}

info() {
    printf "  → %s\n" "$1"
}

warn() {
    printf "  ! %s\n" "$1"
}

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
        info "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
}

install_cursor_agent() {
    if ! command -v cursor-agent >/dev/null 2>&1; then
        info "Installing cursor-agent..."
        curl -fsSL https://cursor.com/install | bash
    fi
}

install_ck() {
    if command -v cargo >/dev/null 2>&1; then
        if ! command -v ck >/dev/null 2>&1; then
            info "Installing ck (semantic code search)..."
            cargo install ck-search
        fi
    else
        warn "Cargo not found. Install Rust to get ck: https://rustup.rs"
    fi
}

install_cursor_cli() {
    # Official method: Cursor > Cmd+Shift+P > "Shell Command: Install 'cursor' command in PATH"
    # This creates /usr/local/bin/cursor. As fallback, symlink to ~/.local/bin
    local cursor_bin="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
    if ! command -v cursor >/dev/null 2>&1; then
        if [[ -x "$cursor_bin" ]]; then
            info "Linking cursor CLI to ~/.local/bin/cursor"
            ln -sf "$cursor_bin" "$HOME/.local/bin/cursor"
        else
            warn "Cursor.app not found. Install from https://cursor.com"
        fi
    fi
}

install_dependencies() {
    section "Dependencies"
    ensure_homebrew
    brew bundle install --file="$DOTFILES_DIR/Brewfile" 2>&1 | grep -E "^(Using|Installing|Upgrading)" | sed 's/^/  /'
    install_bun
    install_cursor_agent
    install_cursor_cli
    install_ck
    success "Dependencies installed"
}

if [[ "${SKIP_DEPENDENCY_INSTALL:-0}" != "1" ]]; then
    install_dependencies
fi

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=false

backup_and_link() {
    local source="$1"
    local target="$2"
    local label="$3"

    if [[ -e "$target" && ! -L "$target" ]]; then
        if [[ "$BACKUP_CREATED" == "false" ]]; then
            mkdir -p "$BACKUP_DIR"
            BACKUP_CREATED=true
        fi
        mv "$target" "$BACKUP_DIR/"
        info "Backed up existing $label"
    fi

    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    success "$label"
}

# ─────────────────────────────────────────────────────────────
# Shell
# ─────────────────────────────────────────────────────────────

section "Shell"
backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc" ".zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile" ".zprofile"
backup_and_link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml" ".config/starship.toml"
backup_and_link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config" ".config/ghostty/config"

# ─────────────────────────────────────────────────────────────
# Git
# ─────────────────────────────────────────────────────────────

section "Git"
backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig" ".gitconfig"
backup_and_link "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global" ".gitignore_global"

# ─────────────────────────────────────────────────────────────
# Claude
# ─────────────────────────────────────────────────────────────

section "Claude"
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md" ".claude/CLAUDE.md"
backup_and_link "$DOTFILES_DIR/agents/claude.settings.json" "$HOME/.claude/settings.json" ".claude/settings.json"
backup_and_link "$DOTFILES_DIR/agents/claude.statusline-command.sh" "$HOME/.claude/statusline-command.sh" ".claude/statusline-command.sh"

# ─────────────────────────────────────────────────────────────
# Codex
# ─────────────────────────────────────────────────────────────

section "Codex"
backup_and_link "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md" ".codex/AGENTS.md"
backup_and_link "$DOTFILES_DIR/agents/codex.config.toml" "$HOME/.codex/config.toml" ".codex/config.toml"

# ─────────────────────────────────────────────────────────────
# Cursor
# ─────────────────────────────────────────────────────────────

section "Cursor"

# Cursor global rules (copy with frontmatter, not symlink)
install_cursor_global_rules() {
    local source="$DOTFILES_DIR/agents/AGENTS.md"
    local target="$HOME/.cursor/rules/global.mdc"
    mkdir -p "$(dirname "$target")"
    {
        echo "---"
        echo "alwaysApply: true"
        echo "---"
        echo ""
        cat "$source"
    } > "$target"
    success ".cursor/rules/global.mdc"
}
install_cursor_global_rules

backup_and_link "$DOTFILES_DIR/cursor/cli-config.json" "$HOME/.cursor/cli-config.json" ".cursor/cli-config.json"
backup_and_link "$DOTFILES_DIR/cursor/mcp.json" "$HOME/.cursor/mcp.json" ".cursor/mcp.json"
backup_and_link "$DOTFILES_DIR/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json" "Cursor/User/settings.json"
backup_and_link "$DOTFILES_DIR/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json" "Cursor/User/keybindings.json"

# ─────────────────────────────────────────────────────────────
# Skills
# ─────────────────────────────────────────────────────────────

section "Skills"

install_skills() {
    local personal_skills="$DOTFILES_DIR/agents/skills"
    local external_skills="$DOTFILES_DIR/.agents/skills"
    local targets=(
        "$HOME/.claude/skills"
        "$HOME/.codex/skills"
    )

    # Collect skill names from both directories
    local skills=()
    local skill_names=()
    for skill in "$personal_skills"/*/; do
        [[ -d "$skill" ]] && skills+=("personal:$(basename "$skill")") && skill_names+=("$(basename "$skill")")
    done
    for skill in "$external_skills"/*/; do
        [[ -d "$skill" ]] && skills+=("external:$(basename "$skill")") && skill_names+=("$(basename "$skill")")
    done

    for target_dir in "${targets[@]}"; do
        # Remove whole-directory symlink if it exists
        if [[ -L "$target_dir" ]]; then
            rm "$target_dir"
        fi
        mkdir -p "$target_dir"

        # Remove orphaned skills (exist in target but not in source)
        for target_skill in "$target_dir"/*/; do
            if [[ -d "$target_skill" ]]; then
                local target_name=$(basename "$target_skill")
                local found=0
                for source_name in "${skill_names[@]}"; do
                    if [[ "$source_name" == "$target_name" ]]; then
                        found=1
                        break
                    fi
                done
                if [[ $found -eq 0 ]]; then
                    rm -rf "$target_skill"
                    info "Removed orphaned skill: $target_name"
                fi
            fi
        done

        for skill_entry in "${skills[@]}"; do
            local skill_type="${skill_entry%%:*}"
            local skill_name="${skill_entry#*:}"
            local skill_source=""

            if [[ "$skill_type" == "personal" ]]; then
                skill_source="$personal_skills/$skill_name/"
            else
                skill_source="$external_skills/$skill_name/"
            fi

            local skill_target="$target_dir/$skill_name"

            # Remove old symlinks
            if [[ -L "$skill_target" ]]; then
                rm "$skill_target"
            fi

            # Sync skill directory with rsync
            # -a: archive mode (preserves permissions, timestamps, etc.)
            # --delete: remove files in target that don't exist in source
            # Trailing slash on source copies contents into target
            mkdir -p "$skill_target"
            rsync -a --delete "$skill_source" "$skill_target/"
        done
    done

    # Print skill status table
    {
        printf "skill\ttype\tclaude\tcodex\n"
        for skill_entry in "${skills[@]}"; do
            local skill_type="${skill_entry%%:*}"
            local skill_name="${skill_entry#*:}"
            local type_label="[P]"
            [[ "$skill_type" == "external" ]] && type_label="[E]"
            printf "%s\t%s\t%s\t%s\n" "$skill_name" "$type_label" "✓" "✓"
        done
    } | column -t -s $'\t' | sed 's/^/  /'
}

install_skills

# ─────────────────────────────────────────────────────────────
# Local files (create from template if missing)
# ─────────────────────────────────────────────────────────────

section "Local"

create_from_template() {
    local target="$1"
    local template="$2"
    local label="$3"

    # Remove broken symlinks
    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    if [[ ! -e "$target" ]]; then
        mkdir -p "$(dirname "$target")"
        if [[ -f "$template" ]]; then
            cat "$template" > "$target"
            success "$label (created from template)"
        else
            warn "$label template not found"
            return 1
        fi
    else
        success "$label (exists)"
    fi
}

# Secrets file (sourced by .zprofile for API keys)
create_from_template "$HOME/.secrets" "$DOTFILES_DIR/local/secrets.template" ".secrets"

# Local environment file (sourced by .zprofile)
create_from_template "$HOME/.local/bin/env" "$DOTFILES_DIR/local/env.template" ".local/bin/env"

# Ensure ~/.local/bin directory exists for local scripts
mkdir -p "$HOME/.local/bin"

# Vault (cross-session memory for agents)
if [[ ! -d "$HOME/Code/vault" ]]; then
    info "Creating vault directory at ~/Code/vault"
    mkdir -p "$HOME/Code/vault/sessions"
    cp "$DOTFILES_DIR/agents/vault-template/CLAUDE.md" "$HOME/Code/vault/"
    cp "$DOTFILES_DIR/agents/vault-template/scratch.md" "$HOME/Code/vault/"
    success "~/Code/vault"
else
    success "~/Code/vault (exists)"
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
        ls -1d "$backup_root"/*/ | head -n "$to_delete" | xargs rm -rf
    fi
}

cleanup_old_backups

# ─────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────

echo ""
if [[ "$BACKUP_CREATED" == "true" ]]; then
    echo "Done! Backups saved to: $BACKUP_DIR"
else
    echo "Done!"
fi
