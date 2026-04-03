" Obsidian Vim keybindings
" Copy to your Obsidian vault root and enable via obsidian-vimrc-support plugin.
" This file is NOT symlinked automatically. It is a reference configuration.

" Exit insert mode with jk
imap jk <Esc>

" Visual line movement (wrapped lines)
nmap j gj
nmap k gk

" Half-page scrolling
nmap <C-d> 10j
nmap <C-u> 10k

" Yank to end of line (consistent with D and C)
nmap Y y$

" Folding
exmap toggleFold obcommand editor:toggle-fold
nmap za :toggleFold
exmap foldAll obcommand editor:fold-all
nmap zM :foldAll
exmap unfoldAll obcommand editor:unfold-all
nmap zR :unfoldAll

" Follow link under cursor
exmap followLink obcommand editor:follow-link
nmap gf :followLink

" Open link in new leaf
exmap followLinkNewLeaf obcommand editor:open-link-in-new-leaf
nmap gF :followLinkNewLeaf

" Navigate back/forward
exmap goBack obcommand app:go-back
nmap <C-o> :goBack
exmap goForward obcommand app:go-forward
nmap <C-i> :goForward

" Search
exmap omnisearch obcommand omnisearch:show
nmap <C-p> :omnisearch

" Focus navigation
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusTop obcommand editor:focus-top
exmap focusBottom obcommand editor:focus-bottom
nmap <A-h> :focusLeft
nmap <A-l> :focusRight
nmap <A-k> :focusTop
nmap <A-j> :focusBottom

" Splits
exmap splitVertical obcommand workspace:split-vertical
exmap splitHorizontal obcommand workspace:split-horizontal
nmap <C-w>v :splitVertical
nmap <C-w>s :splitHorizontal
