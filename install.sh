#!/usr/bin/env bash

set -Eeuo pipefail

# Ask for the root password upfront
sudo -v

# Keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

case "$(uname)" in
  Linux)
    ############################################################################
    # Disable prompts
    ############################################################################
    export DEBIAN_FRONTEND=noninteractive

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
      xsel \
      zsh

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
    # Midnight Commander
    ############################################################################
    sudo apt install -y \
      mc

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
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt update
    sudo apt install -y \
      nodejs

    ############################################################################
    # Insync
    ############################################################################
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
    echo -e "deb [arch=amd64] deb http://apt.insync.io/ubuntu $(lsb_release -cs) non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list
    sudo apt update
    sudo apt install -y \
      insync

    ############################################################################
    # Dropbox
    ############################################################################
    sudo apt install -y \
      nautilus-dropbox

    ############################################################################
    # Spotify
    ############################################################################
    curl -fsSL https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
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
    # Skype
    ############################################################################
    sudo snap install skype --classic

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
    # Sublime Text 3
    ############################################################################
    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo -e "deb [arch=amd64] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install -y \
      sublime-text

    ############################################################################
    # Visual Studio Code
    ############################################################################
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    echo -e "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y \
      code

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
    # Alacritty
    ############################################################################
    sudo add-apt-repository -y ppa:mmstick76/alacritty
    sudo apt update
    sudo apt install -y \
      alacritty

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
    # Neofetch
    ############################################################################
    sudo apt install -y \
      neofetch

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
    # Steam
    ############################################################################
    sudo apt install -y \
      steam

    ############################################################################
    # Handbrake
    ############################################################################
    sudo add-apt-repository -y ppa:stebbins/handbrake-releases
    sudo apt update
    sudo apt install -y \
      handbrake-cli \
      handbrake-gtk

    ############################################################################
    # Piper
    ############################################################################
    sudo apt install -y \
      piper

    ############################################################################
    # Drivers
    ############################################################################
    sudo add-apt-repository -y ppa:oibaf/graphics-drivers
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update
    sudo apt install -y \
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
    # Zsh
    ############################################################################
    ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc
    command -v zsh | sudo tee -a /etc/shells
    sudo sed -i -- 's/auth       required   pam_shells.so/# auth       required   pam_shells.so/g' /etc/pam.d/chsh
    sudo chsh "$USER" -s "$(command -v zsh)"

    ############################################################################
    # Alacritty
    ############################################################################
    ln -s ~/.dotfiles/alacritty/linux.yml ~/.alacritty.yml

    ############################################################################
    # Conky
    ############################################################################
    ln -s ~/.dotfiles/conky/.conkyrc ~/.conkyrc

    ############################################################################
    # GPG
    ############################################################################
    ln -s ~/.dotfiles/gnupg ~/.gnupg
    ln -s ~/.dotfiles/gnupg/gpg-agent-linux.conf ~/.dotfiles/gnupg/gpg-agent.conf
    chmod 700 ~/.gnupg

  ;;
  Darwin)
    ############################################################################
    # xCode
    ############################################################################
    # xcode-select -p || exit 1
    # sudo xcodebuild -license accept
    # sudo xcode-select --install

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
    export PATH="/usr/local/sbin:$PATH"
    HOMEBREW_FORCE_BREWED_CURL=1 brew bundle --file "${HOME}/.dotfiles/Brewfile"

    ############################################################################
    # Bash
    ############################################################################
    echo -e "/usr/local/bin/bash" | sudo tee -a /etc/shells

    ############################################################################
    # Zsh
    ############################################################################
    ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc
    echo -e "/usr/local/bin/zsh" | sudo tee -a /etc/shells
    chsh -s "/usr/local/bin/zsh"

    ############################################################################
    # Alacritty
    ############################################################################
    ln -s ~/.dotfiles/alacritty/macos.yml ~/.alacritty.yml

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

    open "/tmp/gruvbox-dark.itermcolors"
  ;;
esac

################################################################################
# Config folder
################################################################################
if [ ! -d ~/.config ] && [ ! -h ~/.config ]; then
  mkdir ~/.config
fi

################################################################################
# Midnight Commander
################################################################################
if [ ! -d ~/.local/share/mc/skins ] && [ ! -h ~/.local/share/mc/skins ]; then
  mkdir -p ~/.local/share/mc/skins
fi

ln -s ~/.dotfiles/mc//gruvbox256.ini ~/.local/share/mc/skins/gruvbox256.ini

################################################################################
# Npm
################################################################################
ln -s ~/.dotfiles/nodejs/.npmrc ~/.npmrc
mkdir ~/.global-modules

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
ln -s ~/.dotfiles/coc ~/.config/coc

npm install \
  --global-style \
  --ignore-scripts \
  --no-bin-links \
  --only=prod \
  --prefix="${HOME}/.dotfiles/coc/extensions"

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

################################################################################
# SSH
################################################################################
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
    # Clean the mess
    brew cleanup -s

    # Enable TRIM and reboot
    yes | sudo trimforce enable

  ;;
esac
