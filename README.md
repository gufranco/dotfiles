<div align="center">

<br>

<strong>One-command development environment for macOS and Linux. 50+ tool configs, consistent Catppuccin Mocha theme, modern CLI replacements, and ready-to-go Docker services.</strong>

<br>
<br>

[![CI](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-zsh-blue?style=flat-square)]()
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)]()

</div>

---

**50+** tool configs · **22** Catppuccin Mocha themed tools · **60** Git aliases · **6** Docker services · **31** Vim plugins

<table>
<tr>
<td width="50%" valign="top">

### Catppuccin Mocha Everywhere

One color palette across 22 tools: terminals, editors, file managers, email, music, git diffs, monitoring dashboards, and fuzzy finders.

</td>
<td width="50%" valign="top">

### Modern CLI Replacements

`cat` becomes `bat`, `ls` becomes `eza`, `top` becomes `btm`, `ping` becomes `gping`. Graceful fallbacks when the modern tool is not installed.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### One-Command Install

`curl | bash` sets up everything: Homebrew packages, symlinks, shell config, GPG keys, SSH, and language runtimes. Works on fresh macOS or Ubuntu.

</td>
<td width="50%" valign="top">

### Docker Services on Demand

PostgreSQL, MongoDB, Redis, Valkey, and Redict as shell functions: `postgres-init`, `mongo-start`, `redis-stop`. Colima as the VM, configured for Apple Silicon with Rosetta 2.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### GPG-Signed Everything

Commits and tags are signed by default. GPG keys are imported automatically, SSH keys get proper permissions, and tokens are GPG-encrypted.

</td>
<td width="50%" valign="top">

### Fast Shell Startup

Node.js, Python, and Ruby are managed by [mise](https://mise.jdx.dev). Versions are defined in `mise/config.toml` and activated automatically in interactive shells. Per-project overrides go in a `.mise.toml` file in the project root.

</td>
</tr>
</table>

## Quick Start

### Prerequisites

| Tool | Install |
|:-----|:--------|
| macOS or Ubuntu/Debian | Fresh install works |
| Git | Pre-installed on macOS, `apt install git` on Linux |
| curl | Pre-installed on both |

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

### Verify

```bash
source ~/.zshrc
bat --version    # syntax-highlighted cat
eza --version    # modern ls
```

The installer detects your OS and architecture automatically. On macOS it installs Homebrew and runs the Brewfile. On Linux it uses apt, snap, and direct downloads.

## What Gets Installed

### Shell

| Feature | Implementation |
|:--------|:---------------|
| Shell | Zsh with Oh My Zsh and Spaceship prompt |
| Fuzzy finder | fzf with bat preview and Catppuccin Mocha colors |
| Tab completion | fzf-tab for fuzzy tab completion |
| Syntax highlighting | zsh-syntax-highlighting for fish-like coloring |
| Smart cd | zoxide with frecency-based directory jumping |
| Shell history | atuin for searchable, synced shell history |
| Per-directory env | direnv with automatic `.envrc` loading |
| History | Deduplication, ignore common commands |
| GNU tools on macOS | coreutils, findutils, grep, sed, tar, make override BSD via PATH |

### Modern Tool Replacements

Aliases activate only when the modern tool is installed:

| Alias | Replaces | Tool |
|:------|:---------|:-----|
| `cat` | cat | `bat` with syntax highlighting, plain output when piped |
| `ls` | ls | `eza` with icons, git status, tree view via `lt` |
| `top` | top | `btm` (Bottom) system monitor TUI |
| `ping` | ping | `gping` with graphical output (macOS) |
| `stats` | - | `tokei` for code statistics (macOS) |

### Editor

Vim with 31 plugins managed by vim-plug:

| Category | Plugins |
|:---------|:--------|
| Language support | coc.nvim (LSP), vim-polyglot, vim-matchup, rainbow_csv |
| Navigation | fzf, fzf.vim, vim-sneak (jump motions), vim-fetch (open at line) |
| Git | vim-signify (hunks), vim-fugitive (commands), conflict-marker.vim |
| Editing | vim-surround, vim-visual-multi, vim-pasta, targets.vim, vim-unimpaired, vim-repeat, vim-abolish (case coercion), splitjoin.vim |
| Files | vim-eunuch (Rename, Delete, Move, SudoWrite) |
| UI | lightline, vim-devicons, undotree, vim-cool, vim-search-pulse, winresizer |
| Theme | catppuccin/vim, driving both the colorscheme and lightline |
| Defaults | vim-sensible, vim-opinion |
| Integration | vim-tmux (tmux.conf syntax), vim-tmux-navigator (split movement) |

`vimrc` holds 33 `Plug` lines. Three of them are the Homebrew, `/usr/local`, and `~/.fzf` paths for the same local fzf install, and only the one that exists on the machine loads, so the plugin count is 31.

CoC extensions: TypeScript, ESLint, Prettier, CSS, JSON, Shell, snippets, import-cost.

### Debugging

A ready-to-use debugger for Python and Node.js, linked and installed by `install.sh`.

Python uses the standard library `pdb` with a richer `.pdbrc`. The aliases `dir`, `attrs`, `vars`, `src`, and `loc` inspect objects and locals at the prompt, adapted from Trey Hunner's [Customizing pdb with .pdbrc](https://treyhunner.com/2026/04/customizing-pdb-with-pdbrc/). `breakpoint()` is wired through [`python/debughook.py`](python/debughook.py), which prefers pdbp, then ipdb, then falls back to stdlib pdb, so it never dies in a virtualenv that lacks the fancy debuggers. [`python/pythonrc`](python/pythonrc) is the `PYTHONSTARTUP` file: persistent REPL history and pretty-printed output.

Node.js gets the built-in V8 Inspector workflow. The `ni`, `nib`, and `niw` aliases drive `node inspect` and `--inspect-brk` for terminal and Chrome DevTools debugging. `jsr` opens a custom REPL from [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) with deep colorized inspection.

### Terminal Multiplexer

Tmux with 9 plugins and vim-style keybindings, installed by tpm:

| Plugin | What it does |
|:-------|:-------------|
| catppuccin/tmux | Status bar, window list, and pane styling |
| tmux-sensible-revamped | Version, OS, and terminal aware defaults: truecolor, OSC 52 clipboard, focus events |
| tmux-pain-control-revamped | Vim-style pane splits, navigation, resize, and window moves |
| tmux-launcher-revamped | Opens lazygit, lazydocker, and other TUIs in a popup or a fresh window |
| tmux-tiling-revamped | i3-like BSP tiling, pane marks, and a floating scratchpad |
| tmux-scroll-revamped | Sends the wheel to the app when it wants it, enters copy-mode otherwise |
| tmux-fzf-revamped | Fuzzy switch or kill any session, window, or pane |
| tmux-extract-revamped | Fuzzy-grab urls, paths, words, or lines off the pane and paste them |
| tmux-autoreload-revamped | Re-sources the config when it changes |

Everything except the Catppuccin theme comes from the [tmux-revamped](https://github.com/tmux-revamped) family. `tmux-persist-revamped` replaces tmux-resurrect and tmux-continuum with one plugin that writes no temp files; it sits in [`tmux/.tmux.conf`](tmux/.tmux.conf) commented out.

### Git

60 aliases, performance-tuned config, and Catppuccin Mocha colors for diffs, status, branches, and blame:

| Alias | Command | What it does |
|:------|:--------|:-------------|
| `st` | `status -sb` | Short status |
| `lg` | `log --graph --decorate` | Colored graph log |
| `fork` | `checkout -q -b` | Create branch |
| `publish` | `push -u origin HEAD` | Push new branch |
| `force` | `push --force-with-lease` | Safe force push |
| `cleanup` | merged branch delete | Remove merged branches |
| `today` | `log --since=midnight` | Today's commits |
| `sw` | `switch` | Modern branch switching |

Delta as the diff pager with line numbers, hyperlinks, and Catppuccin Mocha syntax theme. Histogram diff algorithm, zdiff3 merge conflicts, and automatic rebase on pull.

### Infrastructure

Docker development via Colima with auto-configured VM sizing:

| Service | Command | Port |
|:--------|:--------|:-----|
| PostgreSQL | `postgres-init` | 5432 |
| MongoDB | `mongo-init` | 27017 |
| Redis | `redis-init` | 6379 |
| Valkey | `valkey-init` | 7000 |
| Redict | `redict-init` | 6379 |
| Ubuntu | `ubuntu-init` | - |

Each service has `-init`, `-start`, `-stop`, `-purge`, and `-terminal` functions. Colima VM uses Apple's Virtualization.framework on macOS with Rosetta 2 for x86_64 container support on Apple Silicon.

### Linux Gaming (x86_64 only)

SteamOS-parity Steam + Proton setup for NVIDIA hybrid GPU laptops. Installed automatically on `amd64` Ubuntu systems.

| Component | What it does |
|:----------|:-------------|
| NVIDIA driver (graphics-drivers PPA) | Latest branch; open kernel modules on Turing+, proprietary on pre-Turing MX |
| NVIDIA Prime | Hybrid GPU switching: iGPU for desktop, dGPU for games |
| Suspend/resume hardening | Preserves VRAM across the laptop suspend cycles |
| iGPU media stack | Per machine: Intel (media-va-driver) or AMD (mesa-va-drivers) |
| Mesa bleeding edge | Latest Vulkan (RADV/ANV) via oibaf PPA |
| Vulkan 64-bit + 32-bit | Full Vulkan stack for both GPUs |
| XanMod kernel | fsync/winesync for Proton frame-time consistency, HZ=500, full preempt |
| scx_lavd scheduler | Latency-aware sched_ext scheduler (what Valve/CachyOS ship) |
| zram + tuned sysctl | Compressed RAM swap with zram-aware VM tuning |
| earlyoom | Kills the biggest offender before a freeze; protects Steam/Proton |
| ananicy-cpp | Auto-nices background processes so they never preempt games |
| GameMode | CPU governor flip + priority tuning while gaming |
| MangoHud + GOverlay | FPS/frametime overlay with a managed config |
| vkBasalt | CAS sharpening post-processing with a managed config |
| Gamescope | Valve's micro-compositor with FSR upscaling |
| Steam + GE-Proton | Native Steam; GE-Proton auto-downloaded (add proton-cachyos via ProtonUp-Qt) |
| Heroic / Lutris / Bottles | Epic/GOG/Amazon and other launchers (Flatpak) |
| Controller drivers | steam-devices udev + xpadneo/xone DKMS for Xbox pads |
| NVIDIA shader cache env | Persistent, prune-proof shader cache to kill recompile stutter |

**After install, reboot** (to boot the XanMod kernel and load scx_lavd) **and run:**

```bash
gaming-check    # verifies all components
```

**Per-game Steam launch options** (right-click game, Properties, Launch Options):

```bash
gaming-launch-options    # prints all recommended options
```

The standard option for most games:

```
prime-run gamemoderun mangohud %command%
```

These GPUs are GTX/MX (no tensor or RT cores), so DLSS and hardware ray tracing do not apply. The performance lever is FSR upscaling via gamescope: render below native and upscale.

**One-time Steam setup:** Settings, Compatibility, enable "Enable Steam Play for all other titles", select "Proton Experimental" or a GE-Proton version. Keep Settings, Downloads, Shader Pre-Caching enabled.

**GE-Proton stays updated automatically** via `f5`, which also rebuilds the controller DKMS modules after a kernel bump. Check [protondb.com](https://www.protondb.com/) for per-game compatibility and [areweanticheatyet.com](https://areweanticheatyet.com/) before buying multiplayer titles.

**If a game does not work:** switch to GE-Proton in the game's Compatibility settings, check ProtonDB, or use `protontricks <appid> --gui` to install missing Windows components.

## Catppuccin Mocha Theme

Most tools use the [Catppuccin](https://catppuccin.com) Mocha flavor with the mauve accent, vendored as git submodules from the official ports where the tool can load a theme from a path, and inlined from the official port or palette otherwise:

| Tool | Method |
|:-----|:-------|
| Ghostty | Built-in `catppuccin-mocha` theme |
| Kitty | `catppuccin/kitty` submodule (`themes/mocha.conf`) |
| iTerm2 | `catppuccin/iterm` submodule preset (manual import) |
| Tilix | `catppuccin/tilix` submodule scheme |
| Bat | `catppuccin/bat` submodule tmTheme |
| Delta | `catppuccin/delta` submodule feature |
| Vim | `catppuccin/vim` plugin + lightline |
| Neovim | `catppuccin/nvim` plugin + lualine |
| Tmux | `catppuccin/tmux` plugin |
| Bottom | Official Mocha `[styles]` |
| K9s | `catppuccin/k9s` submodule skin |
| Lazygit | Official Mocha mauve `gui.theme` |
| Lazydocker | Official Mocha mauve theme |
| Yazi | `catppuccin/yazi` submodule flavor |
| eza | Mocha mauve `theme.yml` (vendored from `catppuccin/eza`) |
| Mutt | `catppuccin/neomutt` submodule |
| fzf | Official Mocha `--color` |
| Midnight Commander | `catppuccin/mc` submodule skin (inherits Mocha from terminal palette) |
| tig | Mocha hex built from the palette |
| Git colors | Mocha hex in `[color]` sections |
| Tealdeer | Mocha RGB in `config.toml` |
| cmus | Nearest 256-color Mocha in `rc` |
| GoAccess | Dark HTML report (no Catppuccin port) |

Theme submodules track upstream `main`; `f5` updates them with `git submodule update --remote`. GoAccess is the only tool not pixel-exact: its HTML report supports only bright/dark built-ins, so it uses dark. cmus has no 24-bit color support, so it uses the nearest 256-color values.

## System Update

Run `f5` in any terminal to update everything at once:

1. Pulls latest dotfiles and submodules
2. Updates AWS configuration
3. Updates Vim plugins and CoC extensions
4. Updates Oh My Zsh, Zsh plugins, and Tmux plugins
5. Upgrades mise-managed runtimes (Node.js, Python, Ruby)
6. On macOS: runs `brew update`, `brew upgrade`, `brew bundle`, and Mac App Store updates
7. On Linux: runs `apt update` and `apt dist-upgrade`
8. Reloads Tmux and Zsh configs

## Symlink Map

All configs are symlinked by `install.sh` using `safe_link`, which is idempotent and creates parent directories automatically.

<details>
<summary><strong>Full symlink map</strong></summary>

| Source | Target |
|:-------|:-------|
| `zsh/.zshrc` | `~/.zshrc` |
| `git/.gitconfig` | `~/.gitconfig` |
| `vim` | `~/.vim` |
| `vim/vimrc` | `~/.vimrc` |
| [`nvim`](nvim) | `~/.config/nvim` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `tmux` | `~/.tmux` |
| `ghostty` | `~/.config/ghostty` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `kitty/catppuccin/themes` | `~/.config/kitty/themes` |
| `bat/config` | `~/.config/bat/config` |
| `bat/catppuccin/themes` | `~/.config/bat/themes` |
| `eza` | `~/.config/eza` |
| `yazi` | `~/.config/yazi` |
| `kanata/kanata.kbd` | `~/.config/kanata/kanata.kbd` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `bottom/bottom.toml` | `~/.config/bottom/bottom.toml` |
| [`lazygit/config.yml`](lazygit/config.yml) | `~/.config/lazygit/config.yml` |
| `lazydocker/config.yml` | `~/.config/lazydocker/config.yml` |
| `k9s/config.yml` | `~/.config/k9s/config.yml` |
| `k9s/catppuccin/dist` | `~/.config/k9s/skins` |
| [`tealdeer/config.toml`](tealdeer/config.toml) | `~/.config/tealdeer/config.toml` |
| `htop/htoprc` | `~/.config/htop/htoprc` |
| `gh/config.yml` | `~/.config/gh/config.yml` |
| `glab/config.yml` | `~/.config/glab-cli/config.yml` |
| `gnupg` | `~/.gnupg` |
| `ssh` | `~/.ssh` |
| `nodejs/.npmrc` | `~/.npmrc` |
| `nodejs/.yarnrc.yml` | `~/.yarnrc.yml` |
| `nodejs/.pnpmrc` | `~/.pnpmrc` |
| [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) | `~/.config/node/repl-init.mjs` |
| [`python/.pdbrc`](python/.pdbrc) | `~/.pdbrc` |
| [`python/pythonrc`](python/pythonrc) | `~/.pythonrc` |
| [`python/debughook.py`](python/debughook.py) | `~/.config/python/debughook.py` |
| `mutt/.muttrc` | `~/.muttrc` |
| `mutt` | `~/.mutt` |
| `curl/.curlrc` | `~/.curlrc` |
| `wget/.wgetrc` | `~/.wgetrc` |
| `readline/.inputrc` | `~/.inputrc` |
| `ripgrep/.ripgreprc` | `~/.ripgreprc` |
| `fd/.fdrc` | `~/.fdrc` |
| `telnet/.telnetrc` | `~/.telnetrc` |
| [`cmus/rc`](cmus/rc) | `~/.config/cmus/rc` |
| `atuin/config.toml` | `~/.config/atuin/config.toml` |
| `direnv/direnv.toml` | `~/.config/direnv/direnv.toml` |
| `direnv/direnvrc` | `~/.config/direnv/direnvrc` |
| `thefuck/settings.py` | `~/.config/thefuck/settings.py` |
| [`tig/config`](tig/config) | `~/.config/tig/config` |
| [`broot/conf.toml`](broot/conf.toml) | `~/.config/broot/conf.toml` |
| [`ranger/rc.conf`](ranger/rc.conf) | `~/.config/ranger/rc.conf` |
| [`ranger/rifle.conf`](ranger/rifle.conf) | `~/.config/ranger/rifle.conf` |
| [`ranger/scope.sh`](ranger/scope.sh) | `~/.config/ranger/scope.sh` |
| `newsboat/config` | `~/.config/newsboat/config` |
| `newsboat/urls` | `~/.config/newsboat/urls` |
| [`navi/config.yaml`](navi/config.yaml) | `~/.config/navi/config.yaml` |
| `asciinema/config` | `~/.config/asciinema/config` |
| `goaccess/goaccess.conf` | `~/.config/goaccess/goaccess.conf` |
| `taskwarrior/taskrc` | `~/.config/task/taskrc` |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` |

On macOS, lazygit, lazydocker, k9s, and ghostty also get symlinks into `~/Library/Application Support/`.

</details>

<details>
<summary><strong>Project structure</strong></summary>

```
.dotfiles/
├── asciinema/        # Asciinema terminal recorder config
├── atuin/            # Atuin shell history config
├── bat/              # Bat config + Catppuccin Mocha theme
├── bottom/           # Bottom system monitor, Catppuccin Mocha styled
├── broot/            # Broot file manager, Catppuccin Mocha themed
├── cmus/             # cmus music player, Catppuccin Mocha themed
├── conky/            # Conky system monitor (Linux)
├── curl/             # Curl config
├── direnv/           # direnv per-directory env config
├── eza/              # eza (ls replacement) config + Catppuccin Mocha theme
├── fd/               # fd (find replacement) config
├── gh/               # GitHub CLI config
├── ghostty/          # Ghostty terminal + Catppuccin Mocha theme
├── git/              # Git config, hooks, message template, 60 aliases
├── glab/             # GitLab CLI config
├── gnupg/            # GPG config and public keys
├── goaccess/         # GoAccess web log analyzer config
├── htop/             # htop config
├── k9s/              # K9s Kubernetes dashboard + Catppuccin Mocha skin
├── kanata/           # Kanata keyboard remapper config
├── kitty/            # Kitty terminal + Catppuccin Mocha theme
├── lazydocker/       # Lazydocker config, Catppuccin Mocha
├── lazygit/          # Lazygit config, Catppuccin Mocha
├── mailcap/          # Mailcap config
├── mise/             # mise runtime manager (Node.js, Python, Ruby)
├── mutt/             # Neomutt email client + Catppuccin Mocha theme
├── nodejs/           # npm, yarn, pnpm configs + GPG-encrypted tokens
├── nvim/             # Neovim config, standalone lua setup with lazy.nvim
├── vim/              # Vim config, 31 plugins
├── obsidian/         # Obsidian notes config
├── ranger/           # Ranger file manager config
├── readline/         # Readline config
├── ripgrep/          # Ripgrep config
├── ssh/              # SSH config and public keys
├── tealdeer/         # Tealdeer (tldr) config, Catppuccin Mocha
├── telnet/           # Telnet config
├── themes/           # Terminal themes (iTerm2)
├── tilix/            # Tilix terminal config
├── navi/             # Navi cheatsheet manager + custom cheats
├── newsboat/         # Newsboat RSS reader config
├── opencode/         # OpenCode AI config
├── taskwarrior/      # Taskwarrior task manager, Catppuccin Mocha themed
├── thefuck/          # TheFuck command corrector config
├── tig/              # Tig git TUI, Catppuccin Mocha themed
├── tmux/             # Tmux config + 9 plugins
├── tmuxp/            # tmuxp session layouts
├── wget/             # Wget config
├── yazi/             # Yazi file manager + Catppuccin Mocha theme
├── zsh/              # Zsh: aliases, functions, paths, settings, infrastructure
├── Brewfile          # Homebrew packages, apps, and fonts
├── install.sh        # Cross-platform installer
└── LICENSE           # MIT
```

</details>

## Adding New Configs

1. Create a directory: `myapp/`
2. Add config files
3. Add to `install.sh`:
   ```bash
   safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
   ```

## Security

Private keys and credentials are excluded via `.gitignore`. Only public GPG keys and SSH public keys are tracked. API tokens are stored as GPG-encrypted files and decrypted at shell startup with caching.

GnuPG never fetches a key from the network while verifying a signature. Automatic retrieval reveals to a third party which messages are being read, so keys are fetched explicitly with `gpg --recv-keys`.

### Mail Signing

Outgoing mail is signed by default, with the signature written inline in the message body rather than attached as `signature.asc`. Postponed drafts are encrypted, so a draft of an encrypted message is never stored in clear text on the mail server.

Inline signing requires NeoMutt's classic PGP backend, because the GPGME backend cannot produce inline messages. Both backends are configured and one line at the top of the Crypto section in [`mutt/.muttrc`](mutt/.muttrc) selects between them:

| Setting in [`mutt/.muttrc`](mutt/.muttrc) | Backend | Profile sourced |
|---|---|---|
| `set my_pgp_inline = yes` | classic PGP, inline signatures | [`mutt/crypto/inline.muttrc`](mutt/crypto/inline.muttrc) |
| line commented out | GPGME, PGP/MIME with protected headers | [`mutt/crypto/gpgme.muttrc`](mutt/crypto/gpgme.muttrc) |

Switching backends requires restarting NeoMutt, since `crypt_use_gpgme` has no effect when set interactively.

The classic backend invokes `pgpewrap` by bare name to expand multiple recipients. It ships inside NeoMutt's `libexec` directory, which [`zsh/paths`](zsh/paths) puts on `PATH` for both Linux and macOS.

Every setting an account applies has a matching `reset` in [`mutt/normalize.muttrc`](mutt/normalize.muttrc), which runs first when switching accounts. A setting added to an account file without a matching reset leaks into the next account.

## License

[MIT](LICENSE) since 2014.
