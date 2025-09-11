# Dotfiles Makefile
# Simple commands for managing dotfiles installation and maintenance

.PHONY: help install install-selective install-config update clean test backup restore

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "Installation:"
	@echo "  make install          - Full installation of dotfiles"
	@echo "  make install-selective - Interactive selective installation"
	@echo "  make install-config   - Configuration-based installation"
	@echo "  make install-vps      - VPS/Linux server installation (minimal)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update           - Update Homebrew packages"
	@echo "  make backup           - Backup current configurations"
	@echo "  make restore          - Restore from backup"
	@echo "  make clean            - Clean up temporary files"
	@echo ""
	@echo "Development:"
	@echo "  make test             - Test configurations"
	@echo "  make lint             - Lint shell scripts"

# Installation commands
install:
	@echo "Starting full dotfiles installation..."
	./scripts/install.sh

install-selective:
	@echo "Starting selective installation..."
	./scripts/selective.sh

install-config:
	@echo "Starting configuration-based installation..."
	@if [ ! -f install-config.yml ]; then \
		echo "Creating config from example..."; \
		cp install-config.example.yml install-config.yml; \
		echo "Please edit install-config.yml and run 'make install-config' again"; \
		exit 1; \
	fi
	./scripts/config-install.sh

# Maintenance commands
update:
	@echo "Updating Homebrew packages..."
	brew update
	brew upgrade
	brew bundle cleanup --file=Brewfile

backup:
	@echo "Creating backup of existing configurations..."
	@mkdir -p ~/.dotfiles-backups
	@BACKUP_DIR=~/.dotfiles-backups/backup-$(shell date +%Y%m%d-%H%M%S) && \
	mkdir -p $$BACKUP_DIR && \
	echo "Backing up to $$BACKUP_DIR" && \
	[ -f ~/.zshrc ] && cp ~/.zshrc $$BACKUP_DIR/ || true && \
	[ -f ~/.vimrc ] && cp ~/.vimrc $$BACKUP_DIR/ || true && \
	[ -f ~/.gitconfig ] && cp ~/.gitconfig $$BACKUP_DIR/ || true && \
	[ -f ~/.tmux.conf ] && cp ~/.tmux.conf $$BACKUP_DIR/ || true && \
	echo "Backup completed: $$BACKUP_DIR"

restore:
	@echo "Available backups:"
	@ls -la ~/.dotfiles-backups/ 2>/dev/null || echo "No backups found"
	@echo "To restore, manually copy files from backup directory"

clean:
	@echo "Cleaning up temporary files..."
	@rm -f /tmp/dotfiles-*
	@rm -rf ~/.vim/plugged/*/doc/tags
	@echo "Cleanup completed"

# Development commands
test:
	@echo "Testing shell configurations..."
	@zsh -n zsh/.zshrc || echo "Zsh config has syntax errors"
	@bash -n scripts/*.sh || echo "Some scripts have syntax errors"
	@echo "Basic tests completed"

lint:
	@echo "Linting shell scripts..."
	@command -v shellcheck >/dev/null 2>&1 && \
		find scripts -name "*.sh" -exec shellcheck {} \; || \
		echo "shellcheck not found - install with: brew install shellcheck"

# Quick setup for new machines
bootstrap:
	@echo "Bootstrapping new machine..."
	@if [ ! -d /opt/homebrew ] && [ ! -d /usr/local/Homebrew ]; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@if [ ! -d ~/.oh-my-zsh ]; then \
		echo "Installing Oh My Zsh..."; \
		sh -c "$$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	fi
	@echo "Bootstrap completed - now run: make install"

# Brew bundle operations
brew-install:
	@echo "Installing packages from Brewfile..."
	brew bundle install

brew-cleanup:
	@echo "Cleaning up unused packages..."
	brew bundle cleanup --file=Brewfile

# VPS installation (Linux servers)
install-vps:
	@echo "Starting VPS-specific installation..."
	./scripts/vps-install.sh

# Quick aliases for common operations
i: install
s: install-selective
c: install-config
u: update
b: backup
v: install-vps