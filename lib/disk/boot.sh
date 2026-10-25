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

disk_le_bytes() {
  printf '\\0%03o\\0%03o\\0%03o\\0%03o' \
    $(($1 % 256)) $(($1 / 256 % 256)) $(($1 / 65536 % 256)) $(($1 / 16777216 % 256))
}

disk_mbr_write() {
  disk_mw_start="$(disk_le_bytes "$3")"
  disk_mw_count="$(disk_le_bytes "$4")"
  disk_mw_type="$(printf '\\0%03o' "$2")"
  printf '%b' "\0000\0376\0377\0377${disk_mw_type}\0376\0377\0377${disk_mw_start}${disk_mw_count}" |
    dd of="$1" bs=1 seek=446 conv=notrunc 2>/dev/null || return 1
  printf '%b' '\0125\0252' | dd of="$1" bs=1 seek=510 conv=notrunc 2>/dev/null
}

disk_sparse_file() {
  rm -f "$1"
  dd if=/dev/zero of="$1" bs=1 count=0 seek="$2" 2>/dev/null
}

disk_exfat_build() {
  disk_xb_os="$(disk_os)"
  case "${disk_xb_os}" in
    Darwin)
      disk_xb_attach="$(hdiutil attach -nomount -imagekey diskimage-class=CRawDiskImage "$1" 2>/dev/null)" || return 1
      disk_xb_whole="$(printf '%s\n' "${disk_xb_attach}" | awk 'NR == 1 { print $1 }')"
      disk_xb_part="$(printf '%s\n' "${disk_xb_attach}" | awk 'NR == 2 { print $1 }')"
      [ -n "${disk_xb_part}" ] || disk_xb_part="${disk_xb_whole}"
      disk_xb_status=0
      newfs_exfat -v "$2" "/dev/r${disk_xb_part#/dev/}" >/dev/null 2>&1 || disk_xb_status=1
      hdiutil detach "${disk_xb_whole}" >/dev/null 2>&1
      return "${disk_xb_status}"
      ;;
    Linux)
      disk_cmd_exists mkfs.exfat || {
        disk_error "mkfs.exfat is not installed. Install the exfatprogs package."
        return 1
      }
      disk_xb_loop="$(sudo losetup -f --show -o 1048576 "$1")" || return 1
      disk_xb_status=0
      sudo mkfs.exfat -L "$2" "${disk_xb_loop}" >/dev/null 2>&1 || disk_xb_status=1
      sudo losetup -d "${disk_xb_loop}"
      return "${disk_xb_status}"
      ;;
    *) return 1 ;;
  esac
}

disk_fat_build() {
  disk_fb_sectors=$(($3 / 512))
  disk_fb_target="$1@@$4"
  case "$2" in
    fat32) mformat -i "${disk_fb_target}" -F -T "${disk_fb_sectors}" -v "$5" :: >/dev/null 2>&1 ;;
    *) mformat -i "${disk_fb_target}" -T "${disk_fb_sectors}" -v "$5" :: >/dev/null 2>&1 ;;
  esac
}

disk_floppy_build() {
  disk_fl_kib=$(($2 / 1024))
  mformat -i "$1" -f "${disk_fl_kib}" -v "$3" :: >/dev/null 2>&1 ||
    mformat -i "$1" -T $(($2 / 512)) -v "$3" :: >/dev/null 2>&1
}

disk_metadata_end() {
  disk_me_fs="$(disk_magic_hex "$1" $(($2 + 3)) 8)"
  disk_me_bps="$(disk_le_uint "$1" $(($2 + 11)) 2)"
  [ "${disk_me_bps}" -gt 0 ] || disk_me_bps=512
  case "${disk_me_fs}" in
    4558464154202020)
      disk_me_heap="$(disk_le_uint "$1" $(($2 + 88)) 4)"
      disk_me_clusters="$(disk_le_uint "$1" $(($2 + 92)) 4)"
      disk_me_shift="$(disk_le_uint "$1" $(($2 + 109)) 1)"
      disk_me_csize=$((512 << disk_me_shift))
      printf '%s\n' "$(($2 + disk_me_heap * 512 + (disk_me_clusters / 8 / disk_me_csize + 64) * disk_me_csize))"
      ;;
    *)
      disk_me_reserved="$(disk_le_uint "$1" $(($2 + 14)) 2)"
      disk_me_fats="$(disk_le_uint "$1" $(($2 + 16)) 1)"
      disk_me_roots="$(disk_le_uint "$1" $(($2 + 17)) 2)"
      disk_me_fat16="$(disk_le_uint "$1" $(($2 + 22)) 2)"
      disk_me_fat32="$(disk_le_uint "$1" $(($2 + 36)) 4)"
      disk_me_spc="$(disk_le_uint "$1" $(($2 + 13)) 1)"
      disk_me_fatlen="${disk_me_fat16}"
      [ "${disk_me_fatlen}" -gt 0 ] || disk_me_fatlen="${disk_me_fat32}"
      printf '%s\n' "$(($2 + (disk_me_reserved + disk_me_fats * disk_me_fatlen) * disk_me_bps + disk_me_roots * 32 + 64 * disk_me_spc * disk_me_bps))"
      ;;
  esac
}

disk_default_fs() {
  disk_df_mb=$(($1 / 1048576))
  if [ "${disk_df_mb}" -le 3 ]; then
    printf 'floppy\n'
  elif [ "${disk_df_mb}" -le 2048 ]; then
    printf 'fat\n'
  elif [ "${disk_df_mb}" -le 32768 ]; then
    printf 'fat32\n'
  else
    printf 'exfat\n'
  fi
}

disk_fs_type_byte() {
  case "$1" in
    fat32) printf '12\n' ;;
    exfat) printf '7\n' ;;
    *) printf '14\n' ;;
  esac
}

disk_build_volume() {
  disk_bv_image="$1"
  disk_bv_fs="$2"
  disk_bv_label="$3"
  disk_bv_size="$4"
  disk_sparse_file "${disk_bv_image}" "${disk_bv_size}" || return 1
  if [ "${disk_bv_fs}" = "floppy" ]; then
    disk_floppy_build "${disk_bv_image}" "${disk_bv_size}" "${disk_bv_label}" || return 1
    DISK_VOLUME_OFFSET=0
    return 0
  fi
  disk_bv_type="$(disk_fs_type_byte "${disk_bv_fs}")"
  disk_mbr_write "${disk_bv_image}" "${disk_bv_type}" 2048 $((disk_bv_size / 512 - 2048)) || return 1
  DISK_VOLUME_OFFSET=1048576
  case "${disk_bv_fs}" in
    exfat) disk_exfat_build "${disk_bv_image}" "${disk_bv_label}" ;;
    *) disk_fat_build "${disk_bv_image}" "${disk_bv_fs}" $((disk_bv_size - 1048576)) 1M "${disk_bv_label}" ;;
  esac
}

disk_is_windows_iso() {
  [ "${MODE:-}" = "raw" ] && return 1
  [ "${DISK_SRC_KIND}" = "raw" ] || return 1
  disk_wi_cd="$(disk_magic_hex "$1" 32769 5)"
  [ "${disk_wi_cd}" = "4344303031" ] || return 1
  disk_mbr_valid "$1" && return 1
  disk_wi_list="$(disk_iso_list "$1")" || return 1
  printf '%s\n' "${disk_wi_list}" | grep -Eiq '(^|[[:space:]/])sources/install\.(wim|esd)$'
}

disk_iso_list() {
  if disk_cmd_exists bsdtar; then
    bsdtar -tf "$1" 2>/dev/null && return 0
  fi
  if disk_cmd_exists 7z; then
    disk_il_listing="$(7z l -ba -slt "$1" 2>/dev/null)" || return 1
    printf '%s\n' "${disk_il_listing}" | sed -n 's/^Path = //p'
    return 0
  fi
  disk_warning "Neither bsdtar nor 7z is installed, so this ISO cannot be checked for a Windows installer."
  return 1
}

disk_iso_label() {
  disk_il_raw="$(dd if="$1" bs=1 skip=32808 count=32 2>/dev/null)"
  disk_il_label="$(printf '%s' "${disk_il_raw}" | tr -cd 'A-Za-z0-9_' | tr '[:lower:]' '[:upper:]' | cut -c1-11)"
  printf '%s\n' "${disk_il_label:-WINUSB}"
}

disk_iso_extract() {
  mkdir -p "$2" || return 1
  if disk_cmd_exists 7z; then
    7z x -y -bd -o"$2" "$1" >/dev/null 2>&1 && return 0
  fi
  bsdtar -xf "$1" -C "$2" 2>/dev/null
}

disk_split_wim() {
  disk_sw_wim="$(find "$1" -ipath '*/sources/install.wim' -type f 2>/dev/null)"
  disk_sw_wim="$(printf '%s\n' "${disk_sw_wim}" | sed -n '1p')"
  [ -n "${disk_sw_wim}" ] || return 0
  disk_sw_size="$(disk_file_size "${disk_sw_wim}")"
  [ "${disk_sw_size}" -gt "${FAT32_MAX_FILE:-4294967295}" ] || return 0
  if ! disk_cmd_exists wimlib-imagex; then
    disk_error "STOPPED: install.wim is over 4 GiB, which FAT32 cannot hold, and wimlib-imagex is needed to split it. Install wimlib."
    return 1
  fi
  disk_sw_human="$(disk_human "${disk_sw_size}")"
  disk_info "Splitting the ${disk_sw_human} install.wim into parts FAT32 can hold." >&2
  disk_sw_part_mb=$((${FAT32_MAX_FILE:-4294967295} * 9 / 10485760))
  [ "${disk_sw_part_mb}" -ge 1 ] || disk_sw_part_mb=1
  wimlib-imagex split "${disk_sw_wim}" "${disk_sw_wim%.*}.swm" "${disk_sw_part_mb}" >/dev/null 2>&1 || {
    disk_error "STOPPED: wimlib-imagex could not split install.wim."
    return 1
  }
  rm -f "${disk_sw_wim}"
}

disk_tree_bytes() {
  disk_tb_kib="$(du -sk "$1" 2>/dev/null)"
  disk_tb_kib="${disk_tb_kib%%[[:space:]]*}"
  disk_is_uint "${disk_tb_kib}" || disk_tb_kib=0
  printf '%s\n' "$((disk_tb_kib * 1024))"
}

disk_fat_copy_tree() {
  for disk_fc_entry in "$2"/* "$2"/.[!.]*; do
    [ -e "${disk_fc_entry}" ] || continue
    mcopy -s -b -Q -i "$1@@1M" "${disk_fc_entry}" ::/ >/dev/null 2>&1 || return 1
  done
  return 0
}

disk_fat_verify_tree() {
  disk_fv_files="$(cd "$2" && find . -type f 2>/dev/null)"
  disk_fv_count=0
  disk_fv_back="${DISK_SRC_WORK}/verify.tmp"
  printf '%s\n' "${disk_fv_files}" | while IFS= read -r disk_fv_rel; do
    [ -n "${disk_fv_rel}" ] || continue
    disk_fv_rel="${disk_fv_rel#./}"
    mcopy -n -i "$1@@1M" "::/${disk_fv_rel}" "${disk_fv_back}" >/dev/null 2>&1 || {
      printf '%s\n' "${disk_fv_rel}"
      continue
    }
    cmp -s "${disk_fv_back}" "$2/${disk_fv_rel}" || printf '%s\n' "${disk_fv_rel}"
  done >"${DISK_SRC_WORK}/verify.bad"
  rm -f "${disk_fv_back}"
  if [ -s "${DISK_SRC_WORK}/verify.bad" ]; then
    disk_error "STOPPED: these files did not copy into the FAT32 volume intact:"
    disk_fv_bad="$(sed -n '1,20p' "${DISK_SRC_WORK}/verify.bad")"
    disk_log_lines disk_error "${disk_fv_bad}"
    return 1
  fi
  disk_fv_count="$(printf '%s\n' "${disk_fv_files}" | sed '/^$/d' | wc -l)"
  disk_fv_count="$(printf '%s' "${disk_fv_count}" | tr -d '[:space:]')"
  disk_info "All ${disk_fv_count} files read back identical from the new volume." >&2
  return 0
}

disk_windows_image() {
  disk_wn_iso="$1"
  disk_wn_tree="${DISK_SRC_WORK}/iso"
  disk_wn_image="${DISK_SRC_WORK}/windows.img"
  disk_cmd_exists mformat || {
    disk_error "STOPPED: building a Windows USB needs mtools. Install it: brew install mtools, or apt install mtools."
    return 1
  }
  disk_wn_iso_size="$(disk_file_size "${disk_wn_iso}")"
  disk_wn_free="$(disk_free_bytes "${DISK_SRC_WORK}")"
  if [ "${disk_wn_free}" -lt $((disk_wn_iso_size * 22 / 10)) ]; then
    disk_wn_need="$(disk_human $((disk_wn_iso_size * 22 / 10)))"
    disk_error "STOPPED: laying out this ISO needs about ${disk_wn_need} free in ${DISK_SRC_WORK}."
    return 1
  fi
  disk_info "Extracting the ISO to lay it out as a FAT32 drive." >&2
  disk_iso_extract "${disk_wn_iso}" "${disk_wn_tree}" || {
    disk_error "STOPPED: the ISO could not be extracted."
    return 1
  }
  disk_split_wim "${disk_wn_tree}" || return 1
  disk_wn_bytes="$(disk_tree_bytes "${disk_wn_tree}")"
  disk_wn_size=$(((disk_wn_bytes * 105 / 100 + 8388608 + 1048575) / 1048576 * 1048576))
  [ "${disk_wn_size}" -ge 41943040 ] || disk_wn_size=41943040
  disk_wn_label="$(disk_iso_label "${disk_wn_iso}")"
  disk_build_volume "${disk_wn_image}" fat32 "${disk_wn_label}" "${disk_wn_size}" || {
    disk_error "STOPPED: the FAT32 volume could not be created."
    return 1
  }
  disk_info "Copying the installer files into the FAT32 volume." >&2
  disk_fat_copy_tree "${disk_wn_image}" "${disk_wn_tree}" || {
    disk_error "STOPPED: copying the installer files into the FAT32 volume failed."
    return 1
  }
  disk_fat_verify_tree "${disk_wn_image}" "${disk_wn_tree}" || return 1
  rm -rf "${disk_wn_tree}"
  printf '%s\n' "${disk_wn_image}"
}
