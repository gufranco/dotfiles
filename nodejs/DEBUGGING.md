# Node.js debugging cheat-sheet

Node has no `.pdbrc`, but it ships a full V8 Inspector stack. Three ways to debug,
from lightest to richest: the terminal debugger, Chrome DevTools, and an editor via
DAP. The custom REPL lives in [`repl-init.mjs`](repl-init.mjs).

## 1. Terminal debugger: `node inspect`

Start it with the `ni` alias, or drop a `debugger;` statement in the code and run `nib`.

```sh
ni app.js          # node inspect app.js, pauses on the first line
nib app.js         # node --inspect-brk app.js, break before user code
```

Command reference once paused:

| Command | Short | Action |
|:--------|:------|:-------|
| `cont` | `c` | Resume until the next breakpoint |
| `next` | `n` | Step over |
| `step` | `s` | Step into |
| `out` | `o` | Step out of the current function |
| `pause` | | Pause running code |
| `setBreakpoint(line)` | `sb(line)` | Breakpoint on a line in the current file |
| `setBreakpoint('fn')` | `sb('fn')` | Breakpoint on a function |
| `setBreakpoint('f.js', 1, 'x>4')` | | Conditional breakpoint |
| `clearBreakpoint('f.js', 1)` | `cb(...)` | Remove a breakpoint |
| `backtrace` | `bt` | Current call stack |
| `list(5)` | | Show 5 lines of source context |
| `watch('expr')` | | Print `expr` at every break |
| `unwatch('expr')` | | Stop watching `expr` |
| `watchers` | | Show all watchers |
| `repl` | | Evaluate in the paused script's scope, Ctrl+C to leave |
| `exec expr` | `p expr` | Evaluate a single expression |
| `restart` / `kill` | | Restart or stop the script |

Pressing Enter repeats the last command.

## 2. Chrome DevTools

For a full GUI with breakpoints, the scope pane, and a console:

1. Run `nib app.js`. Node prints `Debugger listening on ws://127.0.0.1:9229/...`.
2. Open `chrome://inspect` in Chrome or `edge://inspect` in Edge.
3. Under Remote Target, click `inspect`. The dedicated DevTools window reconnects across restarts.

Security: the inspector grants full code execution inside the process. The default
`127.0.0.1` bind is local-only. Never bind a public address. For a remote box, forward
the port over SSH instead: `ssh -L 9229:localhost:9229 user@host`.

`--inspect-brk` is preferred over `--inspect` for short scripts, since a plain `--inspect`
script can finish before the debugger attaches.

## 3. Neovim via nvim-dap

The dap plugins are declared in [`../nvim/init.vim`](../nvim/init.vim) and the `pwa-node`
adapter binary is installed by [`../install.sh`](../install.sh) into `~/.local/share/js-debug`.

| Keymap | Action |
|:-------|:-------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint, prompts for the condition |
| `<leader>dc` | Continue or start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open the REPL |
| `<leader>du` | Toggle the dap-ui panels |
| `<leader>dt` | Terminate the session |

Pick `Launch file` to debug the current file, or `Attach` to attach to a running
process started with `nib`.

## 4. Console and inspection helpers

| Tool | Use |
|:-----|:----|
| `console.dir(obj, { depth: null, colors: true })` | Full nested dump of one object |
| `console.table(rows)` | Tabular view of an array of objects |
| `util.inspect(obj, { depth, colors })` | String form with control over depth |
| `nw app.js` | `node --watch`, restart on file change |

The custom REPL launched with `jsr` already sets `util.inspect.defaultOptions` to
depth 6 with colors, so `console.log` and bare expression results print deeply by default.

## Aliases

Defined in [`../zsh/aliases`](../zsh/aliases):

| Alias | Expands to |
|:------|:-----------|
| `ni` | `node inspect` |
| `nib` | `node --inspect-brk` |
| `niw` | `node --inspect-wait` |
| `nw` | `node --watch` |
| `jsr` | Custom REPL from `repl-init.mjs` |
