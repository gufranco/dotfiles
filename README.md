# Dotfiles

Personal dotfiles for macOS and Linux. All configs live in `~/.dotfiles/` and are symlinked into place by `install.sh`.

## Quick Start

```shell
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

## Project Structure

```
.dotfiles/
├── bat/                  # Bat (cat replacement) config + Tokyo Night theme
├── bottom/               # Bottom (btm) system monitor, Tokyo Night styled
├── claude/               # Claude Code: rules, skills, hooks, MCP
├── cmus/                 # cmus music player
├── conky/                # Conky system monitor (Linux)
├── curl/                 # Curl config
├── eza/                  # eza (ls replacement) config
├── fd/                   # fd (find replacement) config
├── gh/                   # GitHub CLI config
├── ghostty/              # Ghostty terminal + Tokyo Night theme
├── git/                  # Git config, hooks, message template
├── glab/                 # GitLab CLI config
├── gnupg/                # GPG config and public keys
├── htop/                 # htop config (Broken Gray scheme)
├── k9s/                  # K9s config + Tokyo Night skin
│   └── skins/            # K9s skin files
├── kitty/                # Kitty terminal + Tokyo Night theme
├── lazydocker/           # Lazydocker config, Tokyo Night borders
├── lazygit/              # Lazygit config, Tokyo Night theme
├── mailcap/              # Mailcap config
├── mutt/                 # Neomutt email client
├── nodejs/               # npm, yarn, pnpm configs
├── readline/             # Readline config
├── ripgrep/              # Ripgrep config
├── ssh/                  # SSH config and public keys
├── tealdeer/             # Tealdeer (tldr) config, Tokyo Night colors
├── telnet/               # Telnet config
├── themes/               # Terminal themes (iTerm2, Tilix)
├── tilix/                # Tilix terminal config
├── tmux/                 # Tmux config and plugins
├── vim/                  # Vim/Neovim config and plugins
├── wget/                 # Wget config
├── yazi/                 # Yazi file manager + Tokyo Night theme
├── zsh/                  # Zsh: aliases, functions, settings, paths
├── Brewfile              # Homebrew packages (macOS)
├── install.sh            # Installation script
└── README.md
```

## Tokyo Night Theme

All tools that support custom colors use the [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) "Night" variant for a consistent look across the entire terminal environment.

| Tool | How |
|------|-----|
| Ghostty | Custom theme file (`ghostty/themes/tokyo-night`) |
| Kitty | Custom theme file (`kitty/themes/tokyo-night.conf`) |
| Tilix | Exported color scheme (`tilix/tokyonight-night-tilix.json`) |
| Bat | Theme in `bat/themes/` |
| Vim | `tokyonight-vim` plugin |
| Tmux | Tokyo Night Revamped plugin |
| Bottom | `[styles]` section in `bottom/bottom.toml` |
| K9s | Skin file in `k9s/skins/tokyo-night.yaml` |
| Lazygit | `gui.theme` in `lazygit/config.yml` |
| Lazydocker | Theme colors in `lazydocker/config.yml` |
| Tealdeer | `[style.*]` RGB values in `tealdeer/config.toml` |
| Yazi | Full theme in `yazi/theme.toml` |
| fzf | `FZF_DEFAULT_OPTS --color` in `zsh/settings` |
| nnn | `NNN_FCOLORS` palette indices in `zsh/settings` |
| htop | `color_scheme=6` (Broken Gray, darkest built-in; no custom hex support) |

## Modern Tool Replacements

These aliases are defined in `zsh/aliases` and only activate when the modern tool is installed:

| Alias | Points to | Replaces |
|-------|-----------|----------|
| `cat` | `bat` | Syntax-highlighted file viewer, plain output when piped |
| `ls` | `eza` | Icons, git status, tree view via `lt` |
| `du` | `dust` | Visual disk usage with tree output |
| `df` | `duf` | Modern disk free with color output |
| `ps` | `procs` | Process viewer with tree and color |
| `top` | `btm` | Bottom system monitor TUI |
| `vim`/`vi` | `nvim` | Neovim |
| `ping` | `gping` | Graphical ping (macOS only) |
| `stats` | `tokei` | Code statistics (macOS only) |

GNU coreutils, findutils, grep, sed, tar, make, and other GNU tools override their BSD counterparts via PATH priority in `zsh/paths`.

## Shell Configuration

Zsh with Oh My Zsh, Spaceship prompt, and these integrations:

- **direnv**: per-directory env via `.envrc`
- **fzf**: fuzzy finder with bat preview and Tokyo Night colors
- **fzf-tab**: tab completion through fzf
- **zsh-syntax-highlighting**: fish-like command highlighting

## Symlink Map

All files are symlinked by `install.sh` using `safe_link`. Key mappings:

| Source | Target |
|--------|--------|
| `zsh/.zshrc` | `~/.zshrc` |
| `git/.gitconfig` | `~/.gitconfig` |
| `vim` | `~/.vim` |
| `vim/.vimrc` | `~/.vimrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
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

On macOS, lazygit, lazydocker, k9s, and ghostty also get symlinks into `~/Library/Application Support/`.

## Installation

### macOS

1. Installs Homebrew
2. Installs everything from `Brewfile`
3. Symlinks all configs
4. Configures shell, Git, GPG, SSH

### Linux (Ubuntu/Debian)

1. Updates system packages
2. Installs development tools, Docker, Node.js, Python, Go, Rust
3. Installs applications
4. Symlinks all configs

## Adding New Configs

1. Create a directory: `myapp/`
2. Add config files
3. Add to `install.sh`:
   ```bash
   safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
   ```

## Security

Private keys and credentials are excluded via `.gitignore`. Only public GPG keys and SSH public keys are tracked.

## License

See [LICENSE](LICENSE) file.
