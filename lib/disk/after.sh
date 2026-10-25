#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_ask() {
  disk_ak_answer=""
  printf '%s ' "$1"
  IFS= read -r disk_ak_answer || disk_ak_answer=""
  case "${disk_ak_answer}" in
    y | Y | yes | YES) printf 'y\n' ;;
    n | N | no | NO) printf 'n\n' ;;
    *) printf '%s\n' "$2" ;;
  esac
}

disk_ask_options() {
  [ -t 0 ] || return 0
  if [ -z "${VERIFY:-}" ]; then
    VERIFY="$(disk_ask 'Read everything back and compare it with the image when done? [Y/n]' y)"
  fi
  if [ -z "${DELETE:-}" ] && [ "${VERIFY}" != "n" ] && [ "${DISK_SRC_KIND}" != "device" ]; then
    DELETE="$(disk_ask 'Move the image to the Trash once every disk validated? [y/N]' n)"
  fi
  if [ -z "${REINSERT:-}" ] && [ "${VERIFY}" != "n" ]; then
    REINSERT="$(disk_ask 'After ejecting, check the disk again when you plug it back in? [y/N]' n)"
  fi
  export VERIFY DELETE REINSERT
  return 0
}

disk_trash() {
  if [ -n "${DISK_TRASH:-}" ]; then
    "${DISK_TRASH}" "$1" && return 0
    return 1
  fi
  if [ -x /usr/bin/trash ]; then
    /usr/bin/trash "$1" && return 0
  fi
  if disk_cmd_exists gio; then
    gio trash "$1" && return 0
  fi
  printf 'No Trash is available. Type delete to remove %s for good: ' "$1"
  disk_tr_answer=""
  IFS= read -r disk_tr_answer || disk_tr_answer=""
  if [ "${disk_tr_answer}" = "delete" ]; then
    rm -f "$1" && return 0
  fi
  disk_warning "Kept $1."
  return 1
}

disk_delete_source() {
  [ "${DELETE:-}" = "y" ] || return 0
  if [ "${VERIFY:-y}" = "n" ]; then
    disk_warning "DELETE=y is ignored because nothing was read back, so nothing proves the copy is good."
    return 0
  fi
  if [ "${DISK_SRC_KIND}" = "device" ]; then
    disk_warning "The source is a drive, so there is no image file to delete."
    return 0
  fi
  disk_ds_now="$(disk_source_sha256)"
  if [ "${disk_ds_now}" != "${DISK_SRC_SHA}" ]; then
    disk_error "The image changed while it was being written, so it is kept."
    disk_error "Before: ${DISK_SRC_SHA}"
    disk_error "Now:    ${disk_ds_now}"
    return 1
  fi
  if disk_trash "${DISK_SRC_ORIGIN}"; then
    disk_success "Moved ${DISK_SRC_ORIGIN} to the Trash."
  fi
  return 0
}

disk_find_returned() {
  disk_fr_all="$(disk_eligible)"
  for disk_fr_disk in ${disk_fr_all}; do
    disk_listed "${disk_fr_disk}" "$3" && continue
    disk_fr_size="$(disk_size_bytes "${disk_fr_disk}")"
    [ "${disk_fr_size}" = "$1" ] || continue
    disk_fr_id="$(disk_identity "${disk_fr_disk}")"
    [ "${disk_fr_id}" = "$2" ] || continue
    printf '%s\n' "${disk_fr_disk}"
    return 0
  done
  return 1
}

disk_reinsert_check() {
  [ "${REINSERT:-}" = "y" ] || return 0
  disk_rc_waited=0
  disk_rc_before="$(disk_eligible)"
  disk_info "Unplug ${1}, plug it back in, and leave it alone. Waiting up to 5 minutes."
  while [ "${disk_rc_waited}" -lt 300 ]; do
    disk_rc_disk="$(disk_find_returned "$2" "$3" "${disk_rc_before}")" && break
    sleep 1
    disk_rc_waited=$((disk_rc_waited + 1))
  done
  if [ -z "${disk_rc_disk:-}" ]; then
    disk_warning "The disk did not come back within 5 minutes, so the reinsertion check was skipped."
    return 0
  fi
  sleep 5
  disk_rc_status=0
  if disk_is_mounted "${disk_rc_disk}"; then
    disk_error "STOPPED: the system mounted ${disk_rc_disk} when it came back."
    disk_rc_status=1
  fi
  disk_validate_target "${disk_rc_disk}" "${DISK_SRC_SIZE}" "${DISK_SRC_SHA}" || disk_rc_status=1
  disk_bounded 30 sudo diskutil eject "${disk_rc_disk}" >/dev/null 2>&1 || disk_bounded 30 sudo eject "${disk_rc_disk}" >/dev/null 2>&1
  [ "${disk_rc_status}" -eq 0 ] && disk_success "After unplugging and plugging back in, ${disk_rc_disk} still matches the image byte for byte."
  return "${disk_rc_status}"
}

disk_again_allowed() {
  [ "${AGAIN:-}" = "y" ] || return 1
  [ "$1" -lt 100 ] || return 1
  [ "${DISK_SRC_KIND}" = "device" ] && return 0
  [ -f "${DISK_SRC_PATH}" ]
}

disk_after_write() {
  [ "$1" -eq 0 ] || return 1
  disk_aw_round=1
  while disk_again_allowed "${disk_aw_round}"; do
    printf 'Insert the next disk and press Enter, or type q to finish: '
    disk_aw_answer=""
    IFS= read -r disk_aw_answer || disk_aw_answer="q"
    [ "${disk_aw_answer}" = "q" ] && break
    disk_write_once || return 1
    disk_aw_round=$((disk_aw_round + 1))
  done
  disk_delete_source
}
