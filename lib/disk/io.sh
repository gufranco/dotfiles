#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_release() {
  disk_rl_disk="$1"
  disk_rl_os="$(disk_os)"
  case "${disk_rl_os}" in
    Darwin)
      disk_bounded 30 sudo diskutil unmountDisk force "${disk_rl_disk}" >/dev/null 2>&1
      disk_is_mounted "${disk_rl_disk}" || return 0
      disk_rl_list="$(diskutil list "${disk_rl_disk}" 2>/dev/null)"
      disk_rl_slices="$(printf '%s\n' "${disk_rl_list}" | awk '$NF ~ /^disk[0-9]+s[0-9]+$/ { print $NF }')"
      for disk_rl_slice in ${disk_rl_slices}; do
        disk_bounded 20 sudo diskutil unmount force "/dev/${disk_rl_slice}" >/dev/null 2>&1
      done
      disk_is_mounted "${disk_rl_disk}" && return 1
      return 0
      ;;
    Linux)
      DISK_RELEASED=0
      disk_rl_children="$(lsblk -nro NAME "${disk_rl_disk}" 2>/dev/null)"
      for disk_rl_child in ${disk_rl_children}; do
        if sudo umount "/dev/${disk_rl_child}" 2>/dev/null; then
          DISK_RELEASED=$((DISK_RELEASED + 1))
        fi
      done
      if sudo umount "${disk_rl_disk}" 2>/dev/null; then
        DISK_RELEASED=$((DISK_RELEASED + 1))
      fi
      if ! disk_rl_mounts="$(lsblk -nro MOUNTPOINT "${disk_rl_disk}" 2>/dev/null)"; then
        return 2
      fi
      disk_rl_mounts="$(printf '%s' "${disk_rl_mounts}" | tr -d '[:space:]')"
      [ -n "${disk_rl_mounts}" ] && return 1
      return 0
      ;;
    *) return 1 ;;
  esac
}

disk_unmount_for_write() {
  disk_info "Unmounting $1..."
  disk_uw_status=0
  disk_release "$1" || disk_uw_status="$?"
  disk_uw_os="$(disk_os)"
  case "${disk_uw_status}" in
    0)
      if [ "${disk_uw_os}" = "Darwin" ] || [ "${DISK_RELEASED:-0}" -gt 0 ]; then
        disk_success "Disk unmounted"
      fi
      return 0
      ;;
    2)
      disk_error "Unable to read the mount state of $1, so this stops here"
      return 1
      ;;
    *)
      disk_error "Disk is still mounted, so writing to it would corrupt the mounted volume"
      return 1
      ;;
  esac
}

disk_eject_now() {
  disk_en_os="$(disk_os)"
  case "${disk_en_os}" in
    Darwin)
      if disk_bounded 30 sudo diskutil eject "$1" >/dev/null 2>&1; then
        disk_success "Cartridge ejected."
        return 0
      fi
      if disk_bounded 20 sudo diskutil unmountDisk force "$1" >/dev/null 2>&1; then
        disk_warning "The drive refused to eject. The volume is unmounted, so nothing else will touch it."
      else
        disk_error "The drive answered neither eject nor unmount within the time allowed."
      fi
      ;;
    Linux)
      if disk_bounded 30 sudo eject "$1" >/dev/null 2>&1; then
        disk_success "Cartridge ejected."
        return 0
      fi
      disk_error "The drive did not eject within the time allowed."
      ;;
    *) ;;
  esac
  disk_error "Cut power to the drive before doing anything else with it. Do not press eject repeatedly."
  return 1
}

disk_probe_cache_bypass() {
  DISK_READ_FLAGS=""
  DISK_WRITE_FLAGS=""
  DISK_FLUSH=0
  disk_pc_os="$(disk_os)"
  [ "${disk_pc_os}" = "Linux" ] || return 0
  if sudo dd if="$1" bs="$2" count=1 iflag=direct status=none >/dev/null 2>&1; then
    DISK_READ_FLAGS="iflag=direct"
    DISK_WRITE_FLAGS="oflag=direct"
    disk_info "Bypassing the page cache so every chunk reaches the media."
  else
    DISK_FLUSH=1
    disk_info "Direct I/O is unavailable, so buffers are dropped before every verify."
  fi
  return 0
}

disk_flush_reads() {
  [ "${DISK_FLUSH:-0}" = "1" ] || return 0
  sync
  sudo blockdev --flushbufs "$1" 2>/dev/null
  return 0
}

disk_block_bytes() {
  disk_bb_block=1048576
  disk_bb_floor="${DISK_SECTOR}"
  [ "${disk_bb_floor}" -ge 512 ] || disk_bb_floor=512
  if [ "${DISK_CEILING:-0}" -gt 0 ] && [ "${disk_bb_block}" -gt "${DISK_CEILING}" ]; then
    disk_bb_block="${DISK_CEILING}"
  fi
  [ "${disk_bb_block}" -lt "${disk_bb_floor}" ] && disk_bb_block="${disk_bb_floor}"
  while [ "${disk_bb_block}" -gt "${disk_bb_floor}" ]; do
    if [ $(($1 % disk_bb_block)) -eq 0 ] && [ $(($2 % disk_bb_block)) -eq 0 ]; then
      printf '%s\n' "${disk_bb_block}"
      return 0
    fi
    disk_bb_block=$((disk_bb_block / 2))
  done
  printf '%s\n' "${disk_bb_floor}"
}

disk_dd_bytes() {
  awk '/bytes/ { print $1; exit }' "$1"
}

disk_dd_error() {
  disk_de_text="$(grep -v -E 'records (in|out)|bytes' "$1" 2>/dev/null)"
  printf '%s\n' "${disk_de_text}" | awk 'NF { line[++n] = $0 } END { s = ""; for (i = (n > 2 ? n - 1 : 1); i <= n; i++) s = s (s == "" ? "" : " ") line[i]; print s }'
}

disk_move() {
  disk_mv_direction="$1"
  disk_mv_source="$2"
  disk_mv_target="$3"
  disk_mv_offset="$4"
  disk_mv_bytes="$5"
  disk_mv_err="${DISK_TMPDIR}/dd.err"
  disk_mv_block="$(disk_block_bytes "${disk_mv_offset}" "${disk_mv_bytes}")"
  disk_mv_count=$((disk_mv_bytes / disk_mv_block))
  disk_mv_at=$((disk_mv_offset / disk_mv_block))
  DISK_MOVED=0
  DISK_TIMED_OUT=0
  DISK_INTERRUPTED=0
  disk_set_error ""

  disk_mv_deadline="${DISK_DEADLINE:-0}"
  disk_mv_outcome=0
  if [ "${disk_mv_direction}" = "write" ]; then
    disk_dd_write "${disk_mv_deadline}" "${disk_mv_source}" "${disk_mv_target}" \
      "${disk_mv_block}" "${disk_mv_at}" "${disk_mv_count}" 2>"${disk_mv_err}" || disk_mv_outcome="$?"
  else
    disk_dd_read "${disk_mv_deadline}" "${disk_mv_source}" "${disk_mv_target}" \
      "${disk_mv_block}" "${disk_mv_at}" "${disk_mv_count}" 2>"${disk_mv_err}" || disk_mv_outcome="$?"
  fi

  case "${disk_mv_outcome}" in
    0) ;;
    124 | 137)
      DISK_TIMED_OUT=1
      disk_mv_shown="$(disk_duration "${disk_mv_deadline}")"
      disk_set_error "the drive did not finish a ${disk_mv_bytes} byte ${disk_mv_direction} at offset ${disk_mv_offset} within ${disk_mv_shown}"
      return 1
      ;;
    130 | 143)
      DISK_INTERRUPTED=1
      disk_set_error "the ${disk_mv_direction} at offset ${disk_mv_offset} was interrupted"
      return 1
      ;;
    *)
      disk_mv_said="$(disk_dd_error "${disk_mv_err}")"
      disk_set_error "${disk_mv_said}"
      return 1
      ;;
  esac

  DISK_MOVED="$(disk_dd_bytes "${disk_mv_err}")"
  disk_is_uint "${DISK_MOVED}" || DISK_MOVED=0
  if [ "${DISK_MOVED}" -ne "${disk_mv_bytes}" ]; then
    disk_set_error "dd moved ${DISK_MOVED} of ${disk_mv_bytes} bytes at offset ${disk_mv_offset} with bs=${disk_mv_block}"
  fi
  return 0
}

disk_dd_write() {
  if [ "$1" -gt 0 ]; then
    disk_bounded_ms "$1" sudo dd if="$2" of="$3" bs="$4" seek="$5" count="$6" conv=notrunc ${DISK_WRITE_FLAGS:+"${DISK_WRITE_FLAGS}"}
  else
    sudo dd if="$2" of="$3" bs="$4" seek="$5" count="$6" conv=notrunc ${DISK_WRITE_FLAGS:+"${DISK_WRITE_FLAGS}"}
  fi
}

disk_dd_read() {
  if [ "$1" -gt 0 ]; then
    disk_bounded_ms "$1" sudo dd if="$2" of="$3" bs="$4" skip="$5" count="$6" ${DISK_READ_FLAGS:+"${DISK_READ_FLAGS}"}
  else
    sudo dd if="$2" of="$3" bs="$4" skip="$5" count="$6" ${DISK_READ_FLAGS:+"${DISK_READ_FLAGS}"}
  fi
}

disk_writes_land() {
  disk_wl_io="$(disk_io_device "$1")"
  disk_wl_probe="${DISK_TMPDIR}/write-probe"
  disk_wl_back="${DISK_TMPDIR}/write-probe-back"
  for disk_wl_octal in '\252' '\125'; do
    head -c "${DISK_SECTOR}" /dev/zero | tr '\000' "${disk_wl_octal}" >"${disk_wl_probe}" || return 2
    disk_wl_size="$(disk_file_size "${disk_wl_probe}")"
    [ "${disk_wl_size}" -eq "${DISK_SECTOR}" ] || return 2
    disk_move write "${disk_wl_probe}" "${disk_wl_io}" 0 "${DISK_SECTOR}" || return 2
    [ "${DISK_MOVED}" -eq "${DISK_SECTOR}" ] || return 2
    sync
    disk_move read "${disk_wl_io}" "${disk_wl_back}" 0 "${DISK_SECTOR}" || return 2
    [ "${DISK_MOVED}" -eq "${DISK_SECTOR}" ] || return 2
    cmp -s "${disk_wl_probe}" "${disk_wl_back}" || return 1
  done
  return 0
}

disk_write_protect_advice() {
  case "${DISK_FAMILY:-}" in
    floppy | superdisk)
      disk_info "Cover the square hole on the corner of the disk by sliding its tab shut, then run this again."
      ;;
    zip | jaz | pocketzip)
      disk_info "Unlock the cartridge, through the Iomega tools or its write-protect tab, then run this again."
      ;;
    *)
      disk_info "Release the write-protect switch or lock on the device, then run this again."
      ;;
  esac
  return 0
}

disk_report_write_protected() {
  disk_error "STOPPED: $1 is write protected, so nothing on it can be $3."
  case "$2" in
    flag) disk_error "The drive reports this media as read-only." ;;
    silent) disk_error "The drive accepted a test write and the media kept its previous contents." ;;
    *) ;;
  esac
  disk_write_protect_advice
  return 0
}

disk_head_crash_advice() {
  if [ "$3" = "stall" ]; then
    disk_error "The drive stopped answering mid-transfer, which is a head retrying a seek, not slow data."
  fi
  if [ "$1" -eq 1 ]; then
    disk_error "The drive dropped off the bus mid-operation, which is a hardware fault, not bad data."
  fi
  if disk_head_crash_family && { [ "$1" -eq 1 ] || [ "$2" != "other" ] || [ -n "$3" ]; }; then
    disk_error "On a ${DISK_FAMILY} drive this is the click of death: the head is out of alignment."
    disk_error "The drive will damage every cartridge you insert next, and this cartridge will damage every drive."
    disk_error "Retire both. Do not test this cartridge in a working drive to confirm."
    disk_error "One stall is the whole verdict. There is no reading it again to be sure."
    return 0
  fi
  disk_error "A drive that fails this way can damage the next media it is given."
  return 0
}

disk_fault() {
  disk_ft_disk="$1"
  disk_ft_kind="${3:-}"
  disk_ft_gone=0
  disk_ft_detail="$(disk_get_error)"
  [ -z "${disk_ft_detail}" ] && disk_ft_detail="${DISK_LAST_DETAIL:-}"
  disk_ft_class="$(disk_error_class "${disk_ft_detail}")"

  disk_error "STOPPED: $2"
  [ -n "${disk_ft_detail}" ] && disk_error "dd said: ${disk_ft_detail}"
  case "${disk_ft_detail}" in
    *[Rr]ead-only* | *"Permission denied"* | *EROFS*)
      disk_error "That reads as write protection rather than worn media."
      disk_write_protect_advice
      ;;
    *) ;;
  esac

  disk_device_gone "${disk_ft_disk}" && disk_ft_gone=1
  if [ "${disk_ft_gone}" -eq 1 ]; then
    disk_error "${disk_ft_disk} is no longer on the bus, so there is nothing left to eject by software."
  else
    disk_error "Ejecting immediately rather than continuing."
    disk_bounded 20 sync >/dev/null 2>&1
    disk_eject_now "${disk_ft_disk}"
  fi

  disk_head_crash_advice "${disk_ft_gone}" "${disk_ft_class}" "${disk_ft_kind}"
  DISK_LAST_DETAIL=""
  return 1
}

disk_bit_report() {
  disk_br_sample="${BIT_SAMPLE:-65536}"
  { cmp -l -n "$3" "$1" "$2" 2>/dev/null || true; } |
    awk -v sample="${disk_br_sample}" -f "${DISK_LIB}/bitreport.awk"
}
