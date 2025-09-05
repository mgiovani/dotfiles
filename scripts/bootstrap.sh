#!/bin/bash

# Dotfiles Bootstrap Script
# Sets up a new development environment with essential tools and configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_status "Detected macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_status "Detected Linux"
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO=$ID
            print_status "Distribution: $DISTRO"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
        print_status "Detected Windows"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Install package manager
install_package_manager() {
    case $OS in
        macos)
            if ! command -v brew &> /dev/null; then
                print_status "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add brew to PATH for Apple Silicon Macs
                if [[ $(uname -m) == "arm64" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
                print_success "Homebrew installed successfully"
            else
                print_success "Homebrew already installed"
            fi
            ;;
        linux)
            # Package managers are usually pre-installed on Linux
            case $DISTRO in
                ubuntu|debian)
                    sudo apt update
                    ;;
                fedora|centos|rhel)
                    if command -v dnf &> /dev/null; then
                        sudo dnf update
                    else
                        sudo yum update
                    fi
                    ;;
                arch)
                    sudo pacman -Sy
                    ;;
            esac
            ;;
    esac
}

# Install essential tools
install_essentials() {
    print_status "Installing essential development tools..."
    
    case $OS in
        macos)
            # Essential macOS tools
            local packages=(
                "git"
                "vim"
                "zsh"
                "stow"
                "fzf"
                "the_silver_searcher"
                "node"
                "python"
                "go"
                "tmux"
            )
            
            for package in "${packages[@]}"; do
                if brew list "$package" &>/dev/null; then
                    print_success "$package already installed"
                else
                    print_status "Installing $package..."
                    brew install "$package"
                fi
            done
            ;;
        linux)
            case $DISTRO in
                ubuntu|debian)
                    local packages=(
                        "git"
                        "vim"
                        "zsh"
                        "stow"
                        "fzf"
                        "silversearcher-ag"
                        "nodejs"
                        "npm"
                        "python3"
                        "python3-pip"
                        "golang"
                        "tmux"
                        "curl"
                        "wget"
                        "build-essential"
                    )
                    
                    sudo apt update
                    for package in "${packages[@]}"; do
                        if dpkg -l | grep -q "^ii  $package "; then
                            print_success "$package already installed"
                        else
                            print_status "Installing $package..."
                            sudo apt install -y "$package"
                        fi
                    done
                    ;;
                fedora|centos|rhel)
                    local packages=(
                        "git"
                        "vim"
                        "zsh"
                        "stow"
                        "fzf"
                        "the_silver_searcher"
                        "nodejs"
                        "npm"
                        "python3"
                        "python3-pip"
                        "golang"
                        "tmux"
                        "curl"
                        "wget"
                        "@development-tools"
                    )
                    
                    local installer="dnf"
                    if ! command -v dnf &> /dev/null; then
                        installer="yum"
                    fi
                    
                    for package in "${packages[@]}"; do
                        print_status "Installing $package..."
                        sudo $installer install -y "$package"
                    done
                    ;;
                arch)
                    local packages=(
                        "git"
                        "vim"
                        "zsh"
                        "stow"
                        "fzf"
                        "the_silver_searcher"
                        "nodejs"
                        "npm"
                        "python"
                        "python-pip"
                        "go"
                        "tmux"
                        "curl"
                        "wget"
                        "base-devel"
                    )
                    
                    for package in "${packages[@]}"; do
                        if pacman -Q "$package" &>/dev/null; then
                            print_success "$package already installed"
                        else
                            print_status "Installing $package..."
                            sudo pacman -S --noconfirm "$package"
                        fi
                    done
                    ;;
            esac
            ;;
    esac
}

# Setup shell
setup_shell() {
    print_status "Setting up shell environment..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_success "Oh My Zsh already installed"
    fi
    
    # Install Powerlevel10k theme
    if [[ ! -d "$HOME/powerlevel10k" ]]; then
        print_status "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        print_success "Powerlevel10k installed"
    else
        print_success "Powerlevel10k already installed"
    fi
    
    # Install Zinit (plugin manager)
    if [[ ! -d "$HOME/.local/share/zinit/zinit.git" ]]; then
        print_status "Installing Zinit plugin manager..."
        bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
        print_success "Zinit installed"
    else
        print_success "Zinit already installed"
    fi
    
    # Change default shell to zsh
    if [[ "$SHELL" != */zsh ]]; then
        print_status "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        print_warning "You'll need to log out and back in for the shell change to take effect"
    else
        print_success "Default shell is already zsh"
    fi
}

# Setup development environment
setup_dev_env() {
    print_status "Setting up development environment..."
    
    # Install NVM (Node Version Manager)
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        print_success "NVM installed"
    else
        print_success "NVM already installed"
    fi
    
    # Install pyenv (Python version manager) - only on Linux/macOS
    if [[ "$OS" != "windows" ]] && [[ ! -d "$HOME/.pyenv" ]]; then
        print_status "Installing pyenv..."
        curl https://pyenv.run | bash
        print_success "pyenv installed"
    elif [[ -d "$HOME/.pyenv" ]]; then
        print_success "pyenv already installed"
    fi
    
    # Install Base16 Shell (terminal colors)
    if [[ ! -d "$HOME/.config/base16-shell" ]]; then
        print_status "Installing Base16 Shell..."
        git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
        print_success "Base16 Shell installed"
    else
        print_success "Base16 Shell already installed"
    fi
}

# Install fonts (for better terminal experience)
install_fonts() {
    print_status "Installing Nerd Fonts for better terminal experience..."
    
    case $OS in
        macos)
            if ! brew list --cask font-fira-code-nerd-font &>/dev/null; then
                brew tap homebrew/cask-fonts
                brew install --cask font-fira-code-nerd-font
                print_success "Fira Code Nerd Font installed"
            else
                print_success "Fira Code Nerd Font already installed"
            fi
            ;;
        linux)
            local font_dir="$HOME/.local/share/fonts"
            if [[ ! -f "$font_dir/FiraCode Nerd Font Complete.otf" ]]; then
                print_status "Downloading Fira Code Nerd Font..."
                mkdir -p "$font_dir"
                wget -O "$font_dir/FiraCode Nerd Font Complete.otf" \
                    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.otf"
                fc-cache -fv
                print_success "Fira Code Nerd Font installed"
            else
                print_success "Fira Code Nerd Font already installed"
            fi
            ;;
    esac
}

# Main bootstrap process
main() {
    print_status "Starting development environment bootstrap..."
    print_status "This will install essential tools and configure your development environment."
    
    # Ask for confirmation
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Bootstrap cancelled."
        exit 0
    fi
    
    detect_os
    install_package_manager
    install_essentials
    setup_shell
    setup_dev_env
    install_fonts
    
    print_success "Bootstrap completed!"
    print_status ""
    print_status "Next steps:"
    print_status "  1. Install dotfiles by running: ./scripts/install.sh"
    print_status "  2. Restart your terminal or log out and back in"
    print_status "  3. Run 'p10k configure' to set up your prompt"
    print_status "  4. Install vim plugins by running ':PlugInstall' in vim"
    print_status ""
    print_warning "Note: Some changes require a terminal restart or re-login to take effect."
}

# Allow script to be sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi