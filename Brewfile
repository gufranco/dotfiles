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
tap 'homebrew/services' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
tap 'mongodb/brew' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
tap 'neomutt/neomutt'
tap 'universal-ctags/universal-ctags'
brew 'ack'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'binutils'
brew 'cmake'
brew 'coreutils'
brew 'findutils'
brew 'flyctl'
brew 'git'
brew 'gnu-sed'
brew 'gnupg'
brew 'htop'
brew 'libpq' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'lynx'
brew 'macos-term-size' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'mas'
brew 'mongodb-community' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'mongodb/brew/mongodb-database-tools' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'mongosh' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'moreutils'
brew 'neomutt'
brew 'neovim' if architecture == 'arm64' || cpu_model.include?('Core(TM) i')
brew 'node', link: true
brew 'node@14' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'openssl'
brew 'postgresql' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'redis' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
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
brew 'zsh'
brew 'zsh-syntax-highlighting'
# cask "stats"
# cask 'jdownloader'
# cask 'paragon-ntfs' if architecture == 'x86_64'
cask 'balenaetcher'
cask 'burn'
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
cask 'intel-power-gadget' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
cask 'istat-menus'
cask 'iterm2'
cask 'keka'
cask 'logitech-options'
cask 'slack'
cask 'spotify'
cask 'the-unarchiver'
cask 'transmission-nightly'
cask 'tunnelblick'
cask 'turbo-boost-switcher' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
cask 'utm' if architecture == 'arm64'
cask 'virtualbox' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
cask 'virtualbox-extension-pack' if architecture == 'x86_64' && cpu_model.include?('Core(TM) i')
cask 'visual-studio-code'
cask 'vlc'
# mas 'Xcode', id: 497_799_835
mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
