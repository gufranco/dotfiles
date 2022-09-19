# frozen_string_literal: true

architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip

tap 'buo/cask-upgrade'
tap 'homebrew/bundle'
tap 'homebrew/cask'
tap 'homebrew/cask-drivers'
tap 'homebrew/cask-fonts'
tap 'homebrew/cask-versions'
tap 'homebrew/core'
tap 'neomutt/neomutt'
tap 'universal-ctags/universal-ctags'
brew 'ack'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'binutils'
brew 'cmake'
brew 'coreutils'
brew 'curl'
brew 'findutils'
brew 'flyctl'
brew 'git'
brew 'gnu-sed'
brew 'gnupg'
brew 'htop'
brew 'lynx'
brew 'mas'
brew 'moreutils'
brew 'neomutt'
brew 'neovim' if architecture == 'arm64' || cpu_model.include?('Core(TM) i')
brew 'node', link: true
brew 'openssl'
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'rsync'
brew 'ruby', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'tmux'
brew 'universal-ctags/universal-ctags/universal-ctags', args: ['HEAD']
brew 'urlview'
brew 'vim'
brew 'wget'
brew 'yarn'
brew 'zlib'
brew 'zsh-syntax-highlighting'
brew 'zsh'
# cask 'jdownloader'
# cask 'paragon-ntfs' if architecture == 'x86_64'
# cask 'stats'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'dbeaver-community'
cask 'docker'
cask 'drivedx'
cask 'dropbox'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'huiontablet'
cask 'insomnia'
cask 'intel-power-gadget' if cpu_model.include?('Core(TM) i')
cask 'istat-menus'
cask 'iterm2'
cask 'keka'
cask 'logitech-options'
cask 'mongodb-compass'
cask 'slack'
cask 'spotify'
cask 'the-unarchiver'
cask 'transmission-nightly'
cask 'tunnelblick'
# cask 'turbo-boost-switcher' if cpu_model.include?('Core(TM) i')
cask 'utm' if architecture == 'arm64'
cask 'virtualbox' if cpu_model.include?('Core(TM) i')
cask 'virtualbox-extension-pack' if cpu_model.include?('Core(TM) i')
cask 'visual-studio-code'
cask 'vlc'
# mas 'Xcode', id: 497_799_835
mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
