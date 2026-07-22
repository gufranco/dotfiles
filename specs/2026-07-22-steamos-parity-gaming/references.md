# References

Research conducted 2026-07-22 across four areas. Sources below; verify version
thresholds and flags against installed tool versions before implementing
(`gamescope --help`, `ubuntu-drivers devices`, `nvidia-smi`).

## NVIDIA driver / Wayland / DLSS

- NVIDIA open GPU kernel modules transition: https://developer.nvidia.com/blog/nvidia-transitions-fully-towards-open-source-gpu-kernel-modules
- Ubuntu NVIDIA 580 driver: https://ubuntuhandbook.org/index.php/2025/09/ubuntu-added-nvidia-580-driver/
- graphics-drivers PPA: https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa
- Explicit sync on Wayland: https://linuxiac.com/wayland-nvidia-explicit-sync-support/
- Xwayland 24.1: https://www.phoronix.com/news/XWayland-24.1-Released
- Plasma Wayland future: https://blogs.kde.org/2025/11/26/going-all-in-on-a-wayland-future/
- DLSS under Proton (dxvk-nvapi): https://github.com/jp7677/dxvk-nvapi
- GE-Proton DLSS notes: https://www.gamingonlinux.com/2025/12/ge-proton-10-26-released-with-fex-included-improvements-for-dlss-and-game-fixes/
- Shader disk cache skip-cleanup: https://github.com/ValveSoftware/steam-for-linux/issues/11392
- NVIDIA OpenGL env vars: https://us.download.nvidia.com/XFree86/Linux-x86/319.32/README/openglenvvariables.html
- Suspend/resume power management: https://download.nvidia.com/XFree86/Linux-x86_64/435.17/README/powermanagement.html
- DXVK / GPL vs async: https://www.pcgamingwiki.com/wiki/DXVK ; https://www.gamingonlinux.com/2023/01/ge-proton-removes-the-dxvk-async-patch-in-version-7-45/

## SteamOS internals / gamescope / RADV / HDR / VRR

- SteamOS 3 overview: https://rootpages.lukeshort.cloud/latest/unix_distributions/steamos.html
- gamescope: https://github.com/ValveSoftware/gamescope ; https://wiki.archlinux.org/title/Gamescope
- gamescope-session (ChimeraOS): https://github.com/ChimeraOS/gamescope-session ; https://github.com/ChimeraOS/gamescope-session-steam
- Steam Deck kernel tuning: https://botmonster.com/self-hosting/tuning-the-steam-deck-oled-kernel-for-gaming-performance/
- Mesa 26.0 / RADV: https://www.gamingonlinux.com/2026/02/mesa-26-0-is-out-bringing-ray-tracing-performance-improvements-for-amd-radv/ ; https://docs.mesa3d.org/drivers/radv.html
- Mesa envvars: https://docs.mesa3d.org/envvars.html
- Linux HDR guide: https://github.com/DXC-0/Linux-HDR-Guide
- VRR ArchWiki: https://wiki.archlinux.org/title/Variable_refresh_rate
- Proton-CachyOS vs upstream: https://thenets.org/posts/proton-cachyos-vs-upstream-proton/
- MangoHud: https://github.com/flightlessmango/MangoHud ; https://wiki.archlinux.org/title/MangoHud
- vkBasalt: https://github.com/DadSchoorse/vkBasalt

## Kernel / scheduler / memory / I/O

- XanMod: https://xanmod.org/ ; install https://linuxcapable.com/install-xanmod-kernel-on-ubuntu-linux/
- Liquorix: https://liquorix.net/
- CachyOS kernel: https://github.com/CachyOS/linux-cachyos
- sched_ext / scx_lavd: https://sched-ext.com/docs/scheds/rust/scx_lavd ; https://wiki.cachyos.org/configuration/sched-ext/ ; https://www.phoronix.com/news/sched-ext-future-plans-2026
- zram ArchWiki: https://wiki.archlinux.org/title/Zram
- THP madvise vs always: https://www.phoronix.com/review/thp-madvise-always
- zram vs zswap: https://nicholaslyz.com/blog/2025/04/08/zram-vs-zswap/
- gamemode: https://manpages.ubuntu.com/manpages/jammy/man8/gamemoded.8.html
- ananicy rules: https://github.com/CachyOS/ananicy-rules
- I/O scheduler: https://www.phoronix.com/review/linux-56-nvme ; https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_storage_devices/setting-the-disk-scheduler_managing-storage-devices

## Proton / controllers / experience layer

- Gamepad ArchWiki: https://wiki.archlinux.org/title/Gamepad
- xpadneo: https://atar-axis.github.io/xpadneo/
- sc-controller: https://github.com/Ryochan7/sc-controller
- gamescope-session guides: https://github.com/shahnawazshahin/steam-using-gamescope-guide ; https://github.com/Grimish-ng/steam-gamescope-guide
- ProtonUp-Qt / proton-cachyos: https://www.gamingonlinux.com/2025/03/protonup-qt-v2-12-brings-a-new-steam-deck-theme-and-support-for-proton-cachyos/ ; https://wiki.cachyos.org/configuration/gaming/
- Heroic: https://heroicgameslauncher.com ; Lutris: https://lutris.net ; Bottles: https://usebottles.com
- Anti-cheat tracker: https://areweanticheatyet.com/ ; https://github.com/AreWeAntiCheatYet/AreWeAntiCheatYet
- LACT (GPU control): https://github.com/ilya-zlobintsev/LACT
- steamtinkerlaunch: https://github.com/sonic2kk/steamtinkerlaunch
- Steam ROM Manager: https://github.com/SteamGridDB/steam-rom-manager

## Distro alternatives (context, not adopted)

- Bazzite: https://bazzite.gg ; ChimeraOS: https://chimeraos.org ; Nobara: https://nobaraproject.org
- Comparison: https://shattered.io/bazzite-vs-steamos/
