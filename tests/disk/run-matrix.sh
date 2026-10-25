#!/bin/sh
set -u

tests_dir="$(cd "$(dirname "$0")" && pwd)"
os="$(uname -s)"
failed=0

if [ -n "${DISK_SHELLS:-}" ]; then
  shells="${DISK_SHELLS}"
elif [ "${os}" = "Darwin" ]; then
  shells="/bin/sh|dash|bash|bash --posix|zsh"
else
  shells="dash|bash|bash --posix|zsh|/bin/sh"
fi

if [ "$#" -eq 0 ]; then
  set -- "${tests_dir}"
fi

old_ifs="${IFS}"
IFS='|'
for shell in ${shells}; do
  IFS="${old_ifs}"
  printf '== %s ==\n' "${shell}"
  if ! DISK_SHELL="${shell}" bats "$@"; then
    failed=$((failed + 1))
  fi
  IFS='|'
done
IFS="${old_ifs}"

if [ "${failed}" -ne 0 ]; then
  printf '%s shell(s) failed\n' "${failed}"
  exit 1
fi
printf 'every shell passed\n'
