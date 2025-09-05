#!/usr/bin/env bash

# Selective Installation Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║               Installation                   ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}"
    echo
}

# Check and install Homebrew if needed
check_homebrew() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add Homebrew to PATH for Apple Silicon Macs
            if [[ $(uname -m) == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            echo -e "${GREEN}Homebrew installed successfully!${NC}"
        else
            echo -e "${GREEN}Homebrew already installed.${NC}"
        fi
    fi
}

show_menu() {
    echo -e "${BLUE}Choose what to install:${NC}"
    echo
    echo "1) Essential tools only (git, curl, wget, stow)"
    echo "2) Modern CLI tools (ripgrep, fzf, bat, eza, etc.)"
    echo "3) Development tools (vim, tmux, languages, databases)"
    echo "4) Applications (cursor, terminals, browsers)"
    echo "5) Everything (full installation)"
    echo "6) Just dotfiles (no packages)"
    echo "7) Interactive (y/n for each package)"
    echo "q) Quit"
    echo
}

install_essential() {
    echo -e "${GREEN}Installing essential tools...${NC}"
    brew install curl wget git openssh gnupg stow
}

install_modern_cli() {
    echo -e "${GREEN}Installing modern CLI tools...${NC}"
    brew install ripgrep fzf fd bat eza dust duf procs bottom tree zoxide mcfly tldr thefuck trash choose navi
}

install_dev_tools() {
    echo -e "${GREEN}Installing development tools...${NC}"
    brew install vim neovim tmux jq yq fx httpie hyperfine lf watch node python@3.12 go libpq sqlite docker-compose bruno-cli gh delta
}

install_applications() {
    echo -e "${GREEN}Installing applications...${NC}"
    brew install --cask cursor iterm2 warp insomnia bruno raycast rectangle alt-tab google-chrome microsoft-edge 1password 1password-cli vlc
    brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-cascadia-code
}

install_dotfiles() {
    echo -e "${GREEN}Installing dotfiles...${NC}"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$SCRIPT_DIR/install.sh"
}

install_oh_my_zsh() {
    echo -e "${GREEN}Installing Oh My Zsh...${NC}"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}✓ Oh My Zsh installed${NC}"
    else
        echo -e "${GREEN}✓ Oh My Zsh already installed${NC}"
    fi
}

install_powerlevel10k() {
    echo -e "${GREEN}Installing Powerlevel10k theme...${NC}"
    
    # If brew installed p10k, we're done
    if brew list powerlevel10k &> /dev/null; then
        echo -e "${GREEN}✓ Powerlevel10k installed via Homebrew${NC}"
    elif [[ ! -d "$HOME/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        echo -e "${GREEN}✓ Powerlevel10k installed${NC}"
    else
        echo -e "${GREEN}✓ Powerlevel10k already installed${NC}"
    fi
}


install_interactive() {
    echo -e "${GREEN}Interactive installation - choose each package individually${NC}"
    echo -e "${BLUE}(Will ask about each package, then install all selected at once)${NC}"
    echo
    
    # Get script directory and find Brewfile
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local brewfile="$(dirname "$script_dir")/Brewfile"
    
    if [[ ! -f "$brewfile" ]]; then
        echo -e "${RED}Error: Brewfile not found at $brewfile${NC}"
        return 1
    fi
    
    # Parse Brewfile to extract packages with comments
    local brew_lines=$(grep '^brew ' "$brewfile")
    local cask_lines=$(grep '^cask ' "$brewfile")
    
    echo -e "${BLUE}Found $(echo "$brew_lines" | wc -l) brew packages and $(echo "$cask_lines" | wc -l) cask packages in Brewfile${NC}"
    echo
    
    # Arrays to collect selected packages
    local selected_brew=()
    local selected_cask=()
    local install_dotfiles_flag=false
    
    # Function to ask for each package with description
    ask_brew_packages() {
        echo -e "${BLUE}=== CLI Tools ===${NC}"
        
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                local package=$(echo "$line" | sed 's/brew "//' | sed 's/".*//')
                local comment=$(echo "$line" | grep -o '#.*' | sed 's/^# *//' || echo "")
                
                if [[ -n "$comment" ]]; then
                    echo -e "${YELLOW}$package${NC} - $comment"
                    read -n 1 -p "Install? [y/N]: " answer
                else
                    read -n 1 -p "Install $package? [y/N]: " answer
                fi
                echo
                
                if [[ $answer =~ ^[Yy]$ ]]; then
                    selected_brew+=("$package")
                    echo -e "${GREEN}✓ Added $package${NC}"
                fi
            fi
        done <<< "$brew_lines"
        echo
    }
    
    # Function to ask for cask packages with description  
    ask_cask_packages() {
        local category="$1"
        local filter="$2"
        
        echo -e "${BLUE}=== $category ===${NC}"
        
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                local package=$(echo "$line" | sed 's/cask "//' | sed 's/".*//')
                local comment=$(echo "$line" | grep -o '#.*' | sed 's/^# *//' || echo "")
                
                # Apply filter
                if [[ "$filter" == "font" && ! "$package" =~ ^font- ]]; then
                    continue
                elif [[ "$filter" == "app" && "$package" =~ ^font- ]]; then
                    continue
                fi
                
                if [[ -n "$comment" ]]; then
                    echo -e "${YELLOW}$package${NC} - $comment"
                    read -n 1 -p "Install? [y/N]: " answer
                else
                    read -n 1 -p "Install $package? [y/N]: " answer
                fi
                echo
                
                if [[ $answer =~ ^[Yy]$ ]]; then
                    selected_cask+=("$package")
                    echo -e "${GREEN}✓ Added $package${NC}"
                fi
            fi
        done <<< "$cask_lines"
        echo
    }
    
    # Ask for each category from Brewfile
    ask_brew_packages
    ask_cask_packages "Applications" "app"
    ask_cask_packages "Fonts" "font"
    
    # Ask about dotfiles
    read -n 1 -p "Install dotfiles configurations? [y/N]: " answer
    echo
    if [[ $answer =~ ^[Yy]$ ]]; then
        install_dotfiles_flag=true
        echo -e "${GREEN}✓ Added dotfiles to installation list${NC}"
    fi
    echo
    
    # Show summary
    echo -e "${BLUE}=== Installation Summary ===${NC}"
    if [[ ${#selected_brew[@]} -gt 0 ]]; then
        echo -e "${GREEN}Brew packages (${#selected_brew[@]}):${NC} ${selected_brew[*]}"
    fi
    if [[ ${#selected_cask[@]} -gt 0 ]]; then
        echo -e "${GREEN}Cask applications (${#selected_cask[@]}):${NC} ${selected_cask[*]}"
    fi
    if [[ $install_dotfiles_flag == true ]]; then
        echo -e "${GREEN}Dotfiles:${NC} configurations will be installed"
    fi
    
    if [[ ${#selected_brew[@]} -eq 0 && ${#selected_cask[@]} -eq 0 && $install_dotfiles_flag == false ]]; then
        echo -e "${YELLOW}Nothing selected for installation.${NC}"
        return
    fi
    
    echo
    read -n 1 -p "Proceed with installation? [y/N]: " confirm
    echo
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        return
    fi
    
    echo
    echo -e "${GREEN}Starting installation...${NC}"
    
    # Install brew packages
    if [[ ${#selected_brew[@]} -gt 0 ]]; then
        echo -e "${GREEN}Installing brew packages...${NC}"
        brew install "${selected_brew[@]}" || echo -e "${YELLOW}Some brew packages failed to install${NC}"
    fi
    
    # Install cask applications
    if [[ ${#selected_cask[@]} -gt 0 ]]; then
        echo -e "${GREEN}Installing applications...${NC}"
        brew install --cask "${selected_cask[@]}" || echo -e "${YELLOW}Some applications failed to install${NC}"
    fi
    
    # Install dotfiles
    if [[ $install_dotfiles_flag == true ]]; then
        install_dotfiles
        install_oh_my_zsh
        install_powerlevel10k
    fi
    
    echo -e "${GREEN}Interactive installation completed!${NC}"
}

main() {
    print_header
    check_homebrew
    
    while true; do
        show_menu
        read -p "Enter your choice [1-7,q]: " choice
        echo
        
        case $choice in
            1)
                install_essential
                ;;
            2)
                install_modern_cli
                ;;
            3)
                install_dev_tools
                ;;
            4)
                install_applications
                ;;
            5)
                echo -e "${GREEN}Installing everything...${NC}"
                install_essential
                install_modern_cli
                install_dev_tools
                install_applications
                install_dotfiles
                install_oh_my_zsh
                install_powerlevel10k
                break
                ;;
            6)
                install_dotfiles
                install_oh_my_zsh
                install_powerlevel10k
                break
                ;;
            7)
                install_interactive
                break
                ;;
            q|Q)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                continue
                ;;
        esac
        
        echo
        read -p "Install more? [y/N]: " more
        if [[ ! $more =~ ^[Yy]$ ]]; then
            break
        fi
    done
    
    echo -e "${GREEN}Installation completed!${NC}"
}

main "$@"