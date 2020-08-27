if &compatible
  set nocompatible
endif

if has('win32')
    let $PLUGGEDDIR = "~/vimfiles/plugged"
    set pythonthreedll=python38.dll
else
    let $PLUGGEDDIR = "~/.vim/plugged"
endif

call plug#begin($PLUGGEDDIR)

Plug 'dracula/vim', { 'as': 'dracula.vim' }

Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'vifm/vifm.vim'

Plug 'ipod825/vim-netranger'
Plug 'terryma/vim-multiple-cursors'

call plug#end()

color dracula
let g:dracula_colorterm = 0

" not a typo!
let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ }

let mapleader = ","

syntax on

filetype plugin on
filetype indent on

set autoread
set cmdheight=1
set hidden
set history=9000
set laststatus=2
set splitright

set ignorecase
set incsearch
set lazyredraw
set magic
set matchtime=2
set showmatch
set smartcase

set nobackup
set nowritebackup
set noswapfile

set number
set ruler

set autoindent
set expandtab
set foldcolumn=1
set shiftwidth=4
set smartindent
set smarttab
set tabstop=4
set wrap

set noerrorbells
set novisualbell
set t_vb=
set timeoutlen=500

set encoding=utf8
set fileformats=unix,dos,mac

set backspace=eol,start,indent
set whichwrap+=<,>,h,l

if has("gui_running")
  set columns=160
  set lines=50

  set guicursor+=n-v-c:blinkon0

  if has("gui_gtk")
    set guifont=Hack\ 11
  elseif has("gui_win32")
    set guifont=Hack:h11:cANSI
  elseif has("gui_mac")
    set guifont=Hack:h11
  endif
endif
