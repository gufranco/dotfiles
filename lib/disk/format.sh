#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_format_usage() {
  disk_info "Usage: kakikomi format <device|mount_point> [fat32|exfat|fat|floppy] [LABEL]"
  disk_info "       kakikomi format /dev/disk4                  (FAT32 up to 32 GiB, exFAT above)"
  disk_info "       kakikomi format /dev/disk4 exfat MEDIA"
  disk_info "       kakikomi format /dev/disk5 floppy GAMES     (a 1.44 MB disk with no partition table)"
  disk_info "A quick format: only the new filesystem structures are written, then read back."
}

disk_format_fs() {
  case "$1" in
    '') disk_default_fs "$2" ;;
    fat32 | exfat | fat | floppy) printf '%s\n' "$1" ;;
    *)
      disk_error "Unknown filesystem: $1. Use fat32, exfat, fat or floppy."
      return 1
      ;;
  esac
}

disk_format_label() {
  disk_fl_label="$(printf '%s' "${1:-UNTITLED}" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9_ -' | cut -c1-11)"
  printf '%s\n' "${disk_fl_label:-UNTITLED}"
}

disk_format_tools() {
  case "$1" in
    exfat) return 0 ;;
    *)
      disk_cmd_exists mformat && return 0
      disk_error "STOPPED: FAT formatting needs mtools. Install it: brew install mtools, or apt install mtools."
      return 1
      ;;
  esac
}

disk_format_prefix() {
  disk_fp_volume="${DISK_SRC_WORK}/volume.img"
  disk_fp_prefix="${DISK_SRC_WORK}/format.img"
  disk_info "Building an empty $2 filesystem named $3 for ${4} bytes."
  disk_build_volume "${disk_fp_volume}" "$2" "$3" "$4" || {
    disk_error "STOPPED: the $2 filesystem could not be created."
    return 1
  }
  disk_fp_end="$(disk_metadata_end "${disk_fp_volume}" "${DISK_VOLUME_OFFSET}")"
  disk_fp_end=$(((disk_fp_end + 1048575) / 1048576 * 1048576))
  [ "${disk_fp_end}" -gt "$4" ] && disk_fp_end="$4"
  dd if="${disk_fp_volume}" of="${disk_fp_prefix}" bs=1048576 count=$((disk_fp_end / 1048576)) 2>/dev/null || return 1
  if [ $((disk_fp_end % 1048576)) -ne 0 ]; then
    dd if="${disk_fp_volume}" of="${disk_fp_prefix}" bs=1 skip=$((disk_fp_end / 1048576 * 1048576)) \
      seek=$((disk_fp_end / 1048576 * 1048576)) count=$((disk_fp_end % 1048576)) conv=notrunc 2>/dev/null || return 1
  fi
  rm -f "${disk_fp_volume}"
  printf '%s\n' "${disk_fp_prefix}" >"${DISK_SRC_WORK}/prefix-path"
  return 0
}

disk_format_main() {
  case "${1:-}" in
    -h | --help)
      disk_format_usage
      return 0
      ;;
    '')
      disk_error "No device specified"
      disk_format_usage
      return 1
      ;;
    *) ;;
  esac
  disk_fm_disk="$(disk_resolve "$1")" || return 1
  disk_fm_size="$(disk_size_bytes "${disk_fm_disk}")"
  if ! disk_is_uint "${disk_fm_size}" || [ "${disk_fm_size}" -eq 0 ]; then
    disk_error "Unable to determine the size of ${disk_fm_disk}"
    return 1
  fi
  disk_fm_size=$((disk_fm_size / 1048576 * 1048576))
  disk_fm_fs="$(disk_format_fs "${2:-}" "${disk_fm_size}")" || return 1
  disk_fm_label="$(disk_format_label "${3:-}")"
  disk_format_tools "${disk_fm_fs}" || return 1
  disk_refuse_target "${disk_fm_disk}" "" "" || return 1

  DISK_SRC_WORK="$(mktemp -d "${TMPDIR:-/tmp}/kakikomi_format.XXXXXX")" || return 1
  trap disk_write_cleanup EXIT
  trap disk_write_interrupted INT TERM HUP
  disk_format_prefix "${disk_fm_disk}" "${disk_fm_fs}" "${disk_fm_label}" "${disk_fm_size}" || return 1
  disk_fm_prefix="$(cat "${DISK_SRC_WORK}/prefix-path")"
  disk_source_open "${disk_fm_prefix}" || return 1
  DISK_SRC_NOTE="a new ${disk_fm_fs} filesystem named ${disk_fm_label}, its structures only"
  DISK_QUIET_TAIL=1
  DELETE=n
  export DELETE
  disk_write_checksum || return 1
  disk_write_once "${disk_fm_disk}"
}
