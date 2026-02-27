<div align="center">

<br>

<strong>One-command development environment for macOS and Linux. 33 tool configs, consistent Tokyo Night theme, modern CLI replacements, and ready-to-go Docker services.</strong>

<br>
<br>

[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-zsh-blue?style=flat-square)]()
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)]()

</div>

---

**33** tool configs · **139** brew packages · **53** desktop apps · **72** Nerd Fonts · **14** Tokyo Night themed tools · **60** Git aliases · **6** Docker services · **18** Claude Code skills

<table>
<tr>
<td width="50%" valign="top">

### Tokyo Night Everywhere

One color palette across 14 tools: terminals, editors, file managers, git diffs, monitoring dashboards, and fuzzy finders.

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

NVM, Chruby, and heavy tooling are lazy-loaded via stub functions. They only initialize when you first call `node`, `ruby`, or `nvm`.

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
| `vim`/`vi` | vim | `nvim` (Neovim) |
| `ping` | ping | `gping` with graphical output (macOS) |
| `stats` | - | `tokei` for code statistics (macOS) |

### Editor

Vim/Neovim with 24 plugins managed by vim-plug:

| Category | Plugins |
|:---------|:--------|
| Language support | coc.nvim (LSP), vim-polyglot, vim-matchup, rainbow_csv |
| Navigation | fzf.vim, EasyMotion |
| Git | vim-signify (hunks), vim-fugitive (commands) |
| Editing | vim-surround, vim-visual-multi, targets.vim, vim-unimpaired |
| UI | lightline, vim-devicons, undotree, vim-cool |

CoC extensions: TypeScript, ESLint, Prettier, CSS, JSON, Shell, snippets, import-cost.

### Terminal Multiplexer

Tmux with 8 plugins and vim-style keybindings:

| Plugin | What it does |
|:-------|:-------------|
| Yoru Revamped | Status bar with system stats, git info, weather, and network |
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

### Claude Code

18 custom skills for AI-assisted development:

| Skill | What it does |
|:------|:-------------|
| `/commit` | Semantic commits with optional `--pipeline` CI monitoring |
| `/pr` | PR creation with self-review and pipeline monitoring |
| `/review` | Code review following project conventions |
| `/readme` | Marketing-grade README generation |
| `/assessment` | Architecture completeness audit |
| `/test` | Test runner with coverage and linting |
| `/checks` | CI/CD status monitoring |
| `/terraform` | Terraform workflows with safety gates |
| `/docker` | Container management with Colima awareness |

Plus 13 rule files covering code style, resilience, caching, API design, testing, security, database patterns, distributed systems, observability, debugging, git workflow, verification, and LLM documentation references.

## Tokyo Night Theme

All tools use the [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) "Night" variant:

| Tool | Method |
|:-----|:-------|
| Ghostty | Custom theme file |
| Kitty | Custom theme file |
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
| fzf | `FZF_DEFAULT_OPTS --color` |
| Git | `[color]` sections in `.gitconfig` |

## System Update

Run `f5` in any terminal to update everything at once:

1. Pulls latest dotfiles and submodules
2. Updates Vim plugins and CoC extensions
3. Updates Oh My Zsh, Zsh plugins, and Tmux plugins
4. Updates Node.js LTS via NVM
5. On macOS: runs `brew update`, `brew upgrade`, `brew bundle`, and Mac App Store updates
6. On Linux: runs `apt update` and `apt dist-upgrade`
7. Reloads Tmux and Zsh configs

## Symlink Map

All configs are symlinked by `install.sh` using `safe_link`, which is idempotent and creates parent directories automatically.

<details>
<summary><strong>Full symlink map</strong></summary>

| Source | Target |
|:-------|:-------|
| `zsh/.zshrc` | `~/.zshrc` |
| `git/.gitconfig` | `~/.gitconfig` |
| `vim` | `~/.vim` |
| `vim/.vimrc` | `~/.vimrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `tmux` | `~/.tmux` |
| `ghostty` | `~/.config/ghostty` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `bat/config` | `~/.config/bat/config` |
| `eza` | `~/.config/eza` |
| `yazi` | `~/.config/yazi` |
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
| `claude` | `~/.claude` |
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

On macOS, lazygit, lazydocker, k9s, and ghostty also get symlinks into `~/Library/Application Support/`.

</details>

<details>
<summary><strong>Project structure</strong></summary>

```
.dotfiles/
├── bat/              # Bat config + Tokyo Night theme
├── bottom/           # Bottom system monitor, Tokyo Night styled
├── claude/           # Claude Code: 13 rules, 18 skills, hooks, MCP
├── cmus/             # cmus music player
├── conky/            # Conky system monitor (Linux)
├── curl/             # Curl config
├── eza/              # eza (ls replacement) config
├── fd/               # fd (find replacement) config
├── gh/               # GitHub CLI config
├── ghostty/          # Ghostty terminal + Tokyo Night theme
├── git/              # Git config, hooks, message template, aliases
├── glab/             # GitLab CLI config
├── gnupg/            # GPG config and public keys
├── htop/             # htop config
├── k9s/              # K9s Kubernetes dashboard + Tokyo Night skin
├── kitty/            # Kitty terminal + Tokyo Night theme
├── lazydocker/       # Lazydocker config, Tokyo Night
├── lazygit/          # Lazygit config, Tokyo Night
├── mailcap/          # Mailcap config
├── mutt/             # Neomutt email client
├── nodejs/           # npm, yarn, pnpm configs + GPG-encrypted tokens
├── readline/         # Readline config
├── ripgrep/          # Ripgrep config
├── ssh/              # SSH config and public keys
├── tealdeer/         # Tealdeer (tldr) config, Tokyo Night
├── telnet/           # Telnet config
├── themes/           # Terminal themes (iTerm2, Tilix)
├── tilix/            # Tilix terminal config
├── tmux/             # Tmux config + 8 plugins
├── vim/              # Vim/Neovim config + 24 plugins
├── wget/             # Wget config
├── yazi/             # Yazi file manager + Tokyo Night theme
├── zsh/              # Zsh: aliases, functions, paths, settings, infrastructure
├── Brewfile          # 139 packages, 53 apps, 72 fonts
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
