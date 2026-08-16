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
set colorcolumn=72
set nojoinspaces
set noautoindent
set nosmartindent
set backspace=indent,eol,start

augroup mutt_compose
  autocmd!
  autocmd BufRead,BufNewFile * setlocal filetype=mail
  autocmd FileType mail setlocal textwidth=72
  autocmd FileType mail setlocal formatoptions=tcqjln
  autocmd FileType mail setlocal comments=n:>,n:\|
  autocmd FileType mail setlocal spell spelllang=en
  autocmd FileType mail call cursor(search('^$', 'cnw') + 1, 1)
augroup END
