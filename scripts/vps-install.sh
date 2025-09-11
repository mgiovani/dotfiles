#!/bin/bash
# VPS Installation Script
# Minimal setup for Linux VPS - only essential tools and configs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux VPS only"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

print_status "Starting VPS installation from: $DOTFILES_DIR"

# Install essential packages only
print_status "Installing essential packages..."
if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y git curl zsh tmux vim fzf unzip
elif command -v yum >/dev/null 2>&1; then
    sudo yum update -y
    sudo yum install -y git curl zsh tmux vim fzf unzip
else
    print_warning "Package manager not detected. Please install manually: git curl zsh tmux vim fzf"
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_status "Oh My Zsh already installed"
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    print_status "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
    print_status "Powerlevel10k already installed"
fi

# Install Oh My Zsh plugins
print_status "Installing Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# Backup existing configs
print_status "Backing up existing configurations..."
backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

for file in .zshrc .tmux.conf .vimrc .gitconfig .p10k.zsh; do
    if [ -f "$HOME/$file" ]; then
        cp "$HOME/$file" "$backup_dir/"
        print_status "Backed up $file"
    fi
done

# Create symlinks for essential configs only
print_status "Creating symlinks..."

# Zsh configuration
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    print_status "Linked .zshrc"
fi

if [ -f "$DOTFILES_DIR/zsh/.zsh_aliases" ]; then
    ln -sf "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
    print_status "Linked .zsh_aliases"
fi

# Tmux configuration
if [ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]; then
    ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    print_status "Linked .tmux.conf"
fi

# Vim configuration (if exists)
if [ -f "$DOTFILES_DIR/vim/.vimrc" ]; then
    ln -sf "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
    print_status "Linked .vimrc"
fi

# Powerlevel10k configuration (if exists)
if [ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ]; then
    ln -sf "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    print_status "Linked .p10k.zsh"
fi

# Change default shell to zsh if not already
#if [ "$SHELL" != "$(which zsh)" ]; then
#    print_status "Changing default shell to zsh..."
#    chsh -s "$(which zsh)"
#    print_warning "You'll need to log out and log back in for the shell change to take effect"
#fi

print_status "VPS installation completed!"
print_status "Backup of original configs saved to: $backup_dir"
print_status ""
print_status "To complete the setup:"
print_status "1. Restart your shell: exec zsh"
print_status "2. Or log out and log back in"
print_status ""
print_status "What was installed:"
print_status "- Essential packages: git, curl, zsh, tmux, vim, fzf"
print_status "- Oh My Zsh with Powerlevel10k theme"
print_status "- Zsh plugins: autosuggestions, syntax-highlighting"
print_status "- Your dotfiles configurations (symlinked)"
