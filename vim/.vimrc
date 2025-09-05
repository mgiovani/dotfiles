set nocompatible
filetype off

" Auto install vim-plug and plugins
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Code formatter and requirements
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'editorconfig/editorconfig-vim'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" CMD
Plug 'dkprice/vim-easygrep'

" Vim Customization
Plug 'chriskempson/base16-vim'
Plug 'bling/vim-airline'
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }
Plug 'junegunn/fzf.vim'
Plug 'davidhalter/jedi-vim'
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'terryma/vim-multiple-cursors'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-syntastic/syntastic'
Plug 'Xuyuanp/nerdtree-git-plugin'
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

call plug#end()

" Google codefmt config
call glaive#Install()
Glaive codefmt plugin[mappings]
Glaive codefmt google_java_executable="java -jar /path/to/google-java-format-VERSION-all-deps.jar"

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
set ttimeoutlen=50
set wildignore=*/htmlcov/*,*/functional*,*.swp,*.bak,*.pyc,*.class,*/node_modules/*,*/bower_components/*
set wildmenu

let g:vimspector_enable_mappings = 'HUMAN'
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
cnoreabbrev W w
hi Normal ctermbg=NONE
inoremap <C-c> <Esc><Esc>
map <F4> 5gg3f<SPACE>ly$ggp<S-a>:<SPACE>
map <S-Tab> :tabprevious<cr>
map <Tab> :tabnext<cr>
map <silent> <C-m> :set list!<CR>
nmap <F1> :noh<cr>
nmap <leader>o :NERDTreeToggle<cr>
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

" Collors and Themes
syntax on
filetype plugin indent on
syntax enable

if isdirectory(expand($HOME . '/.vim/plugged/'))
    set background=dark
    let base16colorspace=256

    if isdirectory(expand($HOME . '/.vim/plugged/base16-vim/'))
        colorscheme base16-default-dark
    endif

    if isdirectory(expand($HOME . '/.vim/plugged/vim-airline/'))
        let g:airline#extensions#tabline#enabled = 1
        let g:airline_powerline_fonts = 1
        let g:airline_theme = 'powerlineish'
        let g:airline#extensions#branch#enabled = 1

        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*

        let g:syntastic_aggregate_errors = 1
        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 2
        let g:syntastic_check_on_wq = 0
        let g:syntastic_enable_highlighting = 1
        let g:syntastic_error_symbol = '✗'
        let g:syntastic_warning_symbol = '⚠'
        " let g:syntastic_python_checkers = ['ale']
    endif

    if isdirectory(expand($HOME . '/.vim/plugged/jedi-vim/'))
        let g:jedi#use_tabs_not_buffers = 1
        let g:jedi#show_call_signatures = 2
        let g:jedi#auto_initialization = 1
        let g:jedi#popup_on_dot = 1
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

" Ruff Configuration (Python linting/formatting)
nnoremap <leader>c :ALEFix ruff<cr>
nnoremap <leader>f :w<CR>:silent !ruff format % > /dev/null 2>&1<CR>:e!<CR>:redraw!<CR>
let g:ale_linters = {'python': ['ruff']}
let g:ale_fixers = {'python': ['ruff']}
let g:ale_python_ruff_executable = 'ruff'
" Update the config path to be more generic - users should customize this
" let g:ale_python_ruff_options = '--config ~/path/to/your/pyproject.toml'
