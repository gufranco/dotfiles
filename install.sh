#!/usr/bin/env bash

set -Eeuo pipefail

# Ask for the root password upfront
sudo -v

# Keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

case "$(uname)" in
  "Linux")
    export DEBIAN_FRONTEND=noninteractive

    ############################################################################
    # Update / upgrade
    ############################################################################
    sudo add-apt-repository universe
    sudo apt update
    sudo apt dist-upgrade -y

    ############################################################################
    # Basic packages
    ############################################################################
    echo -e "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

    sudo apt install -y \
      apt-transport-https \
      build-essential \
      ca-certificates \
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
    if [ -d ~/.dotfiles ] || [ -h ~/.dotfiles ]; then
      cd ~/.dotfiles || exit 1
      git remote set-url origin https://github.com/gufranco/dotfiles.git
      git checkout master
      git pull
      git remote set-url origin git@github.com:gufranco/dotfiles.git
    else
      git clone --recursive --depth=1 https://github.com/gufranco/dotfiles.git ~/.dotfiles
      cd ~/.dotfiles || exit 1
      git remote set-url origin git@github.com:gufranco/dotfiles.git
    fi

    ############################################################################
    # Enable exFat
    ############################################################################
    sudo apt install -y \
      exfat-fuse \
      exfatprogs

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
    sudo apt install -y zsh

    if ! grep -q "$(command -v zsh)" /etc/shells; then
      command -v zsh | sudo tee -a /etc/shells
    fi

    sudo chsh "$USER" -s "$(command -v zsh)"

    ############################################################################
    # Docker
    ############################################################################
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt install -y docker-ce
    sudo usermod -a -G docker "$USER"

    ############################################################################
    # Node.js
    ############################################################################
    sudo apt install -y \
      ca-certificates \
      curl \
      g++ \
      gcc \
      gnupg \
      make
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/nodesource.gpg
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt update
    sudo apt install -y nodejs

    ############################################################################
    # Python
    ############################################################################
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.14

    ############################################################################
    # Dropbox
    ############################################################################
    sudo apt install -y nautilus-dropbox

    ############################################################################
    # Spotify
    ############################################################################
    curl -fsSL https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo -e "deb [arch=$(dpkg --print-architecture)] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y spotify-client

    ############################################################################
    # Chrome
    ############################################################################
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo -e "deb [arch=$(dpkg --print-architecture)] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable

    ############################################################################
    # DBeaver
    ############################################################################
    sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce
    sudo apt update
    sudo apt install -y dbeaver-ce

    ############################################################################
    # Ripgrep
    ############################################################################
    sudo apt install -y ripgrep

    ############################################################################
    # Fzf
    ############################################################################
    sudo apt install -y fzf

    ############################################################################
    # Universal ctags
    ############################################################################
    sudo apt install -y universal-ctags

    ############################################################################
    # Visual Studio Code
    ############################################################################
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/visual_studio.gpg
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/visual_studio.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code

    ############################################################################
    # Postman
    ############################################################################
    sudo snap install postman

    ############################################################################
    # GPG
    ############################################################################
    sudo apt install -y \
      gpg \
      gnupg-agent

    ############################################################################
    # Neomutt
    ############################################################################
    sudo apt install -y neomutt

    ############################################################################
    # Lynx
    ############################################################################
    sudo apt install -y lynx

    ############################################################################
    # Shellcheck
    ############################################################################
    sudo apt install -y shellcheck

    ############################################################################
    # Hack Nerd Font
    ############################################################################
    sudo apt install -y fonts-hack-ttf

    curl -#fLo \
      ~/.local/share/fonts/HackNerdFont-Regular.ttf \
      --create-dirs https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf

    sudo fc-cache -fv

    ############################################################################
    # Kitty
    ############################################################################
    sudo apt install -y kitty

    ############################################################################
    # VLC
    ############################################################################
    sudo apt install -y vlc

    ############################################################################
    # Conky
    ############################################################################
    sudo apt install -y conky-all

    if [ -d ~/.conkyrc ] || [ -h ~/.conkyrc ]; then
      rm -rf ~/.conkyrc
    fi

    ln -s ~/.dotfiles/conky/.conkyrc ~/.conkyrc

    ############################################################################
    # Transmission
    ############################################################################
    sudo apt install -y transmission

    ############################################################################
    # Asciinema
    ############################################################################
    sudo apt install -y asciinema

    ############################################################################
    # Preload
    ############################################################################
    sudo apt install -y preload

    ############################################################################
    # TLP
    ############################################################################
    sudo add-apt-repository -y ppa:linrunner/tlp
    sudo apt update
    sudo apt install -y tlp

    ############################################################################
    # Caffeine
    ############################################################################
    sudo apt install -y caffeine

    ############################################################################
    # Slack
    ############################################################################
    sudo snap install slack

    ;;
  "Darwin")
    ############################################################################
    # Rosetta 2
    ############################################################################
    if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/pgrep oahd >/dev/null; then
      /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi

    ############################################################################
    # Homebrew
    ############################################################################
    if [ ! -x "$(command -v brew)" ]; then
      CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      case "$(uname -m)" in
        "arm64")
          export HOMEBREW_PREFIX="/opt/homebrew"
          export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
          export HOMEBREW_REPOSITORY="/opt/homebrew"
          export HOMEBREW_SHELLENV_PREFIX="/opt/homebrew"
          export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
          export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
          export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

          ;;
        "x86_64")
          export HOMEBREW_PREFIX="/usr/local"
          export HOMEBREW_CELLAR="/usr/local/Cellar"
          export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
          export HOMEBREW_SHELLENV_PREFIX="/usr/local"
          export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
          export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
          export INFOPATH="/usr/local/share/info:${INFOPATH:-}"

          ;;
      esac
    fi

    ############################################################################
    # dotfiles
    ############################################################################
    if [ -d ~/.dotfiles ] || [ -h ~/.dotfiles ]; then
      cd ~/.dotfiles || exit 1
      git remote set-url origin https://github.com/gufranco/dotfiles.git
      git checkout master
      git pull
      git remote set-url origin git@github.com:gufranco/dotfiles.git
    else
      git clone --recursive --depth=1 https://github.com/gufranco/dotfiles.git ~/.dotfiles
      cd ~/.dotfiles || exit 1
      git remote set-url origin git@github.com:gufranco/dotfiles.git
    fi

    ############################################################################
    # Homebrew bundle
    ############################################################################
    brew bundle --file "$HOME/.dotfiles/Brewfile" --force cleanup --no-lock

    ############################################################################
    # Bash
    ############################################################################
    if ! grep -q "$(brew --prefix)/bin/bash" /etc/shells; then
      echo -e "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
    fi

    ############################################################################
    # Zsh
    ############################################################################
    if ! grep -q "$(brew --prefix)/bin/zsh" /etc/shells; then
      echo -e "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
    fi
    chsh -s "$(brew --prefix)/bin/zsh"

    ;;
esac

################################################################################
# Node.js
################################################################################
if [ -d ~/.npmrc ] || [ -h ~/.npmrc ]; then
  rm -rf ~/.npmrc
fi

ln -s ~/.dotfiles/nodejs/.npmrc ~/.npmrc

if [ ! -d ~/.nvm ] && [ ! -h ~/.nvm ]; then
  mkdir -p ~/.nvm
fi

################################################################################
# Oh-my-zsh
################################################################################
if [ -d ~/.zshrc ] || [ -h ~/.zshrc ]; then
  rm -rf ~/.zshrc
fi

ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc

if [ -d ~/.oh-my-zsh ] || [ -h ~/.oh-my-zsh ]; then
  rm -rf ~/.oh-my-zsh
fi

git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ] || [ -h ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ] || [ -h ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

if [ -d ~/.oh-my-zsh/custom/plugins/you-should-use ] || [ -h ~/.oh-my-zsh/custom/plugins/you-should-use ]; then
  rm -rf ~/.oh-my-zsh/custom/plugins/you-should-use
fi

git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use.git ~/.oh-my-zsh/custom/plugins/you-should-use

if [ -d ~/.oh-my-zsh/custom/themes/spaceship-prompt ] || [ -h ~/.oh-my-zsh/custom/themes/spaceship-prompt ]; then
  rm -rf ~/.oh-my-zsh/custom/themes/spaceship-prompt
fi

git clone --depth=1 https://github.com/denysdovhan/spaceship-prompt.git ~/.oh-my-zsh/custom/themes/spaceship-prompt

if [ -d ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme ] || [ -h ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme ]; then
  rm -rf ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme
fi

ln -s ~/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme

################################################################################
# Git
################################################################################
if [ -d ~/.gitconfig ] || [ -h ~/.gitconfig ]; then
  rm -rf ~/.gitconfig
fi

ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig

################################################################################
# Vim
################################################################################
if [ -d ~/.vim ] || [ -h ~/.vim ]; then
  rm -rf ~/.vim
fi

ln -s ~/.dotfiles/vim ~/.vim

if [ -d ~/.vimrc ] || [ -h ~/.vimrc ]; then
  rm -rf ~/.vimrc
fi

ln -s ~/.dotfiles/vim/.vimrc ~/.vimrc

################################################################################
# GPG
################################################################################
if [ -d ~/.gnupg ] || [ -h ~/.gnupg ]; then
  rm -rf ~/.gnupg
fi

ln -s ~/.dotfiles/gnupg ~/.gnupg
chmod 700 ~/.gnupg
chmod 400 ~/.gnupg/keys/*

if [ -d ~/.gnupg/gpg-agent.conf ] || [ -h ~/.gnupg/gpg-agent.conf ]; then
  rm -rf ~/.gnupg/gpg-agent.conf
fi

case "$(uname)" in
  "Linux")
    ln -s ~/.dotfiles/gnupg/gpg-agent-linux.conf ~/.gnupg/gpg-agent.conf

    ;;
  "Darwin")
    ln -s ~/.dotfiles/gnupg/gpg-agent-macos-"$(uname -m)".conf ~/.gnupg/gpg-agent.conf

    ;;
esac

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
if [ -d ~/.muttrc ] || [ -h ~/.muttrc ]; then
  rm -rf ~/.muttrc
fi

ln -s ~/.dotfiles/mutt/.muttrc ~/.muttrc

if [ -d ~/.mutt ] || [ -h ~/.mutt ]; then
  rm -rf ~/.mutt
fi

ln -s ~/.dotfiles/mutt ~/.mutt

if [ -d ~/.mailcap ] || [ -h ~/.mailcap ]; then
  rm -rf ~/.mailcap
fi

ln -s ~/.dotfiles/mutt/.mailcap ~/.mailcap

################################################################################
# Tmux
################################################################################
if [ -d ~/.tmux.conf ] || [ -h ~/.tmux.conf ]; then
  rm -rf ~/.tmux.conf
fi

ln -s ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

if [ -d ~/.tmux ] || [ -h ~/.tmux ]; then
  rm -rf ~/.tmux
fi

ln -s ~/.dotfiles/tmux ~/.tmux

################################################################################
# Curl
################################################################################
if [ -d ~/.curlrc ] || [ -h ~/.curlrc ]; then
  rm -rf ~/.curlrc
fi

ln -s ~/.dotfiles/curl/.curlrc ~/.curlrc

################################################################################
# Wget
################################################################################
if [ -d ~/.wgetrc ] || [ -h ~/.wgetrc ]; then
  rm -rf ~/.wgetrc
fi

ln -s ~/.dotfiles/wget/.wgetrc ~/.wgetrc

################################################################################
# Readline
################################################################################
if [ -d ~/.inputrc ] || [ -h ~/.inputrc ]; then
  rm -rf ~/.inputrc
fi

ln -s ~/.dotfiles/readline/.inputrc ~/.inputrc

################################################################################
# Kitty
################################################################################
if [ -d ~/.config/kitty/kitty.conf ] || [ -h ~/.config/kitty/kitty.conf ]; then
  rm -rf ~/.config/kitty/kitty.conf
fi

mkdir -p ~/.config/kitty
ln -s ~/.dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

################################################################################
# Finish
################################################################################
case "$(uname)" in
  "Linux")
    # Clean the mess
    sudo apt autoremove -y
    sudo apt clean all -y

    ;;
  "Darwin")
    # Clean the mess
    brew cleanup -s

    # Enable TRIM
    if [ "$(system_profiler SPSerialATADataType | grep 'TRIM Support' | awk '{print $3}')" = "Yes" ]; then
      yes | sudo trimforce enable
    fi

    ;;
esac

# Reboot
sudo shutdown -r now
