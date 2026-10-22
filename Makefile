.PHONY: compile install setup setup-private-skills setup-devin-plugin publish-devin-plugin link update fast-forward-private-skills update-private-skills update-skills check check-source test-compile-global test-hooks

compile:
	bun agents/compile-global.ts

test-compile-global:
	bun test agents/compile-global.test.ts

test-hooks:
	bun test git-hooks/tests

check-source: test-compile-global test-hooks
	@bun agents/compile-global.ts --check

# Full install with dependencies
install:
	./install.sh

# Repo-local setup (git hooks, etc.) — run per clone/worktree
setup:
	./setup.sh

setup-private-skills:
	git submodule update --init -- agents/skills.local
	$(MAKE) link

fast-forward-private-skills:
	@changes=$$(git -C agents/skills.local status --porcelain) || exit $$?; test -z "$$changes" || { echo "Commit or stash private skill changes before updating"; exit 1; }
	git -C agents/skills.local fetch origin main
	git -C agents/skills.local merge --ff-only origin/main

setup-devin-plugin:
	@test -e agents/devin-plugin/.git || git clone git@github.com:Aias/devin-plugin.git agents/devin-plugin

# Publish the Devin build to the private plugin that Devin Cloud, CLI, and Desktop load
publish-devin-plugin: compile
	@test -e agents/devin-plugin/.git || { echo "Run make setup-devin-plugin first"; exit 1; }
	git -C agents/devin-plugin pull -q --ff-only
	mkdir -p agents/devin-plugin/.devin-plugin
	cp devin/plugin.json agents/devin-plugin/.devin-plugin/plugin.json
	cp agents/.build/devin/GLOBAL.md agents/devin-plugin/AGENTS.md
	rsync -a --delete agents/.build/devin/skills/ agents/devin-plugin/skills/
	git -C agents/devin-plugin add -A
	git -C agents/devin-plugin diff --cached --quiet || { git -C agents/devin-plugin commit -q -m "Publish dotfiles $$(git rev-parse --short HEAD)" && git -C agents/devin-plugin push -q; }
	devin plugins update aias

update-private-skills:
	@test -e agents/skills.local/.git || { echo "Run make setup-private-skills first"; exit 1; }
	$(MAKE) fast-forward-private-skills
	$(MAKE) link

# Link only (skip brew packages)
link:
	SKIP_DEPENDENCY_INSTALL=1 ./install.sh

# Pull latest and reinstall
update:
	@if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then \
		git pull --no-recurse-submodules --rebase --autostash; \
	else \
		echo "No upstream for branch '$$(git branch --show-current)'; rebasing onto origin/main instead."; \
		git pull --no-recurse-submodules --rebase --autostash origin main; \
	fi
	@if test -e agents/skills.local/.git; then $(MAKE) fast-forward-private-skills; fi
	$(MAKE) install

# Update external skills from skills.sh
update-skills:
	npx skills update
	@make link
	@echo ""
	@echo "External skills updated. Review changes and commit if needed."

# Check symlink health
check: check-source
	@GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[0;33m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'; \
	issues=""; \
	current_section=""; \
	while IFS='|' read -r section source target label; do \
		case "$$section" in \#*|"") continue;; esac; \
		section=$$(echo "$$section" | xargs); \
		source=$$(echo "$$source" | xargs); \
		target=$$(echo "$$target" | xargs); \
		label=$$(echo "$$label" | xargs); \
		if [ "$$section" != "$$current_section" ]; then \
			[ -n "$$current_section" ] && echo ""; \
			printf "$${BOLD}%s$${RESET}\n" "$$section"; \
			current_section="$$section"; \
		fi; \
		target_path=~/"$$target"; \
		expected_path="$$PWD/$$source"; \
		if [ -L "$$target_path" ] && [ "$$(readlink "$$target_path")" = "$$expected_path" ]; then \
			printf "  $${GREEN}✓$${RESET} %s\n" "$$label"; \
		elif [ -L "$$target_path" ]; then \
			printf "  $${RED}✗$${RESET} %s $${DIM}(wrong target)$${RESET}\n" "$$label"; \
			issues="$$issues $$label"; \
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
	if [ -f ~/.cursor/rules/global.mdc ] && { printf '%s\n' '---' 'alwaysApply: true' '---' ''; cat agents/.build/cursor/GLOBAL.md; } | cmp -s - ~/.cursor/rules/global.mdc; then \
		printf "  $${GREEN}✓$${RESET} %s\n" ".cursor/rules/global.mdc"; \
	elif [ -f ~/.cursor/rules/global.mdc ]; then \
		printf "  $${RED}✗$${RESET} %s $${DIM}(out of sync)$${RESET}\n" ".cursor/rules/global.mdc"; \
		issues="$$issues .cursor/rules/global.mdc"; \
	else \
		printf "  $${YELLOW}-$${RESET} %s $${DIM}(missing)$${RESET}\n" ".cursor/rules/global.mdc"; \
		issues="$$issues .cursor/rules/global.mdc"; \
	fi; \
	check_merged() { \
		local live="$$HOME/$$2"; \
		if [ -L "$$live" ]; then \
			printf "  $${RED}✗$${RESET} %s $${DIM}(symlink — live file must stay a real JSON file)$${RESET}\n" "$$2"; issues="$$issues $$2"; \
		elif [ -f "$$live" ]; then \
			python3 -c 'import json,sys; t=json.load(open(sys.argv[1]))[sys.argv[3]]; l=json.load(open(sys.argv[2])).get(sys.argv[3]) or {}; sys.exit(0 if all(l.get(k) == v for k, v in t.items()) else 1)' "$$1" "$$live" "$$3" \
				&& printf "  $${GREEN}✓$${RESET} %s\n" "$$2 $$3" \
				|| { printf "  $${RED}✗$${RESET} %s $${DIM}(%s out of sync — run make link)$${RESET}\n" "$$2" "$$3"; issues="$$issues $$2"; }; \
		else \
			printf "  $${YELLOW}-$${RESET} %s $${DIM}(missing)$${RESET}\n" "$$2"; issues="$$issues $$2"; \
		fi; \
	}; \
	check_merged cursor/cli-config.json .cursor/cli-config.json attribution; \
	echo ""; \
	printf "$${BOLD}Devin (special)$${RESET}\n"; \
	check_merged devin/config.json .config/devin/config.json read_config_from; \
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
	printf "  %-$${max_w}s  type  claude  codex  cursor\n" "skill"; \
	check_skill() { \
		local skill="$$1" type_label="$$2" name built target exclusions status; \
		set --; \
		for entry in claude:.claude/skills codex:.codex/skills cursor:.cursor/skills; do \
			name="$${entry%%:*}"; built="agents/.build/$$name/skills/$$skill"; target="$$HOME/$${entry#*:}/$$skill"; exclusions="agents/.build/$$name/excluded-skills.txt"; status="$${YELLOW}-$${RESET}"; \
			if [ -d "$$built" ] && [ -d "$$target" ] && [ -z "$$(rsync -anic --delete "$$built/" "$$target/")" ]; then status="$${GREEN}✓$${RESET}"; \
			elif [ -d "$$built" ]; then status="$${RED}✗$${RESET}"; issues="$$issues $$name:$$skill"; \
			elif grep -Fxq "$$skill" "$$exclusions" && { [ -e "$$target" ] || [ -L "$$target" ]; }; then status="$${RED}✗$${RESET}"; issues="$$issues $$name:$$skill"; \
			elif grep -Fxq "$$skill" "$$exclusions"; then status="$${DIM}-$${RESET}"; fi; \
			set -- "$$@" "$$status"; \
		done; \
		printf "  %-$${max_w}s  %b   %b       %b      %b\n" "$$skill" "$$type_label" "$$@"; \
	}; \
	for skill in $$(ls -1d agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
		check_skill "$$skill" "$${DIM}[P]$${RESET}"; \
	done; \
	for skill in $$(ls -1d .agents/skills/*/ 2>/dev/null | xargs -I{} basename {}); do \
		check_skill "$$skill" "$${DIM}[E]$${RESET}"; \
	done; \
	for skill in $$(ls -1d agents/skills.local/*/ 2>/dev/null | xargs -I{} basename {}); do \
		check_skill "$$skill" "$${DIM}[L]$${RESET}"; \
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
