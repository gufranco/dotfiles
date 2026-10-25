#!/bin/sh
os="$(uname -s)"
if [ "${os}" = "Darwin" ]; then
  diskutil mountDisk "$1" >/dev/null
else
  mount_dir="$(mktemp -d)"
  sudo mount -o offset=1048576 "$1" "${mount_dir}"
fi
