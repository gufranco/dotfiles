<div align="center">

<strong>一条命令搭好 macOS 和 Linux 的开发环境：zsh、Vim、tmux 和 56 个工具配置，统一使用 Catppuccin Mocha 配色。</strong>

<sub>[English](README.md) | [日本語](README.ja.md) | 简体中文 | [繁體中文 (香港)](README.zh-HK.md)</sub>

[![Install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![Lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![License](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square)](LICENSE)

</div>

---

[`Brewfile`](Brewfile) 声明了 231 个 formula、91 个 cask 和 12 个 Mac App Store 应用，23 个工具共用 Catppuccin Mocha 主题，Git 配有 60 个别名。

## 用法

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL 5432 in Docker through Colima
fde                    # fuzzy-pick a running container and open a shell in it
lt                     # tree view of the current directory with eza
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

## 快速开始

### 前提条件

| 工具 | 安装 |
|:-----|:--------|
| macOS 或 Ubuntu | 全新安装的系统即可 |
| Git | macOS 自带；Ubuntu 上运行 `sudo apt install git` |
| curl | 两个系统都自带 |

### 安装

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh) 会检测操作系统和架构。在 macOS 上，它会安装 Homebrew 并执行 Brewfile；在 Linux 上，它使用 apt、snap 和直接下载。

### 验证

```bash
exec zsh
bat --version
zoxide --version
```

两条命令都会输出版本号。如果出现 `command not found`，说明安装中途停止了。每一步都是幂等的，再运行一次 `install.sh` 即可。

## 安装内容

### Shell

| 功能 | 实现 |
|:--------|:---------------|
| Shell | 使用 Oh My Zsh 和 Spaceship 提示符的 Zsh |
| 模糊查找 | 带 bat 预览和 Catppuccin Mocha 配色的 fzf |
| Tab 补全 | fzf-tab |
| 语法高亮 | zsh-syntax-highlighting |
| 智能 cd | 按使用频率和最近访问排序的 zoxide |
| Shell 历史 | 可搜索、可同步的 atuin |
| 按目录设置环境变量 | 在 `cd` 时加载 `.envrc` 的 direnv |
| 运行时 | mise：Node.js LTS、最新的 Python 和 Ruby，项目级覆盖写在 `.mise.toml` 中 |
| macOS 上的 GNU 工具 | coreutils、findutils、grep、sed、tar 和 make 在 PATH 中优先于 BSD 版本 |

### 现代工具替代

每个别名只在对应工具已安装时才会定义，工具缺失时会回退到系统命令：

| 别名 | 工具 |
|:------|:-----|
| `cat` | `bat`，管道输出时为纯文本 |
| `ls` | 带图标、目录优先的 `eza` |
| `lt` | 两层深的 `eza` 树形视图 |
| `top` | `btm` |
| `ping` | `gping`，仅限 macOS |
| `stats` | `tokei`，仅限 macOS |

### 编辑器

使用 vim-plug 管理 31 个插件的 Vim：

| 类别 | 插件 |
|:---------|:--------|
| 语言支持 | coc.nvim, vim-polyglot, vim-matchup, rainbow_csv |
| 导航 | fzf, fzf.vim, vim-sneak, vim-fetch |
| Git | vim-signify, vim-fugitive, conflict-marker.vim |
| 编辑 | vim-surround, vim-visual-multi, vim-pasta, targets.vim, vim-unimpaired, vim-repeat, vim-abolish, splitjoin.vim |
| 文件 | vim-eunuch |
| 界面 | lightline, vim-devicons, undotree, vim-cool, vim-search-pulse, winresizer |
| 主题 | catppuccin/vim，同时驱动配色方案和 lightline |
| 默认设置 | vim-sensible, vim-opinion |
| 集成 | vim-tmux, vim-tmux-navigator |

[`vim/vimrc`](vim/vimrc) 中有 33 行 `Plug`。其中 3 行分别指向同一个 fzf 的 Homebrew、`/usr/local` 和 `~/.fzf` 副本，只会加载机器上实际存在的那一个。

CoC 扩展：TypeScript、ESLint、Prettier、CSS、JSON、Shell、snippets 和 import-cost。

Neovim 在 [`nvim/`](nvim) 中有一套基于 lazy.nvim 的独立 Lua 配置。

### 调试

Python 使用标准库的 `pdb`，并配合功能更丰富的 [`python/.pdbrc`](python/.pdbrc)。别名 `dir`、`attrs`、`vars`、`src` 和 `loc` 可以在提示符下检查对象和局部变量，改编自 Trey Hunner 的 [Customizing pdb with .pdbrc](https://treyhunner.com/2026/04/customizing-pdb-with-pdbrc/)。`breakpoint()` 经由 [`python/debughook.py`](python/debughook.py)，依次优先选用 pdbp、ipdb，最后是标准的 `pdb`，因此在两者都没有安装的 virtualenv 中也能工作。[`python/pythonrc`](python/pythonrc) 是 `PYTHONSTARTUP` 文件，提供持久化的 REPL 历史和美化输出。

Node.js 使用内置的 V8 Inspector。别名 `ni`、`nib` 和 `niw` 运行 `node inspect` 和 `--inspect-brk`，用于在终端和 Chrome DevTools 中调试。`jsr` 从 [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) 打开一个支持深层彩色检查的 REPL。

### 终端复用器

带 19 个插件和 Vim 风格快捷键的 tmux，插件由 tpm 安装：

| 插件 | 作用 |
|:-------|:-------------|
| catppuccin/tmux | 状态栏、窗口列表和窗格样式 |
| tmux-sensible-revamped | 根据 tmux 版本、操作系统和终端调整的默认设置：真彩色、OSC 52 剪贴板、焦点事件 |
| tmux-pain-control-revamped | Vim 风格的窗格拆分、导航、调整大小和窗口移动 |
| tmux-launcher-revamped | 在弹出窗口或新窗口中打开 lazygit、lazydocker 等 TUI |
| tmux-tiling-revamped | 类似 i3 的 BSP 平铺、窗格标记和浮动草稿区 |
| tmux-scroll-revamped | 应用需要滚轮时交给应用，否则进入 copy-mode |
| tmux-reorder-revamped | 在状态栏上拖动窗口标签，标签会滑到指针所在位置 |
| tmux-fzf-revamped | 模糊切换或关闭任意会话、窗口或窗格 |
| tmux-extract-revamped | 从窗格中模糊提取 URL、路径、单词或整行并粘贴 |
| tmux-autoreload-revamped | 配置变化时重新加载 |
| tmux-persist-revamped | 保存会话，并在服务器启动时恢复 |
| tmux-cpu, ram, disk, battery, git, time, music and weather revamped | 状态栏各个分段 |

除 Catppuccin 主题外，所有插件都来自 [tmux-revamped](https://github.com/tmux-revamped) 系列。`tmux-persist-revamped` 取代了 tmux-resurrect 和 tmux-continuum，并且不写任何临时文件。

### Git

[`git/.gitconfig`](git/.gitconfig) 中有 60 个别名，常用的包括：

| 别名 | 命令 |
|:------|:--------|
| `st` | `status -sb` |
| `lg` | 彩色的 `log --graph --decorate` |
| `fork` | `checkout -q -b` |
| `publish` | `push -u origin HEAD` |
| `force` | `push --force-with-lease` |
| `cleanup` | 删除已合并的本地分支，保留 `main`、`master` 和 `develop` |
| `today` | `log --since=midnight --oneline` |
| `sw` | `switch` |

提交和标签默认使用 GPG 签名。Delta 作为 diff 分页器，显示行号和超链接，并使用 Catppuccin Mocha 主题。配置还设置了 histogram diff 算法、`zdiff3` 冲突标记，以及带 autostash 的 pull 时 rebase。

### Docker 服务

Docker 运行在 Colima 中，虚拟机规格根据主机的 CPU 数量和内存决定。在 Apple Silicon 上使用 Apple 的 Virtualization.framework，并通过 Rosetta 2 运行 x86_64 镜像。

| 服务 | 命令 | 端口 |
|:--------|:--------|:-----|
| PostgreSQL | `postgres-init` | 5432 |
| MongoDB | `mongo-init` | 27017 |
| Redis | `redis-init` | 6379 |
| Valkey | `valkey-init` | 7000 |
| Redict | `redict-init` | 6379 |
| Ubuntu | `ubuntu-init` | 无 |

每个服务还有 `-start`、`-stop`、`-purge` 和 `-terminal` 函数，所有端口只绑定到 `127.0.0.1`。`fde`、`fdl` 和 `fds` 用 fzf 选择一个运行中的容器，分别打开 shell、跟踪日志或停止容器。

### 自研工具

同一作者编写的 6 个命令行工具，在 macOS 上通过 [gufranco/tap](https://github.com/gufranco/homebrew-tap) 这个 Homebrew tap 安装。在 Linux 上，[`install.sh`](install.sh) 会安装除 fusho 以外的全部工具。

| 工具 | 作用 |
|:-----|:-------------|
| [fusho](https://github.com/gufranco/fusho) | 以 GitHub 用户名为收件人，通过任意聊天工具发送加密消息 |
| [jimaku](https://github.com/gufranco/jimaku) | 为文件夹中的每个视频下载字幕，保存为 UTF-8，语言由 `JIMAKU_LANGUAGE` 指定 |
| [kakikomi](https://github.com/gufranco/kakikomi) | 将镜像写入软盘、Zip 盘、U 盘和硬盘，逐块校验，从不挂载 |
| [kiyome](https://github.com/gufranco/kiyome) | 用 5 种经过校验的模式擦除磁盘，并指出出错的位线 |
| [shiwake](https://github.com/gufranco/shiwake) | 按首字母把文件夹中的文件分到 A 到 Z 的子文件夹，从不覆盖已有文件 |
| [yakitsuke](https://github.com/gufranco/yakitsuke) | 把任意视频转换为跨多张光盘的 VCD 镜像，并根据每行字幕下方的画面调整字幕样式 |

### Linux 游戏

面向配备 NVIDIA 混合显卡笔记本的 Steam 和 Proton 环境，功能与 SteamOS 看齐。在 `amd64` 的 Ubuntu 上自动安装，在 ARM 上跳过。

| 组件 | 作用 |
|:----------|:-------------|
| 来自 graphics-drivers PPA 的 NVIDIA 驱动 | 最新分支；Turing 及更新的显卡使用开源内核模块，较旧的 MX 芯片使用专有驱动 |
| NVIDIA Prime | 混合显卡切换：集显负责桌面，独显运行游戏 |
| 挂起与恢复加固 | 在笔记本挂起期间保留显存内容 |
| 集显媒体栈 | 根据机器使用 Intel 的 `media-va-driver` 或 AMD 的 `mesa-va-drivers` |
| 来自 oibaf PPA 的 Mesa | 最新的 RADV 和 ANV Vulkan 驱动 |
| Vulkan，64 位和 32 位 | 为两块 GPU 提供完整的 Vulkan 栈 |
| XanMod 内核 | 用于稳定 Proton 帧时间的 fsync 和 winesync，HZ=500，完全抢占 |
| scx_lavd 调度器 | Valve 和 CachyOS 采用的延迟感知 sched_ext 调度器 |
| zram 与 sysctl 调优 | 压缩内存交换，并针对 zram 调整虚拟内存参数 |
| earlyoom | 在系统卡死前结束占用最大的进程，保护 Steam 和 Proton |
| ananicy-cpp | 降低后台进程的优先级，使其不会抢占游戏 |
| GameMode | 游戏运行时切换 CPU 调频策略并提高优先级 |
| MangoHud 和 GOverlay | 带托管配置的 FPS 和帧时间叠加层 |
| vkBasalt | 带托管配置的 CAS 锐化 |
| Gamescope | Valve 的微型合成器，支持 FSR 超分辨率 |
| Steam 和 GE-Proton | 原生 Steam；GE-Proton 自动下载，proton-cachyos 可通过 ProtonUp-Qt 获取 |
| Heroic、Lutris 和 Bottles | 通过 Flatpak 安装的 Epic、GOG、Amazon 等启动器 |
| 手柄驱动 | 来自 steam-launcher 的 udev 规则，以及 Xbox 手柄用的 xpadneo 和 xone DKMS 模块 |
| NVIDIA 着色器缓存环境变量 | 持久且不会被清理的着色器缓存，避免游戏因重新编译而卡顿 |

> [!IMPORTANT]
> 首次安装后请重启，以启动 XanMod 内核并加载 scx_lavd，然后运行 `gaming-check` 检查所有组件。

`gaming-launch-options` 会输出每个游戏推荐的 Steam 启动选项。大多数游戏使用：

```bash
prime-run gamemoderun mangohud %command%
```

这些 GPU 是没有 Tensor 核心和 RT 核心的 GTX 和 MX 型号，因此 DLSS 和硬件光线追踪不适用。提升性能的手段是通过 Gamescope 进行 FSR 超分辨率：以低于原生的分辨率渲染再放大。

在 Steam 中打开「设置」下的「兼容性」，开启「为所有其他产品启用 Steam Play」，然后选择「Proton Experimental」或某个 GE-Proton 版本。「设置」下「下载」中的着色器预缓存保持开启。

`f5` 会保持 GE-Proton 为最新版本，并在内核更新后重新构建手柄的 DKMS 模块。游戏无法运行时，可以在该游戏的兼容性设置中切换到 GE-Proton，查看 [ProtonDB](https://www.protondb.com/)，或运行 `protontricks <appid> --gui` 安装缺失的 Windows 组件。[Are We Anti-Cheat Yet](https://areweanticheatyet.com/) 列出了哪些多人游戏可以在 Proton 下运行。

## Catppuccin Mocha 主题

23 个工具使用 [Catppuccin](https://catppuccin.com) 的 Mocha 风格，强调色为 mauve。如果工具能从路径加载主题，就以 git 子模块的形式引入官方移植；否则从官方移植或调色板直接写进配置：

| 工具 | 方式 |
|:-----|:-------|
| Ghostty | 内置的 `Catppuccin Mocha` 主题 |
| Bat | `catppuccin/bat` 子模块的 tmTheme |
| Delta | `catppuccin/delta` 子模块的 feature |
| Git | `[color]` 段中的 Mocha 十六进制颜色 |
| Vim | `catppuccin/vim` 插件和 lightline |
| Neovim | `catppuccin/nvim` 插件和 lualine |
| Tmux | `catppuccin/tmux` 插件 |
| fzf | 官方的 Mocha `--color` |
| zsh-autosuggestions | 建议文字使用 Mocha 的柔和前景色 |
| eza | 来自 `catppuccin/eza` 的 Mocha mauve [`eza/theme.yml`](eza/theme.yml) |
| ripgrep | [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc) 中的 Mocha 配色 |
| Bottom | 官方的 Mocha `[styles]` |
| K9s | `catppuccin/k9s` 子模块的皮肤 |
| Lazygit | 官方的 Mocha mauve `gui.theme` |
| Lazydocker | 官方的 Mocha mauve 主题 |
| tig | 根据调色板生成的 Mocha 十六进制颜色 |
| broot | [`broot/conf.toml`](broot/conf.toml) 中的 Mocha 皮肤 |
| Midnight Commander | `catppuccin/mc` 子模块的皮肤 |
| NeoMutt | `catppuccin/neomutt` 子模块 |
| Newsboat | [`newsboat/config`](newsboat/config) 中的 Mocha 配色 |
| Taskwarrior | [`taskwarrior/taskrc`](taskwarrior/taskrc) 中的 Mocha 配色 |
| Tealdeer | [`tealdeer/config.toml`](tealdeer/config.toml) 中的 Mocha RGB |
| cmus | cmus 不支持 24 位色，因此 [`cmus/rc`](cmus/rc) 使用最接近的 256 色 Mocha 值 |

GoAccess 没有 Catppuccin 移植，其 HTML 报告只提供亮色和暗色两种内置主题，因此使用暗色。主题子模块跟踪上游的 `main`，由 `f5` 通过 `git submodule update --remote` 更新。

## 系统更新

`f5` 一次运行即可更新全部内容：

1. 拉取 dotfiles 及其子模块
2. 更新 AWS 配置和 Claude 工程规则
3. 更新 Vim 插件、CoC 扩展和 Neovim 插件
4. 更新 Oh My Zsh、Zsh 插件和 Tmux 插件
5. 刷新 tldr 缓存等工具数据
6. 升级 mise 管理的运行时
7. 在 macOS 上：执行 `brew update`、`brew bundle`、会卸载 Brewfile 之外所有内容的 `brew bundle cleanup --force --zap`、`brew upgrade --greedy`，移除从 gufranco/tap 安装的应用的隔离标记，并更新 Mac App Store 应用
8. 在 Linux 上：执行 `apt update`、`apt dist-upgrade` 和 `apt autoremove`，重新构建 xpadneo 和 xone 模块，并更新独立工具、Nerd Fonts、Flatpak 应用和 GE-Proton
9. 安装、升级并清理 [`Uvfile`](Uvfile) 中列出的 uv 工具
10. 回收缓存空间：清理 Homebrew 下载缓存，并修剪 npm、pnpm、yarn、uv 和 Go 的缓存；在 macOS 上还会清除 Xcode 的 `DerivedData`、清理 CocoaPods 缓存并删除不可用的模拟器。Docker 和 Colima 虚拟机磁盘保持不动，正在运行的容器不受影响
11. 重新加载 Tmux 和 Zsh 配置

## 符号链接一览

`install.sh` 使用 `safe_link` 链接所有配置。`safe_link` 是幂等的，会创建父目录，并在链接前把已有的文件或目录移到 `<path>.backup.<timestamp>`。

<details>
<summary><strong>完整的符号链接一览</strong></summary>

| 源 | 目标 |
|:-------|:-------|
| [`zsh/.zshrc`](zsh/.zshrc) | `~/.zshrc` |
| [`git/.gitconfig`](git/.gitconfig) | `~/.gitconfig` |
| [`vim`](vim) | `~/.vim` |
| [`vim/vimrc`](vim/vimrc) | `~/.vimrc` |
| [`nvim`](nvim) | `~/.config/nvim` |
| [`tmux/.tmux.conf`](tmux/.tmux.conf) | `~/.tmux.conf` |
| [`tmux`](tmux) | `~/.tmux` |
| [`ghostty`](ghostty) | `~/.config/ghostty` |
| [`bat/config`](bat/config) | `~/.config/bat/config` |
| `bat/catppuccin/themes` | `~/.config/bat/themes` |
| [`eza`](eza) | `~/.config/eza` |
| [`kanata/kanata.kbd`](kanata/kanata.kbd) | `~/.config/kanata/kanata.kbd` |
| [`mise/config.toml`](mise/config.toml) | `~/.config/mise/config.toml` |
| [`bottom/bottom.toml`](bottom/bottom.toml) | `~/.config/bottom/bottom.toml` |
| [`lazygit/config.yml`](lazygit/config.yml) | `~/.config/lazygit/config.yml` |
| [`lazydocker/config.yml`](lazydocker/config.yml) | `~/.config/lazydocker/config.yml` |
| [`k9s/config.yml`](k9s/config.yml) | `~/.config/k9s/config.yml` |
| `k9s/catppuccin/dist` | `~/.config/k9s/skins` |
| [`tealdeer/config.toml`](tealdeer/config.toml) | `~/.config/tealdeer/config.toml` |
| [`htop/htoprc`](htop/htoprc) | `~/.config/htop/htoprc` |
| [`gh/config.yml`](gh/config.yml) | `~/.config/gh/config.yml` |
| [`gnupg`](gnupg) | `~/.gnupg` |
| `gnupg/gpg-agent-linux.conf` 或 `gnupg/gpg-agent-macos-<arch>.conf` | `~/.gnupg/gpg-agent.conf` |
| [`ssh`](ssh) | `~/.ssh` |
| [`nodejs/.npmrc`](nodejs/.npmrc) | `~/.npmrc` |
| [`nodejs/.yarnrc.yml`](nodejs/.yarnrc.yml) | `~/.yarnrc.yml` |
| [`nodejs/.pnpmrc`](nodejs/.pnpmrc) | `~/.pnpmrc` |
| [`nodejs/repl-init.mjs`](nodejs/repl-init.mjs) | `~/.config/node/repl-init.mjs` |
| [`clang-tidy/.clang-tidy`](clang-tidy/.clang-tidy) | `~/.clang-tidy` |
| [`golangci/golangci.yml`](golangci/golangci.yml) | `~/.golangci.yml` |
| [`ruff/ruff.toml`](ruff/ruff.toml) | `~/.config/ruff/ruff.toml` |
| [`rubocop/config.yml`](rubocop/config.yml) | `~/.config/rubocop/config.yml` |
| [`luacheck/luacheckrc`](luacheck/luacheckrc) | `~/.config/luacheck/.luacheckrc` |
| [`dart/analysis_options.yaml`](dart/analysis_options.yaml) | `~/analysis_options.yaml` |
| [`python/.pdbrc`](python/.pdbrc) | `~/.pdbrc` |
| [`python/pythonrc`](python/pythonrc) | `~/.pythonrc` |
| [`python/debughook.py`](python/debughook.py) | `~/.config/python/debughook.py` |
| [`mutt/.muttrc`](mutt/.muttrc) | `~/.muttrc` |
| [`mutt`](mutt) | `~/.mutt` |
| [`mailcap/.mailcap`](mailcap/.mailcap) | `~/.mailcap` |
| [`curl/.curlrc`](curl/.curlrc) | `~/.curlrc` |
| [`wget/.wgetrc`](wget/.wgetrc) | `~/.wgetrc` |
| [`readline/.inputrc`](readline/.inputrc) | `~/.inputrc` |
| [`ripgrep/.ripgreprc`](ripgrep/.ripgreprc) | `~/.ripgreprc` |
| [`fd/.fdrc`](fd/.fdrc) | `~/.fdrc` |
| [`telnet/.telnetrc`](telnet/.telnetrc) | `~/.telnetrc` |
| [`cmus/rc`](cmus/rc) | `~/.config/cmus/rc` |
| [`mc/ini`](mc/ini) | `~/.config/mc/ini` |
| `mc/catppuccin/catppuccin.ini` | `~/.local/share/mc/skins/catppuccin.ini` |
| [`atuin/config.toml`](atuin/config.toml) | `~/.config/atuin/config.toml` |
| [`direnv/direnv.toml`](direnv/direnv.toml) | `~/.config/direnv/direnv.toml` |
| [`direnv/direnvrc`](direnv/direnvrc) | `~/.config/direnv/direnvrc` |
| [`thefuck/settings.py`](thefuck/settings.py) | `~/.config/thefuck/settings.py` |
| [`tig/config`](tig/config) | `~/.config/tig/config` |
| [`broot/conf.toml`](broot/conf.toml) | `~/.config/broot/conf.toml` |
| [`ranger/rc.conf`](ranger/rc.conf) | `~/.config/ranger/rc.conf` |
| [`ranger/rifle.conf`](ranger/rifle.conf) | `~/.config/ranger/rifle.conf` |
| [`ranger/scope.sh`](ranger/scope.sh) | `~/.config/ranger/scope.sh` |
| [`newsboat/config`](newsboat/config) | `~/.config/newsboat/config` |
| [`newsboat/urls`](newsboat/urls) | `~/.config/newsboat/urls` |
| [`navi/config.yaml`](navi/config.yaml) | `~/.config/navi/config.yaml` |
| [`navi/cheats`](navi/cheats) | `~/.config/navi/cheats` |
| [`asciinema/config.toml`](asciinema/config.toml) | `~/.config/asciinema/config.toml` |
| [`goaccess/goaccess.conf`](goaccess/goaccess.conf) | `~/.config/goaccess/goaccess.conf` |
| [`taskwarrior/taskrc`](taskwarrior/taskrc) | `~/.taskrc` |
| [`opencode/opencode.json`](opencode/opencode.json) | `~/.config/opencode/opencode.json` |
| [`conky/.conkyrc`](conky/.conkyrc) | `~/.conkyrc`，仅限 Linux |
| [`gamemode/gamemode.ini`](gamemode/gamemode.ini) | `~/.config/gamemode.ini`，Linux 游戏 |
| [`mangohud/MangoHud.conf`](mangohud/MangoHud.conf) | `~/.config/MangoHud/MangoHud.conf`，Linux 游戏 |
| [`vkbasalt/vkBasalt.conf`](vkbasalt/vkBasalt.conf) | `~/.config/vkBasalt/vkBasalt.conf`，Linux 游戏 |
| [`nvidia/99-gaming-nvidia.conf`](nvidia/99-gaming-nvidia.conf) | `~/.config/environment.d/99-gaming-nvidia.conf`，Linux 游戏 |

在 macOS 上，lazygit、lazydocker、k9s 和 Ghostty 还会在 `~/Library/Application Support/` 下创建链接。

[`glab/config.yml`](glab/config.yml) 在首次安装时会被复制而不是链接到 `~/.config/glab-cli/config.yml`，因为 `glab auth login` 会把令牌写进这个文件。

</details>

<details>
<summary><strong>项目结构</strong></summary>

| 路径 | 内容 |
|:-----|:---------|
| [`asciinema/`](asciinema) | Asciinema 终端录制工具 |
| [`atuin/`](atuin) | Atuin shell 历史 |
| [`bat/`](bat) | Bat 配置和 Catppuccin Mocha 主题 |
| [`bottom/`](bottom) | Bottom 系统监视器 |
| [`broot/`](broot) | Broot 文件管理器 |
| [`clang-tidy/`](clang-tidy) | clang-tidy 默认设置，以及 C 和 C++ 的不可变性检查 |
| [`cmus/`](cmus) | cmus 音乐播放器 |
| [`conky/`](conky) | Conky 系统监视器，Linux |
| [`curl/`](curl) | curl |
| [`dart/`](dart) | 包含不可变性 lint 的 Dart 分析器默认设置 |
| [`direnv/`](direnv) | direnv |
| [`eza/`](eza) | eza 及其 Catppuccin Mocha 主题 |
| [`fd/`](fd) | fd |
| [`gamemode/`](gamemode) | GameMode 的 CPU 调频策略和优先级调整，Linux 游戏 |
| [`gh/`](gh) | GitHub CLI |
| [`ghostty/`](ghostty) | Ghostty 终端 |
| [`git/`](git) | Git 配置、提交信息模板和 60 个别名 |
| [`glab/`](glab) | GitLab CLI |
| [`gnupg/`](gnupg) | GPG 配置和密钥 |
| [`goaccess/`](goaccess) | GoAccess Web 日志分析器 |
| [`golangci/`](golangci) | golangci-lint 标准检查器，以及 Go 的不可变性检查器 |
| [`htop/`](htop) | htop |
| [`k9s/`](k9s) | K9s Kubernetes 仪表盘及其 Catppuccin Mocha 皮肤 |
| [`kanata/`](kanata) | Kanata 键盘重映射工具 |
| [`lazydocker/`](lazydocker) | Lazydocker |
| [`lazygit/`](lazygit) | Lazygit |
| [`luacheck/`](luacheck) | 禁止 Lua 隐式全局变量的 luacheck 默认设置 |
| [`mailcap/`](mailcap) | Mailcap |
| [`mangohud/`](mangohud) | MangoHud 叠加层，Linux 游戏 |
| [`mc/`](mc) | Midnight Commander 及其 Catppuccin Mocha 皮肤 |
| [`mise/`](mise) | mise 运行时管理器 |
| [`mutt/`](mutt) | NeoMutt 邮件客户端及其 Catppuccin Mocha 主题 |
| [`navi/`](navi) | Navi 速查表管理器和自定义速查表 |
| [`newsboat/`](newsboat) | Newsboat RSS 阅读器 |
| [`nodejs/`](nodejs) | npm、yarn 和 pnpm 配置，以及 GPG 加密的令牌 |
| [`nvidia/`](nvidia) | NVIDIA 的 Xorg 和着色器缓存附加配置，Linux 游戏 |
| [`nvim/`](nvim) | Neovim，基于 lazy.nvim 的独立 Lua 配置 |
| [`opencode/`](opencode) | OpenCode |
| [`python/`](python) | pdb 配置、`PYTHONSTARTUP` 和 `breakpoint()` 钩子 |
| [`ranger/`](ranger) | Ranger 文件管理器 |
| [`readline/`](readline) | Readline |
| [`ripgrep/`](ripgrep) | ripgrep |
| [`rubocop/`](rubocop) | RuboCop 默认设置和不可变性 cop |
| [`ruff/`](ruff) | Ruff 默认设置和不可变性规则 |
| [`specs/`](specs) | 行为规格和设计记录 |
| [`ssh/`](ssh) | SSH 配置和密钥 |
| [`taskwarrior/`](taskwarrior) | Taskwarrior 任务管理器 |
| [`tealdeer/`](tealdeer) | tldr 客户端 Tealdeer |
| [`telnet/`](telnet) | Telnet |
| [`tests/`](tests) | 调试钩子和 REPL 启动文件的 Python 单元测试 |
| [`thefuck/`](thefuck) | thefuck 命令纠正工具 |
| [`tig/`](tig) | Git 的 TUI 工具 tig |
| [`tmux/`](tmux) | tmux 配置和 19 个插件 |
| [`tmuxp/`](tmuxp) | tmuxp 会话布局 |
| [`vim/`](vim) | Vim 配置和 31 个插件 |
| [`vkbasalt/`](vkbasalt) | vkBasalt CAS 锐化 |
| [`wget/`](wget) | Wget |
| [`zsh/`](zsh) | Zsh：[`config/`](zsh/config) 存放按加载顺序排列的 shell 配置，[`modules/`](zsh/modules) 存放命令 |
| [`Brewfile`](Brewfile) | Homebrew 的 formula、cask、字体和 Mac App Store 应用 |
| [`Uvfile`](Uvfile) | 用 uv 安装的命令行工具 |
| [`install.sh`](install.sh) | 跨平台安装程序 |

</details>

## 添加配置

1. 创建一个目录，例如 `myapp/`，把配置文件放进去。
2. 在 [`install.sh`](install.sh) 中添加链接：

   ```bash
   safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
   ```

3. 运行与 CI 相同的检查：

   ```bash
   shellcheck install.sh
   python3 -m unittest discover -s tests -v
   ```

[lint 工作流](.github/workflows/lint.yml) 还会运行 shfmt、zsh 语法检查、actionlint、YAML 和 TOML 检查，以及 gitleaks 密钥扫描。[安装工作流](.github/workflows/install.yml) 在 Ubuntu 和 macOS 上各运行两次 `install.sh`，以证明它是幂等的。

## 安全

[`ssh/`](ssh) 和 `gnupg/keys/` 中的 SSH 与 GPG 私钥纳入了版本控制，每个都有口令保护。其他凭据通过 [`.gitignore`](.gitignore) 排除。API 令牌以 GPG 加密文件的形式保存，在 shell 启动时解密并缓存。

GnuPG 在验证签名时从不从网络获取密钥。自动获取会让第三方知道正在阅读哪些消息，因此密钥通过 `gpg --recv-keys` 显式获取。

### 邮件签名

外发邮件默认签名，签名以内联方式写在正文中，而不是附加 `signature.asc`。保存的草稿会被加密，因此加密消息的草稿永远不会以明文形式存放在邮件服务器上。

内联签名需要 NeoMutt 的经典 PGP 后端，因为 GPGME 后端无法生成内联消息。两种后端都已配置，[`mutt/.muttrc`](mutt/.muttrc) 中 Crypto 段开头的一行决定使用哪一个：

| 设置 | 后端 | 加载的配置 |
|:--------|:--------|:----------------|
| `set my_pgp_inline = yes` | 经典 PGP，内联签名 | [`mutt/crypto/inline.muttrc`](mutt/crypto/inline.muttrc) |
| 注释掉这一行 | GPGME，带受保护标头的 PGP/MIME | [`mutt/crypto/gpgme.muttrc`](mutt/crypto/gpgme.muttrc) |

切换后端需要重启 NeoMutt，因为交互式设置 `crypt_use_gpgme` 不会生效。

经典后端只按名称调用 `pgpewrap` 来展开多个收件人。`pgpewrap` 位于 NeoMutt 的 `libexec` 目录中，[`zsh/config/paths`](zsh/config/paths) 会在 Linux 和 macOS 上把该目录加入 `PATH`。

账户应用的每个设置在 [`mutt/normalize.muttrc`](mutt/normalize.muttrc) 中都有对应的 `reset`，切换账户时会先运行它。如果在账户文件中添加了设置却没有对应的 reset，这个设置会泄漏到下一个账户。

## 许可证

自 2014 年起采用 [MIT](LICENSE) 许可证。
