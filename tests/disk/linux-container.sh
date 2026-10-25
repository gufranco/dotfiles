#!/bin/sh
set -eu

repo="$(cd "$(dirname "$0")/../.." && pwd)"
image="${DISK_TEST_IMAGE:-ubuntu:26.04}"

docker run --rm --privileged \
  -v "${repo}:/repo" \
  -w /repo \
  -e DISK_SHELL="${DISK_SHELL:-}" \
  -e DISK_TEST_RECORD="${DISK_TEST_RECORD:-}" \
  "${image}" \
  sh -c '
    set -eu
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq >/dev/null
    apt-get install -y -qq --no-install-recommends \
      bats zsh dash openssl util-linux eject mount udev sudo ca-certificates >/dev/null
    exec "$@"
  ' sh "$@"
