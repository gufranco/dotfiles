#!/usr/bin/env bash
set -euo pipefail

check_perm() {
  local path="$1" expected="$2"
  local actual

  case "$(uname)" in
    Linux)  actual=$(stat -Lc %a "$path" 2>/dev/null || echo "missing") ;;
    Darwin) actual=$(stat -Lf %Lp "$path" 2>/dev/null || echo "missing") ;;
  esac

  if [ "$actual" = "$expected" ]; then
    echo "OK: $path ($actual)"
  else
    echo "FAIL: $path (expected $expected, got $actual)"
    return 1
  fi
}

check_perm "$HOME/.gnupg" "700"
check_perm "$HOME/.ssh" "700"
