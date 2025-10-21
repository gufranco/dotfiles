# frozen_string_literal: true

# System specs
architecture = `uname -m`.strip
cpu = `sysctl -n machdep.cpu.brand_string`.strip
model = `sysctl -n hw.model`.strip
serial = `system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $NF}'`.strip
storage = (`diskutil info /dev/disk0 | awk -F'[()]' '/Disk Size/ {sub(/ Bytes/, "", $2); print $2}'`.strip.to_i / 1073741824)

# Serials
macbook_retina_12_2017_serial = 'C02TW09THH29'
macbook_pro_13_mid_2012_serial = 'C02J332HDV30'

tap 'aws/tap'
tap 'buo/cask-upgrade'
tap 'neomutt/neomutt'
tap 'oven-sh/bun'
tap 'stripe/stripe-cli'
tap 'UltimateNova1203/maxcso'
tap 'universal-ctags/universal-ctags'

# brew 'colima'
# brew 'docker-compose'
# brew 'docker-credential-helper'
# brew 'docker'
# brew 'lima-additional-guestagents'
brew 'ack'
brew 'act'
brew 'asciinema'
brew 'autoconf'
brew 'automake'
brew 'awscli'
brew 'bash'
brew 'bat'
brew 'bc'
brew 'binutils'
brew 'ca-certificates'
brew 'cdrtools'
brew 'chruby'
brew 'cmake'
brew 'cocoapods'
brew 'coreutils'
brew 'cpufetch'
brew 'curl'
brew 'diffutils'
brew 'dust'
brew 'fastfetch'
brew 'fd'
brew 'ffmpeg'
brew 'ffmpegthumbnailer' # Yazi dependency
brew 'findutils'
brew 'flyctl'
brew 'fzf'
brew 'gawk'
brew 'gettext'
brew 'gh'
brew 'git'
brew 'glab'
brew 'gnu-tar'
brew 'gnupg'
brew 'golang', link: true
brew 'golangci-lint'
brew 'gpatch'
brew 'grep'
brew 'gsed'
brew 'htop'
brew 'httpie'
brew 'java11'
brew 'jq'
brew 'kubectl'
brew 'lazydocker'
brew 'lazygit'
brew 'libpq'
brew 'libtool'
brew 'lynx'
brew 'make'
brew 'mas'
brew 'micro'
brew 'mtr'
brew 'neomutt'
brew 'neovim'
brew 'nmap'
brew 'node', link: true
brew 'nowplaying-cli'
brew 'nvm'
brew 'openssl'
brew 'oven-sh/bun/bun', link: true
brew 'p7zip'
brew 'pnpm'
brew 'procs'
brew 'pygments'
brew 'python', link: true
brew 'rclone'
brew 'reattach-to-user-namespace'
brew 'ripgrep'
brew 'rsync'
brew 'ruby-install'
brew 'ruby', link: true
brew 'rust', link: true
brew 'shared-mime-info'
brew 'shellcheck'
brew 'snyk-cli'
brew 'stripe-cli'
brew 'telnet'
brew 'tmux'
brew 'tty-clock'
brew 'ucon64'
brew 'UltimateNova1203/maxcso/maxcso'
brew 'unar' # Yazi dependency
brew 'universal-ctags'
brew 'unzip'
brew 'urlview'
brew 'vcdimager'
brew 'vim'
brew 'vint'
brew 'wget'
brew 'yarn'
brew 'yazi'
brew 'zip'
brew 'zlib'
brew 'zoxide' # Yazi dependency
brew 'zsh-syntax-highlighting'
brew 'zsh'

# cask 'docker-desktop'
# cask 'microsoft-teams'
# cask 'paragon-extfs'
# cask 'podman-desktop'
# cask 'rancher'
# cask 'visual-studio-code'
# cask 'zoom'
cask '1password'
cask '8bitdo-ultimate-software'
cask 'aldente' if [macbook_retina_12_2017_serial, macbook_pro_13_mid_2012_serial].include?(serial)
cask 'android-studio'
cask 'arc'
cask 'balenaetcher'
cask 'brave-browser'
cask 'burn'
cask 'cleanmymac'
cask 'coconutbattery'
cask 'cursor-cli'
cask 'cursor'
cask 'cyberduck'
cask 'db-browser-for-sqlite'
cask 'dbeaver-community'
cask 'discord'
cask 'displaylink' if /\AApple M[\d]\z/.match?(cpu)
cask 'figma'
cask 'firefox'
cask 'flixtools'
cask 'font-hack-nerd-font'
cask 'font-jetbrains-mono-nerd-font'
cask 'font-monaspice-nerd-font'
cask 'font-noto-sans-symbols-2'
cask 'gitkraken'
cask 'google-chrome'
cask 'grandperspective'
cask 'handbrake-app'
cask 'insomnia'
cask 'istat-menus'
cask 'itau'
cask 'iterm2'
cask 'jdownloader'
cask 'keka'
cask 'kitty'
cask 'lastpass'
cask 'linear-linear'
cask 'maccy'
cask 'maestral'
cask 'mongodb-compass'
cask 'monitorcontrol'
cask 'mx-power-gadget' if architecture == 'arm64'
cask 'nordvpn'
cask 'opencore-patcher' if [macbook_retina_12_2017_serial, macbook_pro_13_mid_2012_serial].include?(serial)
cask 'openlens'
cask 'orbstack'
cask 'paragon-camptune' if architecture == 'x86_64'
cask 'paragon-ntfs' if architecture == 'x86_64'
cask 'parallels'
cask 'postman'
cask 'shottr'
cask 'slack'
cask 'spotify', args: { 'no-quarantine' => true }
cask 'sublime-text'
cask 'textmate'
cask 'transmission'
cask 'tunnelblick'
cask 'virtualbox' if architecture == 'x86_64'
cask 'vlc'
cask 'zed'

# App Store apps
mas 'Xcode', id: 497_799_835
mas 'Amphetamine', id: 937_984_704
mas 'Magnet', id: 441_258_766

# App Store games
mas 'Cyberpunk 2077', id: 6_633_429_424 if architecture == 'arm64' && storage >= 512
mas 'Death Stranding', id: 6_449_748_961 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 2', id: 1_640_632_432 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 3', id: 1_640_630_077 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 4', id: 6_462_360_082 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 7', id: 1_640_629_241 if architecture == 'arm64' && storage >= 512
mas 'Resident Evil 8', id: 1_640_627_334 if architecture == 'arm64' && storage >= 512
mas 'Stray', id: 6_451_498_949 if architecture == 'arm64' && storage >= 512
