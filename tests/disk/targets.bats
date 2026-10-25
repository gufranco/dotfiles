#!/usr/bin/env bats

# shellcheck source=tests/disk/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  WORK="$(mktemp -d "${BATS_TMPDIR:-/tmp}/disk-targets.XXXXXX")"
  disk_test_setup_env
  IMAGE="${WORK}/fat.img"
  disk_test_fat_image "${IMAGE}" 8 TARGETS
  DEVICES=""
  local index
  for index in 1 2 3; do
    disk_test_fill "${WORK}/t${index}.img" 16 '\252'
    local attached
    attached="$(disk_test_attach "${WORK}/t${index}.img")"
    DEVICES="${DEVICES} ${attached}"
  done
  read -r DEV1 DEV2 DEV3 <<<"${DEVICES}"
}

answer_and_write() {
  local answers="$1"
  shift
  printf '%b' "${answers}" | disk_test_run kakikomi "$@"
}

teardown() {
  local device
  for device in ${DEVICES}; do
    disk_test_detach "${device}"
  done
  if [[ -n "${FAULTY:-}" ]]; then
    sudo dmsetup remove "${FAULTY}" >/dev/null 2>&1 || true
  fi
  rm -rf "${WORK}"
}

@test "kakikomi lists attached removable disks when no target is given" {
  # Arrange
  local answer="0"

  # Act
  run answer_and_write "${answer}\n" "${IMAGE}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *") ${DEV1} "* ]]
  [[ "${output}" == *"Not a listed number or disk: 0"* ]]
}

@test "kakikomi writes the disk chosen in the picker" {
  # Arrange
  local listing number
  listing="$(answer_and_write '0\n' "${IMAGE}" 2>&1 || true)"
  number="$(printf '%s\n' "${listing}" | awk -v dev="${DEV2}" '$2 == dev { sub(/\)/, "", $1); print $1 }')"
  local name="${DEV2##*/}"

  # Act
  run answer_and_write "${number}\n${name}\n" "${IMAGE}"

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${IMAGE}" "${WORK}/t2.img"
}

@test "kakikomi writes three disks in one run and validates each" {
  # Arrange
  local names="${DEV1##*/} ${DEV2##*/} ${DEV3##*/}"

  # Act
  run answer_and_write "${names}\n" "${IMAGE}" "${DEV1}" "${DEV2}" "${DEV3}"

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${IMAGE}" "${WORK}/t1.img"
  disk_test_same_prefix "${IMAGE}" "${WORK}/t2.img"
  disk_test_same_prefix "${IMAGE}" "${WORK}/t3.img"
}

@test "kakikomi finishes the healthy disks when one target fails mid-write" {
  # Arrange
  [[ "${DISK_TEST_OS}" == "Linux" ]] || skip "a failing block device is built with device-mapper, which only Linux has"
  local sectors
  sectors="$(sudo blockdev --getsz "${DEV2}")"
  FAULTY="kakikomi-faulty-$$"
  printf '0 6144 linear %s 0\n6144 64 error\n6208 %s linear %s 6208\n' "${DEV2}" "$((sectors - 6208))" "${DEV2}" |
    sudo dmsetup create "${FAULTY}"
  sudo dmsetup mknodes "${FAULTY}"
  local faulty_dev
  faulty_dev="/dev/mapper/${FAULTY}"
  local names="${DEV1##*/} ${faulty_dev##*/} ${DEV3##*/}"

  # Act
  run answer_and_write "${names}\n" "${IMAGE}" "${DEV1}" "${faulty_dev}" "${DEV3}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"${faulty_dev##*/}: STOPPED"* ]]
  [[ "${output}" == *"${DEV1}: written and verified."* ]]
  [[ "${output}" == *"${DEV3}: written and verified."* ]]
  disk_test_same_prefix "${IMAGE}" "${WORK}/t1.img"
  disk_test_same_prefix "${IMAGE}" "${WORK}/t3.img"
}
