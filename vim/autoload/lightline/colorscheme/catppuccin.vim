" Catppuccin Mocha palette for lightline
" gui hex + nearest 256-color fallback: [guifg, guibg, ctermfg, ctermbg]
let s:base     = ['#1e1e2e', 235]
let s:mantle   = ['#181825', 233]
let s:surface0 = ['#313244', 237]
let s:surface1 = ['#45475a', 239]
let s:text     = ['#cdd6f4', 189]
let s:blue     = ['#89b4fa', 111]
let s:green    = ['#a6e3a1', 150]
let s:red      = ['#f38ba8', 211]
let s:mauve    = ['#cba6f7', 183]
let s:peach    = ['#fab387', 215]

function! s:pair(fg, bg) abort
  return [a:fg[0], a:bg[0], a:fg[1], a:bg[1]]
endfunction

let s:p = {'normal':{}, 'inactive':{}, 'insert':{}, 'replace':{}, 'visual':{}, 'tabline':{}}
let s:p.normal.left   = [ s:pair(s:base, s:blue),  s:pair(s:text, s:surface1) ]
let s:p.normal.right  = [ s:pair(s:base, s:blue),  s:pair(s:text, s:surface1) ]
let s:p.normal.middle = [ s:pair(s:text, s:mantle) ]
let s:p.inactive.left   = [ s:pair(s:text, s:surface0) ]
let s:p.inactive.right  = [ s:pair(s:text, s:surface0) ]
let s:p.inactive.middle = [ s:pair(s:text, s:mantle) ]
let s:p.insert.left   = [ s:pair(s:base, s:green), s:pair(s:text, s:surface1) ]
let s:p.insert.right  = [ s:pair(s:base, s:green), s:pair(s:text, s:surface1) ]
let s:p.replace.left  = [ s:pair(s:base, s:red),   s:pair(s:text, s:surface1) ]
let s:p.replace.right = [ s:pair(s:base, s:red),   s:pair(s:text, s:surface1) ]
let s:p.visual.left   = [ s:pair(s:base, s:mauve), s:pair(s:text, s:surface1) ]
let s:p.visual.right  = [ s:pair(s:base, s:mauve), s:pair(s:text, s:surface1) ]
let s:p.tabline.left   = [ s:pair(s:text, s:surface0) ]
let s:p.tabline.tabsel = [ s:pair(s:base, s:blue) ]
let s:p.tabline.middle = [ s:pair(s:text, s:mantle) ]
let s:p.tabline.right  = [ s:pair(s:text, s:surface0) ]
let s:p.normal.error   = [ s:pair(s:base, s:red) ]
let s:p.normal.warning = [ s:pair(s:base, s:peach) ]

let g:lightline#colorscheme#catppuccin#palette = lightline#colorscheme#fill(s:p)
