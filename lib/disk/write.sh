#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_padded_size() {
  printf '%s\n' "$((($1 + $2 - 1) / $2 * $2))"
}

disk_head_size() {
  disk_hz_head=1048576
  [ "${disk_hz_head}" -lt "$2" ] && disk_hz_head="$2"
  disk_hz_head=$(((disk_hz_head + $2 - 1) / $2 * $2))
  [ "${disk_hz_head}" -gt "$1" ] && disk_hz_head="$1"
  printf '%s\n' "${disk_hz_head}"
}

disk_pad_file() {
  disk_pd_size="$(disk_file_size "$1")"
  [ "${disk_pd_size}" -lt "$2" ] || return 0
  head -c $(($2 - disk_pd_size)) /dev/zero >>"$1"
}

disk_write_chunk() {
  disk_wc_file="$1"
  disk_wc_io="$2"
  disk_wc_offset="$3"
  disk_wc_piece="$4"
  disk_wc_label="$5"
  disk_wc_attempts="${CHUNK_RETRIES:-${DISK_RETRIES}}"
  [ "${disk_wc_attempts}" -ge 1 ] || disk_wc_attempts=1
  DISK_ATTEMPT=1
  DISK_BITS=""
  while [ "${DISK_ATTEMPT}" -le "${disk_wc_attempts}" ]; do
    [ -f "${DISK_STOP_FILE}" ] && {
      DISK_OUTCOME=4
      return 1
    }
    DISK_DEADLINE="$(disk_deadline_ms write "${disk_wc_piece}")"
    DISK_OUTCOME=0
    disk_wipe_attempt write "${disk_wc_file}" "${disk_wc_io}" "${disk_wc_offset}" "${disk_wc_piece}" "${disk_wc_label}" image ||
      DISK_OUTCOME="$?"
    if [ "${DISK_OUTCOME}" -eq 0 ]; then
      DISK_WRITE_ELAPSED="${DISK_ELAPSED}"
      disk_flush_reads "${disk_wc_io}"
      DISK_DEADLINE="$(disk_deadline_ms read "${disk_wc_piece}")"
      disk_wipe_attempt read "${disk_wc_file}" "${disk_wc_io}" "${disk_wc_offset}" "${disk_wc_piece}" "${disk_wc_label}" "the image" ||
        DISK_OUTCOME="$?"
    fi
    case "${DISK_OUTCOME}" in
      0) return 0 ;;
      2 | 3 | 4 | 5) return 1 ;;
      *) DISK_ATTEMPT=$((DISK_ATTEMPT + 1)) ;;
    esac
  done
  DISK_ATTEMPTS="${disk_wc_attempts}"
  return 1
}

disk_place() {
  disk_pl_disk="$1"
  disk_pl_file="$2"
  disk_pl_offset="$3"
  disk_pl_piece="$4"
  disk_pl_number="$5"
  disk_pl_io="$(disk_io_device "${disk_pl_disk}")"
  if ! disk_write_chunk "${disk_pl_file}" "${disk_pl_io}" "${disk_pl_offset}" "${disk_pl_piece}" "${disk_pl_number} of ${DISK_TOTAL}"; then
    disk_pl_chunk="${disk_pl_number%% *}"
    disk_chunk_failed "${disk_pl_disk}" write "${disk_pl_chunk}" "${DISK_TOTAL}" "${disk_pl_offset}"
    return 1
  fi
  if [ "${DISK_ATTEMPT}" -gt 1 ]; then
    DISK_MARGINAL=$((DISK_MARGINAL + 1))
    disk_warning "chunk ${disk_pl_number} of ${DISK_TOTAL} needed ${DISK_ATTEMPT} attempts at offset ${disk_pl_offset}"
    disk_log_lines disk_warning "${DISK_BITS}"
  fi
  if ! disk_watch write write "${disk_pl_number}" "${DISK_TOTAL}" "${disk_pl_piece}" "${DISK_WRITE_ELAPSED}" ||
    ! disk_watch read read "${disk_pl_number}" "${DISK_TOTAL}" "${disk_pl_piece}" "${DISK_ELAPSED}"; then
    disk_fault "${disk_pl_disk}" "${DISK_REASON}" stall
    return 1
  fi
  DISK_DONE=$((DISK_DONE + disk_pl_piece))
  disk_progress Writing "${DISK_DONE}" "${DISK_WORK_BYTES}" "${DISK_STARTED}"
  return 0
}

disk_zero_range() {
  disk_zr_zero="$(disk_pattern_file "${DISK_CHUNK}" 0x00)" || return 1
  disk_zr_offset="$2"
  while [ "${disk_zr_offset}" -lt "$3" ]; do
    disk_zr_piece=$(($3 - disk_zr_offset))
    [ "${disk_zr_piece}" -gt "${DISK_CHUNK}" ] && disk_zr_piece="${DISK_CHUNK}"
    disk_zr_number=$((disk_zr_offset / DISK_CHUNK + 1))
    disk_place "$1" "${disk_zr_zero}" "${disk_zr_offset}" "${disk_zr_piece}" "${disk_zr_number}" || return 1
    disk_zr_offset=$((disk_zr_offset + disk_zr_piece))
  done
  return 0
}

disk_body() {
  disk_bd_offset=0
  disk_bd_index=0
  : >"${DISK_TMPDIR}/head.img"
  while [ "${disk_bd_offset}" -lt "${DISK_PADDED}" ]; do
    disk_bd_piece=$((DISK_PADDED - disk_bd_offset))
    [ "${disk_bd_piece}" -gt "${DISK_CHUNK}" ] && disk_bd_piece="${DISK_CHUNK}"
    disk_bd_index=$((disk_bd_index + 1))
    disk_bd_file="${DISK_TMPDIR}/chunk"
    [ "${disk_bd_offset}" -lt "${DISK_HEAD}" ] && disk_bd_file="${DISK_TMPDIR}/head-${disk_bd_index}"
    if ! disk_source_read "${disk_bd_offset}" "${DISK_CHUNK}" "${disk_bd_file}"; then
      disk_error "STOPPED: the image could not be read at offset ${disk_bd_offset}."
      return 1
    fi
    disk_pad_file "${disk_bd_file}" "${disk_bd_piece}" || return 1
    if [ "${disk_bd_offset}" -lt "${DISK_HEAD}" ]; then
      cat "${disk_bd_file}" >>"${DISK_TMPDIR}/head.img" || return 1
    else
      disk_place "$1" "${disk_bd_file}" "${disk_bd_offset}" "${disk_bd_piece}" "${disk_bd_index}" || return 1
    fi
    disk_bd_offset=$((disk_bd_offset + disk_bd_piece))
  done
  return 0
}

disk_head_last() {
  disk_hl_offset=0
  disk_hl_index=0
  while [ "${disk_hl_offset}" -lt "${DISK_HEAD}" ]; do
    disk_hl_index=$((disk_hl_index + 1))
    disk_hl_piece=$((DISK_HEAD - disk_hl_offset))
    [ "${disk_hl_piece}" -gt "${DISK_CHUNK}" ] && disk_hl_piece="${DISK_CHUNK}"
    disk_place "$1" "${DISK_TMPDIR}/head-${disk_hl_index}" "${disk_hl_offset}" "${disk_hl_piece}" "${disk_hl_index}" || return 1
    disk_hl_offset=$((disk_hl_offset + disk_hl_piece))
  done
  sync
  return 0
}

disk_validate_target() {
  disk_vt_io="$(disk_io_device "$1")"
  disk_flush_reads "${disk_vt_io}"
  disk_vt_human="$(disk_human "$2")"
  disk_info "Reading back all ${disk_vt_human} to compare with the image."
  disk_vt_hash="$({ sudo dd if="${disk_vt_io}" bs=1048576 2>/dev/null || true; } | head -c "$2" | disk_sha256_stdin)"
  if [ "${disk_vt_hash}" != "$3" ]; then
    disk_error "STOPPED: $1 does not hold the image. Expected SHA-256 $3, read ${disk_vt_hash}."
    return 1
  fi
  disk_success "Validated: $1 matches the image, SHA-256 ${disk_vt_hash}"
  return 0
}

disk_write_stages() {
  disk_ws_disk="$1"
  disk_ws_size="$2"
  DISK_PADDED="$(disk_padded_size "${DISK_SRC_SIZE}" "${DISK_SECTOR}")"
  DISK_HEAD="$(disk_head_size "${DISK_PADDED}" "${DISK_CHUNK}")"
  DISK_TOTAL=$(((DISK_PADDED + DISK_CHUNK - 1) / DISK_CHUNK))
  DISK_DONE=0
  DISK_MARGINAL=0
  DISK_PROGRESS_STEP=0
  DISK_WORK_BYTES=$((DISK_PADDED + DISK_HEAD))
  [ "${ZERO_TAIL:-}" = "y" ] && DISK_WORK_BYTES=$((DISK_WORK_BYTES + disk_ws_size - DISK_PADDED))
  DISK_STARTED="$(disk_now_ms)"

  disk_ws_head="$(disk_human "${DISK_HEAD}")"
  disk_info "Blanking the first ${disk_ws_head} so nothing on ${disk_ws_disk} is mountable until the very end."
  disk_zero_range "${disk_ws_disk}" 0 "${DISK_HEAD}" || return 1
  [ "${DISK_SRC_STREAM}" = "1" ] && { disk_stream_start "${DISK_TMPDIR}" || return 1; }
  disk_ws_status=0
  disk_body "${disk_ws_disk}" || disk_ws_status=1
  [ "${DISK_SRC_STREAM}" = "1" ] && disk_stream_stop
  [ "${disk_ws_status}" -eq 0 ] || return 1
  if [ "${ZERO_TAIL:-}" = "y" ] && [ "${disk_ws_size}" -gt "${DISK_PADDED}" ]; then
    disk_ws_tail="$(disk_human $((disk_ws_size - DISK_PADDED)))"
    disk_info "Zeroing the ${disk_ws_tail} past the image."
    disk_zero_range "${disk_ws_disk}" "${DISK_PADDED}" "${disk_ws_size}" || return 1
  fi
  disk_guard_declare "${disk_ws_disk}" "${DISK_TMPDIR}/head.img" "${disk_ws_size}" || {
    disk_eject_now "${disk_ws_disk}"
    return 1
  }
  disk_info "Writing the first ${disk_ws_head} last."
  disk_head_last "${disk_ws_disk}" || return 1
  disk_success "Wrote and verified every chunk of the image."
  if [ "${DISK_MARGINAL}" -gt 0 ]; then
    disk_warning "${DISK_MARGINAL} chunks only settled on a retry. This media is wearing out."
  fi
  return 0
}

disk_write_prepare() {
  DISK_FAMILY="$(disk_family_of "$2")"
  disk_tune
  DISK_SECTOR="$(disk_sector_bytes "$1")"
  disk_wpp_writable=0
  disk_writable_media "$1" || disk_wpp_writable="$?"
  if [ "${disk_wpp_writable}" -eq 1 ]; then
    disk_report_write_protected "$1" flag written
    return 1
  fi
  disk_unmount_for_write "$1" || return 1
  disk_wpp_io="$(disk_io_device "$1")"
  disk_probe_cache_bypass "${disk_wpp_io}" "${DISK_SECTOR}"
  disk_reset_measurements
  disk_wpp_landed=0
  disk_writes_land "$1" || disk_wpp_landed="$?"
  if [ "${disk_wpp_landed}" -eq 1 ]; then
    disk_report_write_protected "$1" silent written
    return 1
  fi
  disk_wpp_size="$(disk_size_bytes "$1")"
  disk_wpp_size=$((disk_wpp_size - disk_wpp_size % DISK_SECTOR))
  disk_wpp_span="$(disk_padded_size "${DISK_SRC_SIZE}" "${DISK_SECTOR}")"
  [ "${ZERO_TAIL:-}" = "y" ] && disk_wpp_span="${disk_wpp_size}"
  disk_set_ceiling "${disk_wpp_span}"
  disk_measure "$1" "${disk_wpp_span}" writing "the write" || return 1
  printf '%s\n' "${disk_wpp_size}" >"${DISK_TMPDIR}/size"
  return 0
}

disk_write_target() {
  disk_wt_disk="$1"
  DISK_ACTION_NOUN="write"
  disk_make_tmpdir kakikomi || return 1
  disk_wt_status=0
  disk_wt_raw="$(disk_size_bytes "${disk_wt_disk}")"
  disk_guard_on "${disk_wt_disk}" || {
    disk_error "STOPPED: could not stop the system from mounting ${disk_wt_disk}."
    disk_drop_tmpdir
    return 1
  }
  disk_breach_start "${disk_wt_disk}"
  disk_write_prepare "${disk_wt_disk}" "$2" || disk_wt_status=1
  if [ "${disk_wt_status}" -eq 0 ]; then
    disk_wt_size="$(cat "${DISK_TMPDIR}/size")"
    disk_write_stages "${disk_wt_disk}" "${disk_wt_size}" || disk_wt_status=1
  fi
  if [ "${disk_wt_status}" -eq 0 ] && [ "${VERIFY:-y}" != "n" ]; then
    disk_validate_target "${disk_wt_disk}" "${DISK_SRC_SIZE}" "${DISK_SRC_SHA}" || disk_wt_status=1
  fi
  if [ "${disk_wt_status}" -eq 0 ]; then
    disk_finish_eject "${disk_wt_disk}"
    disk_reinsert_check "${disk_wt_disk}" "${disk_wt_raw}" "$2" || disk_wt_status=1
  elif [ -n "${DISK_GUARD_DECLARED}" ]; then
    KEEP_GUARD=y
    disk_warning "The mount guard for ${disk_wt_disk} stays in place. Run kakikomi --release once the disk is out."
  fi
  disk_breach_stop "${disk_wt_disk}" || disk_wt_status=1
  disk_guard_off
  disk_drop_tmpdir
  return "${disk_wt_status}"
}

disk_finish_eject() {
  disk_info "Ejecting $1..."
  case "${DISK_FAMILY}" in
    floppy | superdisk)
      disk_release "$1" >/dev/null 2>&1
      disk_success "Done. This drive has no software eject, so take the disk out now."
      disk_wait_removal "$1"
      ;;
    *)
      if disk_bounded 30 sudo diskutil eject "$1" >/dev/null 2>&1 || disk_bounded 30 sudo eject "$1" >/dev/null 2>&1; then
        disk_success "Ejected. $1 is safe to remove."
      else
        disk_warning "$1 did not eject; it stays unmounted and guarded. Remove it once the light stops."
        disk_wait_removal "$1"
      fi
      ;;
  esac
  return 0
}

disk_wait_removal() {
  disk_wr_waited=0
  disk_wr_limit="${REMOVAL_WAIT_SECONDS:-600}"
  while [ "${disk_wr_waited}" -lt "${disk_wr_limit}" ]; do
    disk_device_gone "$1" && return 0
    sleep 1
    disk_wr_waited=$((disk_wr_waited + 1))
  done
  if [ "${KEEP_GUARD:-}" != "y" ]; then
    KEEP_GUARD=y
    disk_warning "$1 is still attached, so the mount guard stays. Run kakikomi --release after removing it."
  fi
  return 0
}
