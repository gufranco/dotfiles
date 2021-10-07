#!/usr/bin/env bash

set -Eeuo pipefail

# Ask for the root password upfront
sudo -v

# Keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

case "$(uname)" in
  Linux)
    ############################################################################
    # Update / upgrade
    ############################################################################
    sudo apt update
    sudo apt dist-upgrade -y

    ############################################################################
    # Purge
    ############################################################################
    sudo apt purge -y \
      apport \
      cmdtest \
      laptop-mode-tools

    ############################################################################
    # Basic packages
    ############################################################################
    sudo apt install -y \
      apt-transport-https \
      build-essential \
      cmake \
      curl \
      git \
      snapd \
      software-properties-common \
      tmux \
      trash-cli \
      ubuntu-restricted-extras \
      wget \
      xsel

    ############################################################################
    # dotfiles
    ############################################################################
    git clone --recursive --depth=1 https://github.com/gufranco/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles || exit 1
    git remote set-url origin git@github.com:gufranco/dotfiles.git

    ############################################################################
    # Enable universe repository
    ############################################################################
    sudo add-apt-repository universe
    sudo apt update

    ############################################################################
    # Enable exFat
    ############################################################################
    sudo apt install -y \
      exfat-fuse \
      exfat-utils

    ############################################################################
    # 7Zip / Rar / Zip
    ############################################################################
    sudo apt install -y \
      p7zip-full \
      p7zip-rar \
      rar \
      unrar \
      unzip \
      zip

    ############################################################################
    # Zsh
    ############################################################################
    sudo apt install -y \
      zsh

    ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc
    command -v zsh | sudo tee -a /etc/shells
    sudo sed -i -- 's/auth       required   pam_shells.so/# auth       required   pam_shells.so/g' /etc/pam.d/chsh
    sudo chsh "$USER" -s "$(command -v zsh)"

    ############################################################################
    # Docker
    ############################################################################
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y \
      docker-ce

    sudo usermod -a -G docker "$USER"

    ############################################################################
    # Node.js
    ############################################################################
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt update
    sudo apt install -y \
      g++ \
      gcc \
      make \
      nodejs

    ############################################################################
    # Dropbox
    ############################################################################
    sudo apt install -y \
      nautilus-dropbox

    ############################################################################
    # Spotify
    ############################################################################
    curl -fsSL https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
    echo -e "deb [arch=amd64] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y \
      spotify-client

    ############################################################################
    # Chrome
    ############################################################################
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo -e "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y \
      google-chrome-stable

    ############################################################################
    # VirtualBox
    ############################################################################
    curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
    curl -fsSL https://www.virtualbox.org/download/oracle_vbox.asc | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
    sudo apt update
    sudo apt install -y \
      virtualbox-6.1 \
      virtualbox-ext-pack

    sudo adduser "$USER" vboxusers

    ############################################################################
    # DBeaver
    ############################################################################
    sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce
    sudo apt update
    sudo apt install -y \
      dbeaver-ce

    ############################################################################
    # Robo 3T
    ############################################################################
    sudo snap install robo3t-snap

    ############################################################################
    # Vim
    ############################################################################
    sudo add-apt-repository -y ppa:jonathonf/vim
    sudo apt update
    sudo apt install -y \
      python3-dev \
      vim \
      vim-gnome

    ############################################################################
    # Ripgrep
    ############################################################################
    sudo apt install -y \
      ripgrep

    ############################################################################
    # Universal ctags
    ############################################################################
    sudo apt install -y \
      universal-ctags

    ############################################################################
    # Visual Studio Code
    ############################################################################
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    echo -e "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y \
      code

    ############################################################################
    # PlatformIO
    ############################################################################
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules

    sudo usermod -a -G tty "$USER"
    sudo usermod -a -G dialout "$USER"
    sudo usermod -a -G plugdev "$USER"

    ############################################################################
    # Insomnia
    ############################################################################
    curl -fsSL https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
    echo -e "deb [arch=amd64] https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee /etc/apt/sources.list.d/insomnia.list
    sudo apt update
    sudo apt install -y \
      insomnia

    ############################################################################
    # Gnome
    ############################################################################
    sudo apt install -y \
      gnome-screensaver \
      gnome-shell-extensions \
      gnome-sushi \
      gnome-tweak-tool

    ############################################################################
    # VeraCrypt
    ############################################################################
    sudo add-apt-repository -y ppa:unit193/encryption
    sudo apt update
    sudo apt install -y \
      veracrypt

    ############################################################################
    # GPG
    ############################################################################
    sudo apt install -y \
      gpg \
      gnupg-agent

    ln -s ~/.dotfiles/gnupg ~/.gnupg
    ln -s ~/.dotfiles/gnupg/gpg-agent-linux.conf ~/.dotfiles/gnupg/gpg-agent.conf
    chmod 700 ~/.gnupg

    ############################################################################
    # Neomutt
    ############################################################################
    sudo apt install -y \
      neomutt

    ############################################################################
    # Lynx
    ############################################################################
    sudo apt install -y \
      lynx

    ############################################################################
    # Shellcheck
    ############################################################################
    sudo apt install -y \
      shellcheck

    ############################################################################
    # Hack Nerd Font
    ############################################################################
    sudo apt install -y \
      fonts-hack-ttf

    curl -#fLo \
      "$HOME/.local/share/fonts/Hack Regular Nerd Font Complete.ttf" \
      --create-dirs https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf

    sudo fc-cache -fv

    ############################################################################
    # Tilix
    ############################################################################
    sudo apt install -y \
      tilix

    curl -#fLo \
      "$HOME/.config/tilix/schemes/gruvbox-dark-medium.json" \
      --create-dirs https://raw.githubusercontent.com/MichaelThessel/tilix-gruvbox/master/gruvbox-dark-medium.json

    ############################################################################
    # VLC
    ############################################################################
    sudo apt install -y \
      vlc

    ############################################################################
    # Conky
    ############################################################################
    sudo apt install -y \
      conky-all

    ln -s ~/.dotfiles/conky/.conkyrc ~/.conkyrc

    ############################################################################
    # Transmission
    ############################################################################
    sudo apt install -y \
      transmission

    ############################################################################
    # Asciinema
    ############################################################################
    sudo apt install -y \
      asciinema

    ############################################################################
    # Preload
    ############################################################################
    sudo apt install -y \
      preload

    ############################################################################
    # TLP
    ############################################################################
    sudo add-apt-repository -y ppa:linrunner/tlp
    sudo apt update
    sudo apt install -y \
      tlp

    ############################################################################
    # Caffeine
    ############################################################################
    sudo apt install -y \
      caffeine

    ############################################################################
    # Drivers
    ############################################################################
    sudo add-apt-repository -y ppa:oibaf/graphics-drivers
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update
    sudo apt install -y \
      freeglut3 \
      mesa-utils \
      mesa-utils-extra \
      mesa-vulkan-drivers \
      vulkan-utils

    ############################################################################
    # Keybase
    ############################################################################
    curl -#fLo \
      "/tmp/keybase.deb" \
      --create-dirs https://prerelease.keybase.io/keybase_amd64.deb

    sudo apt install -y \
      /tmp/keybase.deb

    sudo apt install -y -f

    ############################################################################
    # Slack
    ############################################################################
    curl -fsSL https://packagecloud.io/slacktechnologies/slack/gpgkey | sudo apt-key add -
    echo -e "deb [arch=amd64] https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" | sudo tee /etc/apt/sources.list.d/slack.list
    sudo apt update
    sudo apt install -y \
      slack

    ############################################################################
    # Cura
    ############################################################################
    sudo add-apt-repository -y ppa:thopiekar/cura
    sudo apt install -y \
      cura

  ;;
  Darwin)
    ############################################################################
    # Command Line Tools
    ############################################################################
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    softwareupdate -i -a
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    ############################################################################
    # Homebrew
    ############################################################################
    CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    ############################################################################
    # dotfiles
    ############################################################################
    git clone --recursive --depth=1 https://github.com/gufranco/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles || exit 1
    git remote set-url origin git@github.com:gufranco/dotfiles.git

    ############################################################################
    # Homebrew bundle
    ############################################################################
    case "$(uname -m)" in
      arm64)
        export HOMEBREW_PREFIX="/opt/homebrew"
        export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
        export HOMEBREW_REPOSITORY="/opt/homebrew"
        export HOMEBREW_SHELLENV_PREFIX="/opt/homebrew"
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
        export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
        export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

      ;;
      x86_64)
        export HOMEBREW_PREFIX="/usr/local"
        export HOMEBREW_CELLAR="/usr/local/Cellar"
        export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
        export HOMEBREW_SHELLENV_PREFIX="/usr/local"
        export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
        export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
        export INFOPATH="/usr/local/share/info:${INFOPATH:-}"

      ;;
    esac

    export HOMEBREW_NO_ANALYTICS=1

    brew bundle --file "${HOME}/.dotfiles/Brewfile"

    ############################################################################
    # Bash
    ############################################################################
    echo -e "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells

    ############################################################################
    # Zsh
    ############################################################################
    ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc
    echo -e "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
    chsh -s "$(brew --prefix)/bin/zsh"

    ############################################################################
    # GPG
    ############################################################################
    ln -s ~/.dotfiles/gnupg ~/.gnupg
    ln -s ~/.dotfiles/gnupg/gpg-agent-macos.conf ~/.dotfiles/gnupg/gpg-agent.conf
    chmod 700 ~/.gnupg

    ############################################################################
    # iTerm 2
    ############################################################################
    curl -#fLo \
      "/tmp/gruvbox-dark.itermcolors" \
      --create-dirs https://raw.githubusercontent.com/morhetz/gruvbox-contrib/master/iterm2/gruvbox-dark.itermcolors

    # open "/tmp/gruvbox-dark.itermcolors"

    ############################################################################
    # Hostname
    ############################################################################
    case "$(uname -m)" in
      arm64)
        sudo scutil --set HostName "macbookair"
        sudo scutil --set LocalHostName "macbookair"
        sudo scutil --set ComputerName "macbookair"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "macbookair"

      ;;
      x86_64)
        sudo scutil --set HostName "macbookpro"
        sudo scutil --set LocalHostName "macbookpro"
        sudo scutil --set ComputerName "macbookpro"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "macbookpro"

      ;;
    esac

  ;;
esac

################################################################################
# Config folder
################################################################################
if [ ! -d ~/.config ] && [ ! -h ~/.config ]; then
  mkdir ~/.config
fi

################################################################################
# Npm
################################################################################
if [ ! -d ~/.global-modules ] && [ ! -h ~/.global-modules ]; then
  mkdir ~/.global-modules
fi

ln -s ~/.dotfiles/nodejs/.npmrc ~/.npmrc

################################################################################
# Oh-my-zsh
################################################################################
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

################################################################################
# Spaceship theme
################################################################################
git clone --depth=1 https://github.com/denysdovhan/spaceship-prompt.git ~/.oh-my-zsh/custom/themes/spaceship-prompt
ln -s ~/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme

################################################################################
# Git
################################################################################
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig

################################################################################
# Vim
################################################################################
ln -s ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim ~/.config/nvim
ln -s ~/.dotfiles/vim/init.vim ~/.vimrc

if [ ! -d ~/.config/coc ] && [ ! -h ~/.config/coc ]; then
  mkdir -p ~/.config/coc
fi

################################################################################
# GPG public keys
################################################################################
chmod 700 ~/.gnupg
chmod 400 ~/.gnupg/keys/*
gpg --import ~/.gnupg/keys/ch.protonmail.gufranco.public.pgp
gpg --import ~/.gnupg/keys/com.github.noreply.users.gufranco.public.pgp
gpg --import ~/.gnupg/keys/com.gmail.gustavocfranco.public.pgp
gpg --import ~/.gnupg/keys/com.icloud.gufranco.public.pgp
gpg --import ~/.gnupg/keys/com.live.gufranco.public.pgp
# gpg --import ~/.gnupg/keys/ch.protonmail.gufranco.private.pgp
# gpg --import ~/.gnupg/keys/com.github.noreply.users.gufranco.private.pgp
# gpg --import ~/.gnupg/keys/com.gmail.gustavocfranco.private.pgp
# gpg --import ~/.gnupg/keys/com.icloud.gufranco.private.pgp
# gpg --import ~/.gnupg/keys/com.live.gufranco.private.pgp

################################################################################
# SSH
################################################################################
if [ -d ~/.ssh ] || [ -h ~/.ssh ]; then
  rm -rf ~/.ssh
fi
ln -s ~/.dotfiles/ssh ~/.ssh
chmod 400 ~/.ssh/id_*

################################################################################
# Neomutt
################################################################################
ln -s ~/.dotfiles/mutt/.muttrc ~/.muttrc
ln -s ~/.dotfiles/mutt ~/.mutt
ln -s ~/.dotfiles/mutt/.mailcap ~/.mailcap

################################################################################
# Tmux
################################################################################
ln -s ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/tmux ~/.tmux

################################################################################
# Curl
################################################################################
ln -s ~/.dotfiles/curl/.curlrc ~/.curlrc

################################################################################
# Wget
################################################################################
ln -s ~/.dotfiles/wget/.wgetrc ~/.wgetrc

################################################################################
# Readline
################################################################################
ln -s ~/.dotfiles/.inputrc ~/.inputrc

################################################################################
# Finish
################################################################################
case "$(uname)" in
  Linux)
    # Clean the mess
    sudo apt autoremove -y
    sudo apt clean all -y

    # Reboot
    sudo shutdown -r now

  ;;
  Darwin)
    # Accept xCode's license
    sudo xcodebuild -license accept

    # Clean the mess
    brew cleanup -s

    # Enable TRIM / Reboot
    if [ "$(uname -m)" = "x86_64" ]; then
      yes | sudo trimforce enable
    else
      sudo shutdown -r now
    fi

  ;;
esac
