.PHONY: install link update backup diff

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
