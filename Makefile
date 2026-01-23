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
	@failed=0; \
	check_link() { \
		local label="$$2"; \
		if [ -L "$$1" ]; then \
			printf "  ✓ %s\n" "$$label"; \
		elif [ -e "$$1" ]; then \
			printf "  ✗ %s (not a symlink)\n" "$$label"; \
			failed=1; \
		else \
			printf "  - %s (missing)\n" "$$label"; \
		fi; \
	}; \
	echo "Shell"; \
	check_link ~/.zshrc ".zshrc"; \
	check_link ~/.zprofile ".zprofile"; \
	check_link ~/.config/starship.toml ".config/starship.toml"; \
	check_link ~/.config/ghostty/config ".config/ghostty/config"; \
	echo ""; \
	echo "Git"; \
	check_link ~/.gitconfig ".gitconfig"; \
	check_link ~/.gitignore_global ".gitignore_global"; \
	echo ""; \
	echo "Claude"; \
	check_link ~/.claude/CLAUDE.md ".claude/CLAUDE.md"; \
	check_link ~/.claude/settings.json ".claude/settings.json"; \
	check_link ~/.claude/statusline-command.sh ".claude/statusline-command.sh"; \
	echo ""; \
	echo "Codex"; \
	check_link ~/.codex/AGENTS.md ".codex/AGENTS.md"; \
	check_link ~/.codex/config.toml ".codex/config.toml"; \
	echo ""; \
	echo "Cursor"; \
	if [ -f ~/.cursor/rules/global.mdc ]; then \
		printf "  ✓ %s\n" ".cursor/rules/global.mdc"; \
	else \
		printf "  - %s (missing)\n" ".cursor/rules/global.mdc"; \
	fi; \
	check_link ~/.cursor/cli-config.json ".cursor/cli-config.json"; \
	check_link ~/.cursor/mcp.json ".cursor/mcp.json"; \
	check_link ~/Library/Application\ Support/Cursor/User/settings.json "Cursor/User/settings.json"; \
	check_link ~/Library/Application\ Support/Cursor/User/keybindings.json "Cursor/User/keybindings.json"; \
	echo ""; \
	echo "Skills (✓=synced, ✗=out of sync, -=missing)"; \
	printf "  %-20s %s  %s\n" "" "claude" "codex"; \
	for skill in $$(ls -1d agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
		claude="-"; codex="-"; \
		src="agents/skills/$$skill/SKILL.md"; \
		if [ -f ~/.claude/skills/$$skill/SKILL.md ]; then \
			diff -q "$$src" ~/.claude/skills/$$skill/SKILL.md >/dev/null 2>&1 && claude="✓" || claude="✗"; \
		fi; \
		if [ -f ~/.codex/skills/$$skill/SKILL.md ]; then \
			diff -q "$$src" ~/.codex/skills/$$skill/SKILL.md >/dev/null 2>&1 && codex="✓" || codex="✗"; \
		fi; \
		printf "  %-20s %s       %s\n" "$$skill" "$$claude" "$$codex"; \
	done; \
	if [ "$$failed" = "1" ]; then \
		echo ""; \
		echo "Run 'make link' to fix broken symlinks"; \
		exit 1; \
	fi
