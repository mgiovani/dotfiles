#!/bin/bash

# Configuration-based Installation Script
# Uses install-config.yml for installation preferences

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$DOTFILES_DIR/install-config.yml"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    if [[ -f "$DOTFILES_DIR/install-config.example.yml" ]]; then
        print_status "Creating config file from example..."
        cp "$DOTFILES_DIR/install-config.example.yml" "$CONFIG_FILE"
        print_warning "Please edit $CONFIG_FILE to customize your installation"
        print_status "Run this script again after configuration"
        exit 0
    else
        print_error "No configuration file found!"
        print_status "Create $CONFIG_FILE or run ./scripts/selective-install.sh for interactive mode"
        exit 1
    fi
fi

# Simple YAML parser (basic key-value extraction)
get_config_value() {
    local key="$1"
    grep "^$key:" "$CONFIG_FILE" | sed 's/.*: *//' | tr -d '"' | head -1
}

get_category_enabled() {
    local category="$1"
    grep -A 20 "^categories:" "$CONFIG_FILE" | grep "^  $category:" | sed 's/.*: *//' | head -1
}

# Read configuration
MODE=$(get_config_value "mode")
TERMINAL_PREF=$(get_config_value "terminal_preference")
LAUNCHER_PREF=$(get_config_value "launcher_preference")

print_status "Installation mode: $MODE"
print_status "Config file: $CONFIG_FILE"

# Enterprise mode check
if [[ "$MODE" == "enterprise" ]]; then
    print_warning "Enterprise mode detected"
    
    # Just install dotfiles and safe user tools
    print_status "Installing dotfiles..."
    if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
        "$SCRIPT_DIR/install.sh"
    fi
    
    # Install NVM (safe)
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi
    
    # Install Python packages in user space
    print_status "Installing Python development tools..."
    pip3 install --user ipython black flake8 pytest requests
    
    print_success "Enterprise-safe installation complete!"
    exit 0
fi

# Build package list based on config
declare -a BREW_PACKAGES
declare -a CASK_PACKAGES

# Essential packages (if enabled)
if [[ "$(get_category_enabled "essential")" == "true" ]]; then
    BREW_PACKAGES+=(curl wget git openssh gnupg stow)
fi

# Modern CLI packages
if [[ "$(get_category_enabled "modern_cli")" == "true" ]]; then
    BREW_PACKAGES+=(ripgrep fzf fd bat eza dust duf procs bottom tree zoxide mcfly tldr thefuck trash choose navi)
fi

# Development tools
if [[ "$(get_category_enabled "dev_tools")" == "true" ]]; then
    BREW_PACKAGES+=(vim neovim tmux jq yq fx httpie hyperfine lf watch)
    BREW_PACKAGES+=(node python@3.12 go libpq sqlite docker-compose bruno-cli gh delta)
    CASK_PACKAGES+=(docker visual-studio-code)
fi

# AI tools
if [[ "$(get_category_enabled "ai_tools")" == "true" ]]; then
    CASK_PACKAGES+=(cursor)
fi

# Terminal applications
if [[ "$(get_category_enabled "terminals")" == "true" ]]; then
    CASK_PACKAGES+=(iterm2)
    
    # Add preferred terminal
    case "$TERMINAL_PREF" in
        warp) CASK_PACKAGES+=(warp) ;;
        kitty) CASK_PACKAGES+=(kitty) ;;
        alacritty) CASK_PACKAGES+=(alacritty) ;;
        hyper) CASK_PACKAGES+=(hyper) ;;
    esac
fi

# Productivity apps
if [[ "$(get_category_enabled "productivity")" == "true" ]]; then
    CASK_PACKAGES+=(rectangle)
    
    # Add preferred launcher
    case "$LAUNCHER_PREF" in
        raycast) CASK_PACKAGES+=(raycast) ;;
    esac
fi

# Security tools
if [[ "$(get_category_enabled "security")" == "true" ]]; then
    CASK_PACKAGES+=(1password 1password-cli bitwarden little-snitch)
fi

# Browsers
if [[ "$(get_category_enabled "browsers")" == "true" ]]; then
    CASK_PACKAGES+=(google-chrome firefox brave-browser)
fi

# System utilities  
if [[ "$(get_category_enabled "system")" == "true" ]]; then
    BREW_PACKAGES+=(mas)
    CASK_PACKAGES+=(the-unarchiver appcleaner)
fi

# Fonts
if [[ "$(get_category_enabled "fonts")" == "true" ]]; then
    CASK_PACKAGES+=(font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-cascadia-code)
fi

# Install Homebrew if needed
if [[ ${#BREW_PACKAGES[@]} -gt 0 ]] || [[ ${#CASK_PACKAGES[@]} -gt 0 ]]; then
    if ! command -v brew &> /dev/null; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
fi

# Install CLI packages
if [[ ${#BREW_PACKAGES[@]} -gt 0 ]]; then
    print_status "Installing ${#BREW_PACKAGES[@]} CLI packages..."
    for package in "${BREW_PACKAGES[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_success "$package already installed"
        else
            print_status "Installing $package..."
            brew install "$package" || print_warning "Failed to install $package"
        fi
    done
fi

# Install GUI applications
if [[ ${#CASK_PACKAGES[@]} -gt 0 ]]; then
    print_status "Installing ${#CASK_PACKAGES[@]} GUI applications..."
    
    # Add font tap if needed
    for package in "${CASK_PACKAGES[@]}"; do
        if [[ "$package" == font-* ]]; then
            brew tap homebrew/cask-fonts 2>/dev/null || true
            break
        fi
    done
    
    for package in "${CASK_PACKAGES[@]}"; do
        if brew list --cask "$package" &>/dev/null; then
            print_success "$package already installed"
        else
            print_status "Installing $package..."
            brew install --cask "$package" || print_warning "Failed to install $package"
        fi
    done
fi

# Install dotfiles
print_status "Installing dotfiles..."
if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
    "$SCRIPT_DIR/install.sh"
fi

print_success "🎉 Configuration-based installation complete!"
print_status "Installed $(( ${#BREW_PACKAGES[@]} + ${#CASK_PACKAGES[@]} )) packages"
print_status "Config used: $CONFIG_FILE"