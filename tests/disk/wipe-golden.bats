#!/usr/bin/env bats

# shellcheck source=tests/disk/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  WORK="$(mktemp -d "${BATS_TMPDIR:-/tmp}/disk-wipe.XXXXXX")"
  IMAGE="${WORK}/target.img"
  disk_test_image "${IMAGE}" 4
  DEVICE="$(disk_test_attach "${IMAGE}")"
}

teardown() {
  disk_test_detach "${DEVICE}"
  rm -rf "${WORK}"
}

disk_wipe_run() {
  printf 'y\n' | disk_test_run kiyome "${DEVICE}"
}

@test "kiyome output matches the recorded golden run" {
  # Arrange
  local name="wipe"

  # Act
  run disk_wipe_run

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_matches_golden "${name}" "${output}"
}

@test "kiyome leaves every byte of the device zero" {
  # Arrange
  dd if=/dev/urandom of="${IMAGE}" bs=512 count=16 conv=notrunc 2>/dev/null

  # Act
  run disk_wipe_run

  # Assert
  [[ "${status}" -eq 0 ]]
  local bytes
  bytes="$(disk_test_unique_bytes "${IMAGE}")"
  [[ "${bytes}" == "00" ]]
}
