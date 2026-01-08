# Dotfiles

Modern dotfiles for macOS development environment with curated tools and configurations. Designed to be used by anyone looking for a productive development setup.

## Quick Start

```bash
git clone https://github.com/mgiovani/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
make install
```

## What's Included

- **Zsh**: Modern shell with Zinit plugin manager and Powerlevel10k theme
- **Vim/Neovim**: Both configurations with vim-plug and essential plugins  
- **Tmux**: Terminal multiplexer with vim-like keybindings
- **Git**: Enhanced with delta for beautiful diffs
- **Modern CLI tools**: ripgrep, fzf, bat, eza, and more
- **Development stack**: Node.js, Python, Go (no Ruby/rbenv)
- **Applications**: Cursor, iTerm2, Raycast, browsers, etc.

## Installation Options

### 🚀 Full Installation (Recommended)
Installs everything from the Brewfile plus dotfiles configurations.
```bash
make install
```

### 🎯 Selective Installation  
Interactive installation - choose packages individually with descriptions.
```bash
make install-selective
```

### 📋 Configuration-based Installation
Uses a configuration file where all packages are pre-listed - just remove what you don't want.
```bash
make install-config
# Creates install-config.yml with ALL packages included
# Edit the file to remove unwanted packages, then run again
```

The configuration-based approach includes every package from the Brewfile with descriptions, so you simply delete the lines for packages you don't want rather than having to know what to add.

### Available Commands
```bash
make help          # Show all available commands
make update         # Update Homebrew packages  
make backup         # Backup current configurations
make bootstrap      # Setup new machine from scratch
```

## Zero-Prerequisites Setup

✅ **Homebrew auto-install**: Scripts automatically install Homebrew if missing  
✅ **Package descriptions**: Interactive mode shows what each tool does  
✅ **Cross-platform paths**: Supports both Apple Silicon and Intel Macs  
✅ **Enterprise-friendly**: Respects corporate policies and restrictions  

## Structure

```
├── git/            # Git configuration with delta integration
├── vim/            # Vim configuration  
├── nvim/           # Neovim configuration (lazy migration from vim)
├── zsh/            # Zsh, aliases, and shell configuration
├── tmux/           # Tmux configuration with vim-like keybindings
├── cursor/         # Cursor IDE configuration with vim extension
├── iterm2/         # iTerm2 preferences
├── terminal/       # Windows Terminal configuration
├── raycast/        # Raycast extensions list
├── scripts/        # Installation and setup scripts
└── Brewfile        # All Homebrew packages with descriptions
```

## Modern CLI Replacements

This setup replaces traditional Unix tools with modern, faster alternatives:

| Traditional | Modern Alternative | Benefits |
|-------------|-------------------|----------|
| `grep` | `ripgrep` (rg) | 10x faster, smarter defaults |
| `find` | `fd` | Simple syntax, faster |  
| `cat` | `bat` | Syntax highlighting, Git integration |
| `ls` | `eza` | Colors, icons, Git status |
| `du` | `dust` | Tree view, intuitive output |
| `df` | `duf` | Colorful, user-friendly |
| `ps` | `procs` | Modern output, filtering |
| `top` | `bottom` | Better UI, more info |

All configurations include fallbacks to traditional tools if modern ones aren't available.

## Development Stack

**Languages & Runtimes:**
- **Node.js** + fnm (Fast Node Manager - 40x faster than nvm)
- **Python** + uv (Ultra-fast package manager - replaces pyenv, pip, poetry)
- **Go** (Systems programming, CLI tools)

**No Ruby/rbenv** - Removed to keep the setup focused on actively used technologies.

**Key Tools:**
- **Powerlevel10k**: Fast, customizable zsh theme (installed via brew)
- **Base16 Shell**: Consistent color themes across all terminal applications
- **Delta**: Beautiful git diffs optimized for dark terminals with readable colors
- **Tmux**: Terminal multiplexer with vim-like navigation
- **Cursor**: AI-enhanced VS Code fork for modern development

## Key Features

- **🚀 Performance optimized**: Lazy loading, efficient startup, turbo mode
- **🔄 Auto-installation**: Homebrew and dependencies installed automatically  
- **⚡ Interactive setup**: See package descriptions before installing
- **🎨 Consistent theming**: Base16 Dark theme across all tools
- **⌨️ Vim-everywhere**: Vim keybindings in tmux, Cursor, and terminal
- **🔧 Easy customization**: Well-organized configs with clear sections
- **🏢 Enterprise-ready**: Works with corporate policies and MDM

## Configuration Highlights

**🎯 Configuration-first approach**: The `install-config.yml` includes every package with descriptions - you remove what you don't want rather than guessing what to add.

**📦 Package descriptions**: Every tool in the Brewfile has a comment explaining its purpose, so you make informed choices.

**🔄 Backwards compatible**: Configurations gracefully handle missing tools and provide fallbacks.

## Customization

Edit configurations directly in their respective directories. All symlinks are managed with GNU Stow for easy maintenance and clean uninstallation.

**Popular customizations:**
- Edit `zsh/.zsh_aliases` for personal aliases  
- Modify `zsh/.p10k.zsh` for prompt customization
- Adjust `tmux/.tmux.conf` for keybinding preferences
- Configure `cursor/settings.json` for IDE preferences

## Requirements

- **macOS (10.15+)** or Linux  
- **Git** (usually pre-installed)
- **Internet connection** for downloading packages

**That's it!** The installation scripts handle:
- ✅ Homebrew installation (if missing)
- ✅ Correct PATH setup (Apple Silicon vs Intel)  
- ✅ Package installation and configuration
- ✅ Dotfiles symlinking with GNU Stow

## Getting Help

- Run `make help` to see all available commands
- Check individual config files for inline documentation  
- Each installation method provides clear next steps
- All scripts include error handling and helpful messages