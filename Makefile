.PHONY: compile install link update update-skills backup diff check

# Compile @> annotations from skills into GLOBAL.md + cleaned .build/ copies
compile:
	bun agents/compile-global.ts

# Full install with dependencies
install: compile
	./install.sh

# Link only (skip brew packages)
link: compile
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
	@ts=$$(date +%Y%m%d_%H%M%S); \
	mkdir -p ~/.dotfiles-backup/$$ts; \
	cp ~/.zshrc ~/.dotfiles-backup/$$ts/ 2>/dev/null || true; \
	cp ~/.zprofile ~/.dotfiles-backup/$$ts/ 2>/dev/null || true; \
	cp ~/.gitconfig ~/.dotfiles-backup/$$ts/ 2>/dev/null || true; \
	echo "Backup saved to ~/.dotfiles-backup/$$ts/"

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
	max_w=5; \
	for skill in $$(ls -1d agents/skills/*/ .agents/skills/*/ agents/skills.local/*/ 2>/dev/null | xargs -I{} basename {}); do \
		len=$${#skill}; [ $$len -gt $$max_w ] && max_w=$$len; \
	done; \
	printf "  %-$${max_w}s  type  claude  codex\n" "skill"; \
	check_skill() { \
		local skill="$$1" type_label="$$2" src_dir="$$3"; \
		local claude="$${YELLOW}-$${RESET}" codex="$${YELLOW}-$${RESET}"; \
		local src="$$src_dir/$$skill/SKILL.md"; \
		local built="agents/.build/skills/$$skill/SKILL.md"; \
		local cmp="$$src"; [ -f "$$built" ] && cmp="$$built"; \
		if [ -f ~/.claude/skills/$$skill/SKILL.md ]; then \
			diff -q "$$cmp" ~/.claude/skills/$$skill/SKILL.md >/dev/null 2>&1 && claude="$${GREEN}✓$${RESET}" || claude="$${RED}✗$${RESET}"; \
		fi; \
		if [ -f ~/.codex/skills/$$skill/SKILL.md ]; then \
			diff -q "$$cmp" ~/.codex/skills/$$skill/SKILL.md >/dev/null 2>&1 && codex="$${GREEN}✓$${RESET}" || codex="$${RED}✗$${RESET}"; \
		fi; \
		printf "  %-$${max_w}s  %b   %b       %b\n" "$$skill" "$$type_label" "$$claude" "$$codex"; \
	}; \
	for skill in $$(ls -1d agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
		check_skill "$$skill" "$${DIM}[P]$${RESET}" "agents/skills"; \
	done; \
	for skill in $$(ls -1d .agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
		check_skill "$$skill" "$${DIM}[E]$${RESET}" ".agents/skills"; \
	done; \
	for skill in $$(ls -1d agents/skills.local/*/ 2>/dev/null | xargs -I{} basename {}); do \
		check_skill "$$skill" "$${DIM}[L]$${RESET}" "agents/skills.local"; \
	done; \
	echo ""; \
	if [ -n "$$issues" ]; then \
		count=$$(echo "$$issues" | wc -w | xargs); \
		printf "$${RED}✗ $$count item(s) out of sync:$${RESET}$$issues\n"; \
		printf "$${DIM}Run 'make link' to fix$${RESET}\n"; \
		exit 1; \
	else \
		printf "$${GREEN}✓ All synced$${RESET}\n"; \
	fi
