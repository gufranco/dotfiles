#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_le_uint() {
  disk_lu_bytes="$(od -An -tu1 -v -j "$2" -N "$3" "$1" 2>/dev/null)"
  printf '%s\n' "${disk_lu_bytes}" | awk '
    { for (i = 1; i <= NF; i++) b[++n] = $i }
    END {
      v = 0
      for (i = n; i >= 1; i--) v = v * 256 + b[i]
      printf "%.0f\n", v
    }
  '
}

disk_hex_byte() {
  disk_hb_hex="$(od -An -tx1 -v -j "$2" -N 1 "$1" 2>/dev/null)"
  printf '%s\n' "${disk_hb_hex}" | tr -d ' \n'
}

disk_mbr_valid() {
  disk_mv_sig="$(disk_magic_hex "$1" 510 2)"
  [ "${disk_mv_sig}" = "55aa" ]
}

disk_gpt_starts() {
  disk_gs_sig="$(disk_magic_hex "$1" 512 8)"
  [ "${disk_gs_sig}" = "4546492050415254" ] || return 1
  disk_gs_lba="$(disk_le_uint "$1" 584 8)"
  disk_gs_count="$(disk_le_uint "$1" 592 4)"
  disk_gs_size="$(disk_le_uint "$1" 596 4)"
  [ "${disk_gs_count}" -gt 256 ] && disk_gs_count=256
  disk_gs_index=0
  while [ "${disk_gs_index}" -lt "${disk_gs_count}" ]; do
    disk_gs_at=$((disk_gs_lba * 512 + disk_gs_index * disk_gs_size))
    disk_gs_type="$(disk_magic_hex "$1" "${disk_gs_at}" 16)"
    case "${disk_gs_type}" in
      '' | 00000000000000000000000000000000) ;;
      ef57347c0000aa11aa1100306543ecac)
        DISK_GUARD_UNSUPPORTED="APFS"
        ;;
      *)
        disk_gs_first="$(disk_le_uint "$1" $((disk_gs_at + 32)) 8)"
        printf '%s\n' "$((disk_gs_first * 512))"
        ;;
    esac
    disk_gs_index=$((disk_gs_index + 1))
  done
  return 0
}

disk_ebr_starts() {
  disk_eb_base="$2"
  disk_eb_next="$2"
  disk_eb_hops=0
  while [ "${disk_eb_hops}" -lt 128 ]; do
    disk_eb_file="${DISK_TMPDIR}/ebr"
    sudo dd if="$1" of="${disk_eb_file}" bs=512 skip=$((disk_eb_next / 512)) count=1 2>/dev/null || return 1
    disk_mbr_valid "${disk_eb_file}" || return 0
    disk_eb_type="$(disk_hex_byte "${disk_eb_file}" 450)"
    disk_eb_rel="$(disk_le_uint "${disk_eb_file}" 454 4)"
    if [ "${disk_eb_type}" != "00" ] && [ "${disk_eb_rel}" -gt 0 ]; then
      printf '%s\n' "$((disk_eb_next + disk_eb_rel * 512))"
    fi
    disk_eb_link="$(disk_le_uint "${disk_eb_file}" 470 4)"
    [ "${disk_eb_link}" -gt 0 ] || return 0
    disk_eb_next=$((disk_eb_base + disk_eb_link * 512))
    disk_eb_hops=$((disk_eb_hops + 1))
  done
  return 0
}

disk_partition_starts() {
  DISK_GUARD_UNSUPPORTED=""
  disk_mbr_valid "$1" || return 0
  disk_ps_index=0
  while [ "${disk_ps_index}" -lt 4 ]; do
    disk_ps_entry=$((446 + disk_ps_index * 16))
    disk_ps_type="$(disk_hex_byte "$1" $((disk_ps_entry + 4)))"
    disk_ps_lba="$(disk_le_uint "$1" $((disk_ps_entry + 8)) 4)"
    case "${disk_ps_type}" in
      00) ;;
      ee) disk_gpt_starts "$1" ;;
      05 | 0f | 85) disk_ebr_starts "$2" $((disk_ps_lba * 512)) ;;
      af) DISK_GUARD_UNSUPPORTED="HFS+" ;;
      *) printf '%s\n' "$((disk_ps_lba * 512))" ;;
    esac
    disk_ps_index=$((disk_ps_index + 1))
  done
  return 0
}

disk_fstab_path() {
  printf '%s\n' "${DISK_FSTAB:-/etc/fstab}"
}

disk_fstab_strip() {
  disk_fsp_path="$(disk_fstab_path)"
  [ -f "${disk_fsp_path}" ] || return 0
  disk_fsp_tmp="${DISK_TMPDIR}/fstab.new"
  awk -v tag="$1" '
    $0 == "# kakikomi " tag " begin" { skip = 1; next }
    $0 == "# kakikomi " tag " end" { skip = 0; next }
    !skip { print }
  ' "${disk_fsp_path}" >"${disk_fsp_tmp}" || return 1
  cmp -s "${disk_fsp_tmp}" "${disk_fsp_path}" && return 0
  sudo cp -f "${disk_fsp_tmp}" "${disk_fsp_path}"
}

disk_fstab_append() {
  disk_fa_path="$(disk_fstab_path)"
  disk_fa_tmp="${DISK_TMPDIR}/fstab.new"
  if [ -f "${disk_fa_path}" ]; then
    cp -f "${disk_fa_path}" "${disk_fa_tmp}" || return 1
    [ -f "${disk_fa_path}.kakikomi.bak" ] || sudo cp -f "${disk_fa_path}" "${disk_fa_path}.kakikomi.bak"
  else
    : >"${disk_fa_tmp}"
  fi
  {
    printf '# kakikomi %s begin\n' "$1"
    printf '%s\n' "$2"
    printf '# kakikomi %s end\n' "$1"
  } >>"${disk_fa_tmp}" || return 1
  sudo cp -f "${disk_fa_tmp}" "${disk_fa_path}"
}

disk_volume_lines() {
  disk_vl_attach="$(hdiutil attach -nomount -readonly -imagekey diskimage-class=CRawDiskImage "$1" 2>/dev/null)" || return 1
  disk_vl_devices="$(printf '%s\n' "${disk_vl_attach}" | awk '/^\/dev\// { print $1 }')"
  disk_vl_whole="$(printf '%s\n' "${disk_vl_devices}" | sed -n '1p')"
  disk_vl_lines=""
  disk_vl_status=0
  for disk_vl_dev in ${disk_vl_devices}; do
    disk_vl_type="$(disk_plist_value "${disk_vl_dev}" FilesystemType)"
    [ -n "${disk_vl_type}" ] || continue
    disk_vl_uuid="$(disk_plist_value "${disk_vl_dev}" VolumeUUID)"
    if [ -z "${disk_vl_uuid}" ]; then
      disk_vl_name="$(disk_plist_value "${disk_vl_dev}" VolumeName)"
      if [ -z "${disk_vl_name}" ]; then
        disk_error "A ${disk_vl_type} volume in this image has neither a UUID nor a label, so macOS cannot be told to leave it alone."
        disk_vl_status=1
        continue
      fi
      disk_vl_name="$(printf '%s' "${disk_vl_name}" | sed 's/ /\\040/g')"
      disk_vl_lines="${disk_vl_lines}LABEL=${disk_vl_name} none ${disk_vl_type} rw,noauto
"
    else
      disk_vl_lines="${disk_vl_lines}UUID=${disk_vl_uuid} none ${disk_vl_type} rw,noauto
"
    fi
  done
  hdiutil detach "${disk_vl_whole}" >/dev/null 2>&1
  [ "${disk_vl_status}" -eq 0 ] || return 1
  printf '%s' "${disk_vl_lines}"
}

disk_guard_probe() {
  disk_gp_probe="${DISK_TMPDIR}/probe.img"
  rm -f "${disk_gp_probe}"
  dd if=/dev/zero of="${disk_gp_probe}" bs=1 count=0 seek="$3" 2>/dev/null || return 1
  dd if="$2" of="${disk_gp_probe}" conv=notrunc 2>/dev/null || return 1
  disk_gp_starts="$(disk_partition_starts "$2" "$1")"
  if [ -n "${DISK_GUARD_UNSUPPORTED}" ]; then
    disk_error "STOPPED: this image holds an ${DISK_GUARD_UNSUPPORTED} partition, whose volume identity cannot be read from its header alone."
    return 1
  fi
  disk_gp_head="$(disk_file_size "$2")"
  for disk_gp_start in ${disk_gp_starts}; do
    disk_gp_from="${disk_gp_start}"
    disk_gp_until=$((disk_gp_start + 8388608))
    [ "${disk_gp_from}" -lt "${disk_gp_head}" ] && disk_gp_from="${disk_gp_head}"
    [ "${disk_gp_until}" -gt "$3" ] && disk_gp_until="$3"
    [ "${disk_gp_from}" -lt "${disk_gp_until}" ] || continue
    sudo dd if="$1" of="${disk_gp_probe}" bs=512 skip=$((disk_gp_from / 512)) seek=$((disk_gp_from / 512)) \
      count=$(((disk_gp_until - disk_gp_from) / 512)) conv=notrunc 2>/dev/null || return 1
  done
  printf '%s\n' "${disk_gp_probe}"
}

disk_guard_declare() {
  disk_os_now="$(disk_os)"
  [ "${disk_os_now}" = "Darwin" ] || return 0
  disk_gd_tag="${1##*/}"
  disk_gd_io="$(disk_io_device "$1")"
  disk_gd_probe="$(disk_guard_probe "${disk_gd_io}" "$2" "$3")" || return 1
  disk_gd_lines="$(disk_volume_lines "${disk_gd_probe}")" || {
    disk_error "STOPPED: could not stop the system from mounting $1, so its first sectors stay blank."
    return 1
  }
  rm -f "${disk_gd_probe}"
  disk_fstab_strip "${disk_gd_tag}" || return 1
  if [ -z "${disk_gd_lines}" ]; then
    disk_info "The image holds no volume macOS would mount."
    return 0
  fi
  disk_fstab_append "${disk_gd_tag}" "${disk_gd_lines}" || {
    disk_error "STOPPED: could not stop the system from mounting $1, so its first sectors stay blank."
    return 1
  }
  DISK_GUARD_DECLARED="${disk_gd_tag}"
  disk_gd_count="$(printf '%s\n' "${disk_gd_lines}" | sed '/^$/d' | wc -l)"
  disk_gd_count="$(printf '%s' "${disk_gd_count}" | tr -d '[:space:]')"
  disk_info "Told macOS not to mount the ${disk_gd_count} volume(s) in this image."
  return 0
}

disk_guard_on() {
  disk_go_os="$(disk_os)"
  [ "${disk_go_os}" = "Linux" ] || return 0
  disk_go_name="${1##*/}"
  DISK_GUARD_RULE="/run/udev/rules.d/99-kakikomi-${disk_go_name}.rules"
  sudo mkdir -p /run/udev/rules.d || return 1
  printf 'KERNEL=="%s*", ENV{UDISKS_IGNORE}="1", ENV{UDISKS_AUTO}="0", ENV{UDISKS_SYSTEM}="1"\n' "${disk_go_name}" |
    sudo tee "${DISK_GUARD_RULE}" >/dev/null || return 1
  if disk_cmd_exists udevadm; then
    sudo udevadm control --reload >/dev/null 2>&1
  fi
  return 0
}

disk_guard_off() {
  if [ -n "${DISK_GUARD_RULE}" ] && [ "${KEEP_GUARD:-}" != "y" ]; then
    sudo rm -f "${DISK_GUARD_RULE}"
    disk_cmd_exists udevadm && sudo udevadm control --reload >/dev/null 2>&1
    DISK_GUARD_RULE=""
  fi
  if [ -n "${DISK_GUARD_DECLARED}" ] && [ "${KEEP_GUARD:-}" != "y" ]; then
    disk_fstab_strip "${DISK_GUARD_DECLARED}"
    DISK_GUARD_DECLARED=""
  fi
  return 0
}

disk_breach_artifacts() {
  for disk_ba_name in .fseventsd .Spotlight-V100 .Trashes .TemporaryItems .DS_Store; do
    [ -e "$1/${disk_ba_name}" ] && printf '%s\n' "${disk_ba_name}"
  done
  find "$1" -maxdepth 2 -name '._*' 2>/dev/null | sed -n '1,5p'
  return 0
}

disk_watch_mounts() {
  disk_wm_ticks=0
  while [ -f "$2" ] && [ "${disk_wm_ticks}" -lt 432000 ]; do
    disk_wm_table="$(mount)"
    disk_wm_hits="$(printf '%s\n' "${disk_wm_table}" | awk -v dev="$1" '$1 == dev || index($1, dev "s") == 1 || index($1, dev "p") == 1 { print $1 "\t" $3 }')"
    if [ -n "${disk_wm_hits}" ]; then
      printf '%s\n' "${disk_wm_hits}" | while IFS="$(printf '\t')" read -r disk_wm_dev disk_wm_dir; do
        printf 'mounted %s on %s\n' "${disk_wm_dev}" "${disk_wm_dir}"
        disk_breach_artifacts "${disk_wm_dir}"
      done >>"$3"
      disk_release "$1" >/dev/null 2>&1
    fi
    sleep 0.2
    disk_wm_ticks=$((disk_wm_ticks + 1))
  done
}

disk_breach_start() {
  DISK_BREACH_FLAG="${DISK_TMPDIR}/watching"
  DISK_BREACH_LOG="${DISK_TMPDIR}/breach"
  : >"${DISK_BREACH_FLAG}"
  : >"${DISK_BREACH_LOG}"
  disk_watch_mounts "$1" "${DISK_BREACH_FLAG}" "${DISK_BREACH_LOG}" &
  DISK_BREACH_PID="$!"
  return 0
}

disk_breach_stop() {
  [ -n "${DISK_BREACH_FLAG}" ] && rm -f "${DISK_BREACH_FLAG}"
  if [ -n "${DISK_BREACH_PID}" ]; then
    wait "${DISK_BREACH_PID}" 2>/dev/null
    DISK_BREACH_PID=""
  fi
  if [ -n "${DISK_BREACH_LOG}" ] && [ -s "${DISK_BREACH_LOG}" ]; then
    disk_error "STOPPED: $1 was mounted, so the system may have written to it."
    disk_bs_log="$(cat "${DISK_BREACH_LOG}")"
    disk_log_lines disk_error "${disk_bs_log}"
    return 1
  fi
  return 0
}

disk_udev_release_all() {
  disk_ur_os="$(disk_os)"
  [ "${disk_ur_os}" = "Linux" ] || return 0
  for disk_ur_rule in /run/udev/rules.d/99-kakikomi-*.rules; do
    [ -f "${disk_ur_rule}" ] || continue
    sudo rm -f "${disk_ur_rule}" || return 1
    disk_success "Removed ${disk_ur_rule}."
  done
  disk_cmd_exists udevadm && sudo udevadm control --reload >/dev/null 2>&1
  return 0
}

disk_fstab_release_all() {
  disk_udev_release_all || return 1
  disk_fr_path="$(disk_fstab_path)"
  [ -f "${disk_fr_path}" ] || return 0
  disk_fr_tmp="${TMPDIR:-/tmp}/kakikomi.fstab.$$"
  awk '
    /^# kakikomi .* begin$/ { skip = 1; next }
    /^# kakikomi .* end$/ { skip = 0; next }
    !skip { print }
  ' "${disk_fr_path}" >"${disk_fr_tmp}" || return 1
  if cmp -s "${disk_fr_tmp}" "${disk_fr_path}"; then
    rm -f "${disk_fr_tmp}"
    disk_info "No mount guard was left in ${disk_fr_path}."
    return 0
  fi
  sudo cp -f "${disk_fr_tmp}" "${disk_fr_path}" || return 1
  rm -f "${disk_fr_tmp}"
  disk_success "Removed every mount guard kakikomi left in ${disk_fr_path}."
  return 0
}
