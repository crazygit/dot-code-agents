#!/usr/bin/env bash

set -euo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-}"

if [[ -z "$project_dir" ]]; then
  exit 0
fi

cache_root="${XDG_STATE_HOME:-$HOME/.claude/state}/change-context"
project_key="$(printf '%s' "$project_dir" | shasum -a 256 | awk '{print $1}')"
cache_file="$cache_root/$project_key.json"

if [[ -f "$cache_file" ]]; then
  rm -f "$cache_file"
fi
