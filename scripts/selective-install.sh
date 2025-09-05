#!/usr/bin/env bash

# Selective Installation Script
# Allows granular control over what gets installed

set -e

# Check bash version and upgrade if needed
if (( BASH_VERSINFO[0] < 4 )); then
    echo "Installing newer bash..."
    brew install bash
    echo "Rerunning with updated bash..."
    exec /opt/homebrew/bin/bash "$0" "$@"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                     🎯 Selective Installation                         ║"
    echo "║                   Choose Exactly What You Want                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${CYAN}▶ $1${NC}"
    echo -e "${CYAN}$(printf '─%.0s' {1..60})${NC}"
}

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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Installation categories
declare -A CATEGORIES
CATEGORIES=(
    ["essential"]="Essential CLI Tools"
    ["modern_cli"]="Modern CLI Replacements" 
    ["dev_tools"]="Development Tools"
    ["ai_tools"]="AI Development Tools"
    ["terminals"]="Terminal Applications"
    ["productivity"]="Productivity Apps"
    ["security"]="Security Tools"
    ["browsers"]="Web Browsers"
    ["media"]="Media & Design Tools"
    ["system"]="System Utilities"
    ["fonts"]="Developer Fonts"
)

# Define packages by category
declare -A PACKAGES

PACKAGES[essential]="curl wget git openssh gnupg stow"

PACKAGES[modern_cli]="ripgrep fzf fd bat eza dust duf procs bottom tree zoxide mcfly tldr thefuck trash choose navi"

PACKAGES[dev_tools]="vim neovim tmux jq yq fx httpie hyperfine lf watch node python@3.12 go libpq sqlite docker-compose bruno-cli gh delta"

PACKAGES[ai_tools]="cursor insomnia bruno"

PACKAGES[terminals]="iterm2 warp"

PACKAGES[productivity]="raycast rectangle alt-tab"

PACKAGES[security]="1password 1password-cli"

PACKAGES[browsers]="google-chrome microsoft-edge"

PACKAGES[media]="vlc"

PACKAGES[system]="mas stow"

PACKAGES[fonts]="font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-cascadia-code font-source-code-pro font-hack-nerd-font"

# Function to show package selection menu
show_category_menu() {
    local category=$1
    local packages=(${PACKAGES[$category]})
    local selected=()
    
    print_section "${CATEGORIES[$category]}"
    echo "Select packages to install (space to toggle, enter to continue):"
    echo
    
    for i in "${!packages[@]}"; do
        echo "$((i+1)). ${packages[$i]}"
    done
    echo
    
    while true; do
        read -p "Enter package numbers (e.g., 1 3 5) or 'all' for all, 'none' for none: " input
        
        if [[ "$input" == "all" ]]; then
            selected=("${packages[@]}")
            break
        elif [[ "$input" == "none" ]]; then
            selected=()
            break
        elif [[ -n "$input" ]]; then
            selected=()
            for num in $input; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le "${#packages[@]}" ]]; then
                    selected+=("${packages[$((num-1))]}")
                fi
            done
            break
        else
            print_warning "Please enter package numbers, 'all', or 'none'"
        fi
    done
    
    echo "${selected[@]}"
}

# Function to install selected packages
install_packages() {
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        print_warning "No packages selected"
        return 0
    fi
    
    print_status "Installing ${#packages[@]} packages..."
    
    # Separate brew and cask packages
    local brew_packages=()
    local cask_packages=()
    
    for package in "${packages[@]}"; do
        case "$package" in
            # GUI applications (cask)
            iterm2|warp|kitty|alacritty|hyper|tabby|visual-studio-code|cursor|zed|docker|raycast|rectangle|magnet|karabiner-elements|alt-tab|maccy|bartender|coconutbattery|appcleaner|cleanmymac|1password|1password-cli|bitwarden|little-snitch|lulu|google-chrome|firefox|brave-browser|orion|safari-technology-preview|vlc|handbrake|imageoptim|figma|sketch|mas|the-unarchiver|keka|font-*)
                cask_packages+=("$package")
                ;;
            # CLI tools (brew)
            *)
                brew_packages+=("$package")
                ;;
        esac
    done
    
    # Install Homebrew if needed
    if [[ ${#brew_packages[@]} -gt 0 ]] || [[ ${#cask_packages[@]} -gt 0 ]]; then
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
    if [[ ${#brew_packages[@]} -gt 0 ]]; then
        print_status "Installing CLI packages: ${brew_packages[*]}"
        for package in "${brew_packages[@]}"; do
            if brew list "$package" &>/dev/null; then
                print_success "$package already installed"
            else
                print_status "Installing $package..."
                brew install "$package" || print_warning "Failed to install $package"
            fi
        done
    fi
    
    # Install GUI applications
    if [[ ${#cask_packages[@]} -gt 0 ]]; then
        print_status "Installing GUI applications: ${cask_packages[*]}"
        
        # Add font tap if needed
        for package in "${cask_packages[@]}"; do
            if [[ "$package" == font-* ]]; then
                brew tap homebrew/cask-fonts 2>/dev/null || true
                break
            fi
        done
        
        for package in "${cask_packages[@]}"; do
            if brew list --cask "$package" &>/dev/null; then
                print_success "$package already installed"
            else
                print_status "Installing $package..."
                brew install --cask "$package" || print_warning "Failed to install $package"
            fi
        done
    fi
}

# Function to show category selection
select_categories() {
    print_section "Installation Categories"
    echo "Select categories to configure:"
    echo
    
    local category_keys=($(printf '%s\n' "${!CATEGORIES[@]}" | sort))
    
    for i in "${!category_keys[@]}"; do
        local key="${category_keys[$i]}"
        echo "$((i+1)). ${CATEGORIES[$key]}"
    done
    echo
    
    while true; do
        read -p "Enter category numbers (e.g., 1 3 5) or 'all' for all: " input
        
        if [[ "$input" == "all" ]]; then
            echo "${category_keys[@]}"
            return
        elif [[ -n "$input" ]]; then
            local selected=()
            for num in $input; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le "${#category_keys[@]}" ]]; then
                    selected+=("${category_keys[$((num-1))]}")
                fi
            done
            if [[ ${#selected[@]} -gt 0 ]]; then
                echo "${selected[@]}"
                return
            fi
        fi
        
        print_warning "Please enter valid category numbers or 'all'"
    done
}

# Quick presets
show_presets() {
    print_section "Quick Presets"
    echo "Choose a preset or go custom:"
    echo
    echo "1. 🏢 Enterprise Safe (dotfiles + user-space tools only)"
    echo "2. 🚀 Developer Essentials (essential CLI + dev tools)"
    echo "3. 💻 Full Developer (all dev tools + productivity)"
    echo "4. 🎨 Designer Focus (dev tools + design apps)"
    echo "5. 🔒 Security Focused (dev tools + all security)"
    echo "6. 🧪 Minimal Test (just dotfiles + essential CLI)"
    echo "7. 🎯 Custom Selection (choose categories manually)"
    echo
    
    while true; do
        read -p "Choose preset [1-7]: " choice
        
        case $choice in
            1)
                echo "essential"
                return
                ;;
            2)
                echo "essential modern_cli dev_tools"
                return
                ;;
            3)
                echo "essential modern_cli dev_tools ai_tools terminals productivity"
                return
                ;;
            4)
                echo "essential modern_cli dev_tools productivity media fonts"
                return
                ;;
            5)
                echo "essential modern_cli dev_tools security"
                return
                ;;
            6)
                echo "essential"
                return
                ;;
            7)
                select_categories
                return
                ;;
            *)
                print_warning "Please choose 1-7"
                ;;
        esac
    done
}

# Main installation flow
main() {
    print_banner
    
    # Check for MDM/Enterprise
    if profiles -P 2>/dev/null | grep -q "Device Management"; then
        print_warning "Enterprise/MDM detected - consider enterprise-safe options"
        echo "See ENTERPRISE-CONSIDERATIONS.md for guidance"
        echo
    fi
    
    # Get installation preferences
    show_presets
    selected_categories="$?"
    
    if [[ "$selected_categories" == "essential" && "$1" != "enterprise" ]]; then
        # Enterprise safe mode - just dotfiles
        print_section "Enterprise Safe Installation"
        print_status "Installing dotfiles only..."
        if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
            "$SCRIPT_DIR/install.sh"
        fi
        
        print_status "Installing user-space tools..."
        # NVM
        if [[ ! -d "$HOME/.nvm" ]]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        fi
        
        # Python packages
        pip3 install --user ipython black flake8 pytest
        
        print_success "Enterprise-safe installation complete!"
        return 0
    fi
    
    # Full selective installation
    all_selected_packages=()
    
    for category in $selected_categories; do
        if [[ -n "${PACKAGES[$category]}" ]]; then
            selected_packages=($(show_category_menu "$category"))
            all_selected_packages+=("${selected_packages[@]}")
        fi
    done
    
    # Show summary
    print_section "Installation Summary"
    echo "Selected packages (${#all_selected_packages[@]} total):"
    printf '%s\n' "${all_selected_packages[@]}" | sort | column -c 80
    echo
    
    read -p "Proceed with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled."
        exit 0
    fi
    
    # Install packages
    install_packages "${all_selected_packages[@]}"
    
    # Install dotfiles
    print_section "Installing Dotfiles"
    if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
        "$SCRIPT_DIR/install.sh"
    fi
    
    print_success "🎉 Selective installation complete!"
    print_status "Installed ${#all_selected_packages[@]} packages"
}

# Handle enterprise mode
if [[ "$1" == "enterprise" ]]; then
    main enterprise
else
    main
fi