#!/bin/sh

# shellcheck source=SCRIPTDIR/state.sh
. "${DISK_LIB:?}/state.sh"

disk_magic_hex() {
  disk_mh_bytes="$(od -An -tx1 -v -j "$2" -N "$3" "$1" 2>/dev/null)"
  printf '%s' "${disk_mh_bytes}" | tr -d ' \n'
}

disk_source_kind() {
  if [ -b "$1" ] || [ -c "$1" ]; then
    printf 'device\n'
    return 0
  fi
  case "$1" in
    http://* | https://*)
      printf 'url\n'
      return 0
      ;;
    *) ;;
  esac
  disk_sk_head="$(disk_magic_hex "$1" 0 8)"
  case "${disk_sk_head}" in
    1f8b*) printf 'gzip\n' ;;
    fd377a585a00*) printf 'xz\n' ;;
    28b52ffd*) printf 'zstd\n' ;;
    425a68*) printf 'bzip2\n' ;;
    504b0304*) printf 'zip\n' ;;
    514649fb*) printf 'qcow2\n' ;;
    4b444d56*) printf 'vmdk\n' ;;
    7668647866696c65*) printf 'vhdx\n' ;;
    *) disk_source_trailer_kind "$1" ;;
  esac
}

disk_source_trailer_kind() {
  disk_st_size="$(disk_file_size "$1")"
  if [ "${disk_st_size}" -ge 512 ]; then
    disk_st_tail="$(disk_magic_hex "$1" $((disk_st_size - 512)) 8)"
    case "${disk_st_tail}" in
      636f6e6563746978*)
        printf 'vhd\n'
        return 0
        ;;
      6b6f6c79*)
        printf 'dmg\n'
        return 0
        ;;
      *) ;;
    esac
  fi
  disk_st_text="$(disk_magic_hex "$1" 0 21)"
  case "${disk_st_text}" in
    23204469736b2044657363726970746f7246696c65*) printf 'vmdk\n' ;;
    *) printf 'raw\n' ;;
  esac
}

disk_decompressor() {
  case "$1" in
    gzip) printf 'gzip\n' ;;
    xz) printf 'xz\n' ;;
    zstd) printf 'zstd\n' ;;
    bzip2) printf 'bzip2\n' ;;
    *) return 1 ;;
  esac
}

disk_stream_source() {
  case "$2" in
    zip) bsdtar -xOf "$1" "${DISK_ZIP_MEMBER}" ;;
    *) "$3" -dc "$1" ;;
  esac
}

disk_zip_member() {
  disk_zm_list="$(bsdtar -tf "$1" 2>/dev/null)" || {
    disk_error "$1 could not be read as a zip archive."
    return 1
  }
  disk_zm_files="$(printf '%s\n' "${disk_zm_list}" | sed '/\/$/d;/^__MACOSX\//d;/\/\._/d;/^\._/d')"
  disk_zm_count="$(printf '%s\n' "${disk_zm_files}" | sed '/^$/d' | wc -l)"
  disk_zm_count="$(printf '%s' "${disk_zm_count}" | tr -d '[:space:]')"
  if [ "${disk_zm_count}" -ne 1 ]; then
    disk_error "STOPPED: $1 holds ${disk_zm_count} files, and only a zip with exactly one image can be written."
    disk_log_lines disk_error "${disk_zm_files}"
    disk_info "Extract the one you want with: bsdtar -xf '$1' '<member>'"
    return 1
  fi
  DISK_ZIP_MEMBER="${disk_zm_files}"
  return 0
}

disk_stream_size() {
  case "$2" in
    xz)
      disk_ss_robot="$(xz --robot -l "$1" 2>/dev/null)"
      disk_ss_bytes="$(printf '%s\n' "${disk_ss_robot}" | awk -F'\t' '$1 == "totals" { print $5; exit }')"
      if disk_is_uint "${disk_ss_bytes}"; then
        printf '%s\n' "${disk_ss_bytes}"
        return 0
      fi
      ;;
    *) ;;
  esac
  disk_info "Reading the whole compressed image once to learn its exact size." >&2
  disk_ss_bytes="$({ disk_stream_source "$1" "$2" "$3" 2>/dev/null || true; } | wc -c)"
  disk_ss_bytes="$(printf '%s' "${disk_ss_bytes}" | tr -d '[:space:]')"
  disk_is_uint "${disk_ss_bytes}" || return 1
  printf '%s\n' "${disk_ss_bytes}"
}

disk_hash_tool() {
  if disk_cmd_exists sha256sum; then
    printf 'sha256sum\n'
  elif disk_cmd_exists shasum; then
    printf 'shasum\n'
  else
    printf 'openssl\n'
  fi
}

disk_sha256_stdin() {
  disk_hs_tool="$(disk_hash_tool)"
  case "${disk_hs_tool}" in
    sha256sum) disk_hs_out="$(sha256sum)" ;;
    shasum) disk_hs_out="$(shasum -a 256)" ;;
    *) disk_hs_out="$(openssl dgst -sha256 -r)" ;;
  esac
  printf '%s\n' "${disk_hs_out%% *}"
}

disk_source_sha256() {
  if [ "${DISK_SRC_STREAM}" = "1" ]; then
    { disk_stream_source "${DISK_SRC_PATH}" "${DISK_SRC_KIND}" "${DISK_SRC_TOOL}" 2>/dev/null || true; } | disk_sha256_stdin
  elif [ "${DISK_SRC_KIND}" = "device" ]; then
    disk_ssh_io="$(disk_io_device "${DISK_SRC_PATH}")"
    { sudo dd if="${disk_ssh_io}" bs=1048576 2>/dev/null || true; } | head -c "${DISK_SRC_SIZE}" | disk_sha256_stdin
  else
    disk_sha256_stdin <"${DISK_SRC_PATH}"
  fi
}

disk_expected_sha256() {
  if [ -n "${SHA256:-}" ]; then
    printf '%s\n' "${SHA256}" | tr '[:upper:]' '[:lower:]'
    return 0
  fi
  disk_es_dir="${1%/*}"
  [ "${disk_es_dir}" = "$1" ] && disk_es_dir="."
  disk_es_name="${1##*/}"
  for disk_es_file in "$1.sha256" "${disk_es_dir}/SHA256SUMS" "${disk_es_dir}/sha256sums.txt"; do
    [ -f "${disk_es_file}" ] || continue
    disk_es_hash="$(awk -v name="${disk_es_name}" '
      NF == 1 && $1 ~ /^[0-9a-fA-F]{64}$/ { print tolower($1); exit }
      { file = $2; sub(/^\*/, "", file); if (file == name) { print tolower($1); exit } }
    ' "${disk_es_file}")"
    if [ -n "${disk_es_hash}" ]; then
      printf '%s\n' "${disk_es_hash}"
      return 0
    fi
  done
  return 1
}

disk_download() {
  if ! disk_cmd_exists curl; then
    disk_error "curl is required to download $1" >&2
    return 1
  fi
  disk_dl_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/kakikomi"
  mkdir -p "${disk_dl_cache}" || return 1
  disk_dl_name="${1##*/}"
  disk_dl_name="${disk_dl_name%%\?*}"
  [ -n "${disk_dl_name}" ] || disk_dl_name="download.img"
  disk_dl_target="${disk_dl_cache}/${disk_dl_name}"
  disk_info "Downloading $1" >&2
  if ! curl -fL --retry 3 --connect-timeout 20 -C - -o "${disk_dl_target}" "$1" >&2; then
    disk_error "STOPPED: the download of $1 failed, so nothing was written." >&2
    return 1
  fi
  printf '%s\n' "${disk_dl_target}"
}

disk_free_bytes() {
  disk_fb_df="$(df -Pk "$1" 2>/dev/null)"
  disk_fb_kib="$(printf '%s\n' "${disk_fb_df}" | awk 'NR == 2 { print $4 }')"
  disk_is_uint "${disk_fb_kib}" || disk_fb_kib=0
  printf '%s\n' "$((disk_fb_kib * 1024))"
}

disk_convert() {
  disk_cv_out="${DISK_SRC_WORK}/converted.img"
  case "$2" in
    dmg)
      disk_cv_tool="hdiutil"
      disk_cv_hint="hdiutil ships with macOS only; convert the .dmg on a Mac"
      ;;
    *)
      disk_cv_tool="qemu-img"
      disk_cv_hint="install qemu: brew install qemu, or apt install qemu-utils"
      ;;
  esac
  if ! disk_cmd_exists "${disk_cv_tool}"; then
    disk_error "STOPPED: a $2 image needs ${disk_cv_tool} to become a raw image: ${disk_cv_hint}." >&2
    return 1
  fi
  disk_cv_need="$(disk_file_size "$1")"
  disk_cv_free="$(disk_free_bytes "${DISK_SRC_WORK}")"
  if [ "${disk_cv_free}" -lt "${disk_cv_need}" ]; then
    disk_error "STOPPED: converting $1 needs at least ${disk_cv_need} free bytes in ${DISK_SRC_WORK}, which has ${disk_cv_free}." >&2
    return 1
  fi
  disk_info "Converting the $2 image to raw so it can be written and verified byte for byte." >&2
  if [ "$2" = "dmg" ]; then
    hdiutil convert "$1" -format UDTO -o "${disk_cv_out}" >/dev/null 2>&1 || {
      disk_error "STOPPED: hdiutil could not convert $1." >&2
      return 1
    }
    [ -f "${disk_cv_out}.cdr" ] && mv -f "${disk_cv_out}.cdr" "${disk_cv_out}"
  else
    qemu-img convert -O raw "$1" "${disk_cv_out}" >/dev/null 2>&1 || {
      disk_error "STOPPED: qemu-img could not convert $1." >&2
      return 1
    }
  fi
  printf '%s\n' "${disk_cv_out}"
}

disk_source_open() {
  DISK_SRC_PATH="$1"
  DISK_SRC_ORIGIN="$1"
  DISK_SRC_STREAM=0
  DISK_SRC_TOOL=""
  DISK_ZIP_MEMBER=""
  DISK_SRC_KIND="$(disk_source_kind "$1")"
  if [ "${DISK_SRC_KIND}" = "url" ]; then
    DISK_SRC_PATH="$(disk_download "$1")" || return 1
    DISK_SRC_ORIGIN="${DISK_SRC_PATH}"
    DISK_SRC_KIND="$(disk_source_kind "${DISK_SRC_PATH}")"
  fi
  if [ "${DISK_SRC_KIND}" != "device" ] && [ ! -f "${DISK_SRC_PATH}" ]; then
    disk_error "Image not found: ${DISK_SRC_PATH}"
    return 1
  fi
  disk_source_prepare
}

disk_source_prepare() {
  case "${DISK_SRC_KIND}" in
    gzip | xz | zstd | bzip2)
      DISK_SRC_TOOL="$(disk_decompressor "${DISK_SRC_KIND}")"
      if ! disk_cmd_exists "${DISK_SRC_TOOL}"; then
        disk_error "STOPPED: ${DISK_SRC_TOOL} is needed to read this ${DISK_SRC_KIND} image."
        return 1
      fi
      DISK_SRC_STREAM=1
      DISK_SRC_SIZE="$(disk_stream_size "${DISK_SRC_PATH}" "${DISK_SRC_KIND}" "${DISK_SRC_TOOL}")" || return 1
      ;;
    zip)
      disk_cmd_exists bsdtar || {
        disk_error "STOPPED: bsdtar is needed to read a zip image. Install libarchive-tools."
        return 1
      }
      disk_zip_member "${DISK_SRC_PATH}" || return 1
      DISK_SRC_STREAM=1
      DISK_SRC_SIZE="$(disk_stream_size "${DISK_SRC_PATH}" zip "")" || return 1
      ;;
    dmg | vhd | vhdx | vmdk | qcow2)
      DISK_SRC_PATH="$(disk_convert "${DISK_SRC_PATH}" "${DISK_SRC_KIND}")" || return 1
      DISK_SRC_KIND="raw"
      DISK_SRC_SIZE="$(disk_file_size "${DISK_SRC_PATH}")"
      ;;
    device)
      DISK_SRC_PATH="$(disk_resolve "${DISK_SRC_PATH}")" || return 1
      DISK_SRC_SIZE="$(disk_size_bytes "${DISK_SRC_PATH}")"
      ;;
    *)
      DISK_SRC_SIZE="$(disk_file_size "${DISK_SRC_PATH}")"
      ;;
  esac
  if ! disk_is_uint "${DISK_SRC_SIZE}" || [ "${DISK_SRC_SIZE}" -eq 0 ]; then
    disk_error "STOPPED: ${DISK_SRC_ORIGIN} is empty or its size could not be read."
    return 1
  fi
  return 0
}

disk_stream_start() {
  disk_sst_fifo="$1/source.fifo"
  rm -f "${disk_sst_fifo}"
  mkfifo "${disk_sst_fifo}" || return 1
  disk_stream_source "${DISK_SRC_PATH}" "${DISK_SRC_KIND}" "${DISK_SRC_TOOL}" >"${disk_sst_fifo}" 2>/dev/null &
  DISK_SRC_PID="$!"
  exec 3<"${disk_sst_fifo}"
  return 0
}

disk_stream_stop() {
  exec 3<&-
  if [ -n "${DISK_SRC_PID}" ]; then
    kill "${DISK_SRC_PID}" 2>/dev/null
    wait "${DISK_SRC_PID}" 2>/dev/null
  fi
  DISK_SRC_PID=""
  return 0
}

disk_source_read() {
  disk_sr_out="$3"
  if [ "${DISK_SRC_STREAM}" = "1" ]; then
    dd bs="$2" count=1 iflag=fullblock of="${disk_sr_out}" <&3 2>/dev/null || return 1
  elif [ "${DISK_SRC_KIND}" = "device" ]; then
    disk_sr_io="$(disk_io_device "${DISK_SRC_PATH}")"
    sudo dd if="${disk_sr_io}" of="${disk_sr_out}" bs="$2" skip=$(($1 / $2)) count=1 2>/dev/null || return 1
  else
    dd if="${DISK_SRC_PATH}" of="${disk_sr_out}" bs="$2" skip=$(($1 / $2)) count=1 2>/dev/null || return 1
  fi
  return 0
}
