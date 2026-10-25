#!/usr/bin/env bats

# shellcheck source=tests/disk/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  WORK="$(mktemp -d "${BATS_TMPDIR:-/tmp}/disk-after.XXXXXX")"
  disk_test_setup_env
  IMAGE="${WORK}/fat.img"
  disk_test_fat_image "${IMAGE}" 8 AFTER
  disk_test_fill "${WORK}/t1.img" 16 '\252'
  disk_test_fill "${WORK}/t2.img" 16 '\252'
  DEV1="$(disk_test_attach "${WORK}/t1.img")"
  DEV2="$(disk_test_attach "${WORK}/t2.img")"
  ATTACHED="${DEV1} ${DEV2}"
}

teardown() {
  local device
  for device in ${ATTACHED}; do
    disk_test_detach "${device}"
  done
  rm -rf "${WORK}"
}

answer_and_write() {
  local answers="$1"
  local settings="$2"
  shift 2
  printf '%b' "${answers}" | disk_test_run_env "${settings}" kakikomi "$@"
}

@test "kakikomi AGAIN=y writes the same image to the next disk" {
  # Arrange
  local answers="${DEV1##*/}\n\n${DEV2##*/}\n${DEV2##*/}\nq\n"

  # Act
  run answer_and_write "${answers}" "AGAIN=y" "${IMAGE}" "${DEV1}"

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${IMAGE}" "${WORK}/t1.img"
  disk_test_same_prefix "${IMAGE}" "${WORK}/t2.img"
}

@test "kakikomi REINSERT=y compares the disk again after it comes back" {
  # Arrange
  local log="${WORK}/run.log"
  printf '%s\n' "${DEV1##*/}" | disk_test_run_env "REINSERT=y" kakikomi "${IMAGE}" "${DEV1}" >"${log}" 2>&1 &
  local runner="$!"
  disk_test_wait_for "${log}" "plug it back in" 1200 || cat "${log}"

  # Act
  local returned
  returned="$(disk_test_attach "${WORK}/t1.img")"
  ATTACHED="${ATTACHED} ${returned}"
  local status_code=0
  wait "${runner}" || status_code="$?"

  # Assert
  [[ "${status_code}" -eq 0 ]] || cat "${log}"
  grep -q "still matches the image byte for byte" "${log}"
}
