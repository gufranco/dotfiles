<div align="center">

<strong>One-command development environment for macOS and Linux: zsh, Vim, tmux and 56 tool configs on one Catppuccin Mocha palette.</strong>

English | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [繁體中文 (香港)](README.zh-HK.md)

[![Install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![Lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)

</div>

---

The [`Brewfile`](Brewfile) declares 231 formulae, 91 casks and 12 Mac App Store apps, 23 tools share the Catppuccin Mocha theme, and Git carries 60 aliases.

## Usage

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL 5432 in Docker through Colima
fde                    # fuzzy-pick a running container and open a shell in it
lt                     # tree view of the current directory with eza
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

## Quick Start

### Prerequisites

| Tool | Install |
|:-----|:--------|
| macOS or Ubuntu | A fresh install works |
| Git | Ships with macOS; `sudo apt install git` on Ubuntu |
| curl | Ships with both |

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh) detects the OS and the architecture. On macOS it installs Homebrew and runs the Brewfile. On Linux it uses apt, snap and direct downloads.

### Verify

```bash
exec zsh
bat --version
zoxide --version
```

Both commands print a version number. A `command not found` means the install stopped early; run `install.sh` again, since every step is idempotent.

## What Gets Installed

### Shell

| Feature | Implementation |
|:--------|:---------------|
| Shell | Zsh with Oh My Zsh and the Spaceship prompt |
| Fuzzy finder | fzf with a bat preview and Catppuccin Mocha colors |
| Tab completion | fzf-tab |
| Syntax highlighting | zsh-syntax-highlighting |
| Smart cd | zoxide, ranked by frecency |
| Shell history | atuin, searchable and synced |
| Per-directory env | direnv, loading `.envrc` on `cd` |
| Runtimes | mise: Node.js LTS, latest Python and Ruby, per-project overrides in `.mise.toml` |
| GNU tools on macOS | coreutils, findutils, grep, sed, tar and make take PATH priority over the BSD versions |

### Modern Tool Replacements

Each alias is defined only when its tool is installed, so a missing tool falls back to the system command:

| Alias | Tool |
|:------|:-----|
| `cat` | `bat`, plain output when piped |
| `ls` | `eza` with icons and directories first |
| `lt` | `eza` tree, two levels deep |
| `top` | `btm` |
| `ping` | `gping`, macOS only |
| `stats` | `tokei`, macOS only |

### Editor

Vim with 31 plugins managed by vim-plug:

| Category | Plugins |
|:---------|:--------|
| Language support | coc.nvim, vim-polyglot, vim-matchup, rainbow_csv |
| Navigation | fzf, fzf.vim, vim-sneak, vim-fetch |
| Git | vim-signify, vim-fugitive, conflict-marker.vim |
| Editing | vim-surround, vim-visual-multi, vim-pasta, targets.vim, vim-unimpaired, vim-repeat, vim-abolish, splitjoin.vim |
| Files | vim-eunuch |
| UI | lightline, vim-devicons, undotree, vim-cool, vim-search-pulse, winresizer |
| Theme | catppuccin/vim, driving the colorscheme and lightline |
| Defaults | vim-sensible, vim-opinion |
| Integration | vim-tmux, vim-tmux-navigator |

[`vim/vimrc`](vim/vimrc) holds 33 `Plug` lines. Three of them point at the Homebrew, `/usr/local` and `~/.fzf` copies of the same fzf install, and only the one present on the machine loads.

CoC extensions: TypeScript, ESLint, Prettier, CSS, JSON, Shell, snippets and import-cost.

Neovim has its own Lua setup on lazy.nvim in [`nvim/`](nvim).

### Debugging

Python uses the standard library `pdb` with a richer [`python/.pdbrc`](python/.pdbrc). The aliases `dir`, `attrs`, `vars`, `src` and `loc` inspect objects and locals at the prompt, adapted from Trey Hunner's [Customizing pdb with .pdbrc](https://treyhunner.com/2026/04/customizing-pdb-with-pdbrc/). `breakpoint()` goes through [`python/debughook.py`](python/debughook.py), which prefers pdbp, then ipdb, then the standard `pdb`, so it works in a virtualenv that has neither. [`python/pythonrc`](python/pythonrc) is the `PYTHONSTARTUP` file: persistent REPL history and pretty-printed output.

Node.js uses the built-in V8 Inspector. The `ni`, `nib` and `niw` aliases run `node inspect` and `--inspect-brk` for terminal and Chrome DevTools debugging. `jsr` opens a REPL from [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) with deep colorized inspection.

### Terminal Multiplexer

Tmux with 19 plugins and Vim-style keybindings, installed by tpm:

| Plugin | What it does |
|:-------|:-------------|
| catppuccin/tmux | Status bar, window list and pane styling |
| tmux-sensible-revamped | Defaults aware of the tmux version, OS and terminal: truecolor, OSC 52 clipboard, focus events |
| tmux-pain-control-revamped | Vim-style pane splits, navigation, resizing and window moves |
| tmux-launcher-revamped | Opens lazygit, lazydocker and other TUIs in a popup or a new window |
| tmux-tiling-revamped | i3-like BSP tiling, pane marks and a floating scratchpad |
| tmux-scroll-revamped | Sends the wheel to the app when it wants it, enters copy-mode otherwise |
| tmux-reorder-revamped | Drag a window tab on the status bar and it slides into place under the pointer |
| tmux-fzf-revamped | Fuzzy switch or kill any session, window or pane |
| tmux-extract-revamped | Fuzzy-grab URLs, paths, words or lines off the pane and paste them |
| tmux-autoreload-revamped | Re-sources the config when it changes |
| tmux-persist-revamped | Saves sessions and restores them when the server starts |
| tmux-cpu, ram, disk, battery, git, time, music and weather revamped | Status bar segments |

Every plugin except the Catppuccin theme comes from the [tmux-revamped](https://github.com/tmux-revamped) family. `tmux-persist-revamped` replaces tmux-resurrect and tmux-continuum and writes no temp files.

### Git

60 aliases in [`git/.gitconfig`](git/.gitconfig), including:

| Alias | Command |
|:------|:--------|
| `st` | `status -sb` |
| `lg` | colored `log --graph --decorate` |
| `fork` | `checkout -q -b` |
| `publish` | `push -u origin HEAD` |
| `force` | `push --force-with-lease` |
| `cleanup` | delete local branches already merged, keeping `main`, `master` and `develop` |
| `today` | `log --since=midnight --oneline` |
| `sw` | `switch` |

Commits and tags are GPG-signed by default. Delta is the diff pager, with line numbers, hyperlinks and the Catppuccin Mocha theme. The config also sets the histogram diff algorithm, `zdiff3` conflict markers and rebase on pull with autostash.

### Docker Services

Colima runs Docker, sized from the host's CPU count and memory. On Apple Silicon it uses Apple's Virtualization.framework with Rosetta 2 for x86_64 images.

| Service | Command | Port |
|:--------|:--------|:-----|
| PostgreSQL | `postgres-init` | 5432 |
| MongoDB | `mongo-init` | 27017 |
| Redis | `redis-init` | 6379 |
| Valkey | `valkey-init` | 7000 |
| Redict | `redict-init` | 6379 |
| Ubuntu | `ubuntu-init` | none |

Each service also has `-start`, `-stop`, `-purge` and `-terminal` functions, and every port binds to `127.0.0.1` only. `fde`, `fdl` and `fds` pick a running container with fzf and open a shell in it, follow its logs, or stop it.

### Own Tools

Six command-line tools from the same author come from the [gufranco/tap](https://github.com/gufranco/homebrew-tap) Homebrew tap on macOS. [`install.sh`](install.sh) installs all of them except fusho on Linux.

| Tool | What it does |
|:-----|:-------------|
| [fusho](https://github.com/gufranco/fusho) | Sends an encrypted message through any chat, addressed by GitHub username |
| [jimaku](https://github.com/gufranco/jimaku) | Downloads subtitles for every video in a folder as UTF-8, in the language set by `JIMAKU_LANGUAGE` |
| [kakikomi](https://github.com/gufranco/kakikomi) | Writes images to floppies, Zip disks, USB sticks and hard disks, verified chunk by chunk and never mounted |
| [kiyome](https://github.com/gufranco/kiyome) | Wipes a disk with five verified patterns and names any failing bit line |
| [shiwake](https://github.com/gufranco/shiwake) | Sorts the files of a folder into A to Z subfolders by first letter, never moving one file over another |
| [yakitsuke](https://github.com/gufranco/yakitsuke) | Turns any video into Video CD images split across discs, with subtitles styled for the picture under each line |

### Linux Gaming

A Steam and Proton setup at parity with SteamOS, aimed at laptops with hybrid NVIDIA graphics. It installs automatically on `amd64` Ubuntu and is skipped on ARM.

| Component | What it does |
|:----------|:-------------|
| NVIDIA driver from the graphics-drivers PPA | Latest branch; open kernel modules on Turing and newer, proprietary on older MX chips |
| NVIDIA Prime | Hybrid switching: the iGPU drives the desktop, the dGPU runs games |
| Suspend and resume hardening | Preserves VRAM across laptop suspend cycles |
| iGPU media stack | Intel `media-va-driver` or AMD `mesa-va-drivers`, per machine |
| Mesa from the oibaf PPA | Latest RADV and ANV Vulkan drivers |
| Vulkan, 64-bit and 32-bit | Full Vulkan stack for both GPUs |
| XanMod kernel | fsync and winesync for Proton frame-time consistency, HZ=500, full preemption |
| scx_lavd scheduler | The latency-aware sched_ext scheduler Valve and CachyOS ship |
| zram and tuned sysctl | Compressed RAM swap with VM tuning for zram |
| earlyoom | Kills the largest process before a freeze, sparing Steam and Proton |
| ananicy-cpp | Lowers the priority of background processes so they never preempt a game |
| GameMode | Switches the CPU governor and raises priority while a game runs |
| MangoHud and GOverlay | FPS and frame-time overlay with a managed config |
| vkBasalt | CAS sharpening with a managed config |
| Gamescope | Valve's micro-compositor with FSR upscaling |
| Steam and GE-Proton | Native Steam; GE-Proton downloaded automatically, proton-cachyos available through ProtonUp-Qt |
| Heroic, Lutris and Bottles | Epic, GOG, Amazon and other launchers through Flatpak |
| Controller drivers | udev rules from steam-launcher, plus xpadneo and xone DKMS modules for Xbox pads |
| NVIDIA shader cache env | A persistent shader cache that is never pruned, so games do not stutter recompiling |

> [!IMPORTANT]
> Reboot after the first install to boot the XanMod kernel and load scx_lavd, then run `gaming-check` to verify every component.

`gaming-launch-options` prints the recommended Steam launch options per game. Most games use:

```bash
prime-run gamemoderun mangohud %command%
```

These GPUs are GTX and MX parts with no tensor or RT cores, so DLSS and hardware ray tracing do not apply. The performance lever is FSR upscaling through Gamescope: render below native resolution and upscale.

In Steam, open Settings, then Compatibility, turn on "Enable Steam Play for all other titles" and pick "Proton Experimental" or a GE-Proton version. Leave Shader Pre-Caching on under Settings, then Downloads.

`f5` keeps GE-Proton current and rebuilds the controller DKMS modules after a kernel update. When a game fails, switch it to GE-Proton in its Compatibility settings, check [ProtonDB](https://www.protondb.com/), or run `protontricks <appid> --gui` to install missing Windows components. [Are We Anti-Cheat Yet](https://areweanticheatyet.com/) lists which multiplayer games run under Proton.

## Catppuccin Mocha Theme

23 tools use the [Catppuccin](https://catppuccin.com) Mocha flavor with the mauve accent. Themes come from the official ports as git submodules where the tool loads a theme from a path, and are inlined from the official port or the palette otherwise:

| Tool | Method |
|:-----|:-------|
| Ghostty | Built-in `Catppuccin Mocha` theme |
| Bat | `catppuccin/bat` submodule tmTheme |
| Delta | `catppuccin/delta` submodule feature |
| Git | Mocha hex in the `[color]` sections |
| Vim | `catppuccin/vim` plugin and lightline |
| Neovim | `catppuccin/nvim` plugin and lualine |
| Tmux | `catppuccin/tmux` plugin |
| fzf | Official Mocha `--color` |
| zsh-autosuggestions | Mocha muted foreground for suggestions |
| eza | Mocha mauve [`eza/theme.yml`](eza/theme.yml), from `catppuccin/eza` |
| ripgrep | Mocha colors in [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc) |
| Bottom | Official Mocha `[styles]` |
| K9s | `catppuccin/k9s` submodule skin |
| Lazygit | Official Mocha mauve `gui.theme` |
| Lazydocker | Official Mocha mauve theme |
| tig | Mocha hex built from the palette |
| broot | Mocha skin in [`broot/conf.toml`](broot/conf.toml) |
| Midnight Commander | `catppuccin/mc` submodule skin |
| NeoMutt | `catppuccin/neomutt` submodule |
| Newsboat | Mocha colors in [`newsboat/config`](newsboat/config) |
| Taskwarrior | Mocha colors in [`taskwarrior/taskrc`](taskwarrior/taskrc) |
| Tealdeer | Mocha RGB in [`tealdeer/config.toml`](tealdeer/config.toml) |
| cmus | Nearest 256-color Mocha values in [`cmus/rc`](cmus/rc), since cmus has no 24-bit color |

GoAccess has no Catppuccin port and its HTML report offers only bright and dark built-ins, so it uses dark. Theme submodules track upstream `main`, and `f5` updates them with `git submodule update --remote`.

## System Update

`f5` updates everything in one pass:

1. Pulls the dotfiles and their submodules
2. Updates the AWS configuration and the Claude engineering rules
3. Updates Vim plugins, CoC extensions and Neovim plugins
4. Updates Oh My Zsh, the Zsh plugins and the Tmux plugins
5. Refreshes tool data such as the tldr cache
6. Upgrades the mise runtimes
7. On macOS: `brew update`, `brew bundle`, `brew bundle cleanup --force --zap`, which uninstalls anything not in the Brewfile, `brew upgrade --greedy`, removal of the quarantine flag from apps installed from gufranco/tap, and Mac App Store updates
8. On Linux: `apt update`, `apt dist-upgrade` and `apt autoremove`, a rebuild of the xpadneo and xone modules, and updates to standalone tools, Nerd Fonts, Flatpak apps and GE-Proton
9. Installs, upgrades and prunes the uv tools listed in [`Uvfile`](Uvfile)
10. Reclaims cache space: scrubs the Homebrew download cache and prunes the npm, pnpm, yarn, uv and Go caches; on macOS it also clears Xcode `DerivedData`, cleans the CocoaPods cache and deletes unavailable simulators. Docker and the Colima VM disk are left alone, so running containers survive
11. Reloads the Tmux and Zsh configs

## Symlink Map

`install.sh` links every config with `safe_link`, which is idempotent, creates parent directories, and moves an existing file or directory aside to `<path>.backup.<timestamp>` before linking.

<details>
<summary><strong>Full symlink map</strong></summary>

| Source | Target |
|:-------|:-------|
| [`zsh/.zshrc`](zsh/.zshrc) | `~/.zshrc` |
| [`git/.gitconfig`](git/.gitconfig) | `~/.gitconfig` |
| [`vim`](vim) | `~/.vim` |
| [`vim/vimrc`](vim/vimrc) | `~/.vimrc` |
| [`nvim`](nvim) | `~/.config/nvim` |
| [`tmux/.tmux.conf`](tmux/.tmux.conf) | `~/.tmux.conf` |
| [`tmux`](tmux) | `~/.tmux` |
| [`ghostty`](ghostty) | `~/.config/ghostty` |
| [`bat/config`](bat/config) | `~/.config/bat/config` |
| `bat/catppuccin/themes` | `~/.config/bat/themes` |
| [`eza`](eza) | `~/.config/eza` |
| [`kanata/kanata.kbd`](kanata/kanata.kbd) | `~/.config/kanata/kanata.kbd` |
| [`mise/config.toml`](mise/config.toml) | `~/.config/mise/config.toml` |
| [`bottom/bottom.toml`](bottom/bottom.toml) | `~/.config/bottom/bottom.toml` |
| [`lazygit/config.yml`](lazygit/config.yml) | `~/.config/lazygit/config.yml` |
| [`lazydocker/config.yml`](lazydocker/config.yml) | `~/.config/lazydocker/config.yml` |
| [`k9s/config.yml`](k9s/config.yml) | `~/.config/k9s/config.yml` |
| `k9s/catppuccin/dist` | `~/.config/k9s/skins` |
| [`tealdeer/config.toml`](tealdeer/config.toml) | `~/.config/tealdeer/config.toml` |
| [`htop/htoprc`](htop/htoprc) | `~/.config/htop/htoprc` |
| [`gh/config.yml`](gh/config.yml) | `~/.config/gh/config.yml` |
| [`gnupg`](gnupg) | `~/.gnupg` |
| `gnupg/gpg-agent-linux.conf` or `gnupg/gpg-agent-macos-<arch>.conf` | `~/.gnupg/gpg-agent.conf` |
| [`ssh`](ssh) | `~/.ssh` |
| [`nodejs/.npmrc`](nodejs/.npmrc) | `~/.npmrc` |
| [`nodejs/.yarnrc.yml`](nodejs/.yarnrc.yml) | `~/.yarnrc.yml` |
| [`nodejs/.pnpmrc`](nodejs/.pnpmrc) | `~/.pnpmrc` |
| [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) | `~/.config/node/repl-init.mjs` |
| [`clang-tidy/.clang-tidy`](clang-tidy/.clang-tidy) | `~/.clang-tidy` |
| [`golangci/golangci.yml`](golangci/golangci.yml) | `~/.golangci.yml` |
| [`ruff/ruff.toml`](ruff/ruff.toml) | `~/.config/ruff/ruff.toml` |
| [`rubocop/config.yml`](rubocop/config.yml) | `~/.config/rubocop/config.yml` |
| [`luacheck/luacheckrc`](luacheck/luacheckrc) | `~/.config/luacheck/.luacheckrc` |
| [`dart/analysis_options.yaml`](dart/analysis_options.yaml) | `~/analysis_options.yaml` |
| [`python/.pdbrc`](python/.pdbrc) | `~/.pdbrc` |
| [`python/pythonrc`](python/pythonrc) | `~/.pythonrc` |
| [`python/debughook.py`](python/debughook.py) | `~/.config/python/debughook.py` |
| [`mutt/.muttrc`](mutt/.muttrc) | `~/.muttrc` |
| [`mutt`](mutt) | `~/.mutt` |
| [`mailcap/.mailcap`](mailcap/.mailcap) | `~/.mailcap` |
| [`curl/.curlrc`](curl/.curlrc) | `~/.curlrc` |
| [`wget/.wgetrc`](wget/.wgetrc) | `~/.wgetrc` |
| [`readline/.inputrc`](readline/.inputrc) | `~/.inputrc` |
| [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc) | `~/.ripgreprc` |
| [`fd/.fdrc`](fd/.fdrc) | `~/.fdrc` |
| [`telnet/.telnetrc`](telnet/.telnetrc) | `~/.telnetrc` |
| [`cmus/rc`](cmus/rc) | `~/.config/cmus/rc` |
| [`mc/ini`](mc/ini) | `~/.config/mc/ini` |
| `mc/catppuccin/catppuccin.ini` | `~/.local/share/mc/skins/catppuccin.ini` |
| [`atuin/config.toml`](atuin/config.toml) | `~/.config/atuin/config.toml` |
| [`direnv/direnv.toml`](direnv/direnv.toml) | `~/.config/direnv/direnv.toml` |
| [`direnv/direnvrc`](direnv/direnvrc) | `~/.config/direnv/direnvrc` |
| [`thefuck/settings.py`](thefuck/settings.py) | `~/.config/thefuck/settings.py` |
| [`tig/config`](tig/config) | `~/.config/tig/config` |
| [`broot/conf.toml`](broot/conf.toml) | `~/.config/broot/conf.toml` |
| [`ranger/rc.conf`](ranger/rc.conf) | `~/.config/ranger/rc.conf` |
| [`ranger/rifle.conf`](ranger/rifle.conf) | `~/.config/ranger/rifle.conf` |
| [`ranger/scope.sh`](ranger/scope.sh) | `~/.config/ranger/scope.sh` |
| [`newsboat/config`](newsboat/config) | `~/.config/newsboat/config` |
| [`newsboat/urls`](newsboat/urls) | `~/.config/newsboat/urls` |
| [`navi/config.yaml`](navi/config.yaml) | `~/.config/navi/config.yaml` |
| [`navi/cheats`](navi/cheats) | `~/.config/navi/cheats` |
| [`asciinema/config.toml`](asciinema/config.toml) | `~/.config/asciinema/config.toml` |
| [`goaccess/goaccess.conf`](goaccess/goaccess.conf) | `~/.config/goaccess/goaccess.conf` |
| [`taskwarrior/taskrc`](taskwarrior/taskrc) | `~/.taskrc` |
| [`opencode/opencode.json`](opencode/opencode.json) | `~/.config/opencode/opencode.json` |
| [`conky/.conkyrc`](conky/.conkyrc) | `~/.conkyrc`, Linux only |
| [`gamemode/gamemode.ini`](gamemode/gamemode.ini) | `~/.config/gamemode.ini`, Linux gaming |
| [`mangohud/MangoHud.conf`](mangohud/MangoHud.conf) | `~/.config/MangoHud/MangoHud.conf`, Linux gaming |
| [`vkbasalt/vkBasalt.conf`](vkbasalt/vkBasalt.conf) | `~/.config/vkBasalt/vkBasalt.conf`, Linux gaming |
| [`nvidia/99-gaming-nvidia.conf`](nvidia/99-gaming-nvidia.conf) | `~/.config/environment.d/99-gaming-nvidia.conf`, Linux gaming |

On macOS, lazygit, lazydocker, k9s and Ghostty also get links under `~/Library/Application Support/`.

[`glab/config.yml`](glab/config.yml) is copied to `~/.config/glab-cli/config.yml` on the first install instead of linked, because `glab auth login` writes the token into that file.

</details>

<details>
<summary><strong>Project structure</strong></summary>

| Path | Contents |
|:-----|:---------|
| [`asciinema/`](asciinema) | Asciinema terminal recorder |
| [`atuin/`](atuin) | Atuin shell history |
| [`bat/`](bat) | Bat config and the Catppuccin Mocha theme |
| [`bottom/`](bottom) | Bottom system monitor |
| [`broot/`](broot) | Broot file manager |
| [`clang-tidy/`](clang-tidy) | clang-tidy defaults plus immutability checks for C and C++ |
| [`cmus/`](cmus) | cmus music player |
| [`conky/`](conky) | Conky system monitor, Linux |
| [`curl/`](curl) | curl |
| [`dart/`](dart) | Dart analyzer defaults with immutability lints |
| [`direnv/`](direnv) | direnv |
| [`eza/`](eza) | eza and its Catppuccin Mocha theme |
| [`fd/`](fd) | fd |
| [`gamemode/`](gamemode) | GameMode CPU governor and priority tuning, Linux gaming |
| [`gh/`](gh) | GitHub CLI |
| [`ghostty/`](ghostty) | Ghostty terminal |
| [`git/`](git) | Git config, commit message template and 60 aliases |
| [`glab/`](glab) | GitLab CLI |
| [`gnupg/`](gnupg) | GPG config and keys |
| [`goaccess/`](goaccess) | GoAccess web log analyzer |
| [`golangci/`](golangci) | golangci-lint standard linters plus immutability linters for Go |
| [`htop/`](htop) | htop |
| [`k9s/`](k9s) | K9s Kubernetes dashboard and its Catppuccin Mocha skin |
| [`kanata/`](kanata) | Kanata keyboard remapper |
| [`lazydocker/`](lazydocker) | Lazydocker |
| [`lazygit/`](lazygit) | Lazygit |
| [`luacheck/`](luacheck) | luacheck defaults that forbid implicit globals in Lua |
| [`mailcap/`](mailcap) | Mailcap |
| [`mangohud/`](mangohud) | MangoHud overlay, Linux gaming |
| [`mc/`](mc) | Midnight Commander and its Catppuccin Mocha skin |
| [`mise/`](mise) | mise runtime manager |
| [`mutt/`](mutt) | NeoMutt mail client and its Catppuccin Mocha theme |
| [`navi/`](navi) | Navi cheatsheet manager and custom cheats |
| [`newsboat/`](newsboat) | Newsboat RSS reader |
| [`nodejs/`](nodejs) | npm, yarn and pnpm configs and GPG-encrypted tokens |
| [`nvidia/`](nvidia) | NVIDIA Xorg and shader cache drop-ins, Linux gaming |
| [`nvim/`](nvim) | Neovim, a standalone Lua setup on lazy.nvim |
| [`opencode/`](opencode) | OpenCode |
| [`python/`](python) | pdb config, `PYTHONSTARTUP` and the `breakpoint()` hook |
| [`ranger/`](ranger) | Ranger file manager |
| [`readline/`](readline) | Readline |
| [`ripgrep/`](ripgrep) | ripgrep |
| [`rubocop/`](rubocop) | RuboCop defaults plus immutability cops |
| [`ruff/`](ruff) | Ruff defaults plus immutability rules |
| [`specs/`](specs) | Behavior specs and design records |
| [`ssh/`](ssh) | SSH config and keys |
| [`taskwarrior/`](taskwarrior) | Taskwarrior task manager |
| [`tealdeer/`](tealdeer) | Tealdeer, a tldr client |
| [`telnet/`](telnet) | Telnet |
| [`tests/`](tests) | Python unit tests for the debug hook and the REPL startup file |
| [`thefuck/`](thefuck) | thefuck command corrector |
| [`tig/`](tig) | tig, a Git TUI |
| [`tmux/`](tmux) | Tmux config and 19 plugins |
| [`tmuxp/`](tmuxp) | tmuxp session layouts |
| [`vim/`](vim) | Vim config and 31 plugins |
| [`vkbasalt/`](vkbasalt) | vkBasalt CAS sharpening |
| [`wget/`](wget) | Wget |
| [`zsh/`](zsh) | Zsh: [`config/`](zsh/config) holds the load-ordered shell setup, [`modules/`](zsh/modules) the commands |
| [`Brewfile`](Brewfile) | Homebrew formulae, casks, fonts and Mac App Store apps |
| [`Uvfile`](Uvfile) | CLI tools installed with uv |
| [`install.sh`](install.sh) | Cross-platform installer |

</details>

## Adding a Config

1. Create a directory such as `myapp/` and put the config files in it.
2. Link it from [`install.sh`](install.sh):

   ```bash
   safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
   ```

3. Run the checks CI runs:

   ```bash
   shellcheck install.sh
   python3 -m unittest discover -s tests -v
   ```

The [lint workflow](.github/workflows/lint.yml) also runs shfmt, a zsh syntax check, actionlint, YAML and TOML lint, and a gitleaks secrets scan. The [install workflow](.github/workflows/install.yml) runs `install.sh` twice on Ubuntu and macOS to prove it is idempotent. After Lint passes on `master`, the [release workflow](.github/workflows/release.yml) runs semantic-release, which reads the Conventional Commits since the last tag, cuts the next version, writes `CHANGELOG.md` and publishes a GitHub release.

## Security

The SSH and GPG private keys in [`ssh/`](ssh) and `gnupg/keys/` are tracked, each protected by a passphrase. Other credentials are excluded through [`.gitignore`](.gitignore). API tokens are stored as GPG-encrypted files and decrypted at shell startup with caching.

GnuPG never fetches a key from the network while verifying a signature. Automatic retrieval tells a third party which messages are being read, so keys are fetched explicitly with `gpg --recv-keys`.

### Mail Signing

Outgoing mail is signed by default, with the signature inline in the message body instead of an attached `signature.asc`. Postponed drafts are encrypted, so a draft of an encrypted message is never stored in clear text on the mail server.

Inline signing needs NeoMutt's classic PGP backend, because the GPGME backend cannot produce inline messages. Both backends are configured, and one line at the top of the Crypto section in [`mutt/.muttrc`](mutt/.muttrc) selects between them:

| Setting | Backend | Profile sourced |
|:--------|:--------|:----------------|
| `set my_pgp_inline = yes` | Classic PGP, inline signatures | [`mutt/crypto/inline.muttrc`](mutt/crypto/inline.muttrc) |
| Line commented out | GPGME, PGP/MIME with protected headers | [`mutt/crypto/gpgme.muttrc`](mutt/crypto/gpgme.muttrc) |

Switching backends needs a NeoMutt restart, since `crypt_use_gpgme` has no effect when set interactively.

The classic backend calls `pgpewrap` by bare name to expand multiple recipients. It ships in NeoMutt's `libexec` directory, which [`zsh/config/paths`](zsh/config/paths) adds to `PATH` on Linux and macOS.

Every setting an account applies has a matching `reset` in [`mutt/normalize.muttrc`](mutt/normalize.muttrc), which runs first when switching accounts. A setting added to an account file without a matching reset leaks into the next account.

## License

[MIT](LICENSE), since 2014.
