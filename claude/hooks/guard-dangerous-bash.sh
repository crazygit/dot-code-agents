#!/usr/bin/env bash

set -euo pipefail

payload="$(cat)"
command_text="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"

deny() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
}

if [[ "$command_text" =~ (^|[[:space:]])rm[[:space:]].*-rf([[:space:]]|$) ]]; then
  deny "Blocked destructive rm -rf command. Delete paths manually after reviewing them."
  exit 0
fi

if [[ "$command_text" =~ ^git[[:space:]]+push ]] && [[ "$command_text" =~ --force(-with-lease)? ]]; then
  deny "Blocked force push from Claude Code. Run it manually after explicit review if it is truly required."
  exit 0
fi

if [[ "$command_text" =~ ^terraform[[:space:]]+destroy([[:space:]]|$) ]]; then
  deny "Blocked terraform destroy from Claude Code. Destructive infrastructure changes must be run manually."
  exit 0
fi

if [[ "$command_text" =~ ^terraform[[:space:]]+apply ]] && [[ "$command_text" =~ -auto-approve ]]; then
  deny "Blocked terraform apply -auto-approve. Review the plan and run apply manually."
  exit 0
fi

if [[ "$command_text" =~ curl[[:space:]].*\|[[:space:]]*(sh|bash)([[:space:]]|$) ]]; then
  deny "Blocked curl-pipe-shell pattern. Download and inspect scripts before executing them."
  exit 0
fi

if [[ "$command_text" =~ ^chmod[[:space:]]+-R[[:space:]]+777([[:space:]]|$) ]]; then
  deny "Blocked recursive chmod 777. Review the target path and use the narrowest permissions possible."
  exit 0
fi

exit 0
