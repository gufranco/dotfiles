#!/usr/bin/env bash
# Ranger scope.sh - file preview script
# Symlinked to ~/.config/ranger/scope.sh

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

FILE_PATH="${1}"
PV_WIDTH="${2}"
PV_HEIGHT="${3}"

handle_extension() {
  case "${FILE_PATH##*.}" in
    # Archive
    a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
    rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tzo|war|xpi|xz|Z|zip)
      atool --list -- "${FILE_PATH}" && exit 5
      ;;
    rar)
      unrar lt -p- -- "${FILE_PATH}" && exit 5
      ;;
    7z)
      7z l -p -- "${FILE_PATH}" && exit 5
      ;;
    # PDF
    pdf)
      pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - && exit 5
      ;;
    # JSON
    json)
      jq --color-output '.' "${FILE_PATH}" && exit 5
      ;;
    # Markdown
    md|markdown)
      glow -s dark -w "${PV_WIDTH}" "${FILE_PATH}" && exit 5
      ;;
  esac
}

handle_mime() {
  local mimetype
  mimetype="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"

  case "${mimetype}" in
    text/*)
      bat --color=always --style=numbers --line-range=:500 \
        --terminal-width="${PV_WIDTH}" -- "${FILE_PATH}" && exit 5
      cat "${FILE_PATH}" && exit 5
      ;;
    image/*)
      exiftool "${FILE_PATH}" && exit 5
      ;;
    video/*|audio/*)
      mediainfo "${FILE_PATH}" && exit 5
      exiftool "${FILE_PATH}" && exit 5
      ;;
    application/json)
      jq --color-output '.' "${FILE_PATH}" && exit 5
      ;;
  esac
}

handle_extension
handle_mime

exit 1
