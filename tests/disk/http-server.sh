#!/bin/sh
log="$2/http.log"
python3 -u -m http.server 0 --bind 127.0.0.1 --directory "$1" >"${log}" 2>&1 &
printf '%s\n' "$!" >"$2/http.pid"
tries=0
while [ "${tries}" -lt 100 ]; do
  port="$(sed -n 's/.* port \([0-9][0-9]*\).*/\1/p' "${log}")"
  if [ -n "${port}" ]; then
    printf '%s\n' "${port}"
    exit 0
  fi
  sleep 0.1
  tries=$((tries + 1))
done
exit 1
