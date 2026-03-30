#!/usr/bin/env bash

set -euo pipefail

payload="$(cat)"
project_dir="${CLAUDE_PROJECT_DIR:-}"

if [[ -z "$project_dir" ]]; then
  exit 0
fi

cache_root="${XDG_STATE_HOME:-$HOME/.claude/state}/change-context"
project_key="$(printf '%s' "$project_dir" | shasum -a 256 | awk '{print $1}')"
cache_dir="$cache_root"
cache_file="$cache_dir/$project_key.json"
mkdir -p "$cache_dir"

tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // ""')"
file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')"
command_text="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"

go_changed=false
python_changed=false
terraform_changed=false
docs_changed=false

if [[ -n "$file_path" ]]; then
  case "$file_path" in
    *.go) go_changed=true ;;
    *.py) python_changed=true ;;
    *.tf|*.tfvars) terraform_changed=true ;;
    *.md|*.mdx) docs_changed=true ;;
  esac
fi

if [[ "$tool_name" == "Bash" ]]; then
  case "$command_text" in
    go\ * ) go_changed=true ;;
    pytest*|python\ -m\ pytest*|ruff\ * ) python_changed=true ;;
    terraform\ * ) terraform_changed=true ;;
  esac
fi

tmp_file="$(mktemp)"

if [[ -f "$cache_file" ]]; then
  jq \
    --argjson go_changed "$go_changed" \
    --argjson python_changed "$python_changed" \
    --argjson terraform_changed "$terraform_changed" \
    --argjson docs_changed "$docs_changed" \
    '.go = (.go or $go_changed)
    | .python = (.python or $python_changed)
    | .terraform = (.terraform or $terraform_changed)
    | .docs = (.docs or $docs_changed)
    | .updatedAt = now' \
    "$cache_file" >"$tmp_file"
else
  jq -n \
    --argjson go_changed "$go_changed" \
    --argjson python_changed "$python_changed" \
    --argjson terraform_changed "$terraform_changed" \
    --argjson docs_changed "$docs_changed" \
    '{
      go: $go_changed,
      python: $python_changed,
      terraform: $terraform_changed,
      docs: $docs_changed,
      updatedAt: now
    }' >"$tmp_file"
fi

mv "$tmp_file" "$cache_file"
