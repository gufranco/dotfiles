# frozen_string_literal: true

architecture = `uname -m`.strip
cpu_model = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}'`.strip

tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'homebrew/bundle'
tap 'neomutt/neomutt'
tap 'UltimateNova1203/maxcso'
tap 'universal-ctags/universal-ctags'

brew 'ack'
brew 'act'
brew 'asciinema'
brew 'awscli'
brew 'bash'
brew 'bat'
brew 'ca-certificates'
brew 'chruby'
brew 'cmake'
brew 'cocoapods'
brew 'curl'
brew 'fastfetch'
brew 'fd'
brew 'ffmpeg'
brew 'fzf'
brew 'git'
brew 'gnupg'
brew 'golang'
brew 'java11'
brew 'kubectl'
brew 'lynx'
brew 'mas'
brew 'maxcso'
brew 'neomutt'
brew 'neovim'
brew 'node', link: true
brew 'nvm'
brew 'openssl'
brew 'pnpm'
brew 'python', link: true
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'ruby', link: true
brew 'ruby-install'
brew 'shared-mime-info'
brew 'shellcheck'
brew 'tmux'
brew 'universal-ctags', args: ['HEAD']
brew 'urlview'
brew 'vim'
brew 'vint'
brew 'wget'
brew 'zlib'
brew 'zsh'
brew 'zsh-syntax-highlighting'

cask 'aldente' if architecture == 'x86_64'
cask 'android-studio'
cask 'coconutbattery'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu_model)
cask 'docker' if serial != 'J6WCV57T0W'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'google-chrome'
cask 'handbrake'
cask 'istat-menus'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'maestral'
cask 'microsoft-auto-update'
cask 'microsoft-teams'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'openlens'
cask 'parallels' if architecture == 'arm64' && !['J6WCV57T0W', 'LFHY7WDM00'].include?('serial')
cask 'postman'
cask 'rancher' if serial == 'J6WCV57T0W'
cask 'shottr'
cask 'slack'
cask 'spotify'
cask 'transmission'
cask 'tunnelblick'
cask 'virtualbox' if architecture == 'x86_64'
cask 'visual-studio-code'
cask 'vlc'

mas 'Resident Evil 4', id: 6_462_360_082 if architecture == 'arm64' && !['J6WCV57T0W', 'LFHY7WDM00'].include?('serial')
mas 'Resident Evil 7', id: 1_640_629_241 if architecture == 'arm64' && !['J6WCV57T0W', 'LFHY7WDM00'].include?('serial')
mas 'Resident Evil 8', id: 1_640_627_334 if architecture == 'arm64' && !['J6WCV57T0W', 'LFHY7WDM00'].include?('serial')
mas 'Stray', id: 6_451_498_949 if architecture == 'arm64' && !['J6WCV57T0W', 'LFHY7WDM00'].include?('serial')
mas 'Amphetamine', id: 937_984_704
mas 'CleanMyDrive 2', id: 523_620_159
mas 'Magnet', id: 441_258_766
mas 'Xcode', id: 497_799_835
