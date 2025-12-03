# ~/.zshrc - Interactive shell configuration
# Runs for every new interactive shell

# ─────────────────────────────────────────────────────────────
# Source .zprofile for non-login interactive shells
# ─────────────────────────────────────────────────────────────
if [[ -o interactive && ! -o login ]]; then
  [[ -r "$HOME/.zprofile" ]] && source "$HOME/.zprofile"
fi

# ─────────────────────────────────────────────────────────────
# History configuration
# ─────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Share history across sessions
setopt HIST_IGNORE_ALL_DUPS   # Remove duplicate entries
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt INC_APPEND_HISTORY     # Write immediately, not on exit
setopt HIST_IGNORE_SPACE      # Don't save commands starting with space

# ─────────────────────────────────────────────────────────────
# Shell options
# ─────────────────────────────────────────────────────────────
setopt AUTO_CD                # cd into directories by typing name
setopt CORRECT                # Spell correction for commands
setopt GLOB_DOTS              # Include dotfiles in globbing
setopt NO_BEEP                # Disable terminal beep
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# ─────────────────────────────────────────────────────────────
# Completion system
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # Case-insensitive

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# ─────────────────────────────────────────────────────────────
# fnm (Node version manager)
# ─────────────────────────────────────────────────────────────
eval "$(fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell zsh)"

# ─────────────────────────────────────────────────────────────
# Aliases - Git
# ─────────────────────────────────────────────────────────────
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline -15"
alias ga="git add"
alias gco="git checkout"

# ─────────────────────────────────────────────────────────────
# Aliases - Navigation & Files
# ─────────────────────────────────────────────────────────────
alias ll="ls -lAh"
alias la="ls -A"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mkdir="mkdir -pv"
alias grep="grep --color=auto"

# ─────────────────────────────────────────────────────────────
# Aliases - Tools & Utilities
# ─────────────────────────────────────────────────────────────
alias claude="DEBUG=false $HOME/.local/bin/claude"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias resource="source ~/.zshrc"
alias yolo="claude --dangerously-skip-permissions"

# Package managers
alias rx="rushx"
alias p="pnpm"
alias pup="pnpm update --interactive"
alias ptsc="pnpm tsc --noEmit"

# ─────────────────────────────────────────────────────────────
# Zoxide (smart cd) - install with: brew install zoxide
# ─────────────────────────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "📁 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

# ─────────────────────────────────────────────────────────────
# Syntax highlighting & Autosuggestions
# Install with: brew install zsh-syntax-highlighting zsh-autosuggestions
# ─────────────────────────────────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  # Autosuggestions (load before syntax highlighting)
  [[ -r "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  
  # Syntax highlighting (must be last)
  [[ -r "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ─────────────────────────────────────────────────────────────
# Starship prompt (keep at the end)
# ─────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
