#!/usr/bin/env bats

# shellcheck source=tests/disk/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  WORK="$(mktemp -d "${BATS_TMPDIR:-/tmp}/disk-source.XXXXXX")"
  disk_test_setup_env
  TARGET_IMG="${WORK}/target.img"
  disk_test_fill "${TARGET_IMG}" 16 '\252'
  DEVICE="$(disk_test_attach "${TARGET_IMG}")"
  NAME="$(disk_test_name "${DEVICE}")"
  IMAGE="${WORK}/fat.img"
  disk_test_fat_image "${IMAGE}" 8 SOURCE
  cp -f "${IMAGE}" "${WORK}/original.img"
}

teardown() {
  disk_test_detach "${DEVICE}"
  if [[ -f "${WORK}/http.pid" ]]; then
    kill "$(cat "${WORK}/http.pid")" 2>/dev/null || true
  fi
  rm -rf "${WORK}"
}

write_source() {
  write_source_with "" "$1"
}

write_source_with() {
  printf '%s\n' "${NAME}" | disk_test_run_env "$1" kakikomi "$2" "${DEVICE}"
}

write_compressed() {
  local tool="$1"
  local suffix="$2"
  command -v "${tool}" >/dev/null || skip "${tool} is not installed"
  "${tool}" -c "${IMAGE}" >"${IMAGE}.${suffix}"
  write_source "${IMAGE}.${suffix}"
}

@test "kakikomi streams a gzip image and writes the decompressed bytes" {
  # Arrange
  local tool="gzip"

  # Act
  run write_compressed "${tool}" gz

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi streams an xz image and writes the decompressed bytes" {
  # Arrange
  local tool="xz"

  # Act
  run write_compressed "${tool}" xz

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi streams a zstd image and writes the decompressed bytes" {
  # Arrange
  local tool="zstd"

  # Act
  run write_compressed "${tool}" zst

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi streams a bzip2 image and writes the decompressed bytes" {
  # Arrange
  local tool="bzip2"

  # Act
  run write_compressed "${tool}" bz2

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi writes the one image inside a zip archive" {
  # Arrange
  local archive="${WORK}/single.zip"
  (cd "${WORK}" && bsdtar -a -cf "${archive}" fat.img)

  # Act
  run write_source "${archive}"

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi refuses a zip archive holding two files" {
  # Arrange
  local archive="${WORK}/double.zip"
  cp -f "${IMAGE}" "${WORK}/second.img"
  (cd "${WORK}" && bsdtar -a -cf "${archive}" fat.img second.img)

  # Act
  run write_source "${archive}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"holds 2 files, and only a zip with exactly one image can be written."* ]]
  [[ "${output}" == *"second.img"* ]]
  local bytes
  bytes="$(disk_test_unique_bytes "${TARGET_IMG}")"
  [[ "${bytes}" == "aa" ]] || { printf "found bytes: %s\n" "${bytes}"; false; }
}

@test "kakikomi converts a qcow2 image to raw before writing it" {
  # Arrange
  command -v qemu-img >/dev/null || skip "qemu-img is not installed"
  qemu-img convert -O qcow2 "${IMAGE}" "${WORK}/disk.qcow2"

  # Act
  run write_source "${WORK}/disk.qcow2"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Converting the qcow2 image to raw"* ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi downloads an image from a URL and writes it" {
  # Arrange
  local port
  port="$(sh "${DISK_TESTS_DIR}/http-server.sh" "${WORK}" "${WORK}")"

  # Act
  run write_source_with "XDG_CACHE_HOME=${WORK}/cache" "http://127.0.0.1:${port}/fat.img"

  # Assert
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${WORK}/original.img" "${TARGET_IMG}"
}

@test "kakikomi stops when the image does not match SHA256" {
  # Arrange
  local wrong="0000000000000000000000000000000000000000000000000000000000000000"

  # Act
  run write_source_with "SHA256=${wrong}" "${IMAGE}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"STOPPED: the image does not match its published checksum."* ]]
  local bytes
  bytes="$(disk_test_unique_bytes "${TARGET_IMG}")"
  [[ "${bytes}" == "aa" ]] || { printf "found bytes: %s\n" "${bytes}"; false; }
}

@test "kakikomi accepts an image whose sibling .sha256 file matches" {
  # Arrange
  local sum
  sum="$(disk_test_call disk_sha256_stdin <"${IMAGE}")"
  printf '%s  fat.img\n' "${sum}" >"${IMAGE}.sha256"

  # Act
  run write_source "${IMAGE}"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"The image matches its published SHA-256."* ]]
}

@test "kakikomi clones one drive onto another" {
  # Arrange
  local source_img="${WORK}/source-drive.img"
  disk_test_fat_image "${source_img}" 8 CLONE
  local source_dev
  source_dev="$(disk_test_attach "${source_img}")"

  # Act
  run write_source "${source_dev}"

  # Assert
  disk_test_detach "${source_dev}"
  [[ "${status}" -eq 0 ]]
  disk_test_same_prefix "${source_img}" "${TARGET_IMG}"
}

@test "kakikomi refuses to clone a drive onto itself" {
  # Arrange
  local self="${DEVICE}"

  # Act
  run write_source "${self}"

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"is the drive being copied, so it cannot also be the target."* ]]
}
