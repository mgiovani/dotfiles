#!/bin/bash

# Complete New macOS Machine Setup Script
# Master script that orchestrates the entire setup process

set -e

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
    echo "╔════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                    ║"
    echo "║                        🚀 New macOS Machine Setup 🚀                              ║"
    echo "║                                                                                    ║"
    echo "║                     Complete Developer Environment Setup                           ║"
    echo "║                                                                                    ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

print_section() {
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}$(printf '═%.0s' {1..80})${NC}"
}

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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Check if we're on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "Running on macOS $(sw_vers -productVersion)"
}

# Show setup options
show_menu() {
    print_section "Setup Options"
    echo "Choose what you'd like to install:"
    echo
    echo "1. 🎯 Complete Setup (Recommended)"
    echo "   → Everything: apps, tools, configurations, and dotfiles"
    echo
    echo "2. 🛠  Development Tools Only" 
    echo "   → CLI tools, programming languages, and development apps"
    echo
    echo "3. 🎨 System Configuration Only"
    echo "   → macOS preferences and system settings"
    echo
    echo "4. 📁 Dotfiles Only"
    echo "   → Just install the dotfiles configurations"
    echo
    echo "5. 🔐 SSH Setup Only"
    echo "   → Generate SSH keys and configure for Git services"
    echo
    echo "6. 📋 Custom Selection"
    echo "   → Choose specific components to install"
    echo
    echo "0. ❌ Exit"
    echo
}

# Complete setup
complete_setup() {
    print_section "Complete macOS Setup"
    print_status "This will install everything: tools, apps, configurations, and dotfiles"
    print_status "Estimated time: 45-90 minutes"
    echo
    
    read -p "Continue with complete setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    
    # Step 1: Install development tools and applications
    print_status "Step 1/5: Installing development tools and applications..."
    if [[ -f "$SCRIPT_DIR/macos-setup.sh" ]]; then
        "$SCRIPT_DIR/macos-setup.sh"
    else
        print_warning "macos-setup.sh not found, using Brewfile instead"
        if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
            cd "$DOTFILES_DIR"
            brew bundle install
        fi
    fi
    
    # Step 2: Configure system preferences
    print_status "Step 2/5: Configuring macOS system preferences..."
    if [[ -f "$SCRIPT_DIR/configure-macos.sh" ]]; then
        read -p "Configure macOS system preferences? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            "$SCRIPT_DIR/configure-macos.sh"
        fi
    fi
    
    # Step 3: Setup SSH keys
    print_status "Step 3/5: Setting up SSH keys..."
    if [[ -f "$SCRIPT_DIR/setup-ssh.sh" ]]; then
        read -p "Setup SSH keys for Git services? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            "$SCRIPT_DIR/setup-ssh.sh"
        fi
    fi
    
    # Step 4: Setup shell environment
    print_status "Step 4/5: Setting up shell environment..."
    if [[ -f "$SCRIPT_DIR/bootstrap.sh" ]]; then
        "$SCRIPT_DIR/bootstrap.sh"
    fi
    
    # Step 5: Install dotfiles
    print_status "Step 5/5: Installing dotfiles..."
    if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
        "$SCRIPT_DIR/install.sh"
    fi
    
    print_success "🎉 Complete setup finished!"
}

# Development tools only
development_setup() {
    print_section "Development Tools Setup"
    
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        print_status "Installing development tools via Homebrew..."
        cd "$DOTFILES_DIR"
        brew bundle install
        print_success "Development tools installed!"
    else
        print_error "Brewfile not found"
        return 1
    fi
}

# System configuration only
system_setup() {
    print_section "System Configuration"
    
    if [[ -f "$SCRIPT_DIR/configure-macos.sh" ]]; then
        "$SCRIPT_DIR/configure-macos.sh"
    else
        print_error "configure-macos.sh not found"
        return 1
    fi
}

# Dotfiles only
dotfiles_setup() {
    print_section "Dotfiles Installation"
    
    if [[ -f "$SCRIPT_DIR/install.sh" ]]; then
        "$SCRIPT_DIR/install.sh"
    else
        print_error "install.sh not found"
        return 1
    fi
}

# SSH setup only
ssh_setup() {
    print_section "SSH Key Setup"
    
    if [[ -f "$SCRIPT_DIR/setup-ssh.sh" ]]; then
        "$SCRIPT_DIR/setup-ssh.sh"
    else
        print_error "setup-ssh.sh not found"
        return 1
    fi
}

# Custom selection
custom_setup() {
    print_section "Custom Setup Selection"
    echo "Select components to install (y/n for each):"
    echo
    
    local install_tools=false
    local install_config=false
    local install_dotfiles=false
    local install_ssh=false
    local install_shell=false
    
    read -p "Install development tools and applications? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_tools=true
    fi
    
    read -p "Configure macOS system preferences? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_config=true
    fi
    
    read -p "Setup SSH keys? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_ssh=true
    fi
    
    read -p "Setup shell environment (Oh My Zsh, etc.)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_shell=true
    fi
    
    read -p "Install dotfiles? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dotfiles=true
    fi
    
    # Execute selected components
    if [[ "$install_tools" == true ]]; then
        development_setup
    fi
    
    if [[ "$install_config" == true ]]; then
        system_setup
    fi
    
    if [[ "$install_ssh" == true ]]; then
        ssh_setup
    fi
    
    if [[ "$install_shell" == true ]]; then
        if [[ -f "$SCRIPT_DIR/bootstrap.sh" ]]; then
            "$SCRIPT_DIR/bootstrap.sh"
        fi
    fi
    
    if [[ "$install_dotfiles" == true ]]; then
        dotfiles_setup
    fi
    
    print_success "Custom setup completed!"
}

# Show post-setup instructions
show_post_setup() {
    print_section "🎉 Setup Complete!"
    
    print_success "Your macOS development machine is ready!"
    echo
    print_status "What was installed/configured:"
    echo "  • Modern CLI tools (ripgrep, fzf, bat, exa, etc.)"
    echo "  • Development applications (VS Code, Docker, etc.)"
    echo "  • Productivity tools (Raycast, Rectangle, etc.)"
    echo "  • Programming languages and environments"
    echo "  • Shell configurations (Zsh, Oh My Zsh, Powerlevel10k)"
    echo "  • Git and SSH configuration"
    echo "  • macOS system optimizations"
    echo
    print_status "Next steps:"
    echo "  1. 🔄 Restart your terminal (or run 'source ~/.zshrc')"
    echo "  2. 🎨 Run 'p10k configure' to customize your prompt"
    echo "  3. 📝 Open Vim and run ':PlugInstall' to install plugins"
    echo "  4. 🔧 Customize any settings to your preferences"
    echo "  5. 🚀 Start coding!"
    echo
    print_warning "Some changes may require a full system restart to take effect."
    echo
    print_status "Useful commands to remember:"
    echo "  • rg <search>     - Search in files (ripgrep)"
    echo "  • fzf             - Fuzzy file finder"
    echo "  • bat <file>      - View file with syntax highlighting"
    echo "  • exa -la         - Better ls with colors and icons"
    echo "  • z <directory>   - Smart directory jumping"
    echo "  • lazygit         - Terminal UI for Git"
    echo
    echo "Enjoy your new development environment! 🚀"
}

# Main menu loop
main() {
    print_banner
    
    check_macos
    
    print_status "Welcome to the complete macOS development setup!"
    print_status "This script will help you set up a modern development environment."
    echo
    
    while true; do
        show_menu
        read -p "Choose an option [0-6]: " choice
        echo
        
        case $choice in
            1)
                complete_setup && show_post_setup
                break
                ;;
            2)
                development_setup
                ;;
            3)
                system_setup
                ;;
            4)
                dotfiles_setup
                ;;
            5)
                ssh_setup
                ;;
            6)
                custom_setup
                ;;
            0)
                print_status "Goodbye! 👋"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 0-6."
                ;;
        esac
        echo
        read -p "Press Enter to continue..."
        echo
    done
}

# Allow script to be sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi