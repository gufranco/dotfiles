set nocompatible

set nomodeline
set encoding=utf-8
set fileencoding=utf-8

set nobackup
set nowritebackup
set noswapfile
set noundofile

filetype plugin indent on
syntax enable

set number
set cursorline
set ruler
set showcmd
set laststatus=2
set wrap
set linebreak
set nojoinspaces
set backspace=indent,eol,start

augroup git_editor
  autocmd!
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType gitcommit setlocal colorcolumn=51,73
  autocmd FileType gitcommit setlocal formatoptions=tcqjn
  autocmd FileType gitcommit setlocal spell spelllang=en
  autocmd FileType gitrebase setlocal nospell
  autocmd FileType markdown setlocal textwidth=0
  autocmd FileType markdown setlocal colorcolumn=73
  autocmd FileType markdown setlocal formatoptions=qjn
  autocmd FileType markdown setlocal spell spelllang=en
augroup END
