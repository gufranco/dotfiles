""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quick Reference                                              leader = ,
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Navigation
"   Ctrl+p        Files (fzf)          ,gf    Git files (fzf)
"   ,f            Ripgrep search       ,b     Buffers (fzf)
"   ,h            File history (fzf)   f      Jump to char (EasyMotion)
"   Ctrl+h/j/k/l Window navigation
"
" Code (coc.nvim)
"   gd            Go to definition     gr     References
"   gy            Type definition      gi     Implementation
"   K / gh        Documentation        [g ]g  Prev/next diagnostic
"   Tab / S-Tab   Completion nav       Enter  Confirm completion
"   Ctrl+Space    Trigger completion
"   ,cr           Rename symbol        ,cf    Format selected
"   ,ca           Code action          ,co    Outline
"   ,cs           Symbols              ,cl    Location list
"   ,cc           Commands             ,cx    Extensions
"   ,cR           Restart Coc
"
" Editing
"   gc{motion}    Toggle comment       gcc    Comment line
"   cs'"          Change surround      ds"    Delete surround
"   ysiw"         Surround word        S"     Surround visual
"   Ctrl+n        Multi-cursor         Y      Yank to EOL
"   < / >         Indent (stays visual)
"   Alt+j/k       Move line up/down
"
" Git (signify + fugitive)
"   :Git          Fugitive commands    [c ]c  Prev/next hunk
"
" Other
"   ,s            Source vimrc         ,v     Edit vimrc
"   ,r            Resize windows       Enter  Clear search hl
"   :Wipeout      Close hidden bufs
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8

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

" Defaults
Plug 'tpope/vim-sensible'
Plug 'rstacruz/vim-opinion'

" Theme
Plug 'ghifarit53/tokyonight-vim'

" UI
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'inside/vim-search-pulse'
Plug 'simeji/winresizer', { 'on': 'WinResizerStartResize' }

" Language support
Plug 'neoclide/coc.nvim', { 'branch': 'release', 'do': ':CocInstall coc-snippets coc-tsserver coc-prettier coc-eslint coc-css coc-lists coc-highlight coc-json' }
Plug 'sheerun/vim-polyglot'

" File management
if isdirectory('/opt/homebrew/opt/fzf')
  Plug '/opt/homebrew/opt/fzf'
elseif isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf'
elseif isdirectory(expand('~/.fzf'))
  Plug '~/.fzf'
endif
Plug 'junegunn/fzf.vim'

" Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" Editing
Plug 'sickill/vim-pasta'
Plug 'mg979/vim-visual-multi', { 'branch': 'master' }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

" Navigation
Plug 'easymotion/vim-easymotion'

" Compatibility
Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Built-in packages (Vim 9+)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
packadd comment
packadd hlyank

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Core
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:mapleader = ','
set updatetime=100
set noerrorbells
set novisualbell
set shortmess+=c
set nomodeline
set signcolumn=yes
set fileformats=unix,dos,mac

if executable('rg')
  set grepprg=rg\ --color=never
endif

if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif

let g:editorconfig = v:true

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Files
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set undofile
if !isdirectory($HOME . '/.vim/undodir')
  call mkdir($HOME . '/.vim/undodir', 'p', 0700)
endif
set undodir=~/.vim/undodir

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set colorcolumn=80
set relativenumber
set list

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal & Colors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('termguicolors')
  set termguicolors
endif

if &term =~# '^screen' || &term =~# '^tmux'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

try
  let g:tokyonight_style = 'night'
  let g:tokyonight_enable_italic = 1
  colorscheme tokyonight
catch
  colorscheme desert
endtry
set background=dark

" Subtle indent guides and whitespace markers
highlight! link SpecialKey Comment

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
  \ 'colorscheme': 'tokyonight',
  \ 'active': {
  \   'left': [
  \     [ 'mode', 'paste' ],
  \     [ 'gitbranch', 'readonly', 'filename', 'modified' ]
  \   ],
  \   'right': [
  \     [ 'lineinfo' ],
  \     [ 'percent' ],
  \     [ 'cocstatus', 'filetype' ]
  \   ]
  \ },
  \ 'component': {
  \   'lineinfo': ' %3l:%-2v',
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead',
  \   'cocstatus': 'coc#status',
  \ },
  \ 'separator': {
  \   'left': '', 'right': ''
  \ },
  \ 'subseparator': {
  \   'left': '', 'right': ''
  \ }
\ }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Clear search highlight
nnoremap <CR> :nohlsearch<CR><CR>

" Source / edit vimrc
nmap <Leader>s :source $MYVIMRC<CR>
nmap <Leader>v :edit $MYVIMRC<CR>

" Make Y behave like D and C: yank to end of line
nnoremap Y y$

" Stay in visual mode after indenting
vnoremap < <gv
vnoremap > >gv

" Move lines up/down with Alt+j/k
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Quick window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrc
  autocmd!

  " CursorLine only in active window
  autocmd WinEnter * set cursorline
  autocmd WinLeave * set nocursorline

  " Relative numbers toggle in insert mode
  autocmd InsertEnter * set norelativenumber
  autocmd InsertLeave * set relativenumber

  " Restore cursor position when reopening a file
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif

  " Strip trailing whitespace on save
  autocmd BufWritePre * let b:pos = getpos('.') | %s/\s\+$//e | call setpos('.', b:pos)

  " Refresh lightline on coc status changes
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions & commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Close all hidden, unmodified buffers
command! Wipeout call s:Wipeout()
function! s:Wipeout() abort
  let l:buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && !bufloaded(v:val) && !getbufvar(v:val, "&mod")')
  if !empty(l:buffers)
    execute 'bwipeout' join(l:buffers)
    echo len(l:buffers) . ' buffer(s) wiped out'
  else
    echo 'No buffers to wipe out'
  endif
endfunction

" Show documentation for symbol under cursor
function! s:show_documentation()
  if &filetype ==# 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Coc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
inoremap <silent><expr> <c-space> coc#refresh()

inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1) :
  \ <SID>check_backspace() ? "\<Tab>" :
  \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
  \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! s:check_backspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> gh :call <SID>show_documentation()<CR>

augroup coc_cursorhold
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

nnoremap <silent> <leader>co  :<C-u>CocList outline<cr>
nnoremap <silent> <leader>cs  :<C-u>CocList -I symbols<cr>
nnoremap <silent> <leader>cl  :<C-u>CocList locationlist<cr>
nnoremap <silent> <leader>cc  :<C-u>CocList commands<cr>
nnoremap <silent> <leader>cR  :<C-u>CocRestart<CR>
nnoremap <silent> <leader>cx  :<C-u>CocList extensions<cr>
nmap <leader>cr  <Plug>(coc-rename)
nmap <leader>cf  <Plug>(coc-format-selected)
vmap <leader>cf  <Plug>(coc-format-selected)
vmap <leader>ca  <Plug>(coc-codeaction-selected)
nmap <leader>ca  <Plug>(coc-codeaction-selected)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fzf
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>f :Rg<CR>
nnoremap <silent> <leader>gf :GFiles<CR>
nnoremap <silent> <leader>h :History<CR>
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EasyMotion
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
nmap f <Plug>(easymotion-overwin-f)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WinResizer
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>r :WinResizerStartResize<CR>
