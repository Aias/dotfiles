.PHONY: install link update backup diff check

# Full install with dependencies
install:
	./install.sh

# Link only (skip brew packages)
link:
	SKIP_DEPENDENCY_INSTALL=1 ./install.sh

# Pull latest and reinstall
update:
	git pull
	brew bundle install --file=Brewfile
	./install.sh

# Backup current configs
backup:
	@mkdir -p ~/.dotfiles-backup/$$(date +%Y%m%d_%H%M%S)
	@cp ~/.zshrc ~/.dotfiles-backup/$$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@cp ~/.zprofile ~/.dotfiles-backup/$$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@cp ~/.gitconfig ~/.dotfiles-backup/$$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@echo "Backup saved to ~/.dotfiles-backup/$$(date +%Y%m%d_%H%M%S)/"

# Check for config drift
diff:
	@echo "Checking for drift between repo and live configs..."
	@diff -q ~/.zshrc zsh/.zshrc 2>/dev/null || echo "  zshrc differs"
	@diff -q ~/.zprofile zsh/.zprofile 2>/dev/null || echo "  zprofile differs"
	@diff -q ~/.gitconfig git/.gitconfig 2>/dev/null || echo "  gitconfig differs"

# Check symlink health
check:
	@echo "Checking symlink status..."
	@failed=0; \
	check_link() { \
		if [ -L "$$1" ]; then \
			echo "✓ $$1"; \
		elif [ -f "$$1" ]; then \
			echo "✗ $$1 (regular file, not symlink)"; \
			failed=1; \
		elif [ ! -e "$$1" ]; then \
			echo "- $$1 (missing)"; \
		fi; \
	}; \
	check_link ~/.zshrc; \
	check_link ~/.zprofile; \
	check_link ~/.gitconfig; \
	check_link ~/.config/starship.toml; \
	check_link ~/.config/ghostty/config; \
	check_link ~/.claude/CLAUDE.md; \
	check_link ~/.claude/settings.json; \
	check_link ~/.claude/statusline-command.sh; \
	check_link ~/.codex/AGENTS.md; \
	check_link ~/.codex/config.toml; \
	check_link ~/Code/.cursor/rules/global.mdc; \
	check_link ~/.cursor/cli-config.json; \
	check_link ~/.cursor/mcp.json; \
	check_link ~/.cursor/commands; \
	check_link ~/.claude/commands; \
	check_link ~/Library/Application\ Support/Cursor/User/settings.json; \
	check_link ~/Library/Application\ Support/Cursor/User/keybindings.json; \
	if [ "$$failed" = "1" ]; then \
		echo ""; \
		echo "Run 'make link' to fix broken symlinks"; \
		exit 1; \
	fi
