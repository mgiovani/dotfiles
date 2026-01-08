#!/bin/bash

# Linux Configuration-based Installation Script
# Uses install-config.yml for installation preferences with Linux package manager support

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

# Package manager detection
PACKAGE_MANAGER=""
PKG_INSTALL_CMD=""
PKG_UPDATE_CMD=""
PKG_CHECK_CMD=""

# Detect Linux distribution and package manager
detect_package_manager() {
    print_status "Detecting package manager..."

    if command -v apt &> /dev/null; then
        PACKAGE_MANAGER="apt"
        PKG_INSTALL_CMD="sudo apt install -y"
        PKG_UPDATE_CMD="sudo apt update"
        PKG_CHECK_CMD="dpkg -l"
        print_success "Detected APT package manager (Debian/Ubuntu)"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
        PKG_INSTALL_CMD="sudo dnf install -y"
        PKG_UPDATE_CMD="sudo dnf check-update"
        PKG_CHECK_CMD="dnf list installed"
        print_success "Detected DNF package manager (Fedora)"
    elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
        PKG_INSTALL_CMD="sudo yum install -y"
        PKG_UPDATE_CMD="sudo yum check-update"
        PKG_CHECK_CMD="yum list installed"
        print_success "Detected YUM package manager (CentOS/RHEL)"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
        PKG_INSTALL_CMD="sudo pacman -S --noconfirm"
        PKG_UPDATE_CMD="sudo pacman -Sy"
        PKG_CHECK_CMD="pacman -Q"
        print_success "Detected Pacman package manager (Arch Linux)"
    elif command -v apk &> /dev/null; then
        PACKAGE_MANAGER="apk"
        PKG_INSTALL_CMD="sudo apk add"
        PKG_UPDATE_CMD="sudo apk update"
        PKG_CHECK_CMD="apk info"
        print_success "Detected APK package manager (Alpine Linux)"
    else
        print_error "No supported package manager found!"
        print_status "Supported: apt, dnf, yum, pacman, apk"
        exit 1
    fi
}

# Package name mappings for different package managers
# Format: brew_name -> apt_name|dnf_name|pacman_name|apk_name
get_package_mapping() {
    local brew_name="$1"
    local mapped_name=""

    case "$brew_name" in
        # Special handling for SKIP packages
        powerlevel10k)
            echo "SKIP"
            return
            ;;

        # Special handling for SCRIPT-based installations
        fnm)
            echo "SCRIPT:fnm"
            return
            ;;
        uv)
            echo "SCRIPT:uv"
            return
            ;;
        zoxide)
            echo "SCRIPT:zoxide"
            return
            ;;

        # Special handling for CARGO packages
        bottom)
            echo "CARGO:bottom"
            return
            ;;

        # Direct mappings (same name across all package managers)
        curl|wget|git|vim|neovim|tmux|tree|jq|unzip|htop|ncdu)
            mapped_name="$brew_name"
            ;;

        # Package manager specific mappings
        ripgrep)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="ripgrep" ;;
                dnf|yum) mapped_name="ripgrep" ;;
                pacman) mapped_name="ripgrep" ;;
                apk) mapped_name="ripgrep" ;;
            esac
            ;;
        fzf)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="fzf" ;;
                dnf|yum) mapped_name="fzf" ;;
                pacman) mapped_name="fzf" ;;
                apk) mapped_name="fzf" ;;
            esac
            ;;
        fd)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="fd-find" ;;
                dnf|yum) mapped_name="fd-find" ;;
                pacman) mapped_name="fd" ;;
                apk) mapped_name="fd" ;;
            esac
            ;;
        bat)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="bat" ;;
                dnf|yum) mapped_name="bat" ;;
                pacman) mapped_name="bat" ;;
                apk) mapped_name="bat" ;;
            esac
            ;;
        eza)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="eza" ;;
                dnf|yum) mapped_name="eza" ;;
                pacman) mapped_name="eza" ;;
                apk) mapped_name="SKIP" ;; # Not available in apk
            esac
            ;;
        dust)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="dust" ;;
                dnf|yum) mapped_name="du-dust" ;;
                pacman) mapped_name="dust" ;;
                apk) mapped_name="dust" ;;
            esac
            ;;
        duf)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="duf" ;;
                dnf|yum) mapped_name="duf" ;;
                pacman) mapped_name="duf" ;;
                apk) mapped_name="duf" ;;
            esac
            ;;
        procs)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="procs" ;;
                dnf|yum) mapped_name="procs" ;;
                pacman) mapped_name="procs" ;;
                apk) mapped_name="SKIP" ;; # Not in apk repos
            esac
            ;;
        mcfly)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="SKIP" ;; # Need to build from source
                dnf|yum) mapped_name="SKIP" ;;
                pacman) mapped_name="mcfly" ;;
                apk) mapped_name="SKIP" ;;
            esac
            ;;
        tldr)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="tldr" ;;
                dnf|yum) mapped_name="tldr" ;;
                pacman) mapped_name="tldr" ;;
                apk) mapped_name="tldr" ;;
            esac
            ;;
        thefuck)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="thefuck" ;;
                dnf|yum) mapped_name="thefuck" ;;
                pacman) mapped_name="thefuck" ;;
                apk) mapped_name="SKIP" ;;
            esac
            ;;
        trash)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="trash-cli" ;;
                dnf|yum) mapped_name="trash-cli" ;;
                pacman) mapped_name="trash-cli" ;;
                apk) mapped_name="trash-cli" ;;
            esac
            ;;
        navi)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="SKIP" ;; # Not in apt repos
                dnf|yum) mapped_name="SKIP" ;;
                pacman) mapped_name="navi" ;;
                apk) mapped_name="SKIP" ;;
            esac
            ;;
        yq)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="yq" ;;
                dnf|yum) mapped_name="yq" ;;
                pacman) mapped_name="yq" ;;
                apk) mapped_name="yq" ;;
            esac
            ;;
        fx)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="SKIP" ;; # Need npm install
                dnf|yum) mapped_name="SKIP" ;;
                pacman) mapped_name="fx" ;;
                apk) mapped_name="SKIP" ;;
            esac
            ;;
        httpie)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="httpie" ;;
                dnf|yum) mapped_name="httpie" ;;
                pacman) mapped_name="httpie" ;;
                apk) mapped_name="httpie" ;;
            esac
            ;;
        hyperfine)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="hyperfine" ;;
                dnf|yum) mapped_name="hyperfine" ;;
                pacman) mapped_name="hyperfine" ;;
                apk) mapped_name="hyperfine" ;;
            esac
            ;;
        lf)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="lf" ;;
                dnf|yum) mapped_name="lf" ;;
                pacman) mapped_name="lf" ;;
                apk) mapped_name="lf" ;;
            esac
            ;;
        watch)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="procps" ;;
                dnf|yum) mapped_name="procps-ng" ;;
                pacman) mapped_name="procps-ng" ;;
                apk) mapped_name="procps" ;;
            esac
            ;;
        gh)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="gh" ;;
                dnf|yum) mapped_name="gh" ;;
                pacman) mapped_name="github-cli" ;;
                apk) mapped_name="github-cli" ;;
            esac
            ;;
        delta)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="git-delta" ;;
                dnf|yum) mapped_name="git-delta" ;;
                pacman) mapped_name="git-delta" ;;
                apk) mapped_name="git-delta" ;;
            esac
            ;;
        openssh)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="openssh-client openssh-server" ;;
                dnf|yum) mapped_name="openssh openssh-server" ;;
                pacman) mapped_name="openssh" ;;
                apk) mapped_name="openssh" ;;
            esac
            ;;
        gnupg)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="gnupg" ;;
                dnf|yum) mapped_name="gnupg2" ;;
                pacman) mapped_name="gnupg" ;;
                apk) mapped_name="gnupg" ;;
            esac
            ;;
        stow)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="stow" ;;
                dnf|yum) mapped_name="stow" ;;
                pacman) mapped_name="stow" ;;
                apk) mapped_name="stow" ;;
            esac
            ;;
        libpq)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="postgresql-client" ;;
                dnf|yum) mapped_name="postgresql" ;;
                pacman) mapped_name="postgresql-libs" ;;
                apk) mapped_name="postgresql-client" ;;
            esac
            ;;
        docker-compose)
            case "$PACKAGE_MANAGER" in
                apt) mapped_name="docker-compose" ;;
                dnf|yum) mapped_name="docker-compose" ;;
                pacman) mapped_name="docker-compose" ;;
                apk) mapped_name="docker-compose" ;;
            esac
            ;;
        *)
            # Unknown package - skip or attempt direct install
            print_warning "Unknown package mapping for: $brew_name"
            mapped_name="SKIP"
            ;;
    esac

    echo "$mapped_name"
}

# Install Linux prerequisites
install_linux_prerequisites() {
    print_status "Installing Linux prerequisites..."

    # Update package cache
    eval "$PKG_UPDATE_CMD" || true

    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt install -y \
                build-essential \
                git \
                curl \
                wget \
                unzip \
                ca-certificates \
                gnupg \
                lsb-release
            ;;
        dnf)
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y \
                git \
                curl \
                wget \
                unzip \
                ca-certificates
            ;;
        yum)
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y \
                git \
                curl \
                wget \
                unzip \
                ca-certificates
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed \
                base-devel \
                git \
                curl \
                wget \
                unzip
            ;;
        apk)
            sudo apk add \
                build-base \
                git \
                curl \
                wget \
                unzip \
                ca-certificates
            ;;
    esac

    print_success "Prerequisites installed"
}

# Check if package is installed
is_package_installed() {
    local package="$1"

    case "$PACKAGE_MANAGER" in
        apt)
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        dnf|yum)
            rpm -q "$package" &>/dev/null
            ;;
        pacman)
            pacman -Q "$package" &>/dev/null
            ;;
        apk)
            apk info -e "$package" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Install a single package
install_package() {
    local brew_package="$1"
    local mapped_package

    mapped_package=$(get_package_mapping "$brew_package")

    # Handle special cases
    if [[ "$mapped_package" == "SKIP" ]]; then
        print_warning "Skipping $brew_package (not available for $PACKAGE_MANAGER)"
        return 0
    fi

    if [[ "$mapped_package" =~ ^SCRIPT: ]]; then
        local script_name="${mapped_package#SCRIPT:}"
        install_via_script "$script_name"
        return $?
    fi

    if [[ "$mapped_package" =~ ^CARGO: ]]; then
        local cargo_package="${mapped_package#CARGO:}"
        install_cargo_package "$cargo_package"
        return $?
    fi

    # Handle packages with multiple names (space-separated)
    for pkg in $mapped_package; do
        if is_package_installed "$pkg"; then
            print_success "$pkg already installed"
        else
            print_status "Installing $pkg..."
            eval "$PKG_INSTALL_CMD $pkg" 2>/dev/null || print_warning "Failed to install $pkg"
        fi
    done
}

# Install via curl script
install_via_script() {
    local tool="$1"

    case "$tool" in
        fnm)
            if command -v fnm &> /dev/null; then
                print_success "fnm already installed"
            else
                print_status "Installing fnm via script..."
                curl -fsSL https://fnm.vercel.app/install | bash
                print_success "fnm installed"
            fi
            ;;
        uv)
            if command -v uv &> /dev/null; then
                print_success "uv already installed"
            else
                print_status "Installing uv via script..."
                curl -LsSf https://astral.sh/uv/install.sh | sh
                print_success "uv installed"
            fi
            ;;
        zoxide)
            if command -v zoxide &> /dev/null; then
                print_success "zoxide already installed"
            else
                print_status "Installing zoxide via script..."
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
                print_success "zoxide installed"
            fi
            ;;
        *)
            print_warning "Unknown script installation for: $tool"
            ;;
    esac
}

# Install Rust if not present
install_rust() {
    if command -v cargo &> /dev/null; then
        print_success "Rust already installed"
        return 0
    fi

    print_status "Rust not found. Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # Source cargo env
    source "$HOME/.cargo/env"

    print_success "Rust installed"
}

# Install via cargo
install_cargo_package() {
    local package="$1"

    # Ensure Rust is installed
    install_rust

    # Source cargo env to ensure cargo is in PATH
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi

    if cargo install --list | grep -q "^$package v"; then
        print_success "$package already installed via cargo"
    else
        print_status "Installing $package via cargo..."
        cargo install "$package"
        print_success "$package installed via cargo"
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

# Install packages from config
install_packages() {
    local section="$1"

    local packages
    mapfile -t packages < <(parse_packages "$section" "$CONFIG_FILE")

    if [[ ${#packages[@]} -eq 0 ]]; then
        print_warning "No packages found in $section section"
        return
    fi

    print_status "Installing ${#packages[@]} packages from $section..."

    for package in "${packages[@]}"; do
        if [[ -n "$package" ]]; then
            install_package "$package"
        fi
    done

    print_success "$section installation completed"
}

# Install Nerd Fonts to ~/.local/share/fonts/
install_fonts() {
    local section="fonts"

    local fonts
    mapfile -t fonts < <(parse_packages "$section" "$CONFIG_FILE")

    if [[ ${#fonts[@]} -eq 0 ]]; then
        print_warning "No fonts found in $section section"
        return
    fi

    print_status "Installing ${#fonts[@]} Nerd Fonts..."

    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    for font_brew_name in "${fonts[@]}"; do
        if [[ -z "$font_brew_name" ]]; then
            continue
        fi

        # Convert Homebrew font name to Nerd Font name
        # e.g., font-fira-code-nerd-font -> FiraCode
        local font_name
        case "$font_brew_name" in
            font-fira-code-nerd-font)
                font_name="FiraCode"
                ;;
            font-jetbrains-mono-nerd-font)
                font_name="JetBrainsMono"
                ;;
            font-hack-nerd-font)
                font_name="Hack"
                ;;
            font-roboto-mono-nerd-font)
                font_name="RobotoMono"
                ;;
            font-cascadia-code-nerd-font)
                font_name="CascadiaCode"
                ;;
            font-meslo-lg-nerd-font)
                font_name="Meslo"
                ;;
            *)
                print_warning "Unknown font mapping for: $font_brew_name"
                continue
                ;;
        esac

        # Check if font already exists
        if find "$font_dir" -name "*${font_name}*" -type f | grep -q .; then
            print_success "$font_name Nerd Font already installed"
            continue
        fi

        print_status "Downloading $font_name Nerd Font..."

        # Download from GitHub releases (latest version)
        local download_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
        local temp_file="/tmp/${font_name}.zip"

        if curl -L -o "$temp_file" "$download_url" 2>/dev/null; then
            unzip -o -q "$temp_file" -d "$font_dir/" "*.ttf" "*.otf" 2>/dev/null || true
            rm -f "$temp_file"
            print_success "$font_name Nerd Font installed"
        else
            print_warning "Failed to download $font_name Nerd Font"
        fi
    done

    # Refresh font cache
    if command -v fc-cache &> /dev/null; then
        print_status "Refreshing font cache..."
        fc-cache -fv "$font_dir" >/dev/null 2>&1
        print_success "Font cache refreshed"
    fi

    print_success "Fonts installation completed"
}

# Install shell dependencies
install_shell_deps() {
    print_status "Installing shell dependencies..."

    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_success "Oh My Zsh already installed"
    fi

    # Install Powerlevel10k
    if [[ ! -d "$HOME/powerlevel10k" ]]; then
        print_status "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        print_success "Powerlevel10k installed"
    else
        print_success "Powerlevel10k already installed"
    fi

    # Install Base16 Shell themes
    if [[ ! -d "$HOME/.config/base16-shell" ]]; then
        print_status "Installing Base16 Shell themes..."
        mkdir -p "$HOME/.config"
        git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
        print_success "Base16 Shell installed"
    else
        print_success "Base16 Shell already installed"
    fi

    # Install Zsh plugins
    print_status "Installing Zsh plugins..."

    # zsh-autosuggestions
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    else
        print_success "zsh-autosuggestions already installed"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    else
        print_success "zsh-syntax-highlighting already installed"
    fi

    print_success "Shell dependencies installed"
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

# Main installation function for Linux
run_linux_install() {
    print_status "Starting Linux configuration-based installation..."

    # Check if running on Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "This script is designed for Linux only."
        print_status "Use config-install.sh for macOS"
        exit 1
    fi

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

    # Detect package manager
    detect_package_manager

    # Install prerequisites
    install_linux_prerequisites

    # Install packages by section
    install_packages "cli_tools"

    # Install fonts if section exists
    install_fonts

    # Install shell dependencies
    install_shell_deps

    # Install dotfiles if enabled
    install_dotfiles

    print_success "Linux configuration-based installation completed!"
    print_status "Installed packages based on: $CONFIG_FILE"
    print_status "Package manager used: $PACKAGE_MANAGER"
    print_status ""
    print_status "Next steps:"
    print_status "  1. Restart your terminal or run: exec zsh"
    print_status "  2. Configure Powerlevel10k: p10k configure"
    print_status "  3. Verify installations: which fzf ripgrep bat"
    print_status ""
    print_warning "Note: Some tools were installed via script and may require PATH updates"
    print_status "Add these to your ~/.zshrc or ~/.bashrc if needed:"
    print_status '  export PATH="$HOME/.cargo/bin:$PATH"'
    print_status '  export PATH="$HOME/.local/share/fnm:$PATH"'
    print_status '  eval "$(fnm env)"'
    print_status '  eval "$(zoxide init zsh)"'
}

# Allow script to be sourced for testing or run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_linux_install "$@"
fi
