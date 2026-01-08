#!/usr/bin/env bash
#
# Package Mappings: Homebrew to Linux Package Names
#
# This file provides comprehensive mappings from Homebrew package names
# to their Linux equivalents (primarily Debian/Ubuntu apt packages).
#
# Special Prefixes:
#   SCRIPT:  - Install via curl script (fnm, uv, zoxide)
#   CARGO:   - Install via cargo (eza, dust, procs, bottom, mcfly, navi, hyperfine)
#   SKIP     - macOS only, skip on Linux (mas, GUI casks, fonts)
#   Direct   - Install via package manager with this name
#

# Declare associative array for package mappings
declare -A LINUX_PACKAGES

#
# Essential System Tools
#
LINUX_PACKAGES[curl]="curl"
LINUX_PACKAGES[wget]="wget"
LINUX_PACKAGES[unzip]="unzip"
LINUX_PACKAGES[git]="git"
LINUX_PACKAGES[openssh]="openssh-client"
LINUX_PACKAGES[gnupg]="gnupg"
LINUX_PACKAGES[stow]="stow"

#
# Modern CLI Replacements
#
LINUX_PACKAGES[ripgrep]="ripgrep"
LINUX_PACKAGES[fzf]="fzf"
LINUX_PACKAGES[fd]="fd-find"                    # Note: binary is 'fdfind' on Debian/Ubuntu
LINUX_PACKAGES[bat]="bat"                       # Note: binary is 'batcat' on Debian/Ubuntu
LINUX_PACKAGES[eza]="CARGO:eza"                 # Modern ls replacement (Rust)
LINUX_PACKAGES[dust]="CARGO:du-dust"            # Better du replacement (Rust)
LINUX_PACKAGES[duf]="duf"
LINUX_PACKAGES[procs]="CARGO:procs"             # Modern ps replacement (Rust)
LINUX_PACKAGES[bottom]="CARGO:bottom"           # System monitor (Rust)
LINUX_PACKAGES[tree]="tree"
LINUX_PACKAGES[zoxide]="SCRIPT:zoxide"          # Smarter cd command
LINUX_PACKAGES[mcfly]="CARGO:mcfly"             # Upgraded ctrl-r (Rust)
LINUX_PACKAGES[tldr]="tldr"
LINUX_PACKAGES[thefuck]="thefuck"
LINUX_PACKAGES[trash]="trash-cli"               # Note: different implementation than macOS
LINUX_PACKAGES[navi]="CARGO:navi"               # Interactive cheatsheet tool (Rust)

#
# File Processing & Utilities
#
LINUX_PACKAGES[jq]="jq"
LINUX_PACKAGES[yq]="yq"
LINUX_PACKAGES[fx]="fx"
LINUX_PACKAGES[httpie]="httpie"
LINUX_PACKAGES[hyperfine]="CARGO:hyperfine"     # Command-line benchmarking (Rust)
LINUX_PACKAGES[lf]="lf"
LINUX_PACKAGES[watch]="procps"                  # watch is part of procps package
LINUX_PACKAGES[p7zip]="p7zip-full"

#
# Development Tools
#
LINUX_PACKAGES[vim]="vim"
LINUX_PACKAGES[neovim]="neovim"
LINUX_PACKAGES[tmux]="tmux"
LINUX_PACKAGES[gh]="gh"
LINUX_PACKAGES[delta]="git-delta"               # Better git diff

#
# Programming Languages & Runtimes
#
LINUX_PACKAGES[node]="nodejs"
LINUX_PACKAGES[python@3.12]="python3"           # Generic python3 package
LINUX_PACKAGES[python3]="python3"
LINUX_PACKAGES[go]="golang"

#
# Package Managers & Version Managers
#
LINUX_PACKAGES[fnm]="SCRIPT:fnm"                # Fast Node Manager (install via script)
LINUX_PACKAGES[uv]="SCRIPT:uv"                  # Ultra-fast Python package manager (install via script)

#
# Shell Themes
#
LINUX_PACKAGES[powerlevel10k]="SKIP"            # Installed via Zinit in .zshrc

#
# Databases
#
LINUX_PACKAGES[libpq]="libpq-dev"               # PostgreSQL client tools

#
# DevOps & Cloud
#
LINUX_PACKAGES[docker-compose]="docker-compose"
LINUX_PACKAGES[kubernetes-cli]="kubectl"
LINUX_PACKAGES[helm]="helm"
LINUX_PACKAGES[awscli]="awscli"

#
# macOS-Specific Tools (SKIP on Linux)
#
LINUX_PACKAGES[mas]="SKIP"                      # Mac App Store CLI

#
# GUI Applications (All SKIP on Linux - macOS only)
#
LINUX_PACKAGES[cursor]="SKIP"
LINUX_PACKAGES[xcode]="SKIP"
LINUX_PACKAGES[docker]="SKIP"                   # Use docker-ce on Linux instead
LINUX_PACKAGES[iterm2]="SKIP"
LINUX_PACKAGES[insomnia]="SKIP"
LINUX_PACKAGES[bruno]="SKIP"
LINUX_PACKAGES[bruno-cli]="SKIP"
LINUX_PACKAGES[raycast]="SKIP"
LINUX_PACKAGES[alt-tab]="SKIP"
LINUX_PACKAGES[microsoft-edge]="SKIP"
LINUX_PACKAGES[slack]="SKIP"
LINUX_PACKAGES[vlc]="SKIP"

#
# Fonts (All SKIP on Linux - install via font manager or system packages)
#
LINUX_PACKAGES[font-fira-code-nerd-font]="SKIP"
LINUX_PACKAGES[font-jetbrains-mono-nerd-font]="SKIP"
LINUX_PACKAGES[font-cascadia-code]="SKIP"
LINUX_PACKAGES[font-source-code-pro]="SKIP"
LINUX_PACKAGES[font-hack-nerd-font]="SKIP"
LINUX_PACKAGES[font-inconsolata]="SKIP"
LINUX_PACKAGES[font-roboto-mono-nerd-font]="SKIP"
LINUX_PACKAGES[font-cascadia-mono]="SKIP"
LINUX_PACKAGES[font-sf-mono]="SKIP"

#
# Helper Functions
#

# Get Linux package name for a given Homebrew package
# Usage: get_linux_package "package-name"
# Returns: Linux package name, special prefix (SCRIPT:/CARGO:/SKIP), or empty if not found
get_linux_package() {
    local brew_package="$1"

    if [[ -z "$brew_package" ]]; then
        echo ""
        return 1
    fi

    # Check if package exists in mapping
    if [[ -n "${LINUX_PACKAGES[$brew_package]}" ]]; then
        echo "${LINUX_PACKAGES[$brew_package]}"
        return 0
    else
        # Package not found in mapping - return original name as fallback
        echo "$brew_package"
        return 2
    fi
}

# Check if package should be skipped on Linux
# Usage: should_skip_package "package-name"
# Returns: 0 (true) if should skip, 1 (false) if should install
should_skip_package() {
    local brew_package="$1"
    local linux_package

    linux_package=$(get_linux_package "$brew_package")

    if [[ "$linux_package" == "SKIP" ]]; then
        return 0  # Should skip
    else
        return 1  # Should not skip
    fi
}

# Get installation method for a package
# Usage: get_install_method "package-name"
# Returns: "apt", "cargo", "script", or "skip"
get_install_method() {
    local brew_package="$1"
    local linux_package

    linux_package=$(get_linux_package "$brew_package")

    case "$linux_package" in
        SKIP)
            echo "skip"
            ;;
        SCRIPT:*)
            echo "script"
            ;;
        CARGO:*)
            echo "cargo"
            ;;
        *)
            echo "apt"
            ;;
    esac
}

# Get clean package name (without prefix)
# Usage: get_clean_package_name "package-name"
# Returns: Package name without SCRIPT:/CARGO:/SKIP prefix
get_clean_package_name() {
    local brew_package="$1"
    local linux_package

    linux_package=$(get_linux_package "$brew_package")

    # Remove prefixes
    linux_package="${linux_package#SCRIPT:}"
    linux_package="${linux_package#CARGO:}"

    echo "$linux_package"
}

# Install script URLs for SCRIPT: packages
declare -A INSTALL_SCRIPTS

INSTALL_SCRIPTS[fnm]="curl -fsSL https://fnm.vercel.app/install | bash"
INSTALL_SCRIPTS[uv]="curl -LsSf https://astral.sh/uv/install.sh | sh"
INSTALL_SCRIPTS[zoxide]="curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"

# Get installation script for a SCRIPT: package
# Usage: get_install_script "package-name"
# Returns: Installation command or empty string
get_install_script() {
    local package="$1"

    if [[ -n "${INSTALL_SCRIPTS[$package]}" ]]; then
        echo "${INSTALL_SCRIPTS[$package]}"
        return 0
    else
        echo ""
        return 1
    fi
}

# Export functions for use in other scripts
export -f get_linux_package
export -f should_skip_package
export -f get_install_method
export -f get_clean_package_name
export -f get_install_script

# Print mapping information (for debugging)
print_package_mapping() {
    local brew_package="$1"
    local linux_package
    local method
    local clean_name

    linux_package=$(get_linux_package "$brew_package")
    method=$(get_install_method "$brew_package")
    clean_name=$(get_clean_package_name "$brew_package")

    echo "Homebrew: $brew_package"
    echo "  Linux:  $linux_package"
    echo "  Method: $method"
    echo "  Clean:  $clean_name"
}

# Example usage:
# source scripts/package-mappings.sh
# get_linux_package "node"           # Returns: nodejs
# get_linux_package "fnm"            # Returns: SCRIPT:fnm
# should_skip_package "cursor"       # Returns: 0 (skip)
# get_install_method "eza"           # Returns: cargo
# get_clean_package_name "eza"       # Returns: eza
