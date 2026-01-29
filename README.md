# Dotfiles

Personal dotfiles configuration for macOS and Linux systems. This repository contains configuration files for various development tools, terminal applications, and system utilities.

## Quick Start

```shell
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

## Project Structure

```
.dotfiles/
├── .cursor/              # Cursor IDE engineering rules (submodule)
├── bat/                  # Bat (cat replacement) configuration
├── cmus/                 # Cmus music player configuration
├── conky/                # Conky system monitor configuration
├── curl/                 # Curl configuration
├── eza/                  # eza (ls replacement) configuration
├── fd/                   # fd (find replacement) configuration
├── gh/                   # GitHub CLI (gh) configuration
├── git/                  # Git configuration and hooks
├── glab/                 # GitLab CLI (glab) configuration
├── gnupg/                # GPG configuration and public keys
├── htop/                 # htop configuration
├── kitty/                # Kitty terminal configuration
├── mailcap/              # Mailcap configuration
├── mutt/                 # Neomutt email client configuration
├── nodejs/               # Node.js, npm, yarn, pnpm configuration
├── readline/             # Readline configuration
├── ripgrep/              # Ripgrep configuration
├── ssh/                  # SSH configuration and public keys
├── telnet/               # Telnet configuration
├── themes/               # Terminal themes (iTerm2, Tilix)
├── tilix/                # Tilix terminal configuration
├── tmux/                 # Tmux configuration and plugins
├── vim/                  # Vim/Neovim configuration
├── wget/                 # Wget configuration
├── zsh/                  # Zsh configuration, aliases, functions
├── Brewfile              # Homebrew packages list (macOS)
├── install.sh            # Installation script
└── README.md             # This file
```

## Features

### Shell Configuration (Zsh)
- Oh My Zsh with custom plugins
- Spaceship prompt theme
- Custom aliases and functions
- Utility functions for system management
- Infrastructure helpers (Docker, VMs)

### Development Tools
- **Git**: Comprehensive configuration with aliases, hooks, and templates
- **GitHub CLI (gh)**: Defaults (ssh, vim, delta) in `gh/config.yml`
- **GitLab CLI (glab)**: Defaults (ssh, vim, delta) in `glab/config.yml`
- **Vim/Neovim**: Custom configuration with plugins
- **Node.js**: Configuration for npm, yarn, and pnpm
- **Cursor IDE**: Engineering rules and best practices (via submodule)

### Terminal Applications
- **Kitty**: Terminal emulator configuration
- **Tmux**: Session management with TPM plugins
- **Bat**: Syntax highlighting for cat
- **eza**: Modern ls replacement
- **Ripgrep**: Fast text search
- **fd**: Fast find replacement

### System Tools
- **htop**: Process monitoring configuration
- **Conky**: System monitor configuration
- **GPG**: Key management and agent configuration
- **SSH**: Configuration and key management

### Email
- **Neomutt**: Email client configuration with multiple account support

## Installation

The installation script supports both macOS and Linux (Ubuntu/Debian).

### macOS

The script will:
1. Install Homebrew (if not present)
2. Install packages from `Brewfile`
3. Set up all configuration files via symlinks
4. Configure shell, Git, and development tools

### Linux (Ubuntu/Debian)

The script will:
1. Update system packages
2. Install essential development tools
3. Install Docker, Node.js, Python, Go, Rust
4. Install applications (VS Code, Chrome, Spotify, etc.)
5. Set up all configuration files via symlinks

## Configuration Files

All configuration files are symlinked to their respective locations in your home directory. The script uses `safe_link` to avoid overwriting existing files.

### Key Configurations

- **Zsh**: `~/.zshrc` → `zsh/.zshrc`
- **Git**: `~/.gitconfig` → `git/.gitconfig`
- **GitHub CLI**: `~/.config/gh/config.yml` → `gh/config.yml`
- **GitLab CLI**: `~/.config/glab-cli/config.yml` → `glab/config.yml`
- **Vim**: `~/.vimrc` → `vim/.vimrc`
- **Tmux**: `~/.tmux.conf` → `tmux/.tmux.conf`
- **SSH**: `~/.ssh/config` → `ssh/config`
- **GPG**: `~/.gnupg/` → `gnupg/`

### Brewfile tools without dotfiles config (optional)

These are in the Brewfile but have no versioned config here (either env-specific or optional):

- **starship** – `~/.config/starship.toml` (you use Oh My Zsh Spaceship; add if you switch to standalone Starship)
- **direnv** – `~/.config/direnv/direnvrc` (global defaults; hook is in zsh)
- **mcfly** – `~/.config/mcfly/config.toml` (keybindings, etc.)
- **awscli** – `~/.aws/config` only (never commit `~/.aws/credentials`)
- **terraform** – `~/.terraformrc` or `~/.config/terraform/terraform.rc`
- **docker** – `~/.docker/config.json` (often contains creds; version only if minimal)
- **kubectl** – `~/.kube/config` (sensitive; do not version)

## Security Notes

⚠️ **Important**: This repository contains public GPG keys and SSH public keys only. Private keys and passwords are excluded via `.gitignore`.

- Private GPG keys (`*.private.pgp`) are ignored
- Password files (`password.gpg`) are ignored
- SSH private keys are tracked but should be rotated if exposed

## Customization

### Adding New Configurations

1. Create a new directory for your tool (e.g., `myapp/`)
2. Add configuration files to that directory
3. Add symlink command to `install.sh`:
   ```bash
   safe_link "$HOME/.dotfiles/myapp/config" "$HOME/.config/myapp/config"
   ```

### Modifying Existing Configurations

Edit files directly in the repository. Changes will be reflected after:
- Restarting your terminal (for shell configs)
- Reloading the application (for app configs)
- Running `source ~/.zshrc` (for shell changes)

## Maintenance

### Using the `dot` Function

After installation, you'll have a `dot` function available in your shell that acts as a convenient wrapper for Git operations on the dotfiles repository:

```bash
# Check status
dot status

# Add changes
dot add .

# Commit changes
dot commit -m "chore: update vim config"

# Push changes
dot push origin master

# Pull updates
dot pull origin master
```

The `dot` function is equivalent to running `git -C ~/.dotfiles` but shorter and easier to remember.

### Updating Submodules

```bash
dot submodule update --remote .cursor
```

### Syncing Changes

```bash
# Using the dot function (recommended)
dot pull origin master

# Or traditional way
cd ~/.dotfiles && git pull
# Restart terminal or source configs as needed
```

## License

See [LICENSE](LICENSE) file for details.
