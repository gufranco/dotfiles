#!/usr/bin/env bash
# Auto-format files after Edit/Write operations based on file extension.
#
# Runs the appropriate formatter silently. If the formatter is not
# installed, does nothing. Never fails or blocks.
#
# Receives Edit/Write tool input as JSON on stdin.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('input', {}).get('file_path', ''))
except:
    pass
" 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

EXT="${FILE_PATH##*.}"

case "$EXT" in
    js|jsx|ts|tsx|json|css|scss|html|md|yaml|yml)
        command -v prettier >/dev/null 2>&1 && prettier --write "$FILE_PATH" >/dev/null 2>&1 || true
        ;;
    py)
        command -v black >/dev/null 2>&1 && black --quiet "$FILE_PATH" >/dev/null 2>&1 || \
        command -v ruff >/dev/null 2>&1 && ruff format "$FILE_PATH" >/dev/null 2>&1 || true
        ;;
    go)
        command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE_PATH" >/dev/null 2>&1 || true
        ;;
    rs)
        command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE_PATH" >/dev/null 2>&1 || true
        ;;
    rb)
        command -v rubocop >/dev/null 2>&1 && rubocop -A --fail-level E "$FILE_PATH" >/dev/null 2>&1 || true
        ;;
    sh|bash|zsh)
        command -v shfmt >/dev/null 2>&1 && shfmt -w "$FILE_PATH" >/dev/null 2>&1 || true
        ;;
esac

exit 0
