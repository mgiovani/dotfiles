#!/bin/bash

# macOS Development Machine Setup Script
# Complete setup for a new macOS development machine with modern CLI tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                        macOS Development Setup                               ║${NC}"
    echo -e "${PURPLE}║                     Modern CLI Tools & Applications                         ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_section() {
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}$(printf '═%.0s' {1..80})${NC}"
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

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "Running on macOS $(sw_vers -productVersion)"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    print_section "Installing Xcode Command Line Tools"
    
    if xcode-select --print-path &> /dev/null; then
        print_success "Xcode Command Line Tools already installed"
    else
        print_status "Installing Xcode Command Line Tools..."
        xcode-select --install
        print_warning "Please complete the Xcode Command Line Tools installation and run this script again"
        exit 1
    fi
}

# Install Homebrew
install_homebrew() {
    print_section "Installing Homebrew Package Manager"
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
        print_status "Updating Homebrew..."
        brew update
    else
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed successfully"
    fi
}

# Install modern CLI tools
install_modern_cli_tools() {
    print_section "Installing Modern CLI Tools & Replacements"
    
    local cli_tools=(
        # Modern replacements for classic Unix tools
        "ripgrep"           # rg - faster grep replacement
        "fzf"               # fuzzy finder
        "fd"                # faster find replacement
        "bat"               # better cat with syntax highlighting
        "exa"               # modern ls replacement
        "dust"              # better du replacement
        "duf"               # better df replacement
        "htop"              # better top replacement
        "btop"              # even better system monitor
        "hyperfine"         # command-line benchmarking tool
        "jq"                # JSON processor
        "yq"                # YAML processor
        "httpie"            # better curl for APIs
        "delta"             # better git diff
        "lazygit"           # terminal UI for git
        "gh"                # GitHub CLI
        "tree"              # directory tree display
        "wget"              # download utility
        "curl"              # transfer data utility
        "tldr"              # simplified man pages
        "zoxide"            # smarter cd command
        "thefuck"           # corrects previous commands
        "ncdu"              # disk usage analyzer
        "ranger"            # terminal file manager
        
        # Development tools
        "git"               # version control
        "vim"               # text editor
        "neovim"            # modern vim
        "tmux"              # terminal multiplexer
        "watch"             # run commands periodically
        "entr"              # run commands when files change
        "fswatch"           # file system watcher
        
        # Programming languages & runtimes
        "node"              # JavaScript runtime
        "python@3.12"       # Python
        "go"                # Go language
        "rust"              # Rust language
        "ruby"              # Ruby language
        
        # Databases
        "postgresql@15"     # PostgreSQL database
        "redis"             # Redis cache
        "sqlite"            # SQLite database
        
        # Cloud & DevOps tools
        "docker"            # containerization
        "kubernetes-cli"    # kubectl
        "helm"              # Kubernetes package manager
        "terraform"         # infrastructure as code
        "awscli"            # AWS CLI
        
        # Network tools
        "nmap"              # network scanner
        "netcat"            # networking utility
        "wireshark"         # network analyzer (CLI)
        "mtr"               # network diagnostic tool
        
        # Compression & archive tools
        "p7zip"             # 7zip archiver
        "unrar"             # RAR extraction
        "xz"                # xz compression
        
        # System tools
        "mas"               # Mac App Store CLI
        "mackup"            # application settings backup
        "dockutil"          # dock management
        "trash"             # safer rm command
    )
    
    print_status "Installing CLI tools..."
    for tool in "${cli_tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_success "$tool already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
}

# Install GUI applications
install_gui_applications() {
    print_section "Installing GUI Applications"
    
    local gui_apps=(
        # Development
        "visual-studio-code"        # Code editor
        "cursor"                    # AI-powered code editor
        "zed"                       # Fast code editor
        "iterm2"                    # Better terminal
        "warp"                      # AI terminal
        "docker"                    # Docker Desktop
        "postman"                   # API testing
        "tableplus"                 # Database client
        "sequel-pro"                # MySQL client
        "github-desktop"            # Git GUI
        "sourcetree"                # Git GUI alternative
        
        # Productivity
        "raycast"                   # Spotlight replacement
        "alfred"                    # App launcher
        "rectangle"                 # Window management
        "karabiner-elements"        # Keyboard customization
        "alt-tab"                   # Windows-style alt-tab
        "maccy"                     # Clipboard manager
        "the-unarchiver"            # Archive utility
        "keka"                      # Archive utility
        
        # Browsers
        "google-chrome"             # Web browser
        "firefox"                   # Web browser
        "arc"                       # Modern web browser
        
        # Communication
        "slack"                     # Team communication
        "discord"                   # Community communication
        "zoom"                      # Video conferencing
        "microsoft-teams"           # Video conferencing
        
        # Utilities
        "1password"                 # Password manager
        "bitwarden"                 # Password manager alternative
        "cleanmymac"                # System cleaner
        "bartender-4"               # Menu bar organization
        "coconutbattery"            # Battery health
        "appcleaner"                # Uninstaller
        "finder-fix"                # Finder improvements
        
        # Media
        "vlc"                       # Media player
        "handbrake"                 # Video transcoder
        "imageoptim"                # Image optimization
        "figma"                     # Design tool
        
        # File sync
        "syncthing"                 # File synchronization
        "dropbox"                   # Cloud storage
        "google-drive"              # Cloud storage
        
        # System monitoring
        "activity-monitor"          # Task manager
        "disk-utility"              # Disk management
        "system-information"        # System info
    )
    
    print_status "Installing GUI applications..."
    for app in "${gui_apps[@]}"; do
        if brew list --cask "$app" &>/dev/null; then
            print_success "$app already installed"
        else
            print_status "Installing $app..."
            brew install --cask "$app" || print_warning "Failed to install $app"
        fi
    done
}

# Install fonts
install_fonts() {
    print_section "Installing Developer Fonts"
    
    # Tap the fonts repository
    brew tap homebrew/cask-fonts
    
    local fonts=(
        "font-fira-code-nerd-font"      # FiraCode with icons
        "font-jetbrains-mono-nerd-font" # JetBrains Mono with icons
        "font-cascadia-code"            # Microsoft's Cascadia Code
        "font-source-code-pro"          # Adobe Source Code Pro
        "font-hack-nerd-font"           # Hack with icons
        "font-inconsolata"              # Inconsolata
        "font-roboto-mono-nerd-font"    # Roboto Mono with icons
    )
    
    for font in "${fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            print_success "$font already installed"
        else
            print_status "Installing $font..."
            brew install --cask "$font"
        fi
    done
}

# Setup development environment
setup_dev_environment() {
    print_section "Setting up Development Environment"
    
    # Install Node Version Manager (NVM)
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Install latest LTS Node.js
        nvm install --lts
        nvm use --lts
        print_success "NVM and Node.js LTS installed"
    else
        print_success "NVM already installed"
    fi
    
    # Install Python version manager (pyenv)
    if [[ ! -d "$HOME/.pyenv" ]]; then
        print_status "Installing pyenv..."
        curl https://pyenv.run | bash
        
        # Add pyenv to shell
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
        echo 'eval "$(pyenv init -)"' >> ~/.zprofile
        
        # Install latest Python
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        pyenv install 3.12.0
        pyenv global 3.12.0
        print_success "pyenv and Python 3.12 installed"
    else
        print_success "pyenv already installed"
    fi
    
    # Install Ruby version manager (rbenv)
    if ! command -v rbenv &> /dev/null; then
        print_status "Installing rbenv..."
        brew install rbenv ruby-build
        echo 'eval "$(rbenv init - zsh)"' >> ~/.zprofile
        
        # Install latest stable Ruby
        rbenv install 3.2.0
        rbenv global 3.2.0
        print_success "rbenv and Ruby 3.2.0 installed"
    else
        print_success "rbenv already installed"
    fi
}

# Configure macOS system preferences
configure_macos() {
    print_section "Configuring macOS System Preferences"
    
    # Ask for confirmation
    read -p "Do you want to configure macOS system preferences? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping macOS configuration"
        return 0
    fi
    
    print_status "Configuring system preferences..."
    
    # Close any open System Preferences panes
    osascript -e 'tell application "System Preferences" to quit'
    
    # General UI/UX
    print_status "Setting general preferences..."
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Finder
    print_status "Configuring Finder..."
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Dock
    print_status "Configuring Dock..."
    defaults write com.apple.dock tilesize -int 36
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-process-indicators -bool true
    defaults write com.apple.dock launchanim -bool false
    
    # Screenshots
    print_status "Configuring screenshots..."
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"
    defaults write com.apple.screencapture type -string "png"
    
    # Restart affected applications
    killall Finder
    killall Dock
    
    print_success "macOS preferences configured"
}

# Setup SSH key for GitHub
setup_ssh_github() {
    print_section "Setting up SSH Key for GitHub"
    
    read -p "Do you want to set up SSH key for GitHub? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping SSH setup"
        return 0
    fi
    
    read -p "Enter your GitHub email: " github_email
    if [[ -z "$github_email" ]]; then
        print_error "Email is required"
        return 1
    fi
    
    # Generate SSH key
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        print_status "Generating SSH key..."
        ssh-keygen -t ed25519 -C "$github_email" -f "$HOME/.ssh/id_ed25519" -N ""
        
        # Add SSH key to ssh-agent
        eval "$(ssh-agent -s)"
        echo "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" > ~/.ssh/config
        ssh-add --apple-use-keychain ~/.ssh/id_ed25519
        
        # Copy public key to clipboard
        pbcopy < ~/.ssh/id_ed25519.pub
        
        print_success "SSH key generated and copied to clipboard"
        print_status "Please add this key to your GitHub account:"
        print_status "1. Go to https://github.com/settings/keys"
        print_status "2. Click 'New SSH key'"
        print_status "3. Paste the key and save"
        
        read -p "Press Enter when you've added the key to GitHub..."
        
        # Test SSH connection
        ssh -T git@github.com || print_warning "SSH test failed, but this is often normal"
    else
        print_success "SSH key already exists"
    fi
}

# Final cleanup and summary
cleanup_and_summary() {
    print_section "Cleanup and Summary"
    
    print_status "Running cleanup..."
    brew cleanup
    
    print_success "Setup completed successfully!"
    echo
    print_status "Summary of what was installed:"
    echo "  • Homebrew package manager"
    echo "  • Modern CLI tools (ripgrep, fzf, bat, exa, etc.)"
    echo "  • Development applications (VS Code, Docker, etc.)"
    echo "  • Productivity tools (Raycast, Rectangle, etc.)"
    echo "  • Developer fonts (Nerd Fonts)"
    echo "  • Programming languages (Node.js, Python, Ruby, Go, Rust)"
    echo "  • Development environment (NVM, pyenv, rbenv)"
    echo
    print_status "Next steps:"
    echo "  1. Install your dotfiles: ./scripts/install.sh"
    echo "  2. Restart your terminal"
    echo "  3. Configure applications as needed"
    echo "  4. Run 'p10k configure' to set up your prompt"
    echo
    print_warning "Some changes require a restart to take full effect"
}

# Main execution
main() {
    print_header
    
    print_status "This script will set up your macOS machine with modern development tools."
    print_status "Estimated time: 30-60 minutes depending on your internet connection."
    echo
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled."
        exit 0
    fi
    
    check_macos
    install_xcode_tools
    install_homebrew
    install_modern_cli_tools
    install_gui_applications
    install_fonts
    setup_dev_environment
    configure_macos
    setup_ssh_github
    cleanup_and_summary
    
    print_success "🎉 Your macOS development machine is ready!"
}

# Allow script to be sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi