#!/bin/bash

# macOS System Configuration Script
# Applies developer-friendly system preferences and optimizations

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
    echo -e "${PURPLE}║                     macOS System Configuration                              ║${NC}"
    echo -e "${PURPLE}║                   Developer-Optimized Settings                             ║${NC}"
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

# Check if running on macOS and version
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    
    local macos_version=$(sw_vers -productVersion)
    local major_version=$(echo "$macos_version" | cut -d. -f1)
    local minor_version=$(echo "$macos_version" | cut -d. -f2)
    
    print_success "Running on macOS $macos_version"
    
    if [[ $major_version -ge 15 ]]; then
        print_status "macOS Sequoia (15.x) detected - using latest optimizations"
        MACOS_SEQUOIA=true
    elif [[ $major_version -ge 14 ]]; then
        print_status "macOS Sonoma (14.x) detected"
        MACOS_SEQUOIA=false
    else
        print_warning "macOS version older than Sonoma - some features may not be available"
        MACOS_SEQUOIA=false
    fi
}

# Ask for administrator password upfront
request_sudo() {
    print_section "Administrator Access"
    print_status "Some configurations require administrator privileges."
    sudo -v
    
    # Keep sudo alive throughout the script
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Close System Preferences to prevent conflicts
close_system_preferences() {
    print_status "Closing System Preferences..."
    osascript -e 'tell application "System Preferences" to quit'
}

# Configure General UI/UX settings
configure_general() {
    print_section "General UI/UX Settings"
    
    print_status "Setting appearance preferences..."
    # Set interface style to dark mode
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    
    # macOS Sequoia specific settings
    if [[ "$MACOS_SEQUOIA" == true ]]; then
        print_status "Applying macOS Sequoia 15.1+ specific optimizations..."
        
        # Enable enhanced security for app downloads (Sequoia)
        defaults write com.apple.LaunchServices LSRequireApplicationSignature -bool true
        
        # Improve window server performance (Sequoia optimization)
        defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
        
        # Optimize memory management for Sequoia
        defaults write NSGlobalDomain NSApplicationCrashOnExceptions -bool false
    fi
    
    # Always show scrollbars
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
    
    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    
    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    
    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
    
    # Remove duplicates in the "Open With" menu
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
    
    print_success "General settings configured"
}

# Configure input devices (trackpad, mouse, keyboard)
configure_input() {
    print_section "Input Device Settings"
    
    print_status "Configuring trackpad..."
    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    
    print_status "Configuring keyboard..."
    # Set keyboard repeat rate (fast)
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
    
    print_success "Input device settings configured"
}

# Configure screen and display settings
configure_screen() {
    print_section "Screen & Display Settings"
    
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"
    
    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    
    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 1
    
    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
    
    print_success "Screen settings configured"
}

# Configure Finder
configure_finder() {
    print_section "Finder Configuration"
    
    print_status "Setting Finder preferences..."
    # Allow quitting via ⌘ + Q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true
    
    # Show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Enable spring loading for directories
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true
    
    # Remove the spring loading delay for directories
    defaults write NSGlobalDomain com.apple.springing.delay -float 0
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    # Use list view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # Show the ~/Library folder
    chflags nohidden ~/Library
    
    # Show the /Volumes folder
    sudo chflags nohidden /Volumes
    
    print_success "Finder configured"
}

# Configure Dock
configure_dock() {
    print_section "Dock Configuration"
    
    print_status "Setting Dock preferences..."
    # Set the icon size of Dock items to 36 pixels
    defaults write com.apple.dock tilesize -int 36
    
    # Change minimize/maximize window effect to scale
    defaults write com.apple.dock mineffect -string "scale"
    
    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true
    
    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
    
    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Don't animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false
    
    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.1
    
    # Don't group windows by application in Mission Control
    defaults write com.apple.dock expose-group-by-app -bool false
    
    # Remove the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0
    
    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0
    
    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    
    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true
    
    # Hot corners
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center
    # 13: Lock Screen
    
    # Bottom right screen corner → Desktop
    defaults write com.apple.dock wvous-br-corner -int 4
    defaults write com.apple.dock wvous-br-modifier -int 0
    
    print_success "Dock configured"
}

# Configure Safari & Privacy
configure_safari() {
    print_section "Safari & Privacy Configuration"
    
    print_status "Setting Safari preferences..."
    # Privacy: don't send search queries to Apple
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true
    
    # Show the full URL in the address bar (note: this still hides the scheme)
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
    
    # Set Safari's home page to about:blank for faster loading
    defaults write com.apple.Safari HomePage -string "about:blank"
    
    # Prevent Safari from opening 'safe' files automatically after downloading
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
    
    # Hide Safari's bookmarks bar by default
    defaults write com.apple.Safari ShowFavoritesBar -bool false
    
    # Hide Safari's sidebar in Top Sites
    defaults write com.apple.Safari ShowSidebarInTopSites -bool false
    
    # Enable Safari's debug menu
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
    
    # Enable the Develop menu and the Web Inspector in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
    
    print_success "Safari configured"
}

# Configure Terminal
configure_terminal() {
    print_section "Terminal Configuration"
    
    print_status "Setting Terminal preferences..."
    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4
    
    # Enable Secure Keyboard Entry in Terminal.app
    defaults write com.apple.terminal SecureKeyboardEntry -bool true
    
    # Disable the annoying line marks
    defaults write com.apple.Terminal ShowLineMarks -int 0
    
    print_success "Terminal configured"
}

# Configure development-related settings
configure_development() {
    print_section "Development Environment Settings"
    
    print_status "Configuring development preferences..."
    # Show build times in Xcode
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool true
    
    # Enable developer mode for crash reports
    sudo /usr/sbin/DevToolsSecurity -enable
    
    # Install command line tools if not already installed
    if ! xcode-select -p &> /dev/null; then
        print_status "Installing Xcode Command Line Tools..."
        xcode-select --install
    fi
    
    print_success "Development environment configured"
}

# Configure security settings
configure_security() {
    print_section "Security Configuration"
    
    print_status "Enhancing security settings..."
    # Enable firewall
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    
    # Enable stealth mode (don't respond to ICMP ping)
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    
    # Enable firewall logging
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    
    print_success "Security settings configured"
}

# Kill affected applications
restart_applications() {
    print_section "Restarting Applications"
    
    print_status "Applying changes by restarting applications..."
    
    for app in "Activity Monitor" \
        "cfprefsd" \
        "Dock" \
        "Finder" \
        "Safari" \
        "SystemUIServer" \
        "Terminal"; do
        
        if pgrep "$app" > /dev/null; then
            print_status "Restarting $app..."
            killall "$app" &> /dev/null || true
        fi
    done
    
    print_success "Applications restarted"
}

# Main execution
main() {
    print_header
    
    print_warning "This script will modify your macOS system preferences."
    print_warning "Some changes require a restart to take full effect."
    echo
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Configuration cancelled."
        exit 0
    fi
    
    check_macos
    request_sudo
    close_system_preferences
    
    configure_general
    configure_input
    configure_screen
    configure_finder
    configure_dock
    configure_safari
    configure_terminal
    configure_development
    configure_security
    
    restart_applications
    
    print_success "🎉 macOS configuration completed!"
    print_warning "Some changes may require a full restart to take effect."
    echo
    print_status "You may want to:"
    echo "  • Restart your Mac to ensure all changes take effect"
    echo "  • Adjust any settings that don't suit your preferences"
    echo "  • Install additional applications from the App Store"
}

# Allow script to be sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi