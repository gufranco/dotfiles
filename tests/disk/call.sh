#!/bin/sh
[ -n "${ZSH_VERSION:-}" ] && emulate sh

DISK_LIB="$(cd "$(dirname "$0")/../../lib/disk" && pwd)" || exit 1

# shellcheck source=SCRIPTDIR/../../lib/disk/core.sh
. "${DISK_LIB}/core.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/io.sh
. "${DISK_LIB}/io.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/calibrate.sh
. "${DISK_LIB}/calibrate.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/wipe.sh
. "${DISK_LIB}/wipe.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/source.sh
. "${DISK_LIB}/source.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/guard.sh
. "${DISK_LIB}/guard.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/ui.sh
. "${DISK_LIB}/ui.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/write.sh
. "${DISK_LIB}/write.sh"
# shellcheck source=SCRIPTDIR/../../lib/disk/after.sh
. "${DISK_LIB}/after.sh"

call_breach() {
  disk_make_tmpdir breach || return 1
  disk_breach_start "$1"
  sleep 1
  "$2" "$1"
  sleep 2
  disk_breach_stop "$1"
}

call_changed_source() {
  disk_source_open "$1" || return 1
  DISK_SRC_SHA="0000"
  DELETE=y
  VERIFY=y
  disk_delete_source
}

call_first_boot_disk() {
  disk_cb_list="$(disk_boot_disks)"
  printf '%s\n' "${disk_cb_list}" | sed -n '1p'
}

call_pattern() {
  disk_make_tmpdir pattern || return 1
  disk_cp_file="$(disk_pattern_file "$1" "$2")" || return 1
  od -An -tx1 -v "${disk_cp_file}" | awk '{ for (i = 1; i <= NF; i++) seen[$i] = 1 } END { for (b in seen) printf "%s ", b }'
  wc -c <"${disk_cp_file}"
}

"$@"
