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
    if [ -d ~/.dotfiles ] || [ -h ~/.dotfiles ]; then
      mv ~/.dotfiles /tmp/dotfiles-old
    fi
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
    if [ -d ~/.dotfiles ] || [ -h ~/.dotfiles ]; then
      mv ~/.dotfiles /tmp/dotfiles-old
    fi
    git clone --recursive --depth=1 https://github.com/gufranco/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles || exit 1
    git remote set-url origin git@github.com:gufranco/dotfiles.git

    ############################################################################
    # Homebrew bundle
    ############################################################################
    export PATH="/usr/local/sbin:$PATH"
    HOMEBREW_FORCE_BREWED_CURL=1 brew bundle --file "${HOME}/.dotfiles/Brewfile"

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

if [ -f ~/.local/share/mc/skins ] || [ -h ~/.local/share/mc/skins ]; then
  mv ~/.local/share/mc/skins/gruvbox256.ini /tmp/gruvbox256.ini-old
fi

ln -s ~/.dotfiles/mc//gruvbox256.ini ~/.local/share/mc/skins/gruvbox256.ini

################################################################################
# Node.js
################################################################################
if [ -f ~/.npmrc ] || [ -h ~/.npmrc ]; then
  mv ~/.npmrc /tmp/npmrc-old
fi
ln -s ~/.dotfiles/nodejs/.npmrc ~/.npmrc
mkdir ~/.global-modules

################################################################################
# Bash
################################################################################
if [[ "$(uname)" == "Darwin" ]]; then
  echo -e "/usr/local/bin/bash" | sudo tee -a /etc/shells
fi

################################################################################
# Zsh
################################################################################
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
  mv ~/.zshrc /tmp/zshrc-old
fi
ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc

if [[ "$(uname)" == "Linux" ]]; then
  command -v zsh | sudo tee -a /etc/shells
  sudo sed -i -- 's/auth       required   pam_shells.so/# auth       required   pam_shells.so/g' /etc/pam.d/chsh
  sudo chsh "$USER" -s "$(command -v zsh)"
elif [[ "$(uname)" == "Darwin" ]]; then
  echo -e "/usr/local/bin/zsh" | sudo tee -a /etc/shells
  chsh -s "/usr/local/bin/zsh"
fi

################################################################################
# Oh-my-zsh
################################################################################
if [ -f ~/.oh-my-zsh ] || [ -h ~/.oh-my-zsh ]; then
  mv ~/.oh-my-zsh /tmp/oh-my-zsh-old
fi
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

################################################################################
# Spaceship theme
################################################################################
if [ -f ~/.oh-my-zsh/custom/themes/spaceship-prompt ] || [ -h ~/.oh-my-zsh/custom/themes/spaceship-prompt ]; then
  mv ~/.oh-my-zsh/custom/themes/spaceship-prompt /tmp/spaceship-prompt-old
fi
git clone --depth=1 https://github.com/denysdovhan/spaceship-prompt.git ~/.oh-my-zsh/custom/themes/spaceship-prompt
ln -s ~/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme

################################################################################
# Alacritty
################################################################################
if [ -f ~/.alacritty.yml ] || [ -h ~/.alacritty.yml ]; then
  mv ~/.alacritty.yml /tmp/alacritty.yml-old
fi

if [[ "$(uname)" == "Darwin" ]]; then
  ln -s ~/.dotfiles/alacritty/macos.yml ~/.alacritty.yml
else
  ln -s ~/.dotfiles/alacritty/linux.yml ~/.alacritty.yml
fi

################################################################################
# Git
################################################################################
if [ -f ~/.gitconfig ] || [ -h ~/.gitconfig ]; then
  mv ~/.gitconfig /tmp/gitconfig-old
fi
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig

################################################################################
# Vim
################################################################################
if [ -d ~/.vim ] || [ -h ~/.vim ]; then
  mv ~/.vim /tmp/vim-old
fi
ln -s ~/.dotfiles/vim ~/.vim

if [ -d ~/.config/nvim ] || [ -h ~/.config/nvim ]; then
  mv ~/.config/nvim /tmp/nvim-old
fi
ln -s ~/.dotfiles/vim ~/.config/nvim

if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
  mv ~/.vimrc /tmp/vimrc-old
fi
ln -s ~/.dotfiles/vim/init.vim ~/.vimrc

if [ -f ~/.config/coc ] || [ -h ~/.config/coc ]; then
  mv ~/.config/coc /tmp/coc-old
fi
ln -s ~/.dotfiles/coc ~/.config/coc

npm install \
  --global-style \
  --ignore-scripts \
  --no-bin-links \
  --only=prod \
  --prefix="${HOME}/.dotfiles/coc/extensions"

################################################################################
# GPG
################################################################################
if [ -d ~/.gnupg ] || [ -h ~/.gnupg ]; then
  mv ~/.gnupg /tmp/gnupg-old
fi

ln -s ~/.dotfiles/gnupg ~/.gnupg

if [[ "$(uname)" == "Darwin" ]]; then
  ln -s ~/.dotfiles/gnupg/gpg-agent-macos.conf ~/.dotfiles/gnupg/gpg-agent.conf
else
  ln -s ~/.dotfiles/gnupg/gpg-agent-linux.conf ~/.dotfiles/gnupg/gpg-agent.conf
fi

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
if [ -d ~/.ssh ] || [ -h ~/.ssh ]; then
  mv ~/.ssh /tmp/ssh-old
fi
ln -s ~/.dotfiles/ssh ~/.ssh
chmod 400 ~/.ssh/id_*

################################################################################
# Neomutt
################################################################################
if [ -f ~/.muttrc ] || [ -h ~/.muttrc ]; then
  mv ~/.muttrc /tmp/muttrc-old
fi
ln -s ~/.dotfiles/mutt/.muttrc ~/.muttrc

if [ -d ~/.mutt ] || [ -h ~/.mutt ]; then
  mv ~/.mutt /tmp/mutt-old
fi
ln -s ~/.dotfiles/mutt ~/.mutt

if [ -f ~/.mailcap ] || [ -h ~/.mailcap ]; then
  mv ~/.mailcap /tmp/mailcap-old
fi
ln -s ~/.dotfiles/mutt/.mailcap ~/.mailcap

################################################################################
# Tmux
################################################################################
if [ -f ~/.tmux.conf ] || [ -h ~/.tmux.conf ]; then
  mv ~/.tmux.conf /tmp/tmux.conf-old
fi
ln -s ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

if [ -d ~/.tmux ] || [ -h ~/.tmux ]; then
  mv ~/.tmux /tmp/tmux-old
fi
ln -s ~/.dotfiles/tmux ~/.tmux

################################################################################
# Curl
################################################################################
if [ -f ~/.curlrc ] || [ -h ~/.curlrc ]; then
  mv ~/.curlrc /tmp/curlrc-old
fi
ln -s ~/.dotfiles/curl/.curlrc ~/.curlrc

################################################################################
# Wget
################################################################################
if [ -f ~/.wgetrc ] || [ -h ~/.wgetrc ]; then
  mv ~/.wgetrc /tmp/wgetrc-old
fi
ln -s ~/.dotfiles/wget/.wgetrc ~/.wgetrc

################################################################################
# Readline
################################################################################
if [ -f ~/.inputrc ] || [ -h ~/.inputrc ]; then
  mv ~/.inputrc /tmp/inputrc-old
fi
ln -s ~/.dotfiles/.inputrc ~/.inputrc

################################################################################
# Conky
################################################################################
if [[ "$(uname)" == "Linux" ]]; then
  if [ -f ~/.conkyrc ] || [ -h ~/.conkyrc ]; then
    mv ~/.conkyrc /tmp/conkyrc-old
  fi
  ln -s ~/.dotfiles/conky/.conkyrc ~/.conkyrc
fi

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
