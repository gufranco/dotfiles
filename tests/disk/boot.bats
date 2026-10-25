#!/usr/bin/env bats

# shellcheck source=tests/disk/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  WORK="$(mktemp -d "${BATS_TMPDIR:-/tmp}/disk-boot.XXXXXX")"
  disk_test_setup_env
  TARGET_IMG="${WORK}/target.img"
  disk_test_fill "${TARGET_IMG}" 64 '\252'
  DEVICE="$(disk_test_attach "${TARGET_IMG}")"
  NAME="${DEVICE##*/}"
}

teardown() {
  disk_test_detach "${DEVICE}"
  rm -rf "${WORK}"
}

write_windows() {
  printf '%s\n' "${NAME}" | disk_test_run_env "FAT32_MAX_FILE=1048576" kakikomi "$1" "${DEVICE}"
}

format_with() {
  printf '%s\n' "${NAME}" | disk_test_run kakikomi format "${DEVICE}" "$@"
}

@test "kakikomi format creates an exFAT filesystem with the requested label" {
  # Arrange
  local label="MEDIA"

  # Act
  run format_with exfat "${label}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Validated: ${DEVICE} matches the image"* ]]
  local fs
  fs="$(disk_test_fs_type "${TARGET_IMG}" 1048576)"
  [[ "${fs}" == "exfat" ]]
}

@test "kakikomi format creates a FAT32 filesystem that mtools can read" {
  # Arrange
  local label="STICK"

  # Act
  run format_with fat32 "${label}"

  # Assert
  [[ "${status}" -eq 0 ]]
  local fs listing
  fs="$(disk_test_fs_type "${TARGET_IMG}" 1048576)"
  listing="$(mdir -i "${TARGET_IMG}@@1M" ::)"
  [[ "${fs}" == "fat32" ]]
  [[ "${listing}" == *"Volume in drive : is STICK"* ]]
}

@test "kakikomi format only writes the filesystem structures, a quick format" {
  # Arrange
  local label="QUICK"

  # Act
  run format_with fat32 "${label}"

  # Assert
  [[ "${status}" -eq 0 ]]
  local tail_bytes
  tail_bytes="$(disk_test_range_bytes "${TARGET_IMG}" 62914560 4194304)"
  [[ "${tail_bytes}" == "aa" ]] || { printf "found bytes: %s\n" "${tail_bytes}"; false; }
}

@test "kakikomi format writes a floppy filesystem with no partition table" {
  # Arrange
  disk_test_detach "${DEVICE}"
  head -c 1474560 /dev/zero >"${TARGET_IMG}"
  DEVICE="$(disk_test_attach "${TARGET_IMG}")"
  NAME="${DEVICE##*/}"

  # Act
  run format_with floppy GAMES

  # Assert
  [[ "${status}" -eq 0 ]]
  local listing
  listing="$(mdir -i "${TARGET_IMG}" ::)"
  [[ "${listing}" == *"Volume in drive : is GAMES"* ]]
}

@test "kakikomi format rejects an unknown filesystem name" {
  # Arrange
  local fs="ntfs"

  # Act
  run format_with "${fs}" LABEL

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"Unknown filesystem: ntfs. Use fat32, exfat, fat or floppy."* ]]
}

@test "kakikomi lays a Windows installer ISO out as FAT32 and splits a large install.wim" {
  # Arrange
  command -v wimlib-imagex >/dev/null || skip "wimlib-imagex is not installed"
  command -v mformat >/dev/null || skip "mtools is not installed"
  local iso="${WORK}/win.iso"
  disk_test_windows_iso "${iso}"

  # Act
  run write_windows "${iso}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"laid out as a UEFI-bootable FAT32 drive"* ]]
  [[ "${output}" == *"files read back identical from the new volume."* ]]
  local sources boot
  sources="$(mdir -b -i "${TARGET_IMG}@@1M" ::/sources)"
  boot="$(mdir -b -i "${TARGET_IMG}@@1M" ::/efi/boot)"
  [[ "${sources}" == *"install.swm"* ]]
  [[ "${sources}" == *"install2.swm"* ]]
  [[ "${sources}" != *"install.wim"* ]]
  [[ "${boot}" == *"bootx64.efi"* ]]
}
