# Dotfiles

Modern dotfiles for macOS development environment with curated tools and configurations. Designed to be used by anyone looking for a productive development setup.

## Quick Start

```bash
git clone https://github.com/mgiovani/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
make install
```

## What's Included

- **Zsh**: Modern shell with Zinit plugin manager and Powerlevel10k
- **Vim/Neovim**: Both configurations with vim-plug and essential plugins
- **Tmux**: Terminal multiplexer with vim-like keybindings
- **Git**: Enhanced with delta for beautiful diffs
- **Modern CLI tools**: ripgrep, fzf, bat, eza, and more
- **Development setup**: Node.js, Python, Go, databases
- **Applications**: Cursor, iTerm2, Raycast, browsers, etc.

## Installation Options

### Full Installation
```bash
make install
```

### Selective Installation
```bash
make install-selective
```

### Configuration-based Installation
```bash
make install-config
# Will create config file if it doesn't exist
```

### Available Commands
```bash
make help          # Show all available commands
make update         # Update Homebrew packages
make backup         # Backup current configurations
make bootstrap      # Setup new machine from scratch
```

## Structure

```
├── git/         # Git configuration
├── vim/         # Vim configuration
├── nvim/        # Neovim configuration (lazy migration from vim)
├── zsh/         # Zsh, aliases, and shell configuration
├── tmux/        # Tmux configuration
├── cursor/      # Cursor IDE configuration
├── iterm2/      # iTerm2 preferences
├── raycast/     # Raycast extensions list
├── scripts/     # Installation and setup scripts
└── Brewfile     # Homebrew packages
```

## Modern Tools

This setup replaces traditional Unix tools with modern alternatives:

- `grep` → `ripgrep` (rg)
- `find` → `fd`
- `cat` → `bat`
- `ls` → `eza`
- `du` → `dust`
- `df` → `duf`
- `ps` → `procs`
- `top` → `bottom`

All configurations include fallbacks to traditional tools if modern ones aren't available.

## Key Features

- **Performance optimized**: Lazy loading and efficient startup
- **Cross-platform**: Works on macOS and Linux
- **Vim-like**: Consistent vim keybindings across tools (tmux, cursor)
- **Modern themes**: Base16 Dark Default theme throughout
- **Git integration**: Enhanced diffs with delta, gitgutter, fugitive
- **Developer fonts**: Nerd fonts with icon support

## Customization

Edit configurations directly in their respective directories. All symlinks are managed with GNU Stow for easy maintenance.

## Requirements

- macOS (10.15+) or Linux
- Homebrew (macOS) or system package manager
- Git

The installation script will handle most dependencies automatically.