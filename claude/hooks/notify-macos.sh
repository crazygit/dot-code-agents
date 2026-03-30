#!/usr/bin/env bash

set -euo pipefail

payload="$(cat)"
notification_type="$(printf '%s' "$payload" | jq -r '.notification_type // "notification"')"
message="$(printf '%s' "$payload" | jq -r '.message // "Claude Code needs your attention"')"

if ! command -v osascript >/dev/null 2>&1; then
  exit 0
fi

NOTIFICATION_MESSAGE="$message" \
NOTIFICATION_TITLE="Claude Code ($notification_type)" \
osascript <<'APPLESCRIPT'
display notification (system attribute "NOTIFICATION_MESSAGE") with title (system attribute "NOTIFICATION_TITLE")
APPLESCRIPT
