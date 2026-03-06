#!/bin/bash
# change-tracker.sh — Logs every file Claude modifies with timestamps.
#
# PostToolUse hook for Edit, MultiEdit, and Write.
# Reads tool input from stdin JSON to extract the file path.
# Appends to ~/.claude/changes.log with auto-rotation at 2000 lines.

LOG="$HOME/.claude/changes.log"

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

case "$TOOL" in
  Edit|MultiEdit) ACTION="modified" ;;
  Write)          ACTION="created" ;;
  *)              exit 0 ;;
esac

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $ACTION: $FILE_PATH" >> "$LOG"

# Rotate: keep last 1000 lines when log exceeds 2000
if [ -f "$LOG" ] && [ "$(wc -l < "$LOG")" -gt 2000 ]; then
  tail -n 1000 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi

exit 0
