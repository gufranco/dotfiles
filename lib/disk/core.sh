#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_log() {
  disk_log_prefix="$1"
  shift
  if [ -n "${DISK_LOG_TAG}" ]; then
    printf '%b %s: %s\n' "${disk_log_prefix}" "${DISK_LOG_TAG}" "$*"
  else
    printf '%b %s\n' "${disk_log_prefix}" "$*"
  fi
}

disk_info() {
  disk_log '\033[0;34m[INFO]\033[0m' "$@"
}

disk_success() {
  disk_log '\033[0;32m[\0342\0234\0223]\033[0m' "$@"
}

disk_warning() {
  disk_log '\033[0;33m[!]\033[0m' "$@" >&2
}

disk_error() {
  disk_log '\033[0;31m[\0342\0234\0227]\033[0m' "$@" >&2
}

disk_log_lines() {
  disk_ll_level="$1"
  disk_ll_text="$2"
  [ -z "${disk_ll_text}" ] && return 0
  printf '%s\n' "${disk_ll_text}" | while IFS= read -r disk_ll_line; do
    [ -n "${disk_ll_line}" ] && "${disk_ll_level}" "${disk_ll_line}"
  done
  return 0
}

disk_cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

disk_is_uint() {
  case "$1" in
    '' | *[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

disk_os() {
  if [ -z "${DISK_OS:-}" ]; then
    DISK_OS="$(uname -s)"
  fi
  printf '%s\n' "${DISK_OS}"
}

disk_now_ms() {
  if disk_nm_value="$(perl -MTime::HiRes=clock_gettime,CLOCK_MONOTONIC -e 'printf "%d\n", clock_gettime(CLOCK_MONOTONIC) * 1000' 2>/dev/null)" &&
    disk_is_uint "${disk_nm_value}"; then
    printf '%s\n' "${disk_nm_value}"
    return 0
  fi
  if [ -r /proc/uptime ]; then
    disk_nm_uptime=""
    disk_nm_idle=""
    read -r disk_nm_uptime disk_nm_idle </proc/uptime
    disk_nm_whole="${disk_nm_uptime%.*}"
    disk_nm_cents="${disk_nm_uptime#*.}"
    if disk_is_uint "${disk_nm_whole}" && disk_is_uint "${disk_nm_cents}" && [ -n "${disk_nm_idle}" ]; then
      disk_nm_two="1${disk_nm_cents%"${disk_nm_cents#??}"}"
      printf '%s\n' "$((disk_nm_whole * 1000 + (disk_nm_two - 100) * 10))"
      return 0
    fi
  fi
  disk_nm_value="$(date +%s%N 2>/dev/null)"
  if disk_is_uint "${disk_nm_value}" && [ "${#disk_nm_value}" -gt 13 ]; then
    printf '%s\n' "$((disk_nm_value / 1000000))"
    return 0
  fi
  disk_nm_value="$(date +%s)"
  printf '%s\n' "$((disk_nm_value * 1000))"
}

disk_bounded() {
  disk_b_seconds="$1"
  shift

  if disk_cmd_exists timeout; then
    timeout "${disk_b_seconds}" "$@"
    return "$?"
  fi
  if disk_cmd_exists gtimeout; then
    gtimeout "${disk_b_seconds}" "$@"
    return "$?"
  fi

  "$@" &
  disk_b_pid="$!"
  disk_b_waited=0
  while sudo -n kill -0 "${disk_b_pid}" 2>/dev/null; do
    if [ "${disk_b_waited}" -ge "${disk_b_seconds}" ]; then
      sudo -n kill -TERM "${disk_b_pid}" 2>/dev/null
      sleep 1
      sudo -n kill -KILL "${disk_b_pid}" 2>/dev/null
      wait "${disk_b_pid}" 2>/dev/null
      return 124
    fi
    sleep 1
    disk_b_waited=$((disk_b_waited + 1))
  done
  wait "${disk_b_pid}"
}

disk_bounded_ms() {
  disk_bm_ms="$1"
  shift
  disk_bm_runner=""
  if disk_cmd_exists timeout; then
    disk_bm_runner="timeout"
  elif disk_cmd_exists gtimeout; then
    disk_bm_runner="gtimeout"
  fi

  if [ -n "${disk_bm_runner}" ]; then
    disk_bm_limit="$(printf '%d.%03d' "$((disk_bm_ms / 1000))" "$((disk_bm_ms % 1000))")"
    "${disk_bm_runner}" -k 2 "${disk_bm_limit}" "$@"
    return "$?"
  fi

  disk_bm_seconds=$(((disk_bm_ms + 999) / 1000))
  [ "${disk_bm_seconds}" -lt 1 ] && disk_bm_seconds=1
  disk_bounded "${disk_bm_seconds}" "$@"
}

disk_file_size() {
  if [ ! -f "$1" ]; then
    printf '0\n'
    return 0
  fi
  disk_fs_bytes="$(wc -c <"$1")"
  disk_fs_bytes="$(printf '%s' "${disk_fs_bytes}" | tr -d '[:space:]')"
  disk_is_uint "${disk_fs_bytes}" || disk_fs_bytes=0
  printf '%s\n' "${disk_fs_bytes}"
}

disk_duration() {
  if [ "$1" -lt 1000 ]; then
    printf '%sms\n' "$1"
  else
    printf '%ss\n' "$(($1 / 1000))"
  fi
}

disk_median() {
  disk_md_sorted="$(sort -n)"
  printf '%s\n' "${disk_md_sorted}" | awk '
    NF { value[++n] = $1 }
    END {
      if (n == 0) { print 0; exit }
      if (n % 2) { print value[(n + 1) / 2]; exit }
      print int((value[n / 2] + value[n / 2 + 1]) / 2)
    }
  '
}

disk_set_error() {
  DISK_LAST_ERROR="$1"
  if [ -n "${DISK_ERRFILE:-}" ]; then
    printf '%s\n' "$1" >"${DISK_ERRFILE}"
  fi
  return 0
}

disk_get_error() {
  if [ -n "${DISK_ERRFILE:-}" ] && [ -s "${DISK_ERRFILE}" ]; then
    tr -d '\n' <"${DISK_ERRFILE}"
    return 0
  fi
  printf '%s' "${DISK_LAST_ERROR:-}"
}

disk_report_failure() {
  disk_rf_detail="$(disk_get_error)"
  DISK_LAST_DETAIL="${disk_rf_detail}"
  disk_error "$1"
  if [ -n "${disk_rf_detail}" ]; then
    disk_error "dd said: ${disk_rf_detail}"
    disk_set_error ""
  fi
}

disk_io_device() {
  disk_io_name="${1##*/}"
  disk_io_os="$(disk_os)"
  if [ "${disk_io_os}" = "Darwin" ] && [ "${disk_io_name#r}" = "${disk_io_name}" ] &&
    [ -c "/dev/r${disk_io_name}" ]; then
    printf '/dev/r%s\n' "${disk_io_name}"
    return 0
  fi
  printf '%s\n' "$1"
}

disk_plist_value() {
  disk_pv_plist="$(diskutil info -plist "$1" 2>/dev/null)"
  printf '%s' "${disk_pv_plist}" | plutil -extract "$2" raw - 2>/dev/null
}

disk_info_field() {
  disk_if_text="$(diskutil info "$1" 2>/dev/null)"
  printf '%s\n' "${disk_if_text}" | awk -F': +' -v key="$2" '$1 ~ key { print $2; exit }'
}

disk_identity() {
  disk_id_vendor=""
  disk_id_model=""
  disk_id_os="$(disk_os)"
  case "${disk_id_os}" in
    Darwin)
      disk_id_model="$(disk_plist_value "$1" MediaName)"
      ;;
    Linux)
      disk_id_name="${1##*/}"
      disk_id_vendor="$(cat "/sys/block/${disk_id_name}/device/vendor" 2>/dev/null)"
      disk_id_model="$(cat "/sys/block/${disk_id_name}/device/model" 2>/dev/null)"
      if [ -z "${disk_id_vendor}" ] && [ -z "${disk_id_model}" ]; then
        disk_id_vendor="$(lsblk -dno VENDOR "$1" 2>/dev/null)"
        disk_id_model="$(lsblk -dno MODEL "$1" 2>/dev/null)"
      fi
      ;;
    *) ;;
  esac
  printf '%s %s\n' "${disk_id_vendor}" "${disk_id_model}" |
    awk '{ $0 = toupper($0); $1 = $1; print }'
}

disk_family_of() {
  case "$1" in
    *"ZIP 100"* | *"ZIP 250"* | *"ZIP 750"* | *ZIP100* | *ZIP250* | *ZIP750*) printf 'zip\n' ;;
    *"LS-120"* | *"LS-240"* | *SUPERDISK*) printf 'superdisk\n' ;;
    *"JAZ "* | *JAZ1GB* | *JAZ2GB*) printf 'jaz\n' ;;
    *"USB-FDU"* | *"FD-05"* | *"USB FDD"* | *FLOPPY*) printf 'floppy\n' ;;
    *POCKETZIP* | *"CLIK!"*) printf 'pocketzip\n' ;;
    *) printf '\n' ;;
  esac
}

disk_fragile() {
  case "${DISK_FAMILY:-}" in
    zip | jaz | pocketzip | floppy | superdisk) return 0 ;;
    *) return 1 ;;
  esac
}

disk_head_crash_family() {
  case "${DISK_FAMILY:-}" in
    zip | jaz | pocketzip) return 0 ;;
    *) return 1 ;;
  esac
}

disk_error_class() {
  case "$1" in
    *"Device not configured"* | *"No such device"* | *"No such file or directory"* | \
      *"Operation not permitted"* | *"No medium found"* | *"not ready"* | *"Not ready"* | \
      *ENXIO* | *ENODEV*)
      printf 'bus\n'
      ;;
    *"Input/output error"* | *"I/O error"* | *EIO* | *"Media error"* | *"medium error"*)
      printf 'media\n'
      ;;
    *) printf 'other\n' ;;
  esac
}

disk_device_gone() {
  disk_dg_name="${1##*/}"
  [ -b "$1" ] || [ -c "$1" ] || return 0
  disk_dg_os="$(disk_os)"
  case "${disk_dg_os}" in
    Darwin)
      [ -c "/dev/r${disk_dg_name}" ] || return 0
      disk_bounded 10 diskutil info "$1" >/dev/null 2>&1 || return 0
      ;;
    Linux)
      disk_bounded 10 sudo blockdev --getsize64 "$1" >/dev/null 2>&1 || return 0
      ;;
    *) ;;
  esac
  return 1
}

disk_sector_bytes() {
  disk_sb_bytes=""
  disk_sb_os="$(disk_os)"
  case "${disk_sb_os}" in
    Darwin)
      disk_sb_bytes="$(disk_info_field "$1" 'Device Block Size')"
      disk_sb_bytes="${disk_sb_bytes%% *}"
      ;;
    Linux)
      disk_sb_bytes="$(sudo blockdev --getss "$1" 2>/dev/null)"
      ;;
    *) ;;
  esac
  if ! disk_is_uint "${disk_sb_bytes}" || [ "${disk_sb_bytes}" -lt 512 ]; then
    disk_sb_bytes=512
  fi
  printf '%s\n' "${disk_sb_bytes}"
}

disk_size_bytes() {
  disk_sz_bytes=""
  disk_sz_os="$(disk_os)"
  case "${disk_sz_os}" in
    Darwin)
      disk_sz_text="$(diskutil info "$1" 2>/dev/null)"
      disk_sz_bytes="$(printf '%s\n' "${disk_sz_text}" | sed -nE 's/.*Disk Size:.*\(([0-9]+) Bytes\).*/\1/p')"
      ;;
    Linux)
      disk_sz_bytes="$(sudo blockdev --getsize64 "$1" 2>/dev/null)"
      ;;
    *) ;;
  esac
  printf '%s\n' "${disk_sz_bytes}"
}

disk_writable_media() {
  disk_wm_os="$(disk_os)"
  case "${disk_wm_os}" in
    Darwin)
      disk_wm_answer="$(disk_plist_value "$1" WritableMedia)"
      case "${disk_wm_answer}" in
        false) return 1 ;;
        true) return 0 ;;
        *) ;;
      esac
      ;;
    Linux)
      disk_wm_answer="$(sudo blockdev --getro "$1" 2>/dev/null)"
      case "${disk_wm_answer}" in
        1) return 1 ;;
        0) return 0 ;;
        *) ;;
      esac
      ;;
    *) ;;
  esac
  return 2
}

disk_resolve() {
  disk_rs_input="$1"
  disk_rs_disk=""
  disk_rs_os="$(disk_os)"
  if [ -b "${disk_rs_input}" ] || [ -c "${disk_rs_input}" ]; then
    disk_rs_disk="${disk_rs_input}"
  elif [ -d "${disk_rs_input}" ]; then
    case "${disk_rs_os}" in
      Darwin) disk_rs_disk="$(disk_info_field "${disk_rs_input}" 'Device Node')" ;;
      Linux) disk_rs_disk="$(findmnt -n -o SOURCE "${disk_rs_input}" 2>/dev/null)" ;;
      *) ;;
    esac
    if [ -z "${disk_rs_disk}" ]; then
      disk_error "No device found for mount point: ${disk_rs_input}"
      return 1
    fi
  else
    disk_error "Not a device or mount point: ${disk_rs_input}"
    return 1
  fi

  case "${disk_rs_os}" in
    Darwin)
      disk_rs_whole="$(disk_info_field "${disk_rs_disk}" 'Part of Whole')"
      [ -n "${disk_rs_whole}" ] && disk_rs_disk="/dev/${disk_rs_whole}"
      ;;
    Linux)
      disk_rs_type="$(lsblk -dno TYPE "${disk_rs_disk}" 2>/dev/null)"
      [ "${disk_rs_type}" = "part" ] || {
        printf '%s\n' "${disk_rs_disk}"
        return 0
      }
      disk_rs_parent="$(lsblk -no PKNAME "${disk_rs_disk}" 2>/dev/null)"
      disk_rs_parent="$(printf '%s\n' "${disk_rs_parent}" | sed -n '1p')"
      [ -n "${disk_rs_parent}" ] && disk_rs_disk="/dev/${disk_rs_parent}"
      ;;
    *) ;;
  esac
  printf '%s\n' "${disk_rs_disk}"
}

disk_is_mounted() {
  disk_im_table="$(mount)"
  printf '%s\n' "${disk_im_table}" |
    awk -v dev="$1" '$1 == dev || index($1, dev "s") == 1 { found = 1 } END { exit found ? 0 : 1 }'
}

disk_require_sudo() {
  sudo -n true 2>/dev/null && return 0
  disk_info "Administrator access is required to reach the raw device."
  if ! sudo -v; then
    disk_error "Administrator access was not granted"
    return 1
  fi
  return 0
}

disk_make_tmpdir() {
  DISK_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/$1.XXXXXX")" || {
    disk_error "Unable to create a working directory"
    return 1
  }
  DISK_ERRFILE="${DISK_TMPDIR}/last-error"
  : >"${DISK_ERRFILE}"
  return 0
}

disk_drop_tmpdir() {
  [ -n "${DISK_TMPDIR:-}" ] && rm -rf "${DISK_TMPDIR}"
  DISK_TMPDIR=""
  DISK_ERRFILE=""
  return 0
}
