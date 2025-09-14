set nocompatible
filetype off

" Auto install vim-plug and plugins
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'editorconfig/editorconfig-vim'

" Git
Plug 'tpope/vim-fugitive'

" Vim Customization
Plug 'chriskempson/base16-vim'
Plug 'bling/vim-airline'
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }
Plug 'junegunn/fzf.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'godlygeek/tabular'
Plug 'ryanoasis/vim-devicons'
Plug 'terryma/vim-multiple-cursors'
Plug 'vim-airline/vim-airline-themes'
Plug 'dense-analysis/ale'

" Python
Plug 'hynek/vim-python-pep8-indent'

" GO
Plug 'fatih/vim-go'

" Additional Tools
Plug 'github/copilot.vim'
Plug 'tpope/vim-abolish'
Plug 'puremourning/vimspector'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
Plug 'christoomey/vim-tmux-navigator'
Plug 'preservim/vimux'

call plug#end()


" Vim configs
filetype plugin indent on
set autoindent
set backspace=indent,eol,start
set cc=90
set clipboard=unnamed
set completeopt=longest,menuone
set cursorline
set directory=/tmp
set display=lastline
set encoding=utf8
set expandtab
set exrc
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set mouse=a
set noshowmode
set nowrap
set number
set report=0
set secure
set shiftround
set shiftwidth=4
set smartcase
set softtabstop=4
set splitbelow
set splitright
set tabstop=4
set title
set ttimeoutlen=10
set wildignore=*/htmlcov/*,*/functional*,*.swp,*.bak,*.pyc,*.class,*/node_modules/*,*/bower_components/*,*/.venv/*,*/__pycache__/*,*/.git/*,*/dist/*,*/build/*,*.egg-info/*
set wildmenu

" Performance optimizations
set lazyredraw
set ttyfast
set updatetime=300
set timeoutlen=500

let g:vimspector_enable_mappings = 'HUMAN'
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd VimEnter * command! W w
autocmd VimEnter * command! Wq wq
autocmd VimEnter * command! WQ wq
inoremap <C-c> <Esc><Esc>
map <F4> 5gg3f<SPACE>ly$ggp<S-a>:<SPACE>
map <S-Tab> :tabprevious<cr>
map <Tab> :tabnext<cr>
map <silent> <C-m> :set list!<CR>
nmap <F1> :noh<cr>
nmap <leader>o :Explore<cr>
nnoremap ' `
nnoremap / /\v
nnoremap <Down>  :resize -2<CR>
nnoremap <Left>  :vertical resize +2<CR>
nnoremap <Right> :vertical resize -2<CR>
nnoremap <Up>    :resize +2<CR>
nnoremap <leader>W :%s/\s\+$//<CR>:let @/=''<CR>
nnoremap ` '
nnoremap <c-p> :Files<CR>
noremap Q <Nop>
set listchars=tab:▸\ ,space:·,eol:¬
vnoremap / /\v

" ==================== MODERN FILE EXPLORER SETUP ====================
" Enhanced netrw (built-in file explorer) - modern NERDTree replacement
let g:netrw_banner = 0          " Hide banner
let g:netrw_liststyle = 3       " Tree view
let g:netrw_browse_split = 4    " Open in previous window
let g:netrw_altv = 1            " Open splits to the right
let g:netrw_winsize = 25        " Width of explorer
let g:netrw_list_hide = '.*\.swp$,.*\.pyc$,.*\.git/$'
let g:netrw_hide = 1            " Hide hidden files by default

" Modern file navigation shortcuts
nnoremap <leader>e :Explore<CR>
nnoremap <leader>v :Vexplore<CR>
nnoremap <leader>s :Sexplore<CR>
nnoremap <leader>t :Texplore<CR>

" Enhanced file finding with fzf
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :History<CR>

" Ripgrep integration for vim
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Legacy Ag command mapped to Rg for compatibility
command! -bang -nargs=* Ag
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" FZF
let g:fzf_preview_window = ['right,50%', 'ctrl-/']
let g:fzf_tags_command = 'ctags -R'

" FZF Base16 integration - matches vim colorscheme automatically
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" For better base16 integration, also set FZF environment variable
" This can be added to your shell config (zshrc/bashrc) for system-wide effect:
" export FZF_DEFAULT_OPTS="--color=dark --color=fg:-1,bg:-1,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf"

" Collors and Themes
syntax on
filetype plugin indent on
syntax enable

if isdirectory(expand($HOME . '/.vim/plugged/'))
    set background=dark

    " Fix background color rendering in terminal (required for Base16)
    let &t_ut=''
    let base16colorspace=256

    if isdirectory(expand($HOME . '/.vim/plugged/base16-vim/'))
        " Dynamic Base16 theme integration with shell
        if exists('$BASE16_THEME')
              \ && (!exists('g:colors_name') || g:colors_name != 'base16-$BASE16_THEME')
            let base16colorspace=256
            colorscheme base16-$BASE16_THEME
        else
            colorscheme base16-default-dark
        endif
    endif

    if isdirectory(expand($HOME . '/.vim/plugged/vim-airline/'))
        let g:airline#extensions#tabline#enabled = 1
        let g:airline_powerline_fonts = 1
        let g:airline_theme = 'base16'
        let g:airline#extensions#branch#enabled = 1
        let g:airline_mode_map = {
            \ '__'     : '-',
            \ 'c'      : 'C',
            \ 'i'      : 'I',
            \ 'ic'     : 'I',
            \ 'ix'     : 'I',
            \ 'n'      : 'N',
            \ 'multi'  : 'M',
            \ 'ni'     : 'N',
            \ 'no'     : 'N',
            \ 'R'      : 'R',
            \ 'Rv'     : 'R',
            \ 's'      : 'S',
            \ 'S'      : 'S',
            \ 't'      : 'T',
            \ 'v'      : 'V',
            \ 'V'      : 'V',
            \ }
        let g:airline_left_sep = ''
        let g:airline_right_sep = ''
        let g:airline#extensions#tabline#left_sep = ''
        let g:airline#extensions#tabline#left_alt_sep = ''

        " Customize sections - remove encoding, line/column, and percentage
        let g:airline_section_y = ''          " Remove encoding
        let g:airline_section_z = ''          " Remove line/column and percentage

        " ALE integrates automatically with airline
    endif

    if isdirectory(expand($HOME . '/.vim/plugged/vim-lsp/'))
        let g:lsp_diagnostics_enabled = 1
        let g:lsp_signs_enabled = 1
        let g:lsp_diagnostics_echo_cursor = 1
        let g:lsp_highlights_enabled = 1
        let g:lsp_textprop_enabled = 1
        let g:lsp_settings_filetype_python = ['ruff', 'pyright']
        let g:lsp_settings_enable_suggestions = 1
        let g:lsp_auto_enable = 1

        " Auto-install and configure language servers (2025 modern approach)
        let g:lsp_settings = {
        \ 'ruff': {
        \   'workspace_config': {
        \     'settings': {
        \       'args': ['--preview']
        \     }
        \   }
        \ },
        \ 'pyright': {
        \   'workspace_config': {
        \     'python': {
        \       'analysis': {
        \         'typeCheckingMode': 'basic',
        \         'diagnosticMode': 'workspace',
        \         'stubPath': './typings',
        \         'autoSearchPaths': v:true
        \       }
        \     }
        \   }
        \ }
        \}

        function! s:on_lsp_buffer_enabled() abort
            setlocal omnifunc=lsp#complete
            nmap <buffer> <leader>d <plug>(lsp-definition)
            nmap <buffer> gd <plug>(lsp-definition)
            nmap <buffer> gr <plug>(lsp-references)
            nmap <buffer> gi <plug>(lsp-implementation)
            nmap <buffer> gt <plug>(lsp-type-definition)
            nmap <buffer> <leader>rn <plug>(lsp-rename)
            nmap <buffer> [g <plug>(lsp-previous-diagnostic)
            nmap <buffer> ]g <plug>(lsp-next-diagnostic)
            nmap <buffer> K <plug>(lsp-hover)
        endfunction

        " Auto-install LSP servers only if not already installed
        function! s:install_lsp_servers_once()
            " Check if servers exist before installing
            if !executable('ruff') && !isdirectory(expand('~/.vim/lsp-settings/servers/ruff'))
                silent! LspInstallServer ruff
            endif

            if !isdirectory(expand('~/.vim/lsp-settings/servers/pyright-langserver'))
                silent! LspInstallServer pyright
            endif
        endfunction

        " Only install servers if they don't exist on the system
        autocmd VimEnter * call s:install_lsp_servers_once()

        augroup lsp_install
            au!
            autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
        augroup END
    endif

    if isdirectory(expand($HOME . '/.vim/plugged/vim-multiple-cursors/'))
        let g:multi_cursor_exit_from_visual_mode = 1
        let g:multi_cursor_quit_key='<C-c>'
    endif
endif

" Use ripgrep over grep, with fallback to ag
if executable('rg')
    " Use ripgrep over grep
    set grepprg=rg\ --vimgrep\ --smart-case\ --follow
elseif executable('ag')
    " Fallback to ag if ripgrep not available
    set grepprg=ag\ --nogroup\ --nocolor
endif

" WSL Copy (commented out for cross-platform compatibility)
" autocmd TextYankPost * call system('echo '.shellescape(join(v:event.regcontents, "\<CR>")).' |  clip.exe')

" ==================== ALE + RUFF CONFIGURATION (2025 Best Practices) ====================
" Disable ALE's LSP in favor of standalone LSP plugins
let g:ale_disable_lsp = 1

" Visual indicators
let g:ale_set_signs = 1
let g:ale_set_highlights = 1
let g:ale_virtualtext_cursor = 1

" When to lint
let g:ale_lint_on_save = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_change = 'never'
let g:ale_lint_on_enter = 1

" Use explicit linters (don't auto-detect)
let g:ale_linters_explicit = 1
let g:ale_linters = {
\ 'python': ['ruff'],
\ }

" Modern Ruff fixers - both linting and formatting
let g:ale_fixers = {
\ '*': ['trim_whitespace'],
\ 'python': ['ruff', 'ruff_format'],
\ }

" Auto-fix on save (optional)
let g:ale_fix_on_save = 0

" Key mappings for Ruff
nnoremap <leader>f :ALEFix<CR>
nnoremap <leader>l :ALELint<CR>

" Ruff executable and options
let g:ale_python_ruff_executable = 'ruff'
let g:ale_python_ruff_format_executable = 'ruff'
" Uncomment and customize if you have a specific ruff config
" let g:ale_python_ruff_options = '--config ~/path/to/your/pyproject.toml'

" ==================== VIMUX CONFIGURATION ====================
let g:VimuxHeight = "30"
let g:VimuxOrientation = "h"
let g:VimuxUseNearest = 1

" Vimux key mappings for workflow optimization
nnoremap <leader>vp :VimuxPromptCommand<CR>
nnoremap <leader>vl :VimuxRunLastCommand<CR>
nnoremap <leader>vi :VimuxInspectRunner<CR>
nnoremap <leader>vz :VimuxZoomRunner<CR>
nnoremap <leader>vx :VimuxCloseRunner<CR>
nnoremap <leader>vc :VimuxClearTerminalScreen<CR>

" Python-specific shortcuts
nnoremap <leader>py :call VimuxRunCommand("python " . bufname("%"))<CR>
nnoremap <leader>t :call VimuxRunCommand("pytest " . bufname("%"))<CR>
nnoremap <leader>ta :call VimuxRunCommand("pytest")<CR>

" Enable auto-format on save
let g:ale_fix_on_save = 1

" Session management
set sessionoptions=buffers,curdir,folds,help,tabpages,winsize,resize
nnoremap <leader>ss :mksession! Session.vim<CR>
nnoremap <leader>sr :source Session.vim<CR>
