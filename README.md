<div align="center">

<br>

<strong>One-command development environment for macOS and Linux. 50+ tool configs, consistent Tokyo Night theme, modern CLI replacements, and ready-to-go Docker services.</strong>

<br>
<br>

[![CI](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-zsh-blue?style=flat-square)]()
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)]()

</div>

---

**50+** tool configs · **19** Tokyo Night themed tools · **60** Git aliases · **6** Docker services · **31** Vim plugins

<table>
<tr>
<td width="50%" valign="top">

### Tokyo Night Everywhere

One color palette across 19 tools: terminals, editors, file managers, email, music, git diffs, monitoring dashboards, and fuzzy finders.

</td>
<td width="50%" valign="top">

### Modern CLI Replacements

`cat` becomes `bat`, `ls` becomes `eza`, `top` becomes `btm`, `du` becomes `dust`. Graceful fallbacks when the modern tool is not installed.

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
| Fuzzy finder | fzf with bat preview and Tokyo Night colors |
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
| `du` | du | `dust` with visual tree output |
| `df` | df | `duf` with color output |
| `ps` | ps | `procs` with tree and color |
| `top` | top | `btm` (Bottom) system monitor TUI |
| `ping` | ping | `gping` with graphical output (macOS) |
| `stats` | - | `tokei` for code statistics (macOS) |

### Editor

Vim with 31 plugins managed by vim-plug:

| Category | Plugins |
|:---------|:--------|
| Language support | coc.nvim (LSP), vim-polyglot, vim-matchup, rainbow_csv |
| Navigation | fzf.vim, leap.nvim (jump motions), lazygit.nvim, vim-fetch (open at line) |
| Git | vim-signify (hunks), vim-fugitive (commands), conflict-marker.vim |
| Editing | vim-surround, vim-visual-multi, vim-pasta, targets.vim, vim-unimpaired, vim-repeat, vim-abolish (case coercion), splitjoin.vim |
| Files | vim-eunuch (Rename, Delete, Move, SudoWrite) |
| UI | lightline, vim-devicons, undotree, vim-cool, vim-search-pulse, winresizer |
| Defaults | vim-sensible, vim-opinion |
| Integration | vim-tmux (tmux.conf syntax) |

CoC extensions: TypeScript, ESLint, Prettier, CSS, JSON, Shell, snippets, import-cost.

### Terminal Multiplexer

Tmux with 7 plugins and vim-style keybindings:

| Plugin | What it does |
|:-------|:-------------|
| Yoru Revamped | Status bar with system stats, git info, weather, network, and Tokyo Night theme |
| tmux-resurrect | Save and restore sessions across reboots |
| tmux-yank | Copy to system clipboard |
| extrakto | Extract URLs and file paths with fzf |
| tmux-session-wizard | Fuzzy session switcher |
| tmux-mighty-scroll | Better scrolling in fullscreen apps |
| tmux-menus | Popup context menus via F12 |

### Git

60 aliases, performance-tuned config, and Tokyo Night colors for diffs, status, branches, and blame:

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

Delta as the diff pager with line numbers, hyperlinks, and Tokyo Night syntax theme. Histogram diff algorithm, zdiff3 merge conflicts, and automatic rebase on pull.

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

Full Steam + Proton gaming setup for NVIDIA hybrid GPU laptops. Installed automatically on `amd64` Ubuntu systems.

| Component | What it does |
|:----------|:-------------|
| NVIDIA auto-detect | Installs the best proprietary driver for the GPU |
| NVIDIA Prime | Hybrid GPU switching: iGPU for desktop, dGPU for games |
| Mesa bleeding edge | Latest Vulkan (RADV) for AMD iGPU via oibaf PPA |
| Vulkan 64-bit + 32-bit | Full Vulkan stack for both GPUs |
| Steam | Native .deb from Valve's official repository |
| GE-Proton | Custom Proton with extra game patches, auto-downloaded |
| ProtonUp-Qt | GUI manager for GE-Proton versions (Flatpak) |
| GameMode | CPU governor + I/O priority optimization while gaming |
| MangoHud | FPS, CPU/GPU temps, frame time overlay |
| Gamescope | Valve's micro-compositor with FSR upscaling |
| Protontricks | Per-game Wine component installer |
| Kernel tuning | SteamOS-aligned sysctl: memory maps, swappiness, split-lock, compaction |
| Controller udev | steam-devices rules for PS4, PS5, Switch, Steam Controller |
| NVIDIA power mgmt | dGPU powers down when idle to save battery |

**After install, reboot and run:**

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

**One-time Steam setup:** Settings, Compatibility, enable "Enable Steam Play for all other titles", select "Proton Experimental" or a GE-Proton version.

**GE-Proton stays updated automatically** via `f5`. Check [protondb.com](https://www.protondb.com/) for per-game compatibility reports and recommended settings.

**If a game does not work:** switch to GE-Proton in the game's Compatibility settings, check ProtonDB, or use `protontricks <appid> --gui` to install missing Windows components.

## Tokyo Night Theme

All tools use the [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) "Night" variant:

| Tool | Method |
|:-----|:-------|
| Ghostty | Custom theme file |
| Kitty | Custom theme file |
| iTerm2 | `.itermcolors` theme file |
| Tilix | Exported color scheme |
| Bat | Theme in `bat/themes/` |
| Vim | `tokyonight-vim` plugin |
| Tmux | Yoru Revamped plugin |
| Bottom | `[styles]` in `bottom.toml` |
| K9s | Skin file in `k9s/skins/` |
| Lazygit | `gui.theme` in config |
| Lazydocker | Theme colors in config |
| Tealdeer | RGB values in `config.toml` |
| Yazi | Full theme in `theme.toml` |
| eza | Full theme in `theme.yml` |
| Mutt | Custom theme in `mutt/themes/` |
| cmus | Color scheme in `rc` |
| fzf | `FZF_DEFAULT_OPTS --color` |
| nnn | `NNN_FCOLORS` palette |
| Git | `[color]` sections in `.gitconfig` |

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
| `nvim` | `~/.vim`, `~/.config/nvim` |
| `nvim/init.vim` | `~/.vimrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `tmux` | `~/.tmux` |
| `ghostty` | `~/.config/ghostty` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `kitty/themes` | `~/.config/kitty/themes` |
| `bat/config` | `~/.config/bat/config` |
| `bat/themes` | `~/.config/bat/themes` |
| `eza` | `~/.config/eza` |
| `yazi` | `~/.config/yazi` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `kanata/kanata.kbd` | `~/.config/kanata/kanata.kbd` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `bottom/bottom.toml` | `~/.config/bottom/bottom.toml` |
| `lazygit/config.yml` | `~/.config/lazygit/config.yml` |
| `lazydocker/config.yml` | `~/.config/lazydocker/config.yml` |
| `k9s/config.yml` | `~/.config/k9s/config.yml` |
| `k9s/skins` | `~/.config/k9s/skins` |
| `tealdeer/config.toml` | `~/.config/tealdeer/config.toml` |
| `htop/htoprc` | `~/.config/htop/htoprc` |
| `gh/config.yml` | `~/.config/gh/config.yml` |
| `glab/config.yml` | `~/.config/glab-cli/config.yml` |
| `gnupg` | `~/.gnupg` |
| `ssh` | `~/.ssh` |
| `nodejs/.npmrc` | `~/.npmrc` |
| `nodejs/.yarnrc.yml` | `~/.yarnrc.yml` |
| `nodejs/.pnpmrc` | `~/.pnpmrc` |
| `mutt/.muttrc` | `~/.muttrc` |
| `mutt` | `~/.mutt` |
| `curl/.curlrc` | `~/.curlrc` |
| `wget/.wgetrc` | `~/.wgetrc` |
| `readline/.inputrc` | `~/.inputrc` |
| `ripgrep/.ripgreprc` | `~/.ripgreprc` |
| `fd/.fdrc` | `~/.fdrc` |
| `telnet/.telnetrc` | `~/.telnetrc` |
| `cmus/rc` | `~/.config/cmus/rc` |
| `atuin/config.toml` | `~/.config/atuin/config.toml` |
| `direnv/direnv.toml` | `~/.config/direnv/direnv.toml` |
| `direnv/direnvrc` | `~/.config/direnv/direnvrc` |
| `thefuck/settings.py` | `~/.config/thefuck/settings.py` |
| `tig/config` | `~/.config/tig/config` |
| `broot/conf.toml` | `~/.config/broot/conf.toml` |
| `ranger/rc.conf` | `~/.config/ranger/rc.conf` |
| `ranger/rifle.conf` | `~/.config/ranger/rifle.conf` |
| `ranger/scope.sh` | `~/.config/ranger/scope.sh` |
| `newsboat/config` | `~/.config/newsboat/config` |
| `newsboat/urls` | `~/.config/newsboat/urls` |
| `navi/config.yaml` | `~/.config/navi/config.yaml` |
| `glances/glances.conf` | `~/.config/glances/glances.conf` |
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
├── bat/              # Bat config + Tokyo Night theme
├── bottom/           # Bottom system monitor, Tokyo Night styled
├── broot/            # Broot file manager, Tokyo Night themed
├── cmus/             # cmus music player, Tokyo Night themed
├── conky/            # Conky system monitor (Linux)
├── curl/             # Curl config
├── direnv/           # direnv per-directory env config
├── eza/              # eza (ls replacement) config + Tokyo Night theme
├── fd/               # fd (find replacement) config
├── gh/               # GitHub CLI config
├── ghostty/          # Ghostty terminal + Tokyo Night theme
├── git/              # Git config, hooks, message template, 60 aliases
├── glab/             # GitLab CLI config
├── glances/          # Glances system monitor config
├── gnupg/            # GPG config and public keys
├── goaccess/         # GoAccess web log analyzer config
├── htop/             # htop config
├── k9s/              # K9s Kubernetes dashboard + Tokyo Night skin
├── kanata/           # Kanata keyboard remapper config
├── kitty/            # Kitty terminal + Tokyo Night theme
├── lazydocker/       # Lazydocker config, Tokyo Night
├── lazygit/          # Lazygit config, Tokyo Night
├── mailcap/          # Mailcap config
├── mise/             # mise runtime manager (Node.js, Python, Ruby)
├── mutt/             # Neomutt email client + Tokyo Night theme
├── nodejs/           # npm, yarn, pnpm configs + GPG-encrypted tokens
├── nvim/             # Neovim/Vim config + 31 plugins
├── obsidian/         # Obsidian notes config
├── readline/         # Readline config
├── ripgrep/          # Ripgrep config
├── ssh/              # SSH config and public keys
├── starship/         # Starship prompt config
├── tealdeer/         # Tealdeer (tldr) config, Tokyo Night
├── telnet/           # Telnet config
├── themes/           # Terminal themes (iTerm2)
├── tilix/            # Tilix terminal config
├── navi/             # Navi cheatsheet manager + custom cheats
├── newsboat/         # Newsboat RSS reader config
├── opencode/         # OpenCode AI config
├── ranger/           # Ranger file manager config
├── taskwarrior/      # Taskwarrior task manager, Tokyo Night themed
├── thefuck/          # TheFuck command corrector config
├── tig/              # Tig git TUI, Tokyo Night themed
├── tmux/             # Tmux config + 7 plugins
├── tmuxp/            # tmuxp session layouts
├── wget/             # Wget config
├── yazi/             # Yazi file manager + Tokyo Night theme
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

## License

[MIT](LICENSE) since 2014.
