#!/usr/bin/env bash

set -ex

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
    sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce
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
    sudo apt install -y \
      universal-ctags

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
    # Piper
    ############################################################################
    sudo apt-add-repository -y ppa:libratbag-piper/piper-libratbag-git
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
    # Dock
    ############################################################################
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 30
    gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true

    ############################################################################
    # Clock
    ############################################################################
    # sudo timedatectl set-local-rtc 1

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
    sudo scutil --set HostName "macbook"
    sudo scutil --set LocalHostName "macbook"
    sudo scutil --set ComputerName "macbook"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "macbook"

    ############################################################################
    # Always show scrollbars
    ############################################################################
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

    ############################################################################
    # Expand save panel by default
    ############################################################################
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    ############################################################################
    # Expand print panel by default
    ############################################################################
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    ############################################################################
    # Automatically quit printer app once the print jobs complete
    ############################################################################
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    ############################################################################
    # Display ASCII control characters using caret notation in standard text views
    ############################################################################
    defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

    ############################################################################
    # Disable Resume system-wide
    ############################################################################
    defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

    ############################################################################
    # Set Help Viewer windows to non-floating mode
    ############################################################################
    defaults write com.apple.helpviewer DevMode -bool true

    ############################################################################
    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    ############################################################################
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

    ############################################################################
    # Disable automatic capitalization, smart dashes, period substitution, smart
    # quotes and auto-correct
    ############################################################################
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    ############################################################################
    # Enable tap to click
    ############################################################################
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    ############################################################################
    # Increase sound quality for Bluetooth headphones/headsets
    ############################################################################
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    ############################################################################
    # Enable full keyboard access for all controls
    ############################################################################
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    ############################################################################
    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    ############################################################################
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

    ############################################################################
    # Follow the keyboard focus while zoomed in
    ############################################################################
    defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

    ############################################################################
    # Disable press-and-hold for keys in favor of key repeat
    ############################################################################
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    ############################################################################
    # Set a blazingly fast keyboard repeat rate
    ############################################################################
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    ############################################################################
    # Show language menu in the top right corner of the boot screen
    ############################################################################
    sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

    ############################################################################
    # Energy saving
    ############################################################################
    sudo pmset -a lidwake 1
    sudo pmset -a autorestart 1
    sudo systemsetup -setrestartfreeze on
    sudo pmset -a displaysleep 15
    sudo pmset -c sleep 0
    sudo pmset -b sleep 5
    sudo pmset -a standbydelay 86400
    sudo systemsetup -setcomputersleep Off > /dev/null
    sudo pmset -a hibernatemode 0
    sudo rm /private/var/vm/sleepimage
    sudo touch /private/var/vm/sleepimage
    sudo chflags uchg /private/var/vm/sleepimage

    ############################################################################
    # Require password immediately after sleep or screen saver begins
    ############################################################################
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    ############################################################################
    # Save screenshots to the desktop
    ############################################################################
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    ############################################################################
    # Save screenshots in PNG format
    ############################################################################
    defaults write com.apple.screencapture type -string "png"

    ############################################################################
    # Disable shadow in screenshots
    ############################################################################
    defaults write com.apple.screencapture disable-shadow -bool true

    ############################################################################
    # Enable subpixel font rendering on non-Apple LCDs
    ############################################################################
    defaults write NSGlobalDomain AppleFontSmoothing -int 1

    ############################################################################
    # Enable HiDPI display modes
    ############################################################################
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    ############################################################################
    # Disable window animations and Get Info animations
    ############################################################################
    defaults write com.apple.finder DisableAllAnimations -bool true

    ############################################################################
    # Show all filename extensions
    ############################################################################
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    ############################################################################
    # Show status and path bar
    ############################################################################
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true

    ############################################################################
    # Keep folders on top when sorting by name
    ############################################################################
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    ############################################################################
    # When performing a search, search the current folder by default
    ############################################################################
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    ############################################################################
    # Disable the warning when changing a file extension
    ############################################################################
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    ############################################################################
    # Enable spring loading for directories
    ############################################################################
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    ############################################################################
    # Remove the spring loading delay for directories
    ############################################################################
    defaults write NSGlobalDomain com.apple.springing.delay -float 0

    ############################################################################
    # Avoid creating .DS_Store files on network or USB volumes
    ############################################################################
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    ############################################################################
    # Use list view in all Finder windows by default
    ############################################################################
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    ############################################################################
    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    ############################################################################
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    ############################################################################
    # Disable send and reply animations in Mail.app
    ############################################################################
    defaults write com.apple.mail DisableReplyAnimations -bool true
    defaults write com.apple.mail DisableSendAnimations -bool true

    ############################################################################
    # Copy email addresses as `foo@example.com` in Mail.app
    ############################################################################
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    ############################################################################
    # Display emails in threaded mode in Mail.app
    ############################################################################
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

    ############################################################################
    # Disable inline attachments in Mail.app
    ############################################################################
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    ############################################################################
    # Only use UTF-8 in Terminal.app
    ############################################################################
    defaults write com.apple.terminal StringEncodings -array 4

    ############################################################################
    # Prevent Time Machine from prompting to use new hard drives as backup
    ############################################################################
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    ############################################################################
    # Show the main window when launching Activity Monitor
    ############################################################################
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    ############################################################################
    # Visualize CPU usage in the Activity Monitor Dock icon
    ############################################################################
    defaults write com.apple.ActivityMonitor IconType -int 5

    ############################################################################
    # Show all processes in Activity Monitor
    ############################################################################
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    ############################################################################
    # Sort Activity Monitor results by CPU usage
    ############################################################################
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    ############################################################################
    # Disable automatic emoji substitution in Messages.app
    ############################################################################
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

    ############################################################################
    # Disable smart quotes in Messages.app
    ############################################################################
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

    ############################################################################
    # Disable continuous spell checking in Messages.app
    ############################################################################
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

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
