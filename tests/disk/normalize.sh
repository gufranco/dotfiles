#!/bin/sh
sed -E \
  -e 's#/dev/r?disk[0-9]+#DEV#g' \
  -e 's#/dev/loop[0-9]+#DEV#g' \
  -e 's/[0-9]+ KiB\/s/N KiB\/s/g' \
  -e 's/[0-9]+m?s to reach/N to reach/g' \
  -e 's/allowing [0-9]+x/allowing Nx/g' \
  -e 's/over [0-9]+ chunks/over N chunks/g' \
  -e 's/\[[0-9][0-9]:[0-9][0-9]\] //g'
