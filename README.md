<div align="center">

<strong>One-command development environment for macOS and Linux: zsh, Vim, tmux and 54 tool configs on one Catppuccin Mocha palette.</strong>

English | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [繁體中文 (香港)](README.zh-HK.md)

[![install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![license](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square&label=license)](LICENSE)

</div>

---

These are my dotfiles. One script turns a fresh Mac or Ubuntu machine into the environment I work in: the shell, the editors, the terminal tools, Docker, and on Linux a Steam setup for gaming. Everything it installs and links is listed in [REFERENCE.md](REFERENCE.md).

## What you need

- macOS, or Ubuntu on x86_64 or ARM. Other Linux distributions are not supported, because the Linux path uses apt.
- Git and curl. Both ship with macOS; on Ubuntu run `sudo apt install git curl`.
- An account that can use `sudo`.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh) clones this repository to `~/.dotfiles` and links each config into place. On macOS it installs Homebrew and everything in the [`Brewfile`](Brewfile). On Ubuntu it uses apt, snap and the projects' own installers. Every step is idempotent, so a run that stopped halfway is fixed by running it again.

A file already at a link target is moved aside to `<path>.backup.<timestamp>`, never deleted.

Then open a new shell and check that the tools are there:

```bash
exec zsh
bat --version
zoxide --version
```

Both print a version number.

## Everyday use

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL on 127.0.0.1:5432 in Docker through Colima
fde                    # pick a running container with fzf and open a shell in it
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

`f5` is the one command to remember. It pulls this repository, updates Vim, Neovim, Zsh and Tmux plugins, upgrades the mise runtimes and every system package, and clears package caches. It asks for your password once, at the start, and drops root when it ends, so the next `sudo` asks again. It prints nothing of its own, only the tools' own output, and returns 1 when any step failed. It leaves Docker and the Colima VM alone, so running containers survive. Run `exec zsh` afterwards to load the new shell configuration.

On macOS, `f5` runs `brew bundle cleanup --force --zap`, which uninstalls any formula, cask or app that is not in the [`Brewfile`](Brewfile). Add a package there before installing it by hand, or the next `f5` removes it.

## What you get

**Shell.** Zsh with Oh My Zsh and the Spaceship prompt, fzf with fzf-tab, zoxide, atuin history, direnv, and mise for Node.js, Python and Ruby. On macOS, the GNU versions of coreutils, sed, grep, tar and make come first on `PATH`.

**Editors.** Vim with 31 plugins and CoC for language support, and a separate Neovim setup in Lua on lazy.nvim in [`nvim/`](nvim).

**Tmux.** 19 plugins with Vim-style keys. All but the Catppuccin theme come from the [tmux-revamped](https://github.com/tmux-revamped) family, including session save and restore.

**Git.** 60 aliases in [`git/.gitconfig`](git/.gitconfig), GPG-signed commits and tags, and delta as the diff pager.

**Docker.** Colima runs Docker, sized from the machine's CPUs and memory. `postgres-init`, `mongo-init`, `redis-init`, `valkey-init`, `redict-init` and `ubuntu-init` each start a container with its port bound to `127.0.0.1` only.

**Own tools.** Six command-line tools I wrote, from the [gufranco/tap](https://github.com/gufranco/homebrew-tap) Homebrew tap on macOS and built from source on Linux:

- [fusho](https://github.com/gufranco/fusho) sends an encrypted message through any chat, addressed by GitHub username.
- [jimaku](https://github.com/gufranco/jimaku) downloads subtitles for every video in a folder.
- [kakikomi](https://github.com/gufranco/kakikomi) writes disk images to floppies, Zip disks, USB sticks and hard disks, verifying every chunk.
- [kiyome](https://github.com/gufranco/kiyome) wipes a disk with five verified patterns.
- [shiwake](https://github.com/gufranco/shiwake) sorts the files of a folder into A to Z subfolders.
- [yakitsuke](https://github.com/gufranco/yakitsuke) turns any video into Video CD images.

**Theme.** 22 tools use Catppuccin Mocha with the mauve accent, from the official ports wherever one exists.

**Linux gaming.** On x86_64 Ubuntu, the installer adds a Steam and Proton setup modeled on SteamOS, aimed at laptops with hybrid NVIDIA graphics: the NVIDIA driver with Prime switching, the XanMod kernel, the scx_lavd scheduler, GameMode, MangoHud, Gamescope and GE-Proton. Reboot after the first install, then run `gaming-check`. ARM machines skip this part.

## Adding a config

Put the files in a new directory, such as `myapp/`, and link it from [`install.sh`](install.sh):

```bash
safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
```

Before pushing, run the checks CI runs:

```bash
shellcheck install.sh
python3 -m unittest discover -s tests -v
```

## Testing

The [install workflow](.github/workflows/install.yml) runs `install.sh` twice on the latest Ubuntu LTS and on macOS Tahoe on Apple Silicon, then checks every link and that the main commands are on `PATH`. The second run proves the script is idempotent. The [lint workflow](.github/workflows/lint.yml) runs ShellCheck, shfmt, a zsh syntax check, actionlint, YAML and TOML lint, and a gitleaks secrets scan.

## Limits

- The Linux path supports Ubuntu only.
- Linux gaming needs x86_64; NVIDIA and Mesa drivers are never installed on ARM.
- The SSH and GPG private keys in this repository are mine, encrypted with my passphrase. Remove [`ssh/`](ssh) and `gnupg/keys/` from a fork before using it.

## License

[MIT](LICENSE)
