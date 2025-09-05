# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==================== PERFORMANCE OPTIMIZATIONS ====================
# zsh-defer will be loaded via Zinit for better performance
# Warp-compatible completion setup
# Skip custom completion optimization in Warp terminal as it has its own system
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  # Set up completions with better caching (only rebuild cache once per day)
  autoload -Uz compinit
  if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
fi

# Lazy load NVM
export NVM_DIR="$HOME/.nvm"
# Only set up NVM when we actually need it
nvm() {
  unset -f nvm node npm npx pnpm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}
node() {
  unset -f nvm node npm npx pnpm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  node "$@"
}
npm() {
  unset -f nvm node npm npx pnpm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  npm "$@"
}
npx() {
  unset -f nvm node npm npx pnpm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  npx "$@"
}
pnpm() {
  unset -f nvm node npm npx pnpm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  pnpm "$@"
}

# ==================== ENVIRONMENT VARIABLES ====================
# Consolidate PATH exports to avoid multiple PATH modifications
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$HOME/.poetry/bin:$HOME/bin:/usr/local/bin:/usr/local/opt/grep/libexec/gnubin:/opt/homebrew/opt/llvm/bin:$HOME/go/bin:/usr/local/go/bin:/opt/homebrew/opt/fzf/bin:$PATH"
export GOPATH=$HOME/go
# Only set GPG_TTY if actually using GPG to avoid command execution
if command -v gpg >/dev/null 2>&1; then
  export GPG_TTY=$(tty)
fi
export PYTHONBREAKPOINT=ipdb.set_trace
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export CC=clang
export CXX=clang++

# ==================== OH-MY-ZSH SETUP ====================
# Skip in Warp to reduce initialization time
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  plugins=(git)
  export ZSH="$HOME/.oh-my-zsh"
  source $ZSH/oh-my-zsh.sh
fi

# ==================== NETWORK CONFIGURATION ====================
# Source .netrc for network credentials if it exists
[ -f $HOME/.netrc ] && source $HOME/.netrc

# ==================== ASDF (VERSION MANAGER) ====================
# Lazy load ASDF to avoid startup delay
asdf() {
  unfunction asdf
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  asdf "$@"
}

# ==================== BASE16 SHELL THEME ====================
# Skip Base16 in Warp since it provides its own theming
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  BASE16_SHELL="$HOME/.config/base16-shell/"
  if [ -d "$BASE16_SHELL" ]; then
    [ -n "$PS1" ] && \
        [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
            source "$BASE16_SHELL/profile_helper.sh"
    # Load the default dark theme if it exists
    [ -s "$BASE16_SHELL/scripts/base16-default-dark.sh" ] && \
        source "$BASE16_SHELL/scripts/base16-default-dark.sh"
  fi
fi

set bell-style none

# ==================== POWERLEVEL10K THEME ====================
# Skip P10K in Warp since it provides its own prompt
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  # Try brew-installed p10k first, then fallback to manually installed
  if [[ -f "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
  elif [[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]]; then
    source ~/powerlevel10k/powerlevel10k.zsh-theme
  fi
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# ==================== ADDITIONAL TOOLS ====================
# FZF fuzzy finder - will be deferred after zinit loads zsh-defer
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Lazy load pyenv to avoid startup delay
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

# Bun setup
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# Bun completions - lazy loaded (skip in Warp to avoid conflicts)
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi

# Additional completion setup (if needed for custom completions) - Skip in Warp
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  fpath+=~/.zfunc
  # Completion styling
  zstyle ':completion:*' menu select
fi

# ==================== ALIASES ====================
# Load aliases from separate file for better organization
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# ==================== WARP TERMINAL INTEGRATION ====================
# Enable automatic Warp integration for subshells
# This should be at the end to avoid conflicts with shell initialization
printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'

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

# Now that zsh-defer is loaded, apply it to slow commands
zsh-defer -a [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  zsh-defer -a [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi
