# Decisions

## Made

### D1. NVIDIA open kernel modules over proprietary
Both laptops' dGPUs are assumed Turing+ (RTX 20 / GTX 16 or newer). NVIDIA
recommends the open modules on Turing+ since the R560 branch; userspace is
identical, GSP firmware is bundled. Install `nvidia-driver-580-open`. Fallback
to proprietary `nvidia-driver-580` only when generation detection shows
pre-Turing. Rejected: staying on `ubuntu-drivers autoinstall` | it defaults to
proprietary and misses the open recommendation.

### D2. Keep NVIDIA dGPU as the gaming path on both machines
The user games on the NVIDIA dGPU; the iGPU (Intel on A, AMD on B) is the
display/power path only. PRIME offload (`prime-run`) and `nvidia-prime` stay.
Rejected: an AMD-native SteamOS path | neither machine games on the AMD iGPU.

### D3. zram, not zswap; swappiness=180
zram gives predictable compressed RAM with zstd; correct swappiness with zram is
180 (ratio out of 200 since kernel 5.8). Coupled change: the swappiness value
and the zram unit land together. Rejected: zswap | less predictable for
desktop spikes.

### D4. gamemode owns the CPU governor and scx switch
Governor stays `schedutil` system-wide; gamemode flips to performance per-game
and reverts on exit. scx_lavd is activated by gamemode `[custom]` hooks, not
globally. Rationale: laptops, forcing performance globally wastes battery/heat
and scx_lavd system-wide can add desktop micro-stutter. Rejected: global
performance governor | battery and thermals on a laptop.

### D5. DXVK_ASYNC removed
Obsolete on DXVK 2.x; superseded by graphics pipeline library (GPL). GE-Proton
removed the async patch in 7-45. The existing `gaming-launch-options` helper
recommends it and is being corrected.

### D6. earlyoom over systemd-oomd
systemd-oomd acts on whole cgroups and can kill the desktop session on non-GNOME
setups; it reacts slower via PSI. earlyoom kills the single biggest offender
before a multi-second freeze and lets us protect steam/gamescope/wine.

### D7. Boot-to-gamescope session is opt-in, gated by an env flag
Most fragile item on NVIDIA. Gated behind `DOTFILES_GAMESCOPE_SESSION=1` so a
normal `install.sh` run never touches the login path. Test one machine first.

## Resolved (2026-07-22, user)

### D8. Mesa channel: keep oibaf
Stay on the existing oibaf PPA rather than switching to kisak. User accepts the
bleeding-edge tradeoff. No change to the current Mesa setup in `install.sh`.

### D9. Desktop: GNOME on both machines
No desktop change. GNOME Wayland on Ubuntu 26.04 (explicit sync + experimental
VRR). KDE was only compelling for HDR, which is de-scoped on this hardware.

### D10. Kernel: XanMod MAIN x64v3
Install XanMod MAIN, x64v3 edition, keeping the stock Ubuntu kernel as GRUB
fallback. Enables fsync/winesync and scx_lavd.

### D11. Boot-to-gamescope session: skipped
Do not set up the SteamOS-mode login session (Phase 9). Steam Big Picture is
launched manually. The login path stays untouched; all perf/latency work still
applies.

## Implementation deviations (2026-07-22)

### D12. scx_lavd via systemd service, not gamemode [custom] hooks
Original Phase 4 wired scx switching to gamemode `[custom]` start/stop hooks
(`scxctl switch`). In practice scxctl switching is privilege-sensitive and a
failing hook would silently no-op on every launch. Instead enable scx_lavd as
the system default scheduler via the packaged `scx` systemd service
(`/etc/default/scx` -> `SCX_SCHEDULER=scx_lavd`). scx_lavd is latency-aware
(CachyOS ships it as default) and sched_ext auto-reverts to EEVDF on any BPF
load failure, so there is no boot risk. gamemode keeps only the governor flip
and priority tuning. Rejected: per-game scxctl hooks | fragile, silent failure.

### D13. gamemode config is user-level, GPU section omitted
Symlink `gamemode.ini` to `~/.config/gamemode.ini` (no sudo) rather than
`/etc/gamemode.ini`. Omit the `[gpu]` block: gamemode GPU optimisations target
one fixed device and misbehave with PRIME offload on NVIDIA hybrid. dGPU clocks
are handled by the NVIDIA driver's dynamic power management already.

### D14. Uncertain-availability packages are guarded, never fatal
`ananicy-cpp`, `xpadneo`, `xone`, and `scx-scheds` packaging on Ubuntu 26.04
cannot be verified from the authoring environment. install.sh installs them
guarded (apt-cache probe or DKMS-status check) and degrades to a warning if a
package or repo is absent, so a normal run never breaks. `steam-devices`,
`vkbasalt`, `goverlay`, `earlyoom`, `zram`, and the VA drivers are in Ubuntu
repos and installed directly.
