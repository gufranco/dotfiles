#!/usr/bin/env bash

DISK_TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${DISK_TESTS_DIR}/../.." && pwd)"
DISK_TEST_OS="$(uname -s)"
export DISK_TESTS_DIR DOTFILES_DIR DISK_TEST_OS

disk_test_path() {
  if [[ "${DISK_TEST_OS}" == "Darwin" ]]; then
    printf '%s:%s\n' "${DISK_TESTS_DIR}/shim" "${PATH}"
  else
    printf '%s\n' "${PATH}"
  fi
}

disk_test_attach() {
  local image="$1"
  local listing

  case "${DISK_TEST_OS}" in
    Darwin)
      listing="$(hdiutil attach -nomount -imagekey diskimage-class=CRawDiskImage "${image}")" || return 1
      printf '%s\n' "${listing%%[[:space:]]*}"
      ;;
    Linux)
      sudo losetup -f --show "${image}"
      ;;
    *)
      printf 'unsupported OS: %s\n' "${DISK_TEST_OS}" >&2
      return 1
      ;;
  esac
}

disk_test_detach() {
  local device="$1"

  case "${DISK_TEST_OS}" in
    Darwin) hdiutil detach "${device}" >/dev/null 2>&1 || true ;;
    Linux) sudo losetup -d "${device}" >/dev/null 2>&1 || true ;;
    *) return 1 ;;
  esac
}

disk_test_image() {
  local path="$1"
  local mebibytes="$2"

  dd if=/dev/zero of="${path}" bs=1048576 count="${mebibytes}" 2>/dev/null
}

disk_test_unique_bytes() {
  local dump
  dump="$(od -An -tx1 -v "$1")" || return 1
  awk '
    { for (i = 1; i <= NF; i++) seen[$i] = 1 }
    END {
      n = 0
      for (b in seen) keys[++n] = b
      for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++) if (keys[j] < keys[i]) { t = keys[i]; keys[i] = keys[j]; keys[j] = t }
      for (i = 1; i <= n; i++) printf "%s%s", keys[i], (i < n ? " " : "\n")
    }
  ' <<<"${dump}"
}

disk_test_normalize() {
  sh "${DISK_TESTS_DIR}/normalize.sh"
}

disk_test_matches_golden() {
  local name="$1"
  local actual="$2"
  local golden="${DISK_TESTS_DIR}/golden/${name}.${DISK_TEST_OS}.txt"
  local normalized

  normalized="$(printf '%s\n' "${actual}" | disk_test_normalize)" || return 1
  if [[ "${DISK_TEST_RECORD:-}" == "1" ]]; then
    printf '%s\n' "${normalized}" >"${golden}"
  fi

  diff <(printf '%s\n' "${normalized}") "${golden}"
}
