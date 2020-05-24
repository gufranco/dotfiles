""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
scriptencoding utf-8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Environment
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:uname = substitute(system('uname'), '[[:cntrl:]]', '', 'g')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if empty(glob('~/.dotfiles/vim/autoload/plug.vim'))
  silent execute '!curl -fLo ~/.dotfiles/vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  augroup plug
    autocmd VimEnter * PlugInstall
  augroup END
endif

call plug#begin()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Compatibility
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-sensible'
Plug 'rstacruz/vim-opinion'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tmux-plugins/vim-tmux'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'RRethy/vim-illuminate'
Plug 'inside/vim-search-pulse'
Plug 'itchyny/lightline.vim'
Plug 'jszakmeister/vim-togglecursor'
Plug 'lilydjwg/colorizer'
Plug 'maximbaz/lightline-ale'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'myusuf3/numbers.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-scripts/CursorLineCurrentWindow'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Languages support
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'sheerun/vim-polyglot'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Linters
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'w0rp/ale'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File management
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Windows and buffers
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'artnez/vim-wipeout', { 'on': 'Wipeout' }
Plug 'simeji/winresizer', { 'on': 'WinResizerStartResize' }
Plug 'vim-scripts/ZoomWin', { 'on': 'ZoomWin' }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editing
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'heavenshell/vim-jsdoc', { 'on': 'JsDoc' }
Plug 'roxma/vim-paste-easy'
Plug 'sickill/vim-pasta'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clipboard
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'svermeulen/vim-easyclip'
Plug 'Shougo/denite.nvim'
Plug 'Shougo/neoyank.vim'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Code completion
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'brooth/far.vim', { 'on': ['Far', 'Farundo', 'Farp', 'Farundo'] }
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'kristijanhusak/vim-carbon-now-sh', { 'on': 'CarbonNowSh' }
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
Plug 'ntpeters/vim-better-whitespace'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-repeat'

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable cursor line highlighting
set cursorline

" Enable overlength line highlighting
set colorcolumn=80

" Disable mouse
set mouse=
if !has('nvim')
  set ttymouse=
endif

" Set update interval
set updatetime=100

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set timeoutlen=500
if has('gui_macvim')
  augroup macvim
    autocmd GUIEnter * set vb t_vb=
  augroup END
endif

" Use ripgrep over grep if avaiable
if executable('rg')
  set grepprg=rg\ --color=never
endif

" Set leader key to ,
let g:mapleader = ','

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Use Unix as the standard file type
set fileformats=unix,dos,mac

" Clipboard
if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

" Disable modelines
set nomodeline

" Disable backups
set nobackup

" Disable swap files
set noswapfile

" Disable persistent undo
set noundofile

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Aliases
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Source vimrc
nmap <Leader>s :source $MYVIMRC<CR>

" Edit vimrc
nmap <Leader>v :edit $MYVIMRC<CR>

" Fast saving
nmap <leader>w :w!<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Theme / GUI
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
  colorscheme dracula
catch
  colorscheme desert
endtry
set background=dark

if has('gui_running')
  if s:uname ==# 'Darwin'
    set guifont=Hack\ Regular\ Nerd\ Font\ Complete:h12
  elseif s:uname ==# 'Linux'
    set guifont=Hack\ 10
  endif

  " Remove menu
  set guioptions=

  " Maximize window
  set lines=999
  set columns=999
elseif has('nvim')
  " Enable true colors
  set termguicolors
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle NERDTree
map <leader>n :NERDTreeToggle<CR>

" Close vim if the only window left open is NERDTree
augroup nerdtree
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Automatically remove a buffer when a file is being deleted via a context menu
let g:NERDTreeAutoDeleteBuffer = 1

" Disable display of the 'Bookmarks' label
let g:NERDTreeMinimalUI = 1

" Close the tree window after opening a file
let g:NERDTreeQuitOnOpen = 1

" Display hidden files by default
let g:NERDTreeShowHidden = 1

" Ignore folders and files
let g:NERDTreeIgnore = [
\ '^\.git$[[dir]]',
\ '^node_modules$[[dir]]',
\ '^dist$[[dir]]',
\ '^build$[[dir]]'
\ ]

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
  \ 'colorscheme': 'dracula',
  \ 'active': {
  \   'left': [
  \     [ 'mode', 'paste' ],
  \     [ 'gitbranch', 'readonly', 'filename', 'modified' ]
  \   ],
  \   'right': [
  \     [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]
  \   ]
  \ },
	\ 'component': {
	\   'lineinfo': ' %3l:%-2v',
	\ },
  \ 'component_function': {
  \   'gitbranch': 'fugitive#head',
  \ },
  \ 'separator': {
	\   'left': '', 'right': ''
  \ },
  \ 'subseparator': {
	\   'left': '', 'right': ''
  \ },
  \ 'component_expand': {
  \   'linter_checking': 'lightline#ale#checking',
  \   'linter_warnings': 'lightline#ale#warnings',
  \   'linter_errors': 'lightline#ale#errors',
  \   'linter_ok': 'lightline#ale#ok'
  \ },
  \ 'component_type': {
  \   'linter_checking': 'left',
  \   'linter_warnings': 'warning',
  \   'linter_errors': 'error',
  \   'linter_ok': 'left',
  \ }
\ }

" Ale icons
let g:lightline#ale#indicator_checking = "\uf110"
let g:lightline#ale#indicator_warnings = "\uf071"
let g:lightline#ale#indicator_errors = "\uf05e"
let g:lightline#ale#indicator_ok = "\uf00c"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ale
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Never lint on change
let g:ale_lint_on_text_changed = 'never'

" Lint on save
let g:ale_lint_on_save = 1

" Fix on save
let g:ale_fix_on_save = 1

" Lint on enter
let g:ale_lint_on_enter = 1

" Compatible linters
let g:ale_linters = {
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint'],
  \ 'vim': ['vint'],
\ }

" Compatible fixers
let g:ale_fixers = {
  \ 'javascript': ['prettier', 'eslint'],
  \ 'typescript': ['prettier', 'eslint'],
\ }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ignore files and folders
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|node_modules|dist)$',
  \ 'file': '\v\.(gitkeep|log|gif|jpg|jpeg|png|psd|DS_Store|)$'
\ }

" Show hidden files
let g:ctrlp_show_hidden = 1

" Disable per-session caching
let g:ctrlp_use_caching = 0

" Ripgrep
if executable('rg')
  " Use ripgrep in CtrlP for listing files
  let g:ctrlp_user_command = 'rg %s --files --hidden --follow --color=never --glob "!.git/*"'
else
  " Use grep in CtrlP, but skip files inside .gitignore
  let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" JsDoc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>j :JsDoc<CR>
let g:jsdoc_enable_es6 = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim Multiple Cursors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:multi_cursor_quit_key = '<Esc>'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EasyMotion
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_do_mapping = 0
nmap f <Plug>(easymotion-overwin-f)
let g:EasyMotion_smartcase = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Carbon.now.sh
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:carbon_now_sh_options = 't=dracula&ln=true&fm=Hack'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Easyclip
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EasyClipAlwaysMoveCursorToEndOfPaste = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WinResizer
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>r :WinResizerStartResize<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ZoomWin
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>z :ZoomWin<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" YouCompleteMe
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !exists('g:ycm_semantic_triggers')
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tagbar
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>t :TagbarToggle<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Supertab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:SuperTabDefaultCompletionType = '<c-n>'
