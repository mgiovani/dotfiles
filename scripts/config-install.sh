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
        print_warning "Configuration file created at: $CONFIG_FILE"
        print_status "The file contains ALL packages from Brewfile - just remove the ones you don't want!"
        print_status "Run this script again after customizing your configuration"
        exit 0
    else
        print_error "No configuration file found!"
        print_status "Create $CONFIG_FILE or run ./scripts/selective.sh for interactive mode"
        exit 1
    fi
fi

print_status "Reading configuration from: $CONFIG_FILE"

# Check and install Homebrew if needed
check_homebrew() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add to PATH for Apple Silicon
            if [[ $(uname -m) == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            print_success "Homebrew installed!"
        else
            print_success "Homebrew already installed"
        fi
    fi
}

# Simple YAML parser for our specific format
parse_packages() {
    local section="$1"
    local config_file="$2"
    
    # Extract packages from specific section, removing comments and formatting
    awk "
        /^$section:/ { in_section=1; next }
        /^[a-zA-Z]/ && in_section { in_section=0 }
        in_section && /^  - / { 
            gsub(/^  - /, \"\")
            gsub(/ *#.*/, \"\")
            gsub(/^ */, \"\")
            gsub(/ *$/, \"\")
            if (\$0 != \"\") print \$0
        }
    " "$config_file"
}

# Install packages
install_packages() {
    local package_type="$1"
    local section="$2"
    
    local packages=($(parse_packages "$section" "$CONFIG_FILE"))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        print_warning "No packages found in $section section"
        return
    fi
    
    print_status "Installing ${#packages[@]} packages from $section..."
    
    for package in "${packages[@]}"; do
        if [[ -n "$package" ]]; then
            print_status "Installing $package..."
            if [[ "$package_type" == "cask" ]]; then
                brew install --cask "$package" 2>/dev/null || print_warning "Failed to install $package"
            else
                brew install "$package" 2>/dev/null || print_warning "Failed to install $package"
            fi
        fi
    done
    
    print_success "$section installation completed"
}

# Install dotfiles
install_dotfiles() {
    if grep -q "install_dotfiles: true" "$CONFIG_FILE" 2>/dev/null; then
        print_status "Installing dotfiles configurations..."
        "$SCRIPT_DIR/install.sh"
    else
        print_status "Skipping dotfiles installation (disabled in config)"
    fi
}


# Main installation function
main() {
    print_status "Starting configuration-based installation..."
    
    check_homebrew
    
    # Install packages by section
    install_packages "brew" "cli_tools"
    install_packages "cask" "applications" 
    install_packages "cask" "fonts"
    
    # Install dotfiles if enabled
    install_dotfiles
    
    print_success "Configuration-based installation completed!"
    print_status "Installed packages based on: $CONFIG_FILE"
    print_status "To modify your installation, edit the config file and run this script again"
}

main "$@"