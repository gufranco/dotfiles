#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_media_class() {
  disk_mc_mb=$(($1 / 1024 / 1024))
  if [ "${disk_mc_mb}" -le 3 ]; then
    printf 'floppy\n'
  elif [ "${disk_mc_mb}" -le 260 ]; then
    printf 'zip\n'
  elif [ "${disk_mc_mb}" -le 2048 ]; then
    printf 'small\n'
  elif [ "${disk_mc_mb}" -le 32768 ]; then
    printf 'medium\n'
  else
    printf 'large\n'
  fi
}

disk_partition_node() {
  case "$1" in
    *[0-9]) printf '%sp1\n' "$1" ;;
    *) printf '%s1\n' "$1" ;;
  esac
}

disk_format_floppy() {
  disk_ff_os="$(disk_os)"
  case "${disk_ff_os}" in
    Darwin)
      sudo newfs_msdos -F 12 -v "$2" "$1" >/dev/null 2>&1 && return 0
      ;;
    Linux)
      if ! disk_cmd_exists mkfs.fat; then
        disk_error "mkfs.fat is not installed. Install the dosfstools package."
        return 1
      fi
      sudo mkfs.fat -F 12 -n "$2" "$1" >/dev/null 2>&1 && return 0
      ;;
    *) ;;
  esac
  disk_error "Failed to format floppy"
  return 1
}

disk_format_darwin() {
  disk_fd_fs="MS-DOS $2"
  [ "$2" = "ExFAT" ] && disk_fd_fs="ExFAT"
  if sudo diskutil eraseDisk "${disk_fd_fs}" "$3" MBRFormat "$1" >/dev/null 2>&1; then
    disk_success "Partition created ($2)"
    return 0
  fi
  disk_error "Failed to create partition"
  return 1
}

disk_format_linux() {
  case "$2" in
    FAT16) disk_fl_type="06" disk_fl_tool="mkfs.fat" ;;
    FAT32) disk_fl_type="0b" disk_fl_tool="mkfs.fat" ;;
    *) disk_fl_type="07" disk_fl_tool="mkfs.exfat" ;;
  esac
  if ! disk_cmd_exists sfdisk; then
    disk_error "sfdisk is not installed. Install the fdisk package."
    return 1
  fi
  if ! disk_cmd_exists "${disk_fl_tool}"; then
    disk_error "${disk_fl_tool} is not installed."
    return 1
  fi
  if ! printf ',,%s;\n' "${disk_fl_type}" | sudo sfdisk "$1" >/dev/null 2>&1; then
    disk_error "Failed to create partition table"
    return 1
  fi
  sudo partprobe "$1" 2>/dev/null
  disk_cmd_exists udevadm && sudo udevadm settle >/dev/null 2>&1

  disk_fl_part="$(disk_partition_node "$1")"
  disk_fl_waited=0
  while [ ! -b "${disk_fl_part}" ] && [ "${disk_fl_waited}" -lt 10 ]; do
    sleep 1
    disk_fl_waited=$((disk_fl_waited + 1))
  done
  if [ ! -b "${disk_fl_part}" ]; then
    disk_error "Partition ${disk_fl_part} did not appear"
    return 1
  fi

  disk_fl_ok=1
  case "$2" in
    FAT16) sudo mkfs.fat -F 16 -n "$3" "${disk_fl_part}" >/dev/null 2>&1 || disk_fl_ok=0 ;;
    FAT32) sudo mkfs.fat -F 32 -n "$3" "${disk_fl_part}" >/dev/null 2>&1 || disk_fl_ok=0 ;;
    *) sudo mkfs.exfat -n "$3" "${disk_fl_part}" >/dev/null 2>&1 || disk_fl_ok=0 ;;
  esac
  if [ "${disk_fl_ok}" -eq 1 ]; then
    disk_success "Partition created ($2)"
    return 0
  fi
  disk_error "Failed to format partition"
  return 1
}

disk_create_partition() {
  disk_cp_media="$(disk_media_class "$2")"
  disk_cp_label="NO NAME"
  case "${disk_cp_media}" in
    floppy) disk_cp_fs="FAT12" disk_cp_label="FLOPPY" ;;
    zip) disk_cp_fs="FAT16" disk_cp_label="ZIP" ;;
    small) disk_cp_fs="FAT16" ;;
    medium) disk_cp_fs="FAT32" ;;
    *) disk_cp_fs="ExFAT" ;;
  esac
  [ "${DISK_FAMILY:-}" = "zip" ] && disk_cp_label="ZIP"

  disk_info "Detected media: ${disk_cp_media}"
  disk_info "Creating filesystem (${disk_cp_fs})..."
  if [ "${disk_cp_media}" = "floppy" ]; then
    disk_format_floppy "$1" "${disk_cp_label}" || return 1
    disk_success "Formatted as ${disk_cp_fs} (superfloppy)"
    return 0
  fi
  disk_cp_os="$(disk_os)"
  case "${disk_cp_os}" in
    Darwin) disk_format_darwin "$1" "${disk_cp_fs}" "${disk_cp_label}" ;;
    Linux) disk_format_linux "$1" "${disk_cp_fs}" "${disk_cp_label}" ;;
    *) return 1 ;;
  esac
}
