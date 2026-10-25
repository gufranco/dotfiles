#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_tune() {
  DISK_PROBES=7
  DISK_REPEATS=3
  DISK_RETRIES=3
  DISK_FACTOR_MIN=300
  DISK_FACTOR_MAX=1200
  DISK_SLACK=2
  DISK_CHUNK_TARGET=3000
  DISK_DEADLINE_CAP="${DEADLINE_CAP_MS:-120000}"
  DISK_PROBE_CEILING="${PROBE_CEILING_MS:-15000}"
  if disk_fragile; then
    DISK_PROBES=2
    DISK_REPEATS=1
    DISK_RETRIES=1
    DISK_FACTOR_MIN=250
    DISK_FACTOR_MAX=400
    disk_info "Handling this as fragile media: fewer seeks while measuring, and no retry on a failed chunk."
  fi
  if disk_head_crash_family; then
    DISK_FACTOR_MIN=175
    DISK_FACTOR_MAX=250
    DISK_SLACK=1
    DISK_CHUNK_TARGET=1000
    DISK_PROBE_CEILING="${PROBE_CEILING_MS:-4000}"
    DISK_DEADLINE_CAP="${DEADLINE_CAP_MS:-${DISK_PROBE_CEILING}}"
    disk_info "A ${DISK_FAMILY} head that mistracks destroys the cartridge and then the next drive it meets."
    disk_info "Every transfer is therefore cut off at its own deadline rather than waited on, and one stall ends the run."
  fi
  if disk_fragile; then
    disk_tn_shown="$(disk_duration "${DISK_PROBE_CEILING}")"
    disk_info "Any transfer past ${disk_tn_shown} stops the run, because that is a head retrying rather than reading."
  fi
  return 0
}

disk_reset_measurements() {
  DISK_DRIFT_WRITE=100
  DISK_DRIFT_READ=100
  DISK_MEASURED=0
  DISK_RATE_READ=0
  DISK_RATE_WRITE=0
  DISK_OVERHEAD_READ=0
  DISK_OVERHEAD_WRITE=0
  DISK_FACTOR_READ=0
  DISK_FACTOR_WRITE=0
  DISK_TIMED_OUT=0
  DISK_INTERRUPTED=0
  DISK_DEADLINE="$(disk_idle_deadline)"
  return 0
}

disk_set_ceiling() {
  DISK_CEILING=1048576
  while [ "${DISK_CEILING}" -gt "${DISK_SECTOR}" ] && [ $((DISK_CEILING * 16)) -gt "$1" ]; do
    DISK_CEILING=$((DISK_CEILING / 2))
  done
  return 0
}

disk_pattern_file() {
  disk_pf_target="${DISK_TMPDIR}/pattern-$2"
  disk_pf_size="$(disk_file_size "${disk_pf_target}")"
  if [ ! -f "${disk_pf_target}" ] || [ "${disk_pf_size}" -ne "$1" ]; then
    case "$2" in
      0x00) head -c "$1" /dev/zero >"${disk_pf_target}" || return 1 ;;
      0xFF) head -c "$1" /dev/zero | tr '\000' '\377' >"${disk_pf_target}" || return 1 ;;
      0xAA) head -c "$1" /dev/zero | tr '\000' '\252' >"${disk_pf_target}" || return 1 ;;
      0x55) head -c "$1" /dev/zero | tr '\000' '\125' >"${disk_pf_target}" || return 1 ;;
      *) return 1 ;;
    esac
  fi
  disk_pf_size="$(disk_file_size "${disk_pf_target}")"
  [ "${disk_pf_size}" -eq "$1" ] || return 1
  printf '%s\n' "${disk_pf_target}"
}

disk_expected_ms() {
  if [ "$1" = "write" ]; then
    disk_ex_overhead="${DISK_OVERHEAD_WRITE}"
    disk_ex_rate="${DISK_RATE_WRITE}"
  else
    disk_ex_overhead="${DISK_OVERHEAD_READ}"
    disk_ex_rate="${DISK_RATE_READ}"
  fi
  if [ "${disk_ex_rate:-0}" -le 0 ]; then
    printf '0\n'
    return 0
  fi
  printf '%s\n' "$((disk_ex_overhead + ($2 * 1000) / disk_ex_rate))"
}

disk_time_move() {
  disk_tm_direction="$1"
  disk_tm_io="$2"
  disk_tm_bytes="$4"
  if [ "${disk_tm_direction}" = "write" ]; then
    disk_tm_source="$(disk_pattern_file "${disk_tm_bytes}" 0x00)" || return 1
    disk_tm_target="${disk_tm_io}"
  else
    disk_tm_source="${disk_tm_io}"
    disk_tm_target="${DISK_TMPDIR}/calibration"
    disk_flush_reads "${disk_tm_io}"
  fi

  disk_tm_started="$(disk_now_ms)"
  disk_move "${disk_tm_direction}" "${disk_tm_source}" "${disk_tm_target}" "$3" "${disk_tm_bytes}" || return 1
  disk_tm_now="$(disk_now_ms)"
  disk_tm_elapsed=$((disk_tm_now - disk_tm_started))

  [ "${DISK_MOVED}" -eq "${disk_tm_bytes}" ] || return 1
  if [ "${disk_tm_elapsed}" -lt 0 ]; then
    disk_set_error "the clock went backwards while timing ${disk_tm_bytes} bytes"
    return 1
  fi
  if disk_fragile && [ "${disk_tm_elapsed}" -gt "${DISK_PROBE_CEILING}" ]; then
    disk_tm_shown="$(disk_duration "${disk_tm_elapsed}")"
    disk_set_error "a ${disk_tm_bytes} byte ${disk_tm_direction} took ${disk_tm_shown}, which is a drive retrying a seek rather than reading"
    return 1
  fi
  printf '%s\n' "${disk_tm_elapsed}"
}

disk_quietest_move() {
  disk_qm_attempt=0
  disk_qm_quietest=""
  while [ "${disk_qm_attempt}" -lt "${DISK_REPEATS}" ]; do
    disk_qm_elapsed="$(disk_time_move "$1" "$2" "$3" "$4")" || return 1
    if [ -z "${disk_qm_quietest}" ] || [ "${disk_qm_elapsed}" -lt "${disk_qm_quietest}" ]; then
      disk_qm_quietest="${disk_qm_elapsed}"
    fi
    disk_qm_attempt=$((disk_qm_attempt + 1))
  done
  printf '%s\n' "${disk_qm_quietest}"
}

disk_probe_bytes() {
  disk_pb_floor="${CALIBRATION_FLOOR_MS:-50}"
  disk_pb_candidate=65536
  [ "${disk_pb_candidate}" -lt $(($3 * 2)) ] && disk_pb_candidate=$(($3 * 2))
  [ "${disk_pb_candidate}" -gt "$4" ] && disk_pb_candidate="$4"
  while [ "${disk_pb_candidate}" -lt "$4" ]; do
    disk_pb_elapsed="$(disk_quietest_move "$1" "$2" 0 "${disk_pb_candidate}")" || return 1
    [ "${disk_pb_elapsed}" -ge "${disk_pb_floor}" ] && break
    disk_pb_candidate=$((disk_pb_candidate * 2))
  done
  [ "${disk_pb_candidate}" -gt "$4" ] && disk_pb_candidate="$4"
  printf '%s\n' "${disk_pb_candidate}"
}

disk_probe_verdict() {
  disk_pv_class="$(disk_error_class "${DISK_LAST_DETAIL:-}")"
  if [ "${disk_pv_class}" = "bus" ] || disk_device_gone "$2"; then
    disk_error "$2 stopped answering the bus, so this is the drive or the cartridge, not the data."
    return 2
  fi
  [ "$1" = "write" ] && return 2
  if disk_fragile; then
    disk_error "A ${DISK_FAMILY} disk that cannot be read during a light probe is already failing."
    disk_error "Stopping here rather than seeking across it again."
    return 2
  fi
  disk_warning "That was a read of data this ${DISK_ACTION_NOUN:-run} is about to overwrite, so it does not decide anything."
  disk_warning "Continuing. The verify after each write is what judges the media."
  return 1
}

disk_calibrate() {
  disk_cb_direction="$1"
  disk_cb_disk="$2"
  disk_cb_size="$3"
  disk_cb_probes="${CALIBRATION_PROBES:-${DISK_PROBES}}"
  disk_cb_io="$(disk_io_device "${disk_cb_disk}")"
  disk_cb_unit="${DISK_SECTOR}"
  disk_cb_overheads="${DISK_TMPDIR}/cal-overhead"
  disk_cb_rates="${DISK_TMPDIR}/cal-rate"
  disk_cb_transfers="${DISK_TMPDIR}/cal-transfer"
  [ "${disk_cb_unit}" -lt 4096 ] && disk_cb_unit=4096
  [ "${disk_cb_probes}" -ge 1 ] || disk_cb_probes=1

  disk_cb_stride=$((disk_cb_size / disk_cb_probes))
  disk_cb_stride=$((disk_cb_stride - disk_cb_stride % disk_cb_unit))
  if [ "${disk_cb_stride}" -lt $((disk_cb_unit * 4)) ]; then
    disk_cb_probes=1
    disk_cb_stride="${disk_cb_size}"
  fi

  disk_cb_room=$((disk_cb_stride / 2))
  [ "${disk_cb_room}" -gt 16777216 ] && disk_cb_room=16777216
  disk_cb_room=$((disk_cb_room - disk_cb_room % disk_cb_unit))
  if [ "${disk_cb_room}" -lt $((disk_cb_unit * 2)) ] || [ $((disk_cb_room + disk_cb_unit)) -gt "${disk_cb_size}" ]; then
    disk_warning "${disk_cb_disk} is too small to time, so only the byte-for-byte verify will judge it."
    return 1
  fi

  if ! disk_cb_large="$(disk_probe_bytes "${disk_cb_direction}" "${disk_cb_io}" "${disk_cb_unit}" "${disk_cb_room}")"; then
    disk_report_failure "The ${disk_cb_direction} probe failed on the first sectors of ${disk_cb_disk}."
    disk_probe_verdict "${disk_cb_direction}" "${disk_cb_disk}"
    return "$?"
  fi

  : >"${disk_cb_overheads}"
  : >"${disk_cb_rates}"
  : >"${disk_cb_transfers}"

  disk_cb_index=0
  while [ "${disk_cb_index}" -lt "${disk_cb_probes}" ]; do
    disk_cb_offset=$((disk_cb_index * disk_cb_stride))
    [ $((disk_cb_offset + disk_cb_large + disk_cb_unit)) -gt "${disk_cb_size}" ] && break
    if ! disk_cb_short="$(disk_time_move "${disk_cb_direction}" "${disk_cb_io}" "${disk_cb_offset}" "${disk_cb_unit}")"; then
      disk_report_failure "The ${disk_cb_direction} probe failed at offset ${disk_cb_offset} of ${disk_cb_disk}."
      disk_probe_verdict "${disk_cb_direction}" "${disk_cb_disk}"
      return "$?"
    fi
    disk_cb_next=$((disk_cb_offset + disk_cb_unit))
    if ! disk_cb_long="$(disk_time_move "${disk_cb_direction}" "${disk_cb_io}" "${disk_cb_next}" "${disk_cb_large}")"; then
      disk_report_failure "The ${disk_cb_direction} probe failed at offset ${disk_cb_next} of ${disk_cb_disk}."
      disk_probe_verdict "${disk_cb_direction}" "${disk_cb_disk}"
      return "$?"
    fi
    printf '%s\n' "${disk_cb_short}" >>"${disk_cb_overheads}"
    printf '%s\n' "${disk_cb_long}" >>"${disk_cb_transfers}"
    if [ "${disk_cb_long}" -gt "${disk_cb_short}" ]; then
      printf '%s\n' "$(((disk_cb_large - disk_cb_unit) * 1000 / (disk_cb_long - disk_cb_short)))" >>"${disk_cb_rates}"
    fi
    disk_cb_index=$((disk_cb_index + 1))
  done

  disk_cb_overhead="$(disk_median <"${disk_cb_overheads}")"
  disk_cb_rate="$(disk_median <"${disk_cb_rates}")"
  if [ "${disk_cb_rate:-0}" -le 0 ]; then
    disk_cb_long="$(disk_median <"${disk_cb_transfers}")"
    if [ "${disk_cb_long:-0}" -le 0 ]; then
      disk_warning "${disk_cb_disk} answered too fast to time, so only the byte-for-byte verify will judge it."
      return 1
    fi
    disk_cb_overhead=0
    disk_cb_rate=$((disk_cb_large * 1000 / disk_cb_long))
    disk_info "Separating ${disk_cb_direction} overhead from throughput was not possible, so the whole probe sets the pace."
  fi

  disk_cb_predicted=$((disk_cb_overhead + (disk_cb_large * 1000) / disk_cb_rate))
  [ "${disk_cb_predicted}" -lt 1 ] && disk_cb_predicted=1
  disk_cb_slowest="$(sort -n "${disk_cb_transfers}")"
  disk_cb_slowest="$(printf '%s\n' "${disk_cb_slowest}" | sed -n '$p')"
  disk_cb_spread=$((disk_cb_slowest * 100 / disk_cb_predicted))
  [ "${disk_cb_spread}" -lt 100 ] && disk_cb_spread=100
  disk_cb_spread=$((disk_cb_spread * disk_cb_spread / 100))
  [ "${disk_cb_spread}" -lt "${DISK_FACTOR_MIN}" ] && disk_cb_spread="${DISK_FACTOR_MIN}"
  [ "${disk_cb_spread}" -gt "${DISK_FACTOR_MAX}" ] && disk_cb_spread="${DISK_FACTOR_MAX}"
  [ -n "${SLOW_FACTOR:-}" ] && disk_cb_spread=$((SLOW_FACTOR * 100))

  if [ "${disk_cb_direction}" = "write" ]; then
    DISK_OVERHEAD_WRITE="${disk_cb_overhead}"
    DISK_RATE_WRITE="${disk_cb_rate}"
    DISK_FACTOR_WRITE="${disk_cb_spread}"
  else
    DISK_OVERHEAD_READ="${disk_cb_overhead}"
    DISK_RATE_READ="${disk_cb_rate}"
    DISK_FACTOR_READ="${disk_cb_spread}"
  fi

  disk_cb_shown="$(disk_duration "${disk_cb_overhead}")"
  disk_info "Measured ${disk_cb_direction}: $((disk_cb_rate / 1024)) KiB/s sustained, ${disk_cb_shown} to reach a sector, allowing $((disk_cb_spread / 100))x that before stopping."
  return 0
}

disk_measure() {
  disk_ms_disk="$1"
  disk_ms_size="$2"
  disk_info "Measuring ${disk_ms_disk} before $3 it, so every limit comes from this disk."
  disk_ms_status=0
  disk_ms_write=0
  disk_calibrate read "${disk_ms_disk}" "${disk_ms_size}" || disk_ms_status="$?"
  if [ "${disk_ms_status}" -ne 2 ] && disk_device_gone "${disk_ms_disk}"; then
    disk_ms_status=2
    disk_error "${disk_ms_disk} left the bus while it was being measured."
  fi
  if [ "${disk_ms_status}" -ne 2 ]; then
    disk_calibrate write "${disk_ms_disk}" "${disk_ms_size}" || disk_ms_write="$?"
    [ "${disk_ms_write}" -gt "${disk_ms_status}" ] && disk_ms_status="${disk_ms_write}"
  fi

  case "${disk_ms_status}" in
    0)
      DISK_MEASURED=1
      ;;
    2)
      disk_fault "${disk_ms_disk}" "the disk failed while being measured, before $4 started"
      return 1
      ;;
    *)
      if disk_fragile; then
        disk_error "STOPPED: this disk could not be timed, so nothing would be watching for a stall."
        disk_error "On ${DISK_FAMILY} media the clock is what catches a failing head before it scores the surface."
        disk_error "Running blind would risk the cartridge and the drive, so this stops here."
        disk_eject_now "${disk_ms_disk}"
        return 1
      fi
      disk_warning "Speed is not being watched on this disk. Only the byte-for-byte verify decides."
      ;;
  esac

  if [ "${DISK_MEASURED}" = "1" ]; then
    DISK_CHUNK="$(disk_chunk_bytes "${disk_ms_size}")"
  else
    DISK_CHUNK="${DISK_CEILING}"
    [ "${DISK_CHUNK}" -gt "${disk_ms_size}" ] && DISK_CHUNK="${disk_ms_size}"
  fi
  return 0
}

disk_chunk_bytes() {
  disk_ck_target="${CHUNK_TARGET_MS:-${DISK_CHUNK_TARGET}}"
  disk_ck_unit="${DISK_SECTOR}"
  [ "${disk_ck_unit}" -lt 4096 ] && disk_ck_unit=4096
  disk_ck_candidate="${disk_ck_unit}"
  disk_ck_best="${disk_ck_unit}"
  while [ "${disk_ck_candidate}" -le 67108864 ] && [ "${disk_ck_candidate}" -le "$1" ]; do
    if [ "${disk_ck_candidate}" -gt "${disk_ck_unit}" ]; then
      disk_ck_expected="$(disk_expected_ms write "${disk_ck_candidate}")"
      [ "${disk_ck_expected}" -gt "${disk_ck_target}" ] && break
    fi
    disk_ck_best="${disk_ck_candidate}"
    disk_ck_candidate=$((disk_ck_candidate * 2))
  done
  [ "${disk_ck_best}" -gt "$1" ] && disk_ck_best="$1"
  printf '%s\n' "${disk_ck_best}"
}

disk_budget_ms() {
  if [ "${DISK_MEASURED}" != "1" ] || [ "$2" -le 0 ]; then
    printf '0\n'
    return 0
  fi
  disk_bg_expected="$(disk_expected_ms "$1" "$2")"
  [ "${disk_bg_expected}" -lt 1 ] && disk_bg_expected=1
  if [ "$1" = "write" ]; then
    disk_bg_factor="${DISK_FACTOR_WRITE}"
    disk_bg_drift="${DISK_DRIFT_WRITE}"
    disk_bg_slack=$((DISK_OVERHEAD_WRITE * DISK_SLACK))
  else
    disk_bg_factor="${DISK_FACTOR_READ}"
    disk_bg_drift="${DISK_DRIFT_READ}"
    disk_bg_slack=$((DISK_OVERHEAD_READ * DISK_SLACK))
  fi
  [ "${disk_bg_drift}" -lt 100 ] && disk_bg_drift=100
  disk_bg_baseline=$((disk_bg_expected * disk_bg_drift / 100))
  disk_bg_budget=$((disk_bg_baseline * disk_bg_factor / 100))
  [ "${disk_bg_budget}" -lt $((disk_bg_baseline + disk_bg_slack)) ] && disk_bg_budget=$((disk_bg_baseline + disk_bg_slack))
  printf '%s\n' "${disk_bg_budget}"
}

disk_idle_deadline() {
  if disk_fragile; then
    printf '%s\n' "${DISK_PROBE_CEILING}"
  else
    printf '%s\n' "${DISK_DEADLINE_CAP}"
  fi
}

disk_deadline_ms() {
  disk_dl_budget="$(disk_budget_ms "$1" "$2")"
  [ "${disk_dl_budget:-0}" -le 0 ] && disk_dl_budget="${DISK_DEADLINE_CAP}"
  [ "${disk_dl_budget}" -lt 2000 ] && disk_dl_budget=2000
  [ "${disk_dl_budget}" -gt "${DISK_DEADLINE_CAP}" ] && disk_dl_budget="${DISK_DEADLINE_CAP}"
  printf '%s\n' "${disk_dl_budget}"
}

disk_watch() {
  disk_wt_kind="$1"
  disk_wt_label="$2"
  disk_wt_where="chunk $3 of $4"
  disk_wt_bytes="$5"
  disk_wt_elapsed="$6"
  disk_wt_ceiling=$((${STALL_SECONDS:-0} * 1000))
  DISK_REASON=""
  disk_wt_took="$(disk_duration "${disk_wt_elapsed}")"

  if [ "${disk_wt_ceiling}" -gt 0 ] && [ "${disk_wt_elapsed}" -gt "${disk_wt_ceiling}" ]; then
    disk_wt_shown="$(disk_duration "${disk_wt_ceiling}")"
    DISK_REASON="${disk_wt_label} ${disk_wt_where} took ${disk_wt_took}, over the ${disk_wt_shown} limit you set"
    return 1
  fi
  [ "${DISK_MEASURED}" = "1" ] || return 0
  [ "${disk_wt_bytes}" -le 0 ] && return 0

  disk_wt_expected="$(disk_expected_ms "${disk_wt_kind}" "${disk_wt_bytes}")"
  [ "${disk_wt_expected}" -lt 1 ] && disk_wt_expected=1
  if [ "${disk_wt_kind}" = "write" ]; then
    disk_wt_factor="${DISK_FACTOR_WRITE}"
    disk_wt_drift="${DISK_DRIFT_WRITE}"
  else
    disk_wt_factor="${DISK_FACTOR_READ}"
    disk_wt_drift="${DISK_DRIFT_READ}"
  fi
  [ "${disk_wt_drift}" -lt 100 ] && disk_wt_drift=100
  disk_wt_budget="$(disk_budget_ms "${disk_wt_kind}" "${disk_wt_bytes}")"
  if [ "${disk_wt_budget}" -gt 0 ] && [ "${disk_wt_elapsed}" -gt "${disk_wt_budget}" ]; then
    disk_wt_shown="$(disk_duration "${disk_wt_budget}")"
    DISK_REASON="${disk_wt_label} ${disk_wt_where} took ${disk_wt_took} against ${disk_wt_shown} allowed by what this disk measured"
    return 1
  fi

  disk_wt_ratio=$((disk_wt_elapsed * 100 / disk_wt_expected))
  [ "${disk_wt_ratio}" -lt 1 ] && disk_wt_ratio=1
  disk_wt_drift=$(((disk_wt_drift * 3 + disk_wt_ratio) / 4))
  if [ "${disk_wt_drift}" -gt "${disk_wt_factor}" ]; then
    DISK_REASON="${disk_wt_label} has settled at $((disk_wt_drift / 100))x the speed this disk measured on itself, which it held for the last chunks"
    return 1
  fi
  if [ "${disk_wt_kind}" = "write" ]; then
    DISK_DRIFT_WRITE="${disk_wt_drift}"
  else
    DISK_DRIFT_READ="${disk_wt_drift}"
  fi
  return 0
}
