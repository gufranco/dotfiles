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

disk_test_run() {
  disk_test_run_env "" "$@"
}

disk_test_run_env() {
  local settings="$1"
  local program="$2"
  local search_path
  local -a shell_words env_words
  shift 2
  search_path="$(disk_test_path)"
  read -r -a shell_words <<<"${DISK_SHELL:-sh}"
  read -r -a env_words <<<"${settings}"
  PATH="${search_path}" env "${env_words[@]}" "${shell_words[@]}" "${DOTFILES_DIR}/bin/${program}" "$@"
}

disk_test_call() {
  local search_path
  local -a shell_words
  search_path="$(disk_test_path)"
  read -r -a shell_words <<<"${DISK_SHELL:-sh}"
  PATH="${search_path}" "${shell_words[@]}" "${DISK_TESTS_DIR}/call.sh" "$@"
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
  local file="$1"
  local mebibytes="$2"

  dd if=/dev/zero of="${file}" bs=1048576 count="${mebibytes}" 2>/dev/null
}

disk_test_fat_image() {
  local file="$1"
  local mebibytes="$2"
  local label="$3"
  local base="${file%.*}"

  case "${DISK_TEST_OS}" in
  Darwin)
    hdiutil create -size "${mebibytes}m" -layout MBRSPUD -fs "MS-DOS FAT16" -volname "${label}" -o "${base}.dmg" >/dev/null || return 1
    hdiutil convert "${base}.dmg" -format UDTO -o "${base}" >/dev/null || return 1
    mv -f "${base}.cdr" "${file}"
    rm -f "${base}.dmg"
    ;;
  Linux)
    disk_test_image "${file}" "${mebibytes}"
    printf 'start=2048, type=6\n' | sfdisk -q "${file}" >/dev/null || return 1
    mkfs.fat -F 16 -s 1 --offset 2048 -n "${label}" "${file}" $(((mebibytes - 1) * 1024)) >/dev/null || return 1
    ;;
  *) return 1 ;;
  esac
}

disk_test_random_file() {
  local file="$1"
  local mebibytes="$2"

  dd if=/dev/urandom of="${file}" bs=1048576 count="${mebibytes}" 2>/dev/null
}

disk_test_fill() {
  local file="$1"
  local mebibytes="$2"
  local octal="$3"

  { head -c $((mebibytes * 1048576)) /dev/zero || true; } | LC_ALL=C tr '\000' "${octal}" >"${file}"
}

disk_test_range_bytes() {
  local file="$1"
  local skip="$2"
  local count="$3"
  local part="${file}.range"

  dd if="${file}" of="${part}" bs=512 skip=$((skip / 512)) count=$((count / 512)) 2>/dev/null || return 1
  disk_test_unique_bytes "${part}"
  rm -f "${part}"
}

disk_test_same_prefix() {
  local image="$1"
  local target="$2"
  local bytes
  bytes="$(wc -c <"${image}")"
  bytes="${bytes//[[:space:]]/}"
  head -c "${bytes}" "${target}" >"${target}.prefix" || return 1
  cmp -s "${image}" "${target}.prefix"
  local same="$?"
  rm -f "${target}.prefix"
  return "${same}"
}

disk_test_setup_env() {
  export DISK_FSTAB="${WORK:?}/fstab"
  export REMOVAL_WAIT_SECONDS=1
  export SLOW_FACTOR=50
  export DISK_TRASH="${WORK}/trash.sh"
  : >"${DISK_FSTAB}"
  printf '%s\n' '#!/bin/sh' "mkdir -p '${WORK}/Trash' && mv -f \"\$1\" '${WORK}/Trash/'" >"${DISK_TRASH}"
  chmod +x "${DISK_TRASH}"
  if [[ "${DISK_TEST_OS}" == "Linux" ]]; then
    export ALLOW_INTERNAL=y
  fi
}

disk_test_wait_for() {
  local log="$1"
  local pattern="$2"
  local tenths="$3"
  local waited=0

  while ((waited < tenths)); do
    if grep -Eq -- "${pattern}" "${log}" 2>/dev/null; then
      return 0
    fi
    sleep 0.1
    waited=$((waited + 1))
  done
  printf 'timed out waiting for %s in %s\n' "${pattern}" "${log}" >&2
  return 1
}

disk_test_fs_type() {
  local file="$1"
  local offset="$2"
  local magic
  magic="$(dd if="${file}" bs=1 skip=$((offset + 3)) count=8 2>/dev/null)"
  case "${magic}" in
  EXFAT*) printf 'exfat\n' ;;
  *)
    magic="$(dd if="${file}" bs=1 skip=$((offset + 82)) count=5 2>/dev/null)"
    if [[ "${magic}" == "FAT32" ]]; then
      printf 'fat32\n'
    else
      magic="$(dd if="${file}" bs=1 skip=$((offset + 54)) count=5 2>/dev/null)"
      printf '%s\n' "${magic}" | tr '[:upper:]' '[:lower:]'
    fi
    ;;
  esac
}

disk_test_windows_iso() {
  local iso="$1"
  local tree="${WORK:?}/isotree"
  mkdir -p "${tree}/sources" "${tree}/efi/boot" "${WORK}/payload"
  dd if=/dev/urandom of="${WORK}/payload/blob" bs=1048576 count=3 2>/dev/null
  wimlib-imagex capture "${WORK}/payload" "${tree}/sources/install.wim" --compress=none >/dev/null || return 1
  printf 'MZ fake loader\n' >"${tree}/efi/boot/bootx64.efi"
  printf 'MZ fake setup\n' >"${tree}/setup.exe"
  case "${DISK_TEST_OS}" in
  Darwin) hdiutil makehybrid -iso -joliet -default-volume-name WIN11 -o "${iso}" "${tree}" >/dev/null ;;
  *) xorriso -as mkisofs -quiet -J -V WIN11 -o "${iso}" "${tree}" >/dev/null 2>&1 ;;
  esac
}

disk_test_name() {
  printf '%s\n' "${1##*/}"
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
