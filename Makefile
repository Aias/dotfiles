.PHONY: compile install setup link update update-skills check

# Compile @> annotations from skills into GLOBAL.md + cleaned .build/ copies
compile:
	bun agents/compile-global.ts

# Full install with dependencies
install: compile
	./install.sh

# Repo-local setup (git hooks, etc.) — run per clone/worktree
setup:
	./setup.sh

# Link only (skip brew packages)
link: compile
	SKIP_DEPENDENCY_INSTALL=1 ./install.sh

# Pull latest and reinstall
update:
	git pull --rebase --autostash
	$(MAKE) install

# Update external skills from skills.sh
update-skills:
	npx skills update
	@make link
	@echo ""
	@echo "External skills updated. Review changes and commit if needed."

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
	printf "$${BOLD}Node (special)$${RESET}\n"; \
	if [ -f ~/.config/mise/config.toml ] && ! [ -L ~/.config/mise/config.toml ]; then \
		diff -q mise/global-config.toml ~/.config/mise/config.toml >/dev/null 2>&1 && \
			printf "  $${GREEN}✓$${RESET} %s\n" ".config/mise/config.toml" || \
			{ printf "  $${RED}✗$${RESET} %s $${DIM}(out of sync)$${RESET}\n" ".config/mise/config.toml"; issues="$$issues .config/mise/config.toml"; }; \
	elif [ -L ~/.config/mise/config.toml ]; then \
		printf "  $${RED}✗$${RESET} %s $${DIM}(symlink — run make link)$${RESET}\n" ".config/mise/config.toml"; \
		issues="$$issues .config/mise/config.toml"; \
	else \
		printf "  $${YELLOW}-$${RESET} %s $${DIM}(missing)$${RESET}\n" ".config/mise/config.toml"; \
		issues="$$issues .config/mise/config.toml"; \
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
