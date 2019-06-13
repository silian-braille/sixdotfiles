" Basic Vim Settings
set encoding=utf-8
filetype plugin on
syntax on
colorscheme cyberpunkneon-fork
set number

" Vim-Plug Setup -- Use text following Github page
call plug#begin('~/.vim/plugged')
Plug 'junegunn/goyo.vim'
Plug 'w0rp/ale'
Plug 'itchyny/lightline.vim'
Plug 'Raimondi/delimitMate'
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
call plug#end()

" Disables automatic commentingmato on LF
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e

" ===DEOPLETE===
let g:deoplete#enable_at_startup = 1
set pyxversion=3
" ===LIGHTLINE===
set laststatus=2
