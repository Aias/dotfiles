.PHONY: install link update update-skills backup diff check

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

# Update external skills from skills.sh
update-skills:
	npx skills update
	@make link
	@echo ""
	@echo "External skills updated. Review changes and commit if needed."

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
	@GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[0;33m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'; \
	issues=""; \
	current_section=""; \
	while IFS='|' read -r section source target label; do \
		case "$$section" in \#*|"") continue;; esac; \
		section=$$(echo "$$section" | xargs); \
		target=$$(echo "$$target" | xargs); \
		label=$$(echo "$$label" | xargs); \
		if [ "$$section" != "$$current_section" ]; then \
			[ -n "$$current_section" ] && echo ""; \
			printf "$${BOLD}%s$${RESET}\n" "$$section"; \
			current_section="$$section"; \
		fi; \
		target_path=~/"$$target"; \
		if [ -L "$$target_path" ]; then \
			printf "  $${GREEN}✓$${RESET} %s\n" "$$label"; \
		elif [ -e "$$target_path" ]; then \
			printf "  $${RED}✗$${RESET} %s $${DIM}(not a symlink)$${RESET}\n" "$$label"; \
			issues="$$issues $$label"; \
		else \
			printf "  $${YELLOW}-$${RESET} %s $${DIM}(missing)$${RESET}\n" "$$label"; \
			issues="$$issues $$label"; \
		fi; \
	done < links.txt; \
	echo ""; \
	printf "$${BOLD}Cursor (special)$${RESET}\n"; \
	if [ -f ~/.cursor/rules/global.mdc ]; then \
		printf "  $${GREEN}✓$${RESET} %s\n" ".cursor/rules/global.mdc"; \
	else \
		printf "  $${YELLOW}-$${RESET} %s $${DIM}(missing)$${RESET}\n" ".cursor/rules/global.mdc"; \
		issues="$$issues .cursor/rules/global.mdc"; \
	fi; \
	echo ""; \
	printf "$${BOLD}Skills$${RESET} $${DIM}(✓=synced, ✗=out of sync, -=missing)$${RESET}\n"; \
	{ \
		printf "skill\ttype\tclaude\tcodex\n"; \
		for skill in $$(ls -1d agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
			claude="$${YELLOW}-$${RESET}"; codex="$${YELLOW}-$${RESET}"; \
			src="agents/skills/$$skill/SKILL.md"; \
			if [ -f ~/.claude/skills/$$skill/SKILL.md ]; then \
				diff -q "$$src" ~/.claude/skills/$$skill/SKILL.md >/dev/null 2>&1 && claude="$${GREEN}✓$${RESET}" || claude="$${RED}✗$${RESET}"; \
			fi; \
			if [ -f ~/.codex/skills/$$skill/SKILL.md ]; then \
				diff -q "$$src" ~/.codex/skills/$$skill/SKILL.md >/dev/null 2>&1 && codex="$${GREEN}✓$${RESET}" || codex="$${RED}✗$${RESET}"; \
			fi; \
			printf "%s\t$${DIM}[P]$${RESET}\t%b\t%b\n" "$$skill" "$$claude" "$$codex"; \
		done; \
		for skill in $$(ls -1d .agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
			claude="$${YELLOW}-$${RESET}"; codex="$${YELLOW}-$${RESET}"; \
			src=".agents/skills/$$skill/SKILL.md"; \
			if [ -f ~/.claude/skills/$$skill/SKILL.md ]; then \
				diff -q "$$src" ~/.claude/skills/$$skill/SKILL.md >/dev/null 2>&1 && claude="$${GREEN}✓$${RESET}" || claude="$${RED}✗$${RESET}"; \
			fi; \
			if [ -f ~/.codex/skills/$$skill/SKILL.md ]; then \
				diff -q "$$src" ~/.codex/skills/$$skill/SKILL.md >/dev/null 2>&1 && codex="$${GREEN}✓$${RESET}" || codex="$${RED}✗$${RESET}"; \
			fi; \
			printf "%s\t$${DIM}[E]$${RESET}\t%b\t%b\n" "$$skill" "$$claude" "$$codex"; \
		done; \
	} | column -t -s $$'\t' | sed 's/^/  /'; \
	echo ""; \
	if [ -n "$$issues" ]; then \
		count=$$(echo "$$issues" | wc -w | xargs); \
		printf "$${RED}✗ $$count item(s) out of sync:$${RESET}$$issues\n"; \
		printf "$${DIM}Run 'make link' to fix$${RESET}\n"; \
		exit 1; \
	else \
		printf "$${GREEN}✓ All synced$${RESET}\n"; \
	fi
