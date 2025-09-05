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
    
    # Parse Brewfile to extract packages
    local brew_packages=$(grep '^brew ' "$brewfile" | sed 's/brew "//' | sed 's/".*//' | tr '\n' ' ')
    local cask_packages=$(grep '^cask ' "$brewfile" | sed 's/cask "//' | sed 's/".*//' | tr '\n' ' ')
    local font_packages=$(echo "$cask_packages" | tr ' ' '\n' | grep '^font-' | tr '\n' ' ')
    local app_packages=$(echo "$cask_packages" | tr ' ' '\n' | grep -v '^font-' | tr '\n' ' ')
    
    echo -e "${BLUE}Found $(echo $brew_packages | wc -w) brew packages and $(echo $cask_packages | wc -w) cask packages in Brewfile${NC}"
    echo
    
    # Arrays to collect selected packages
    local selected_brew=()
    local selected_cask=()
    local install_dotfiles_flag=false
    
    # Function to ask for each package
    ask_packages() {
        local category="$1"
        local packages="$2"
        local package_type="$3"
        
        echo -e "${BLUE}=== $category ===${NC}"
        
        for package in $packages; do
            read -n 1 -p "Install $package? [y/N]: " answer
            echo
            if [[ $answer =~ ^[Yy]$ ]]; then
                if [[ $package_type == "brew" ]]; then
                    selected_brew+=("$package")
                else
                    selected_cask+=("$package")
                fi
                echo -e "${GREEN}✓ Added $package to installation list${NC}"
            fi
        done
        echo
    }
    
    # Ask for each category from Brewfile
    ask_packages "CLI Tools" "$brew_packages" "brew"
    ask_packages "Applications" "$app_packages" "cask"
    ask_packages "Fonts" "$font_packages" "cask"
    
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
    fi
    
    echo -e "${GREEN}Interactive installation completed!${NC}"
}

main() {
    print_header
    
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
                break
                ;;
            6)
                install_dotfiles
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