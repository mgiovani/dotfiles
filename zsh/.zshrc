# ==================== ENVIRONMENT DETECTION ====================
# Detect if we're on macOS or Linux to adapt configurations
if [[ "$OSTYPE" == "darwin"* ]]; then
  export IS_MACOS=true
  export IS_LINUX=false
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export IS_MACOS=false
  export IS_LINUX=true
else
  export IS_MACOS=false
  export IS_LINUX=false
fi

# ==================== TMUX AUTO-START ====================
# Auto-start tmux if not already running and not in tmux (disabled by default)
# Uncomment the following lines if you want tmux to auto-start
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#   exec tmux new-session -A -s main
# fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==================== PERFORMANCE OPTIMIZATIONS ====================
# Set up completions with better caching (only rebuild cache once per day)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ==================== NODE VERSION MANAGER (NVM) ====================
# Lazy load NVM (macOS only - uses Homebrew paths)
if [[ "$IS_MACOS" == "true" ]]; then
  export NVM_DIR="$HOME/.nvm"
  # Only set up NVM when we actually need it
  nvm() {
    unset -f nvm node npm npx pnpm bru
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    nvm "$@"
  }
  node() {
    unset -f nvm node npm npx pnpm bru
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    node "$@"
  }
  npm() {
    unset -f nvm node npm npx pnpm bru
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    npm "$@"
  }
  npx() {
    unset -f nvm node npm npx pnpm bru
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    npx "$@"
  }
  pnpm() {
    unset -f nvm node npm npx pnpm bru
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    pnpm "$@"
  }
  bru() {
    unset -f nvm node npm npx pnpm bru
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    bru "$@"
  }
fi

# ==================== ENVIRONMENT VARIABLES ====================
# Consolidate PATH exports to avoid multiple PATH modifications
if [[ "$IS_MACOS" == "true" ]]; then
  # macOS-specific paths (Homebrew)
  export PATH="/opt/homebrew/opt/libpq/bin:$HOME/.local/bin:/opt/homebrew/bin:$HOME/.poetry/bin:$HOME/bin:/usr/local/bin:/usr/local/opt/grep/libexec/gnubin:/opt/homebrew/opt/llvm/bin:$HOME/go/bin:/usr/local/go/bin:/opt/homebrew/opt/fzf/bin:$PATH"
else
  # Linux/VPS-specific paths
  export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$HOME/go/bin:/usr/local/go/bin:$PATH"
  # Add cargo bin if it exists (for Rust tools)
  if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
fi
export GOPATH=$HOME/go
# Only set GPG_TTY if actually using GPG to avoid command execution
if command -v gpg >/dev/null 2>&1; then
  export GPG_TTY=$(tty)
fi
export PYTHONBREAKPOINT=ipdb.set_trace
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
# ==================== COMPILER CONFIGURATION ====================
if [[ "$IS_MACOS" == "true" ]]; then
  export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
  export CC=clang
  export CXX=clang++
fi
export FZF_DEFAULT_OPTS="--color=dark --color=fg:-1,bg:-1,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf"


# ==================== OH-MY-ZSH SETUP ====================
# OH-MY-ZSH initialization
plugins=(git)
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# ==================== NETWORK CONFIGURATION ====================
# Source .netrc for network credentials if it exists
[ -f $HOME/.netrc ] && source $HOME/.netrc

# ==================== ASDF (VERSION MANAGER) ====================
# Lazy load ASDF to avoid startup delay (macOS only)
if [[ "$IS_MACOS" == "true" ]]; then
  asdf() {
    unfunction asdf
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
    asdf "$@"
  }
fi

# Base16 Shell will be loaded by Zinit below

set bell-style none

# ==================== POWERLEVEL10K THEME ====================
# Powerlevel10k will be loaded by Zinit below - no manual sourcing needed
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ==================== ADDITIONAL TOOLS ====================
# FZF fuzzy finder - platform-specific paths
if [[ "$IS_MACOS" == "true" ]]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
else
  # Linux FZF integration - try common paths
  if command -v fzf &> /dev/null; then
    # Try common FZF installation paths on Linux
    [ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi

# Lazy load pyenv to avoid startup delay (macOS only)
if [[ "$IS_MACOS" == "true" ]]; then
  pyenv() {
    unfunction pyenv
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi
    pyenv "$@"
  }
  python() {
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
      unfunction python
    fi
    python "$@"
  }
fi

# Bun setup (macOS only)
if [[ "$IS_MACOS" == "true" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi

fpath+=~/.zfunc
# Completion styling
zstyle ':completion:*' menu select

# ==================== ALIASES ====================
# Load aliases from separate file for better organization
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# ==================== CLAUDE CLI ALIAS BYPASS ====================
# Disable modern tool aliases when CLAUDE_CLI is set for compatibility
if [[ -n "$CLAUDE_CLI" ]]; then
  # Unalias modern replacements to use original commands
  unalias ls ll la tree cat less grep search find du df ps htop top rm time 2>/dev/null

  # Disable delta for git commands - use plain diff output
  export GIT_PAGER=""
  alias git='git -c core.pager="" -c interactive.difffilter=""'
fi

# ==================== ZINIT PLUGIN MANAGER ====================

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

# ==================== ZINIT TURBO MODE PLUGINS ====================
# Load plugins with turbo mode for better performance

# Powerlevel10k theme - load immediately for prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Base16 Shell - load immediately for theme consistency
zinit load chriskempson/base16-shell

# Syntax highlighting - load after 1 second
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  blockf \
  zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

# Load zsh-defer with zinit for even better performance
zinit load romkatv/zsh-defer

# Now that zsh-defer is loaded, apply it to slow commands (macOS only)
if [[ "$IS_MACOS" == "true" ]]; then
  zsh-defer -a [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  zsh-defer -a [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi

# Zoxide integration - lazy load for better performance (if available)
if command -v zoxide >/dev/null 2>&1; then
  if [[ "$IS_MACOS" == "true" ]]; then
    zsh-defer -a eval "$(zoxide init zsh)"
  else
    eval "$(zoxide init zsh)"
  fi
fi

# Set Base16 theme after plugins are loaded (if available)
if command -v base16_default-dark >/dev/null 2>&1; then
  base16_default-dark
fi

# Load thefuck if available (macOS only)
if [[ "$IS_MACOS" == "true" ]] && command -v thefuck >/dev/null 2>&1; then
  eval $(thefuck --alias)
fi
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
