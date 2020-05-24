#!/usr/bin/env bash

set -ex
sudo -v
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
    # 7Zip
    ############################################################################
    sudo apt install -y \
      p7zip-full \
      p7zip-rar

    ############################################################################
    # Rar
    ############################################################################
    sudo apt install -y \
      unrar \
      rar

    ############################################################################
    # Zip
    ############################################################################
    sudo apt install -y \
      unzip \
      zip

    ############################################################################
    # Docker
    ############################################################################
    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    # sudo apt update
    # sudo apt install -y \
    #   docker-ce
    # sudo usermod -a -G docker "$USER"
    sudo apt install -y \
      docker.io
    sudo systemctl enable --now docker
    sudo usermod -a -G docker "$USER"

    ############################################################################
    # Node.js
    ############################################################################
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt update
    sudo apt install -y \
      nodejs

    ############################################################################
    # Dropbox
    ############################################################################
    sudo apt install -y \
      nautilus-dropbox

    ############################################################################
    # Java
    ############################################################################
    sudo add-apt-repository -y ppa:linuxuprising/java
    sudo apt update
    sudo apt install -y \
      oracle-java14-installer

    ############################################################################
    # Android Studio
    ############################################################################
    sudo add-apt-repository -y ppa:maarten-fonville/android-studio
    sudo apt update
    sudo apt install -y \
      android-studio

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
    # DBeaver
    ############################################################################
    curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
    echo -e "deb [arch=amd64] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
    sudo apt update
    sudo apt install -y \
      dbeaver-ce

    ############################################################################
    # Robo 3T
    ############################################################################
    sudo snap install robo3t-snap

    ############################################################################
    # Vim / gVim
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
    # sudo add-apt-repository -y ppa:hnakamur/universal-ctags
    # sudo apt update
    # sudo apt install -y \
    #   universal-ctags

    ############################################################################
    # Sublime Text 3
    ############################################################################
    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb [arch=amd64] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install -y \
      sublime-text

    ################################################################################
    # Visual Studio Code
    ################################################################################
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    echo -e "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y \
      code

    ############################################################################
    # Insomnia
    ############################################################################
    curl -fsSL https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee /etc/apt/sources.list.d/insomnia.list
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
      gnome-tweak-tool \
      network-manager-openvpn

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
    sudo apt install -y \
      fonts-hack-ttf

    curl -fLo \
      "$HOME/.local/share/fonts/Hack Regular Nerd Font Complete.ttf" \
      --create-dirs https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
    sudo fc-cache -fv

    ############################################################################
    # Tilix
    ############################################################################
    sudo apt install -y \
      tilix

    curl -fLo \
      "$HOME/.config/tilix/schemes/Dracula.json" \
      --create-dirs https://raw.githubusercontent.com/dracula/tilix/master/Dracula.json

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
    # QBittorrent
    ############################################################################
    sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
    sudo apt update
    sudo apt install -y \
      qbittorrent

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
    # Lutris
    ############################################################################
    sudo add-apt-repository -y ppa:lutris-team/lutris
    sudo apt update
    sudo apt install -y \
      lutris

    ############################################################################
    # Keybase
    ############################################################################
    curl -fLo \
      "/tmp/keybase.deb" \
      --create-dirs https://prerelease.keybase.io/keybase_amd64.deb
    sudo apt install -y \
      /tmp/keybase.deb

    ############################################################################
    # Pcsx2
    ############################################################################
    sudo apt install -y \
      pcsx2

    ############################################################################
    # Handbrake
    ############################################################################
    sudo add-apt-repository -y ppa:stebbins/handbrake-releases
    sudo apt update
    sudo apt install -y \
      handbrake-cli \
      handbrake-gtk

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
    # Fstrim
    ############################################################################
    echo -e "#\!/bin/sh\n" | sudo tee /etc/cron.hourly/fstrim
    echo -e "/sbin/fstrim --all || exit 1" | sudo tee -a /etc/cron.hourly/fstrim
    sudo chmod +x /etc/cron.hourly/fstrim

    ############################################################################
    # Dock
    ############################################################################
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 30
    gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true

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
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    ############################################################################
    # Homebrew bundle
    ############################################################################
    brew bundle

    ############################################################################
    # iTerm 2
    ############################################################################
    curl -fLo \
      "/tmp/Dracula.itermcolors" \
      --create-dirs https://raw.githubusercontent.com/dracula/iterm/master/Dracula.itermcolors
    open "/tmp/Dracula.itermcolors"

    ############################################################################
    # Hostname
    ############################################################################
    sudo scutil --set HostName macbook
    sudo scutil --set LocalHostName macbook
    sudo scutil --set ComputerName macbook

    ############################################################################
    # Battery config
    ############################################################################
    sudo pmset -b standbydelaylow 300
    sudo pmset -b standby 1
    sudo pmset -b halfdim 1
    sudo pmset -b sms 0
    sudo pmset -b disksleep 10
    sudo pmset -b standbydelayhigh 600
    sudo pmset -b sleep 10
    sudo pmset -b autopoweroffdelay 40000
    sudo pmset -b hibernatemode 25
    sudo pmset -b autopoweroff 1
    sudo pmset -b ttyskeepawake 0
    sudo pmset -b womp 0
    sudo pmset -b tcpkeepalive 0
    sudo pmset -b displaysleep 2
    sudo pmset -b highstandbythreshold 80
    sudo pmset -b acwake 0
    sudo pmset -b lidwake 1

    ############################################################################
    # AC config
    ############################################################################
    sudo pmset -c standbydelaylow 900
    sudo pmset -c standby 1
    sudo pmset -c halfdim 1
    sudo pmset -c sms 0
    sudo pmset -c networkoversleep 0
    sudo pmset -c disksleep 10
    sudo pmset -c standbydelayhigh 1200
    sudo pmset -c sleep 10
    sudo pmset -c autopoweroffdelay 20000
    sudo pmset -c hibernatemode 3
    sudo pmset -c autopoweroff 1
    sudo pmset -c womp 0
    sudo pmset -c tcpkeepalive 0
    sudo pmset -c ttyskeepawake 0
    sudo pmset -c displaysleep 10
    sudo pmset -c highstandbythreshold 50
    sudo pmset -c acwake 0
    sudo pmset -c lidwake 1

    ;;
  *)
    echo -e "Invalid system."
    exit 1

    ;;
esac

################################################################################
# Flutter
################################################################################
git clone --depth=1 https://github.com/flutter/flutter.git -b stable ~/.flutter-sdk

################################################################################
# dotfiles
################################################################################
if [ -d ~/.dotfiles ] || [ -h ~/.dotfiles ]; then
  mv ~/.dotfiles /tmp/dotfiles-old
fi
git clone --recursive  --depth=1 https://github.com/gufranco/dotfiles.git ~/.dotfiles
cd ~/.dotfiles || exit 1
git remote set-url origin git@github.com:gufranco/dotfiles.git

################################################################################
# Node.js config
################################################################################
if [ -f ~/.npmrc ] || [ -h ~/.npmrc ]; then
  mv ~/.npmrc /tmp/npmrc-old
fi
ln -s ~/.dotfiles/nodejs/.npmrc ~/.npmrc
mkdir ~/.global-modules

################################################################################
# Bash config
################################################################################
if [[ "$(uname)" == "Darwin" ]]; then
  echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
fi

################################################################################
# Zsh config
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
  echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
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
# Git config
################################################################################
if [ -f ~/.gitconfig ] || [ -h ~/.gitconfig ]; then
  mv ~/.gitconfig /tmp/gitconfig-old
fi
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig

################################################################################
# Vim / Neovim config
################################################################################
if [ -d ~/.vim ] || [ -h ~/.vim ]; then
  mv ~/.vim /tmp/vim-old
fi
ln -s ~/.dotfiles/vim ~/.vim

if [ -d ~/.config/nvim ] || [ -h ~/.config/nvim ]; then
  mv ~/.config/nvim /tmp/nvim-old
fi
mkdir ~/.config
ln -s ~/.dotfiles/vim ~/.config/nvim

if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
  mv ~/.vimrc /tmp/vimrc-old
fi
ln -s ~/.dotfiles/vim/init.vim ~/.vimrc

################################################################################
# GPG config
################################################################################
if [ -d ~/.gnupg ] || [ -h ~/.gnupg ]; then
  mv ~/.gnupg /tmp/gnupg-old
fi
ln -s ~/.dotfiles/gnupg ~/.gnupg

if [[ "$(uname)" == "Linux" ]]; then
  echo "pinentry-program /usr/bin/pinentry-curses" > ~/.gnupg/gpg-agent.conf
elif [[ "$(uname)" == "Darwin" ]]; then
  echo "pinentry-program /usr/local/bin/pinentry-curses" > ~/.gnupg/gpg-agent.conf
fi

chmod 700 ~/.gnupg
chmod 400 ~/.gnupg/keys/*
# gpg --import ~/.gnupg/keys/personal.public
# gpg --import ~/.gnupg/keys/personal.private

################################################################################
# SSH config
################################################################################
if [ -d ~/.ssh ] || [ -h ~/.ssh ]; then
  mv ~/.ssh /tmp/ssh-old
fi
ln -s ~/.dotfiles/ssh ~/.ssh
chmod 400 ~/.ssh/id_*

################################################################################
# Neomutt config
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
# Tmux config
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
# Curl config
################################################################################
if [ -f ~/.curlrc ] || [ -h ~/.curlrc ]; then
  mv ~/.curlrc /tmp/curlrc-old
fi
ln -s ~/.dotfiles/curl/.curlrc ~/.curlrc

################################################################################
# Wget config
################################################################################
if [ -f ~/.wgetrc ] || [ -h ~/.wgetrc ]; then
  mv ~/.wgetrc /tmp/wgetrc-old
fi
ln -s ~/.dotfiles/wget/.wgetrc ~/.wgetrc

################################################################################
# Readline config
################################################################################
if [ -f ~/.inputrc ] || [ -h ~/.inputrc ]; then
  mv ~/.inputrc /tmp/inputrc-old
fi
ln -s ~/.dotfiles/.inputrc ~/.inputrc

################################################################################
# Conky config
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
    brew prune

    # Enable TRIM and reboot
    sudo trimforce enable

  ;;
esac
