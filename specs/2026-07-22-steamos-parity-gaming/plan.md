# SteamOS-Parity Linux Gaming Plan

## Intent

Bring the Steam gaming experience on both Linux laptops as close to SteamOS as
possible: performance, frame-time stability, latency, and console-like UX. This
plan evolves the existing gaming stack from `specs/2026-04-11-linux-gaming-setup`,
it does not replace it.

## Target hardware and OS

Two hybrid laptops, both gaming on an NVIDIA dGPU via PRIME offload:

| Machine | CPU / iGPU | dGPU | Arch | iGPU Vulkan/VA path |
|---------|-----------|------|------|---------------------|
| A | Intel + iGPU | GeForce MX | Pascal or Turing (detect) | ANV + intel-media-va-driver |
| B | AMD Ryzen APU | GeForce GTX 1650 Ti (mobile) | Turing (TU117) | RADV + Mesa VA-API |

OS: Ubuntu 26.04, GNOME (Wayland) by default. Ambition: aggressive (custom
kernel, boot-to-gamescope session, zram, scheduler, VRR where the panel
allows).

### GPU capability tier drives the tuning philosophy

Both dGPUs are entry-level ~4GB-VRAM mobile parts, and both are **GTX/MX, not
RTX**: no tensor cores, no RT cores. Concrete consequences for this plan:

- **DLSS and hardware ray tracing do not apply.** The upscaler that matters here
  is **FSR** (spatial, software) via gamescope `-F fsr`, plus frame limiting.
- **HDR is effectively out of scope**: these panels are almost certainly SDR,
  and even on an HDR panel these GPUs are too weak to spend the budget. VRR
  stays in scope only if the panel advertises it.
- The **highest relative payoff is the CPU-side work** (kernel/fsync,
  scheduler, zram, gamemode, shader cache, earlyoom) plus FSR upscaling and a
  frame cap. On weak GPUs, frame-time stability and latency are where "feels
  like SteamOS" is won, not raw settings.
- 4GB VRAM means texture/setting discipline and render-below-native + FSR
  upscale are the norm; the plan optimizes for that, not for maxed visuals.

## Parity expectation, stated up front

SteamOS is AMD-native. On these NVIDIA-hybrid laptops the following transfer
fully: frame pacing, latency tuning, kernel/scheduler/memory tuning, controller
parity, Proton/shader pipeline, boot-to-Big-Picture, and VRR. HDR is the one
area that is less turnkey on NVIDIA and depends on the laptop panel; the plan
enables it where the display and Wayland stack support it, but does not promise
SteamOS-grade HDR parity. This is a hardware reality, not a config gap.

## Baseline audit: what already exists (keep)

From `install.sh` and `zsh/gaming`, already in place and correct:

- 32-bit (i386) arch, Steam from Valve repo, GE-Proton auto-updated via `f5`.
- NVIDIA drivers (via `ubuntu-drivers`), nvidia-prime, Nouveau blacklist,
  `nvidia-drm.modeset=1`, `NVreg_DynamicPowerManagement=0x02`.
- Mesa via oibaf PPA; Vulkan 64/32-bit.
- `gamemode`, `mangohud`, `gamescope`, `protontricks`, ProtonUp-Qt.
- `/etc/sysctl.d/99-gaming.conf` (max_map_count, swappiness=10,
  compaction_proactiveness=0, dirty_ratio 5/5, split_lock_mitigate=0).
- `/etc/security/limits.d/99-gaming.conf` (nofile 1048576), `input` group.
- `gaming-check` and `gaming-launch-options` helpers.

## Corrections to existing config (do these regardless of the rest)

These are defects or now-outdated choices in the current stack:

1. **`gaming-launch-options` recommends `DXVK_ASYNC=1`.** Obsolete and wrong on
   modern drivers. DXVK 2.x uses `VK_EXT_graphics_pipeline_library` (GPL);
   GE-Proton removed the async patch in 7-45. Remove the async line, replace
   with the GPL-based guidance in Phase 5.
2. **Driver is proprietary via `ubuntu-drivers autoinstall`.** On Turing+ GPUs
   (RTX 20 / GTX 16 series and newer) NVIDIA now recommends the **open** kernel
   modules. Move to `nvidia-driver-580-open`. Fallback to proprietary only for
   pre-Turing (see Phase 1).
3. **Suspend/resume hardening missing.** Add
   `NVreg_PreserveVideoMemoryAllocations=1` and enable the nvidia
   suspend/resume/hibernate systemd units. Laptops suspend constantly; this
   prevents VRAM corruption on resume.
4. **`swappiness=10` is wrong once zram is added.** With zram the correct value
   is `180`. The swappiness change and the zram unit must land in the same
   change (coupled), never separately.

## Phased plan (impact-ranked within each phase)

### Phase 1 - GPU drivers, per-machine iGPU, Wayland

**1a. NVIDIA open driver 580.**
- Add `ppa:graphics-drivers/ppa`.
- Detect GPU generation; install `nvidia-driver-580-open` on Turing+, else
  `nvidia-driver-580` (proprietary). Detection: `ubuntu-drivers devices` +
  a codename check against `lspci`.
- Keep DKMS/apt-managed. Never the `.run` installer.
- **Per-machine reality:** the GTX 1650 Ti (Turing) takes `-open`. The MX takes
  `-open` only if it is MX450/550 (Turing); MX150/250/350 are Pascal and must
  use proprietary `nvidia-driver-580`. Note that branch 580 is the **terminal**
  driver branch for Pascal, so an MX-Pascal machine is pinned to 580 and will
  not move to future branches. The detection must not force `-open`.

**1b. Suspend/resume + power (add to `/etc/modprobe.d/nvidia-power.conf`).**
```
options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
```
Enable `nvidia-suspend.service`, `nvidia-hibernate.service`,
`nvidia-resume.service`. Ensure `/var/tmp` has free space.

**1c. Per-machine iGPU branch in `install.sh`.**
- Detect iGPU vendor (`lspci | grep -E 'VGA|3D'`).
- Intel branch: `intel-media-va-driver-non-free`, `intel-gpu-tools`, `vainfo`.
- AMD branch: `libva2`, `mesa-va-drivers`, `vainfo` (RADV already covered by
  Mesa). No AMD dGPU tools needed; the AMD part is only the APU.
- Shared: keep the NVIDIA dGPU path identical on both.

**1d. Mesa channel: keep oibaf (decided, D8).** Stay on the existing
`ppa:oibaf/graphics-drivers`. No change to the current Mesa setup. Covers both
Intel ANV and AMD RADV plus the 32-bit Vulkan libs already installed.

**1e. Wayland + explicit sync.** With driver 580 + Xwayland 24.1+ + Mutter 48
(Ubuntu 26.04), explicit sync is active by default; no action beyond staying on
Wayland. Flag: verify `nvidia-drm.modeset=1` remains (it does). Note KDE Plasma
6 has the most mature gaming Wayland (VRR/HDR); a "consider Kubuntu/KDE for the
gaming machine" note lives in Phase 10, not mandated.

### Phase 2 - Kernel and scheduler

**2a. XanMod kernel (MAIN, x64v3) [decided, D10].** Brings fsync/futex2/winesync
(the real Proton frame-time win), HZ=500, full preempt, MGLRU. Install via
official XanMod apt repo; `linux-xanmod-x64v3` (verify psABI with
`/usr/bin/x86-64-level`, both CPUs are v3-capable). Keep the stock Ubuntu kernel
installed as GRUB fallback. This is what enables scx_lavd in 2b.

**2b. sched_ext + scx_lavd.** `scx_lavd` is what Valve ships on the Deck and is
what CachyOS ships as its default scheduler; it is the closest thing to
"SteamOS smoothness." Install `scx-scheds`, then enable it as the default
scheduler via its systemd service (`/etc/default/scx` -> `SCX_SCHEDULER=scx_lavd`,
`systemctl enable --now scx`). scx_lavd is latency-aware and safe as a system
default; sched_ext auto-reverts to EEVDF if the BPF scheduler ever fails to
load, so there is no boot risk. See decisions.md D12 for why this replaces the
per-game gamemode hook.

### Phase 3 - Memory and I/O

**3a. zram via `systemd-zram-generator`.** `/etc/systemd/zram-generator.conf`:
```
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
```
**3b. Rewrite `/etc/sysctl.d/99-gaming.conf` to zram-aware values (coupled with
3a):**
```
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 134217728
vm.min_free_kbytes = 262144
vm.max_map_count = 2147483642
vm.compaction_proactiveness = 0
kernel.split_lock_mitigate = 0
```
(Replaces the old `dirty_ratio`/`swappiness=10` values. `max_map_count`,
`compaction_proactiveness`, `split_lock_mitigate` carried over.)

**3c. earlyoom, replacing systemd-oomd.** Prevents multi-second freezes under
memory pressure by killing the biggest offender fast. Configure to protect
`steam|gamescope|wine.*` and prefer browsers as victims. Disable systemd-oomd.

**3d. ananicy-cpp + CachyOS rules.** Auto-nices background processes down so
compilers/browsers do not preempt the game.

**3e. THP = madvise.** Already the Ubuntu default; verify only, do not force
`always`.

**3f. I/O scheduler udev rule.** `none` for NVMe, `mq-deadline` for SATA SSD.
Low impact (NVMe already defaults to none) but correct and harmless.

### Phase 4 - CPU governor and latency (gamemode config)

Add a dotfiles-managed `gamemode/gamemode.ini` symlinked to
`~/.config/gamemode.ini` (user-level, no sudo, and gamemode reads it):
```ini
[general]
desiredgov=performance
defaultgov=schedutil
renice=10
ioprio=0
softrealtime=auto
inhibit_screensaver=1
```
gamemode flips the CPU governor to performance on launch and reverts to
schedutil on exit, so the governor is left at `schedutil` system-wide (do not
force performance globally on laptops, it wastes battery and heat). The
`[gpu]` section is intentionally omitted: gamemode's GPU tuning targets one
fixed device and misbehaves under PRIME offload on NVIDIA hybrid, where the
dGPU clocks are already managed by the driver's dynamic power management. scx is
handled by its own service (2b), not a `[custom]` hook, per D12.

### Phase 5 - Proton, shaders, launch options

**5a. Add proton-cachyos** alongside GE-Proton via ProtonUp-Qt (curated
Experimental + FSR4/DLSS DLL upgrades). Keep Valve Proton as baseline, GE and
CachyOS as per-title fallbacks.

**5b. Shader pipeline.** Keep Steam shader pre-caching + background Vulkan
processing enabled. Rely on GPL (in Proton-Experimental/cachyos) instead of the
removed async patch. Persistent NVIDIA shader cache env (5d).

**5c. Rewrite `gaming-launch-options`.** Reframed for GTX/MX (no DLSS/RT on this
hardware). New recommended lines:
- Standard: `prime-run gamemoderun mangohud %command%`
- **FSR upscale + frame cap (the key lever on these GPUs)**: render below native
  and let gamescope upscale:
  `prime-run gamescope -W <native_w> -H <native_h> -w <render_w> -h <render_h> -F fsr --sharpness 5 -r <fps_cap> --adaptive-sync --mangoapp -- gamemoderun %command%`
- vkBasalt CAS sharpening (alternative to FSR sharpen): `ENABLE_VKBASALT=1 %command%`
- Debug: `prime-run PROTON_LOG=1 gamemoderun %command%`
- **DLSS lines removed** as N/A (no tensor cores). Keep one commented reference
  noting DLSS/`PROTON_ENABLE_NVAPI=1` only matters if an RTX card is added
  later.
- Remove every `DXVK_ASYNC` reference.

**5d. NVIDIA shader-cache env block.** Managed file `nvidia/99-gaming-nvidia.conf`
symlinked to `~/.config/environment.d/99-gaming-nvidia.conf` (systemd user
environment, which reliably reaches Wayland GUI apps including Steam, unlike a
`profile.d` drop-in):
```
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
__GL_SHADER_DISK_CACHE_PATH=${HOME}/.cache/nv
__GL_THREADED_OPTIMIZATIONS=1
__GL_MaxFramesAllowed=1
```
`SKIP_CLEANUP` is the single highest-impact anti-stutter setting on NVIDIA
(stops the driver pruning the cache and forcing recompiles). These only take
effect on the dGPU (PRIME offload); the iGPU desktop is unaffected.

### Phase 6 - Controllers (highest UX-parity win, do early)

- **`steam-devices`** (Valve udev rules): the single biggest "controller works
  outside Steam" fix. Add to `install.sh`.
- **DualSense/DS4**: native `hid-playstation`, no driver. Optional
  `dualsensectl` for LEDs/adaptive triggers off-Steam.
- **Xbox**: `xpadneo` (Bluetooth, DKMS) + `xone` (Xbox dongle/wired, DKMS).
  Both via DKMS so `f5` can rebuild on kernel bumps.
- **sc-controller** for gyro/mapping in non-Steam apps (openSUSE Build Service
  .deb; not in Ubuntu repos).
- User already in `input` group (keep).

### Phase 7 - Overlays and GPU tooling (dotfiles-managed configs)

- Packages: `vkbasalt vkbasalt:i386 goverlay`.
- **MangoHud config**: add `mangohud/MangoHud.conf`, symlink to
  `~/.config/MangoHud/MangoHud.conf` (fps, frametime graph, gpu/cpu temp+load,
  vram, toggle key). Use `--mangoapp` with gamescope, `mangohud` standalone.
- **vkBasalt config**: add `vkbasalt/vkBasalt.conf` (CAS sharpening 0.4, toggle
  Home), symlink to `~/.config/vkBasalt/vkBasalt.conf`.
- **GPU control**: LACT (systemd daemon, modern NVIDIA/AMD fan/power/undervolt)
  preferred over GreenWithEnvy. Optional.
- Optional: `steamtinkerlaunch` for per-game toggles without editing launch
  options.

### Phase 8 - Non-Steam library (keeps the console feel)

- **Heroic** (flatpak): Epic/GOG/Amazon, "Add to Steam" per game.
- **Lutris** (flatpak): Battle.net/EA/Ubisoft/emulators.
- **Bottles** (flatpak): isolated Windows-app prefixes.
- **SteamGridDB / Steam ROM Manager**: artwork so non-Steam entries look native
  in Big Picture.
- All optional, installed via existing flatpak flow in `f5`.

### Phase 9 - Boot-to-gamescope Steam session ("SteamOS mode") [SKIPPED, D11]

Not doing this. Decided to skip the SteamOS-mode login session; it is the most
fragile piece on NVIDIA hybrid and the login path stays untouched. Steam Big
Picture is launched manually instead (`steam -gamepadui`, or the Steam menu).
All perf/latency/controller work still applies without it.

If revisited later: ChimeraOS `gamescope-session` + SDDM Wayland session entry,
gated behind a `DOTFILES_GAMESCOPE_SESSION=1` opt-in flag. Left documented in
`references.md` only.

### Phase 10 - VRR (HDR de-scoped for this hardware)

- **VRR**: add `--adaptive-sync` to gamescope launch lines. On GNOME Wayland,
  enable experimental VRR via gsettings; on KDE it is a first-class Display
  setting. Only worthwhile if the laptop panel advertises VRR/adaptive-sync,
  many entry laptop panels do not. Verify per-machine before wiring it in.
- **HDR: de-scoped.** These are SDR laptop panels driven by entry GTX/MX GPUs;
  HDR is neither available nor worth the GPU budget. Skip `--hdr-enabled`
  entirely. Revisit only if a machine is later paired with an HDR display and a
  stronger GPU.
- **KDE consideration (not mandated)**: Plasma 6 has the most mature Linux VRR.
  Marginal benefit here given weak panels; keep GNOME unless VRR on GNOME proves
  troublesome. Recorded as an open decision, not an action.

### Phase 11 - dotfiles integration and verification

- **install.sh**: per-machine iGPU branch; nvidia-open detection; new PPAs
  (graphics-drivers, kisak, XanMod); packages (scx-scheds, earlyoom,
  ananicy-cpp, zram-generator, steam-devices, vkbasalt, goverlay,
  intel/amd VA drivers); DKMS controller drivers; symlinks for
  gamemode.ini / MangoHud.conf / vkBasalt.conf / shader-cache profile.d;
  rewrite of the gaming sysctl; nvidia suspend units.
- **New managed config files** (single source of truth, symlinked):
  `gamemode/gamemode.ini`, `mangohud/MangoHud.conf`, `vkbasalt/vkBasalt.conf`,
  `nvidia/99-gaming-nvidia.conf` (environment.d env). `/etc/default/scx` and the
  gaming sysctl are written inline via `sudo tee` (root-owned, like limits.d).
- **`zsh/f5`**: add `__f5_update_gaming_dkms` (DKMS rebuild for xpadneo/xone on
  kernel change) called in the Linux branch. XanMod and ananicy updates are
  handled by the existing apt upgrade in `__f5_update_linux`. Keep the strict
  `__log_info` header / silent work / single-summary pattern.
- **`gaming-check`**: extend to verify zram active, scx available, earlyoom
  running, steam-devices rules present, driver is `-open`, suspend units
  enabled, gamemode.ini linked.
- **`.github/scripts/verify-gaming.sh`**: add the new packages/files so CI drift
  check covers them.
- **`README.md` + spec close-out**: update the Linux Gaming section to document
  the new gaming surface; archive this spec per living-specs on completion.

## Anti-cheat reality (set expectations, not a task)

EAC/BattlEye have Proton support but per-title, developer-gated. ~55% of tracked
titles with anti-cheat are broken; kernel-level AC (Vanguard) and some
competitive shooters never run. Check every multiplayer purchase on
areweanticheatyet.com. Single-player is near-universal. Nothing in this plan
changes that; it is a hardware/publisher constraint.

## Impact-ranked priority (do in this order for fastest parity)

| Rank | Item | Phase | Effort | Payoff |
|------|------|-------|--------|--------|
| 1 | `steam-devices` + controller drivers | 6 | Low | Huge UX |
| 2 | Fix `gaming-launch-options` (drop DXVK_ASYNC), env block | 5c/5d | Low | Real anti-stutter |
| 3 | nvidia-open 580 + suspend hardening | 1a/1b | Low | Stability |
| 4 | zram + zram-aware sysctl | 3a/3b | Low | Smoothness |
| 5 | gamemode.ini + governor flip | 4 | Low | Latency |
| 6 | XanMod kernel (fsync) | 2a | Med | Frame-time |
| 7 | scx_lavd via gamemode | 2b | Med | Frame pacing |
| 8 | earlyoom + ananicy-cpp | 3c/3d | Low | No freezes |
| 9 | MangoHud/vkBasalt managed configs | 7 | Low | UX |
| 10 | proton-cachyos, shader precache | 5a/5b | Low | Compat |
| 11 | FSR upscale + frame cap launch pattern | 5c | Low | Perf on weak GPU |
| 12 | Heroic/Lutris non-Steam | 8 | Low | Library |
| 13 | VRR (only if panel supports; HDR de-scoped) | 10 | Med | Feel |
| 14 | Per-machine iGPU branch (Intel/AMD) | 1c | Low | Correctness |

Boot-to-gamescope session (old Phase 9) is skipped (D11). Mesa stays oibaf (D8),
GNOME on both (D9). Ranks 1-5 are near-zero-risk, high-return, and land most of
the perceived SteamOS smoothness on this entry-GPU hardware.

## Risk and rollback

- Every kernel/driver change keeps the prior version as a GRUB fallback.
- swappiness/zram coupling: land together or neither.
- gamescope session behind an opt-in env flag; test one machine first.
- All new config is dotfiles-managed and symlinked, so `git revert` + re-run
  `install.sh` fully rolls back.
- CI drift check (`verify-gaming.sh`) gates the integration.

## Decisions (all resolved, see decisions.md)

1. Mesa channel: **keep oibaf** (D8).
2. Desktop: **GNOME on both** (D9); HDR de-scoped so KDE's edge no longer applies.
3. Kernel: **XanMod MAIN x64v3** (D10), stock kept as fallback.
4. Boot-to-gamescope session: **skipped** (D11); Big Picture launched manually.

No blocking decisions remain. Ready to implement.
