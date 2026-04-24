#!/usr/bin/env bash
set -euo pipefail

errors=0

check_pkg() {
  local pkg="$1"
  if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
    echo "OK: $pkg (dpkg)"
  else
    echo "FAIL: $pkg not installed"
    errors=$((errors + 1))
  fi
}

check_file() {
  local path="$1" label="$2"
  if [ -f "$path" ]; then
    echo "OK: $label ($path)"
  else
    echo "FAIL: $label not found ($path)"
    errors=$((errors + 1))
  fi
}

# i386 architecture enabled
if dpkg --print-foreign-architectures | grep -q i386; then
  echo "OK: i386 architecture enabled"
else
  echo "FAIL: i386 architecture not enabled"
  errors=$((errors + 1))
fi

# Vulkan packages (64-bit)
check_pkg vulkan-tools
check_pkg libvulkan1
check_pkg mesa-vulkan-drivers

# Vulkan packages (32-bit)
check_pkg "libvulkan1:i386"
check_pkg "mesa-vulkan-drivers:i386"
check_pkg "libgl1-mesa-dri:i386"

# Gaming kernel parameters
check_file /etc/sysctl.d/99-gaming.conf "Gaming sysctl config"

# Gaming file descriptor limits
check_file /etc/security/limits.d/99-gaming.conf "Gaming limits config"

# Controller support
check_pkg steam-devices

# Gaming performance tools
check_pkg gamemode
check_pkg "libgamemodeauto0:i386"
check_pkg mangohud
check_pkg gamescope
check_pkg protontricks

# Steam
check_pkg steam-launcher

# GE-Proton directory
GE_DIR="$HOME/.steam/steam/compatibilitytools.d"
if [ -d "$GE_DIR" ] && [ -n "$(ls -A "$GE_DIR" 2>/dev/null)" ]; then
  echo "OK: GE-Proton directory populated ($GE_DIR)"
else
  echo "FAIL: GE-Proton directory empty or missing ($GE_DIR)"
  errors=$((errors + 1))
fi

exit $errors
