#!/usr/bin/env bash

set -euo pipefail

raw_folder="${1:-}"
new_count="${2:-0}"
unread_count="${3:-0}"
total_count="${4:-0}"
mailboxes_with_new="${5:-0}"

only_digits() {
  printf '%s' "${1//[!0-9]/}"
}

new_count="$(only_digits "$new_count")"
unread_count="$(only_digits "$unread_count")"
total_count="$(only_digits "$total_count")"
mailboxes_with_new="$(only_digits "$mailboxes_with_new")"
: "${new_count:=0}" "${unread_count:=0}" "${total_count:=0}" "${mailboxes_with_new:=0}"

account_name_from_folder() {
  case "$1" in
    *imap.gmail.com*) echo "Gmail" ;;
    *imap.mail.me.com*) echo "iCloud" ;;
    *outlook.com* | *office365.com*) echo "Outlook" ;;
    *) echo "Mail" ;;
  esac
}

mailbox_name_from_folder() {
  local path="${1#*://}"
  path="${path#*/}"
  path="${path#\[Gmail\]/}"
  path="${path#INBOX/}"
  if [ -z "$path" ] || [ "$path" = "$1" ]; then
    echo "INBOX"
  else
    echo "$path"
  fi
}

pluralize() {
  if [ "$1" = "1" ]; then
    echo "$1 $2"
  else
    echo "$1 $3"
  fi
}

terminal_bundle_id() {
  if [ -n "${NEOMUTT_NOTIFY_ACTIVATE:-}" ]; then
    echo "$NEOMUTT_NOTIFY_ACTIVATE"
    return 0
  fi
  case "${TERM_PROGRAM:-}" in
    "iTerm.app")
      echo "com.googlecode.iterm2"
      return 0
      ;;
    "Apple_Terminal")
      echo "com.apple.Terminal"
      return 0
      ;;
    "ghostty")
      echo "com.mitchellh.ghostty"
      return 0
      ;;
  esac
  for app in "Ghostty:com.mitchellh.ghostty" "kitty:net.kovidgoyal.kitty" "iTerm:com.googlecode.iterm2"; do
    if [ -d "/Applications/${app%%:*}.app" ]; then
      echo "${app##*:}"
      return 0
    fi
  done
  return 1
}

account="$(account_name_from_folder "$raw_folder")"
mailbox="$(mailbox_name_from_folder "$raw_folder")"
group="neomutt-${account}"

title="$account"
subtitle="$mailbox"
body="$(pluralize "$new_count" "new message" "new messages")"
if [ "$unread_count" -gt 0 ]; then
  body="${body}, ${unread_count} unread"
fi
if [ "$total_count" -gt 0 ]; then
  body="${body} of ${total_count}"
fi
if [ "$mailboxes_with_new" -gt 1 ]; then
  body="${body} | ${mailboxes_with_new} mailboxes have new mail"
fi

case "$(uname)" in
  "Darwin")
    if command -v terminal-notifier >/dev/null 2>&1; then
      args=(-title "$title" -subtitle "$subtitle" -message "$body" -group "$group" -sound Glass)
      if bundle="$(terminal_bundle_id)"; then
        args+=(-activate "$bundle")
      fi
      terminal-notifier "${args[@]}" >/dev/null 2>&1 || true
    else
      osascript -e "display notification \"${body}\" with title \"${title}\" subtitle \"${subtitle}\" sound name \"Glass\"" >/dev/null 2>&1 || true
    fi
    ;;
  "Linux")
    if command -v notify-send >/dev/null 2>&1; then
      notify-send \
        --app-name="NeoMutt" \
        --urgency=normal \
        --expire-time=8000 \
        --icon=mail-unread \
        --hint="string:x-canonical-private-synchronous:${group}" \
        "${title} - ${subtitle}" "$body" >/dev/null 2>&1 || true
    fi
    ;;
esac
