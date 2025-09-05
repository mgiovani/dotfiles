#!/bin/bash

# Dotfiles Installation Script
# Uses GNU Stow for symlink management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

print_status "Dotfiles directory: $DOTFILES_DIR"

# Check if we're in the right directory
if [[ ! -d "$DOTFILES_DIR/git" ]] || [[ ! -d "$DOTFILES_DIR/vim" ]] || [[ ! -d "$DOTFILES_DIR/zsh" ]]; then
    print_error "This doesn't appear to be a valid dotfiles directory."
    print_error "Expected to find git/, vim/, and zsh/ directories."
    exit 1
fi

# Check if GNU Stow is installed
check_stow() {
    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow is not installed."
        print_status "Installing GNU Stow..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                brew install stow
            else
                print_status "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for Apple Silicon Macs
                if [[ $(uname -m) == "arm64" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                
                print_success "Homebrew installed successfully!"
                brew install stow
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y stow
            elif command -v yum &> /dev/null; then
                sudo yum install -y stow
            elif command -v pacman &> /dev/null; then
                sudo pacman -S stow
            else
                print_error "Unable to install stow automatically. Please install it manually."
                exit 1
            fi
        else
            print_error "Unsupported operating system. Please install GNU Stow manually."
            exit 1
        fi
    else
        print_success "GNU Stow is already installed."
    fi
}

# Backup existing dotfiles
backup_existing() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local needs_backup=false
    
    # Check if any files would conflict
    for package in git vim zsh terminal; do
        if [[ -d "$DOTFILES_DIR/$package" ]]; then
            while IFS= read -r -d '' file; do
                local target="$HOME/$(basename "$file")"
                if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
                    if [[ "$needs_backup" == "false" ]]; then
                        print_warning "Found existing dotfiles that will be backed up to: $backup_dir"
                        mkdir -p "$backup_dir"
                        needs_backup=true
                    fi
                    print_status "Backing up existing: $target"
                    mv "$target" "$backup_dir/"
                fi
            done < <(find "$DOTFILES_DIR/$package" -name ".*" -type f -print0)
        fi
    done
    
    if [[ "$needs_backup" == "true" ]]; then
        print_success "Backup completed: $backup_dir"
    fi
}

# Install dotfiles using stow
install_dotfiles() {
    print_status "Installing dotfiles using GNU Stow..."
    
    cd "$DOTFILES_DIR"
    
    # Install each package
    for package in git vim zsh tmux nvim iterm2; do
        if [[ -d "$package" ]]; then
            print_status "Installing $package configuration..."
            
            # Special handling for iTerm2 preferences
            if [[ "$package" == "iterm2" ]]; then
                print_status "Installing iTerm2 preferences..."
                cp "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/"
                print_success "iTerm2 configuration installed (restart iTerm2 to apply)"
            else
                stow --verbose --target="$HOME" "$package"
                print_success "$package configuration installed."
            fi
        fi
    done
    
    # Handle Cursor IDE configuration (macOS specific)
    if [[ -d "cursor" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Installing Cursor IDE configuration..."
        CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
        mkdir -p "$CURSOR_CONFIG_DIR"
        
        if [[ -f "$DOTFILES_DIR/cursor/settings.json" ]]; then
            cp "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_CONFIG_DIR/settings.json"
            print_success "Cursor settings installed."
        fi
        
        if [[ -f "$DOTFILES_DIR/cursor/extensions.json" ]]; then
            cp "$DOTFILES_DIR/cursor/extensions.json" "$CURSOR_CONFIG_DIR/extensions.json"
            print_success "Cursor extensions list installed."
        fi
        
        print_warning "Install Cursor extensions manually or use: cursor --install-extension vscodevim.vim"
    fi
    
    # Handle terminal configuration (not a dotfile, goes to specific location)
    if [[ -d "terminal" ]] && [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        print_status "Windows Terminal configuration found, manual installation required."
        print_warning "Please copy terminal/windows-terminal.json to your Windows Terminal settings."
    fi
}

# Post-installation tasks
post_install() {
    print_status "Running post-installation tasks..."
    
    # Source zsh if it's the current shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        print_status "Sourcing zsh configuration..."
        # Note: This won't work in the script, user needs to do it manually
        print_warning "Please run 'source ~/.zshrc' or restart your terminal to apply zsh changes."
    fi
    
    # Check for required dependencies
    print_status "Checking for recommended dependencies..."
    
    local missing_deps=()
    
    # Check for common tools
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v vim &> /dev/null; then
        missing_deps+=("vim")
    fi
    
    if ! command -v zsh &> /dev/null; then
        missing_deps+=("zsh")
    fi
    
    if ! command -v fzf &> /dev/null; then
        missing_deps+=("fzf")
    fi
    
    if ! command -v ag &> /dev/null; then
        missing_deps+=("the_silver_searcher (ag)")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "The following recommended tools are not installed:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        print_status "Consider installing them for the full experience."
    else
        print_success "All recommended dependencies are installed!"
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_status "Installing Oh My Zsh..."
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed successfully"
    else
        print_success "Oh My Zsh already installed"
    fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    print_status "Setting up Powerlevel10k theme..."
    
    # If brew installed p10k, we're done
    if brew list powerlevel10k &> /dev/null; then
        print_success "Powerlevel10k installed via Homebrew"
    elif [[ ! -d "$HOME/powerlevel10k" ]]; then
        print_status "Installing Powerlevel10k via git clone..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        print_success "Powerlevel10k installed successfully"
    else
        print_success "Powerlevel10k already installed"
    fi
    
    # Ensure p10k config exists
    if [[ ! -f "$HOME/.p10k.zsh" ]] && [[ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ]]; then
        print_status "Setting up Powerlevel10k configuration..."
        # This will be handled by stow, but let's mention it
        print_status "Powerlevel10k configuration will be linked via dotfiles"
    fi
}

# Main installation process
main() {
    print_status "Starting dotfiles installation..."
    print_status "This will install configurations for: git, vim, neovim, zsh, tmux, iTerm2, Cursor IDE"
    
    # Ask for confirmation
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled."
        exit 0
    fi
    
    check_stow
    backup_existing
    install_dotfiles
    install_oh_my_zsh
    install_powerlevel10k
    post_install
    
    print_success "Dotfiles installation completed!"
    print_status "You may need to:"
    print_status "  1. Restart your terminal or run 'source ~/.zshrc'"
    print_status "  2. Install vim plugins by running ':PlugInstall' in vim"
    print_status "  3. Configure Powerlevel10k by running 'p10k configure' (optional)"
    print_status "  4. Configure any tool-specific settings as needed"
}

# Allow script to be sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi