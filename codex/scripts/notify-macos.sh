#!/usr/bin/env bash

set -euo pipefail

if ! command -v osascript >/dev/null 2>&1; then
  exit 0
fi

payload="$(cat || true)"

title="Codex"
message="Codex needs your attention"

if command -v jq >/dev/null 2>&1 && [ -n "${payload}" ]; then
  title="$(printf '%s' "$payload" | jq -r '
    .title
    // .event
    // (if .client then "Codex (" + .client + ")" else empty end)
    // "Codex"
  ' 2>/dev/null || printf 'Codex')"

  message="$(printf '%s' "$payload" | jq -r '
    .message
    // .summary
    // .status
    // (if .client then "Turn finished for " + .client else empty end)
    // "Codex turn finished"
  ' 2>/dev/null || printf 'Codex turn finished')"
else
  message="Codex turn finished"
fi

NOTIFICATION_TITLE="$title" \
NOTIFICATION_MESSAGE="$message" \
osascript <<'APPLESCRIPT'
display notification (system attribute "NOTIFICATION_MESSAGE") with title (system attribute "NOTIFICATION_TITLE")
APPLESCRIPT
