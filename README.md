# Personal Dotfiles Configuration

> **⚠️ IMPORTANT DISCLAIMER**: This is a **personal, opinionated** dotfiles configuration. It is **NOT intended for general use** and may contain configurations that are specific to my workflow, preferences, and system setup. Use at your own risk and with proper understanding of what each component does.

## Overview

This repository contains my personal dotfiles configuration for macOS and Linux systems. It includes configurations for various tools, applications, and system settings that I use in my daily workflow.

## ⚠️ Legal Disclaimer

**THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.**

- This configuration is **personal and opinionated**
- It may **not work** on your system or may cause **unexpected behavior**
- Some configurations may **conflict** with your existing setup
- **Always backup** your current configuration before applying any changes
- **Review and understand** each component before using
- **Use at your own risk** - I am not responsible for any issues that may arise

## What's Included

### Core Tools
- **Shell**: Zsh with custom configuration
- **Terminal**: iTerm2 configuration
- **Editor**: Vim with extensive plugin setup
- **Version Control**: Git configuration with GPG signing
- **Encryption**: GPG setup for secure communication
- **Containerization**: Docker and related tools
- **Package Management**: Homebrew (macOS) and apt (Linux)

### Development Environment
- **Languages**: Node.js, Python, Ruby, Go, Rust
- **Package Managers**: npm, pnpm, pip, gem
- **Linting**: Various linters for different languages
- **Build Tools**: CMake, Make, and other build utilities

### Applications (macOS)
- **Browsers**: Arc, Google Chrome
- **Development**: Cursor, Visual Studio Code, Sublime Text
- **Productivity**: Raycast, Rectangle, Notion, Obsidian
- **Security**: 1Password, Little Snitch, NordVPN
- **System**: CleanMyMac, iStat Menus, MonitorControl

### System Configuration
- **GPG**: Unified configuration for Linux and macOS
- **SSH**: Key management and configuration
- **Mutt**: Email client configuration
- **Tmux**: Terminal multiplexer setup
- **Conky**: System monitoring (Linux)

## Installation

### Prerequisites

**macOS:**
- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools
- Homebrew

**Linux:**
- Ubuntu 20.04+ or similar Debian-based distribution
- sudo access

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

### Manual Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gufranco/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Review the configuration:**
   ```bash
   # Check what will be installed
   cat Brewfile
   cat install.sh
   ```

3. **Run the installation script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Configuration Details

### GPG Setup

The GPG configuration includes:
- Unified setup for Linux and macOS
- Multiple key management
- Secure agent configuration
- SSH key integration

**Setup:**
```bash
~/.dotfiles/gnupg/setup-gpg.sh
```

### Shell Configuration

**Zsh features:**
- Syntax highlighting
- Custom aliases and functions
- Path management
- Container-specific configurations

### Vim Configuration

**Plugins included:**
- Plugin manager (vim-plug)
- Language support (polyglot)
- Git integration (fugitive)
- File navigation (NERDTree)
- Code completion (coc.nvim)
- Theme (tokyonight)

### Tmux Configuration

**Features:**
- Session management
- Plugin system
- Custom key bindings
- Status bar customization

## Customization

### Before Using This Configuration

1. **Review all files** in this repository
2. **Understand what each component does**
3. **Check for conflicts** with your existing setup
4. **Backup your current configuration**
5. **Test in a safe environment** first

### Modifying Configuration

Each component can be customized by editing the respective configuration files:

- **Shell**: `zsh/` directory
- **Vim**: `vim/.vimrc`
- **Git**: `git/` directory
- **GPG**: `gnupg/` directory
- **SSH**: `ssh/` directory

## Troubleshooting

### Common Issues

1. **Permission errors:**
   ```bash
   chmod 700 ~/.gnupg
   chmod 400 ~/.gnupg/gpg-agent.conf
   ```

2. **GPG agent not working:**
   ```bash
   gpgconf --kill gpg-agent
   gpgconf --launch gpg-agent
   ```

3. **Shell not loading:**
   ```bash
   # Check if zsh is installed
   which zsh
   # Restart terminal or run
   source ~/.zshrc
   ```

4. **Vim plugins not working:**
   ```bash
   # Open vim and run
   :PlugInstall
   ```

### Getting Help

- Check the individual README files in each directory
- Review the installation logs
- Test components individually

## Security Considerations

### GPG Keys
- **Public keys** are included for convenience
- **Private keys** are NOT imported automatically
- **Always verify** key fingerprints before use
- **Use your own keys** for production work

### SSH Configuration
- **Review SSH config** before use
- **Use your own SSH keys**
- **Check host configurations**

### System Permissions
- **Review file permissions** after installation
- **Ensure sensitive files** have correct permissions
- **Regularly audit** your configuration

## Contributing

**This is a personal configuration repository.** 

- **Issues**: Feel free to report bugs or suggest improvements
- **Pull Requests**: May be considered for general improvements
- **Forks**: You're welcome to fork and adapt for your own use

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions about this configuration, please open an issue on GitHub.

---

**Remember**: This is a personal configuration. Always review, understand, and test before using in your environment.
