#!/bin/bash

# SSH Key Setup Script for GitHub and other services
# Generates SSH keys and helps configure them for various services

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
    echo -e "${PURPLE}║                          SSH Key Setup                                      ║${NC}"
    echo -e "${PURPLE}║                    Generate & Configure SSH Keys                           ║${NC}"
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

# Check if SSH key already exists
check_existing_keys() {
    print_section "Checking Existing SSH Keys"
    
    if [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]; then
        print_warning "SSH keys already exist:"
        ls -la "$HOME/.ssh/"*.pub 2>/dev/null || true
        echo
        read -p "Do you want to create a new key anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Using existing SSH keys."
            return 1
        fi
    fi
    return 0
}

# Generate SSH key
generate_ssh_key() {
    print_section "Generating SSH Key"
    
    # Get email address
    read -p "Enter your email address: " email
    if [[ -z "$email" ]]; then
        print_error "Email address is required"
        exit 1
    fi
    
    # Get optional comment/identifier
    read -p "Enter a comment/identifier (optional, e.g., 'work', 'personal'): " comment
    if [[ -n "$comment" ]]; then
        key_file="$HOME/.ssh/id_ed25519_$comment"
        full_comment="$email ($comment)"
    else
        key_file="$HOME/.ssh/id_ed25519"
        full_comment="$email"
    fi
    
    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate the key
    print_status "Generating SSH key: $key_file"
    ssh-keygen -t ed25519 -C "$full_comment" -f "$key_file" -N ""
    
    # Set proper permissions
    chmod 600 "$key_file"
    chmod 644 "$key_file.pub"
    
    print_success "SSH key generated: $key_file"
    
    # Store key info for later use
    GENERATED_KEY="$key_file"
    GENERATED_EMAIL="$email"
}

# Configure SSH agent
configure_ssh_agent() {
    print_section "Configuring SSH Agent"
    
    print_status "Adding key to SSH agent..."
    
    # Start ssh-agent if not running
    if ! pgrep -x ssh-agent > /dev/null; then
        eval "$(ssh-agent -s)"
    fi
    
    # Create or update SSH config
    ssh_config="$HOME/.ssh/config"
    
    if [[ ! -f "$ssh_config" ]]; then
        print_status "Creating SSH config file..."
        cat > "$ssh_config" << EOF
# SSH Configuration
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

EOF
        chmod 600 "$ssh_config"
    else
        # Check if our config already exists
        if ! grep -q "UseKeychain yes" "$ssh_config"; then
            print_status "Updating SSH config..."
            echo "" >> "$ssh_config"
            echo "# Auto-generated SSH config" >> "$ssh_config"
            echo "Host *" >> "$ssh_config"
            echo "  AddKeysToAgent yes" >> "$ssh_config"
            echo "  UseKeychain yes" >> "$ssh_config"
        fi
    fi
    
    # Add key to ssh-agent and keychain (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ssh-add --apple-use-keychain "$GENERATED_KEY"
    else
        ssh-add "$GENERATED_KEY"
    fi
    
    print_success "SSH agent configured"
}

# Display public key and copy to clipboard
show_public_key() {
    print_section "Your SSH Public Key"
    
    local public_key_file="${GENERATED_KEY}.pub"
    local public_key_content=$(cat "$public_key_file")
    
    echo -e "${YELLOW}Public key content:${NC}"
    echo "$public_key_content"
    echo
    
    # Copy to clipboard if possible
    if command -v pbcopy &> /dev/null; then
        echo "$public_key_content" | pbcopy
        print_success "Public key copied to clipboard!"
    elif command -v xclip &> /dev/null; then
        echo "$public_key_content" | xclip -selection clipboard
        print_success "Public key copied to clipboard!"
    else
        print_warning "Could not copy to clipboard. Please copy the key manually."
    fi
}

# GitHub setup instructions
github_setup() {
    print_section "GitHub Setup Instructions"
    
    print_status "To add this key to your GitHub account:"
    echo "  1. Go to https://github.com/settings/keys"
    echo "  2. Click 'New SSH key'"
    echo "  3. Give it a title (e.g., 'MacBook Pro - $(date +%Y)')"
    echo "  4. Paste the public key (already copied to your clipboard)"
    echo "  5. Click 'Add SSH key'"
    echo
    
    read -p "Press Enter when you've added the key to GitHub..."
    
    # Test GitHub connection
    print_status "Testing GitHub SSH connection..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_success "GitHub SSH connection successful!"
    else
        print_warning "GitHub SSH test failed, but this is often normal for first-time setup."
        print_status "The connection will work for git operations even if the test shows a warning."
    fi
}

# Other services setup
other_services_setup() {
    print_section "Other Git Services"
    
    print_status "You can also add this key to other services:"
    echo "  • GitLab: https://gitlab.com/-/profile/keys"
    echo "  • Bitbucket: https://bitbucket.org/account/settings/ssh-keys/"
    echo "  • Azure DevOps: https://dev.azure.com/[organization]/_usersSettings/keys"
    echo "  • Your own Git server"
    echo
    
    print_status "For each service:"
    echo "  1. Visit the SSH keys settings page"
    echo "  2. Add a new SSH key"
    echo "  3. Paste the public key content"
    echo "  4. Give it a descriptive name"
}

# Configure Git with SSH
configure_git() {
    print_section "Git Configuration"
    
    # Check if git user is configured
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_name" ]]; then
        read -p "Enter your Git username: " git_name
        git config --global user.name "$git_name"
    fi
    
    if [[ -z "$git_email" ]]; then
        git config --global user.email "$GENERATED_EMAIL"
    fi
    
    # Configure Git to use SSH URLs
    print_status "Configuring Git to use SSH URLs for GitHub..."
    git config --global url."git@github.com:".insteadOf "https://github.com/"
    
    print_success "Git configured to use SSH"
    print_status "Git user: $git_name <$GENERATED_EMAIL>"
}

# Summary
show_summary() {
    print_section "Setup Complete!"
    
    print_success "SSH key setup completed successfully!"
    echo
    print_status "Summary:"
    echo "  • SSH key generated: $GENERATED_KEY"
    echo "  • Key added to SSH agent and keychain"
    echo "  • Public key copied to clipboard"
    echo "  • Git configured to use SSH URLs"
    echo
    print_status "Next steps:"
    echo "  • Add the public key to your Git services (GitHub, GitLab, etc.)"
    echo "  • Test cloning a repository: git clone git@github.com:username/repo.git"
    echo "  • Your SSH key will be automatically used for authentication"
    echo
    print_warning "Keep your private key ($GENERATED_KEY) secure and never share it!"
}

# Main execution
main() {
    print_header
    
    print_status "This script will generate SSH keys and configure them for Git services."
    print_status "The keys will be added to your SSH agent and keychain for convenience."
    echo
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "SSH setup cancelled."
        exit 0
    fi
    
    if check_existing_keys; then
        generate_ssh_key
        configure_ssh_agent
        show_public_key
        configure_git
        github_setup
        other_services_setup
        show_summary
    else
        print_status "Using existing SSH keys. You can manually configure services if needed."
        if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
            cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
            print_success "Existing public key copied to clipboard"
        fi
    fi
}

# Allow script to be sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi