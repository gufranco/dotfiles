<div align="center">

<strong>一条命令搭好 macOS 和 Linux 的开发环境：zsh、Vim、tmux 和 54 个工具配置，统一使用 Catppuccin Mocha 配色。</strong>

[English](README.md) | [日本語](README.ja.md) | 简体中文 | [繁體中文 (香港)](README.zh-HK.md)

[![install](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/install.yml?branch=master&style=flat-square&label=install)](https://github.com/gufranco/dotfiles/actions/workflows/install.yml)
[![lint](https://img.shields.io/github/actions/workflow/status/gufranco/dotfiles/lint.yml?branch=master&style=flat-square&label=lint)](https://github.com/gufranco/dotfiles/actions/workflows/lint.yml)
[![release](https://img.shields.io/github/v/release/gufranco/dotfiles?style=flat-square&label=release)](https://github.com/gufranco/dotfiles/releases/latest)
[![license](https://img.shields.io/github/license/gufranco/dotfiles?style=flat-square&label=license)](LICENSE)

</div>

---

这是我的 dotfiles。一个脚本就能把一台全新的 Mac 或 Ubuntu 机器变成我的工作环境：shell、编辑器、终端工具、Docker，在 Linux 上还有一套用来玩游戏的 Steam 环境。安装和链接的所有内容都列在 [REFERENCE.md](REFERENCE.md) 中，以英文写成。

## 准备条件

- macOS，或者 x86_64 或 ARM 上的 Ubuntu。Linux 部分依赖 apt，因此不支持其他发行版。
- Git 和 curl。macOS 自带这两个工具；在 Ubuntu 上运行 `sudo apt install git curl`。
- 一个可以使用 `sudo` 的账户。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/gufranco/dotfiles/master/install.sh | bash
```

[`install.sh`](install.sh) 会把这个仓库克隆到 `~/.dotfiles`，并把每个配置链接到位。在 macOS 上，它会安装 Homebrew 以及 [`Brewfile`](Brewfile) 中的全部内容；在 Ubuntu 上，它使用 apt、snap 和各项目自己的安装程序。每一步都是幂等的，所以中途停止的安装只需再运行一次即可修复。

如果链接目标处已有文件，它会被移到 `<path>.backup.<timestamp>`，绝不会被删除。

然后打开一个新的 shell，确认工具已经就位：

```bash
exec zsh
bat --version
zoxide --version
```

两条命令都会打印版本号。

## 日常使用

```bash
f5                     # update dotfiles, plugins, runtimes and every package
postgres-init          # start PostgreSQL on 127.0.0.1:5432 in Docker through Colima
fde                    # pick a running container with fzf and open a shell in it
git lg                 # colored graph log
gaming-check           # Linux x86_64: verify the Steam and Proton stack
```

需要记住的命令只有 `f5`。它会拉取这个仓库，更新 Vim、Neovim、Zsh 和 Tmux 的插件，升级 mise 的运行时和所有系统软件包，并清理软件包缓存。它只在开始时询问一次密码，结束时放弃 root 权限，所以之后的 `sudo` 会再次询问密码。它自己不输出任何信息，只显示工具自身的输出；只要有步骤失败，就返回 1。它不会动 Docker 和 Colima 虚拟机，所以正在运行的容器不受影响。运行结束后执行 `exec zsh`，即可加载新的 shell 配置。

在 macOS 上，`f5` 会运行 `brew bundle cleanup --force --zap`，卸载所有不在 [`Brewfile`](Brewfile) 中的 formula、cask 和应用。手动安装软件包之前，请先把它加进 Brewfile，否则下一次 `f5` 会把它删除。

## 包含内容

**Shell。** 搭配 Oh My Zsh 和 Spaceship 提示符的 Zsh、fzf 与 fzf-tab、zoxide、atuin 历史记录、direnv，以及管理 Node.js、Python 和 Ruby 的 mise。在 macOS 上，GNU 版本的 coreutils、sed、grep、tar 和 make 排在 `PATH` 的最前面。

**编辑器。** 装有 31 个插件并用 CoC 提供语言支持的 Vim，以及 [`nvim/`](nvim) 中一套基于 lazy.nvim、用 Lua 编写的独立 Neovim 配置。

**Tmux。** 19 个插件，使用 Vim 风格的按键。除 Catppuccin 主题外，全部来自 [tmux-revamped](https://github.com/tmux-revamped) 系列，其中包括会话的保存与恢复。

**Git。** [`git/.gitconfig`](git/.gitconfig) 中的 60 个别名，GPG 签名的提交和标签，以及作为 diff 分页器的 delta。

**Docker。** 由 Colima 运行 Docker，资源按机器的 CPU 和内存分配。`postgres-init`、`mongo-init`、`redis-init`、`valkey-init`、`redict-init` 和 `ubuntu-init` 各自启动一个容器，端口只绑定到 `127.0.0.1`。

**自制工具。** 我编写的六个命令行工具。在 macOS 上通过 [gufranco/tap](https://github.com/gufranco/homebrew-tap) 这个 Homebrew tap 安装，在 Linux 上从源码构建：

- [fusho](https://github.com/gufranco/fusho) 以 GitHub 用户名为收件人，通过任意聊天工具发送加密消息。
- [jimaku](https://github.com/gufranco/jimaku) 为文件夹中的每个视频下载字幕。
- [kakikomi](https://github.com/gufranco/kakikomi) 把磁盘镜像写入软盘、Zip 磁盘、U 盘和硬盘，并逐块校验。
- [kiyome](https://github.com/gufranco/kiyome) 用五种经过校验的模式擦除磁盘。
- [shiwake](https://github.com/gufranco/shiwake) 把文件夹中的文件按 A 到 Z 分到子文件夹中。
- [yakitsuke](https://github.com/gufranco/yakitsuke) 把任意视频转换成 VCD 镜像。

**主题。** 22 个工具使用以 mauve 为强调色的 Catppuccin Mocha，凡有官方移植版的都采用官方版本。

**Linux 游戏。** 在 x86_64 的 Ubuntu 上，安装程序会加入一套仿照 SteamOS 的 Steam 和 Proton 环境，面向配备 NVIDIA 混合显卡的笔记本电脑：带 Prime 显卡切换的 NVIDIA 驱动、XanMod 内核、scx_lavd 调度器、GameMode、MangoHud、Gamescope 和 GE-Proton。首次安装后请重启，然后运行 `gaming-check`。ARM 机器会跳过这一部分。

## 添加配置

把文件放进一个新目录，例如 `myapp/`，然后在 [`install.sh`](install.sh) 中链接它：

```bash
safe_link "$HOME/.dotfiles/myapp" "$HOME/.config/myapp"
```

推送之前，运行 CI 会执行的检查：

```bash
shellcheck install.sh
python3 -m unittest discover -s tests -v
```

## 测试

[install 工作流](.github/workflows/install.yml) 在最新的 Ubuntu LTS 和 Apple Silicon 上的 macOS Tahoe 上各运行两次 `install.sh`，然后检查每个链接，并确认主要命令都在 `PATH` 中。第二次运行用来证明脚本是幂等的。[lint 工作流](.github/workflows/lint.yml) 运行 ShellCheck、shfmt、zsh 语法检查、actionlint、YAML 和 TOML 检查，以及 gitleaks 密钥扫描。

## 限制

- Linux 部分只支持 Ubuntu。
- Linux 游戏需要 x86_64；ARM 上不会安装 NVIDIA 和 Mesa 驱动。
- 这个仓库中的 SSH 和 GPG 私钥属于我，并用我的密码短语加密。在 fork 后使用之前，请删除 [`ssh/`](ssh) 和 `gnupg/keys/`。

## 许可证

[MIT](LICENSE)
