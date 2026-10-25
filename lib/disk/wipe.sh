#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_unique_chunk() {
  disk_uc_target="${DISK_TMPDIR}/unique-chunk"
  disk_uc_iv="$(printf '%032x' "$1")"
  head -c "$2" /dev/zero |
    openssl enc -aes-128-ctr -nosalt -K "${DISK_KEY}" -iv "${disk_uc_iv}" >"${disk_uc_target}" || return 1
  disk_uc_size="$(disk_file_size "${disk_uc_target}")"
  [ "${disk_uc_size}" -eq "$2" ] || return 1
  printf '%s\n' "${disk_uc_target}"
}

disk_wipe_phase_announce() {
  if [ "$1" = "write" ]; then
    disk_info "Writing $2 over $3 chunks, timing every chunk"
  else
    disk_flush_reads "$4"
    disk_info "Verifying $2 over $3 chunks, timing every chunk"
  fi
}

disk_wipe_attempt() {
  disk_wa_started="$(disk_now_ms)"
  disk_wa_moved=1
  if [ "$1" = "write" ]; then
    disk_move write "$2" "$3" "$4" "$5" || disk_wa_moved=0
  else
    disk_move read "$3" "${DISK_TMPDIR}/readback" "$4" "$5" || disk_wa_moved=0
  fi
  if [ "${disk_wa_moved}" -eq 0 ]; then
    [ "${DISK_INTERRUPTED:-0}" -eq 1 ] && return 4
    [ "${DISK_TIMED_OUT:-0}" -eq 1 ] && return 3
    disk_wa_detail="$(disk_get_error)"
    disk_wa_class="$(disk_error_class "${disk_wa_detail}")"
    [ "${disk_wa_class}" = "bus" ] && return 2
    if [ "${disk_wa_class}" = "media" ] && disk_head_crash_family; then
      return 5
    fi
    return 1
  fi
  disk_wa_now="$(disk_now_ms)"
  DISK_ELAPSED=$((disk_wa_now - disk_wa_started))
  if [ "${DISK_MOVED}" -ne "$5" ]; then
    disk_set_error "chunk $6 moved ${DISK_MOVED} of $5 bytes"
    return 1
  fi
  [ "$1" = "read" ] || return 0
  disk_wa_reference="$(disk_exact_reference "$2" "$5")" || return 1
  if ! cmp -s "${DISK_TMPDIR}/readback" "${disk_wa_reference}"; then
    disk_set_error "chunk $6 did not read back as $7"
    DISK_BITS="$(disk_bit_report "${disk_wa_reference}" "${DISK_TMPDIR}/readback" "$5")"
    return 1
  fi
  return 0
}

disk_exact_reference() {
  disk_er_size="$(disk_file_size "$1")"
  if [ "${disk_er_size}" -eq "$2" ]; then
    printf '%s\n' "$1"
    return 0
  fi
  head -c "$2" "$1" >"${DISK_TMPDIR}/reference" || return 1
  printf '%s\n' "${DISK_TMPDIR}/reference"
}

disk_chunk_settle() {
  disk_cs_attempts="${CHUNK_RETRIES:-${DISK_RETRIES}}"
  [ "${disk_cs_attempts}" -ge 1 ] || disk_cs_attempts=1
  DISK_ATTEMPT=1
  DISK_OUTCOME=1
  DISK_BITS=""
  while [ "${DISK_ATTEMPT}" -le "${disk_cs_attempts}" ]; do
    DISK_OUTCOME=0
    disk_wipe_attempt "$@" || DISK_OUTCOME="$?"
    case "${DISK_OUTCOME}" in
      0 | 2 | 3 | 4 | 5) return 0 ;;
      *) DISK_ATTEMPT=$((DISK_ATTEMPT + 1)) ;;
    esac
  done
  DISK_ATTEMPTS="${disk_cs_attempts}"
  return 0
}

disk_chunk_failed() {
  disk_cf_disk="$1"
  disk_cf_where="$2 chunk $3 of $4"
  disk_log_lines disk_error "${DISK_BITS}"
  case "${DISK_OUTCOME}" in
    4)
      disk_error "STOPPED: interrupted during ${disk_cf_where}."
      disk_error "Nothing else will be written. Ejecting so the head leaves the surface."
      disk_eject_now "${disk_cf_disk}"
      ;;
    3)
      disk_cf_shown="$(disk_duration "${DISK_DEADLINE}")"
      disk_fault "${disk_cf_disk}" "${disk_cf_where} went silent for ${disk_cf_shown} at offset $5" stall
      ;;
    2)
      disk_fault "${disk_cf_disk}" "${disk_cf_where} stopped answering at offset $5"
      ;;
    *)
      if [ "${DISK_OUTCOME}" -eq 5 ] || disk_head_crash_family; then
        disk_fault "${disk_cf_disk}" "${disk_cf_where} did not come back clean at offset $5" fatal
      else
        disk_fault "${disk_cf_disk}" "${disk_cf_where} failed ${DISK_ATTEMPTS:-1} times at offset $5"
      fi
      ;;
  esac
  return 1
}

disk_run_phase() {
  disk_rp_direction="$1"
  disk_rp_disk="$2"
  disk_rp_size="$3"
  disk_rp_pattern="$4"
  disk_rp_io="$(disk_io_device "${disk_rp_disk}")"
  disk_rp_total=$(((disk_rp_size + DISK_CHUNK - 1) / DISK_CHUNK))
  disk_rp_marginal=0
  disk_rp_shown="${disk_rp_pattern}"
  [ "${disk_rp_pattern}" = "unique" ] && disk_rp_shown="per-chunk unique data"
  if [ "${disk_rp_pattern}" != "unique" ] &&
    ! disk_rp_reference="$(disk_pattern_file "${DISK_CHUNK}" "${disk_rp_pattern}")"; then
    disk_error "Unable to build the ${disk_rp_pattern} reference pattern"
    return 1
  fi
  disk_wipe_phase_announce "${disk_rp_direction}" "${disk_rp_shown}" "${disk_rp_total}" "${disk_rp_io}"

  disk_rp_index=0
  while [ "${disk_rp_index}" -lt "${disk_rp_total}" ]; do
    disk_rp_offset=$((disk_rp_index * DISK_CHUNK))
    disk_rp_piece=$((disk_rp_size - disk_rp_offset))
    [ "${disk_rp_piece}" -gt "${DISK_CHUNK}" ] && disk_rp_piece="${DISK_CHUNK}"
    disk_rp_number=$((disk_rp_index + 1))
    if [ "${disk_rp_pattern}" = "unique" ] &&
      ! disk_rp_reference="$(disk_unique_chunk "${disk_rp_index}" "${disk_rp_piece}")"; then
      disk_error "Unable to build the unique pattern for chunk ${disk_rp_number} of ${disk_rp_total}"
      return 1
    fi

    DISK_DEADLINE="$(disk_deadline_ms "${disk_rp_direction}" "${disk_rp_piece}")"
    disk_chunk_settle "${disk_rp_direction}" "${disk_rp_reference}" "${disk_rp_io}" \
      "${disk_rp_offset}" "${disk_rp_piece}" "${disk_rp_number} of ${disk_rp_total}" "${disk_rp_shown}"
    if [ "${DISK_OUTCOME}" -ne 0 ]; then
      disk_chunk_failed "${disk_rp_disk}" "${disk_rp_direction}" "${disk_rp_number}" "${disk_rp_total}" "${disk_rp_offset}"
      return 1
    fi
    if [ "${DISK_ATTEMPT}" -gt 1 ]; then
      disk_rp_marginal=$((disk_rp_marginal + 1))
      disk_warning "${disk_rp_direction} chunk ${disk_rp_number} of ${disk_rp_total} needed ${DISK_ATTEMPT} attempts at offset ${disk_rp_offset}"
      disk_log_lines disk_warning "${DISK_BITS}"
    fi
    if ! disk_watch "${disk_rp_direction}" "${disk_rp_direction}" "${disk_rp_number}" "${disk_rp_total}" "${disk_rp_piece}" "${DISK_ELAPSED}"; then
      disk_fault "${disk_rp_disk}" "${DISK_REASON}" stall
      return 1
    fi
    disk_rp_index=$((disk_rp_index + 1))
  done

  if [ "${disk_rp_direction}" = "write" ]; then
    sync
    disk_success "Write ${disk_rp_shown} completed"
  else
    disk_success "Verify ${disk_rp_shown} completed"
  fi
  if [ "${disk_rp_marginal}" -gt 0 ]; then
    disk_warning "${disk_rp_marginal} of ${disk_rp_total} chunks only settled on a retry. This media is wearing out."
  fi
  DISK_DEADLINE="$(disk_idle_deadline)"
  return 0
}

disk_execute_pass() {
  disk_info "Pass $3 of $4"
  if ! DISK_KEY="$(openssl rand -hex 16)" || [ "${#DISK_KEY}" -ne 32 ]; then
    disk_error "Unable to generate the key for the unique pattern"
    return 1
  fi
  for disk_ep_pattern in unique 0xAA 0x55 0xFF 0x00; do
    disk_run_phase write "$1" "$2" "${disk_ep_pattern}" || return 1
    disk_run_phase read "$1" "$2" "${disk_ep_pattern}" || return 1
  done
  disk_success "Pass $3/$4 completed"
  return 0
}
