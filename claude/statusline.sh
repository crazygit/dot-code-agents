#!/bin/bash
set -euo pipefail

# Check jq dependency
if ! command -v jq &>/dev/null; then
    echo "[jq not installed]"
    exit 0
fi

# Read JSON input from stdin
input=$(cat)

# Single jq call to extract all fields at once while preserving empty values.
# Emit shell-safe assignments so this stays compatible with macOS bash 3.2.
eval "$(
    echo "$input" | jq -r '
        "WORKSPACE_DIR=" + (.workspace.current_dir // "" | @sh),
        "TOP_CWD=" + (.cwd // "" | @sh),
        "MODEL_DISPLAY=" + (.model.display_name // "" | @sh),
        "FIVE_HOUR_USED_PCT=" + (.rate_limits.five_hour.used_percentage // "" | tostring | @sh),
        "SEVEN_DAY_USED_PCT=" + (.rate_limits.seven_day.used_percentage // "" | tostring | @sh),
        "COST_USD=" + (.cost.total_cost_usd // "" | tostring | @sh),
        "COST_DURATION_MS=" + (.cost.total_duration_ms // "" | tostring | @sh),
        "API_DURATION_MS=" + (.cost.total_api_duration_ms // "" | tostring | @sh),
        "LINES_ADDED=" + (.cost.total_lines_added // "" | tostring | @sh),
        "LINES_REMOVED=" + (.cost.total_lines_removed // "" | tostring | @sh),
        "CONTEXT_REMAINING_PCT=" + (.context_window.remaining_percentage // "" | tostring | @sh),
        "CONTEXT_USED_PCT=" + (.context_window.used_percentage // "" | tostring | @sh)
    '
)"

# Prefer workspace.current_dir, fallback to top-level cwd; strip trailing slash
REPO_DIR="${WORKSPACE_DIR:-$TOP_CWD}"
REPO_DIR="${REPO_DIR%/}"

# Show git branch if in a git repo at REPO_DIR
GIT_BRANCH=""
if [ -n "$REPO_DIR" ] && git -C "$REPO_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$REPO_DIR" branch --show-current 2>/dev/null || true)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 $BRANCH"
    fi
fi

# Build cost info piece by piece (only include present fields)
COST_INFO=""
if [ -n "$COST_USD" ] || [ -n "$COST_DURATION_MS" ] || [ -n "$API_DURATION_MS" ] || [ -n "$LINES_ADDED" ] || [ -n "$LINES_REMOVED" ]; then
    parts=()
    if [ -n "$COST_USD" ]; then
        parts+=("💰 ${COST_USD} USD")
    fi
    if [ -n "$COST_DURATION_MS" ]; then
        parts+=("⏱ total ${COST_DURATION_MS} ms")
    fi
    if [ -n "$API_DURATION_MS" ]; then
        parts+=("🔌 api ${API_DURATION_MS} ms")
    fi
    if [ -n "$LINES_ADDED" ] || [ -n "$LINES_REMOVED" ]; then
        la="${LINES_ADDED:-0}"
        lr="${LINES_REMOVED:-0}"
        parts+=("✏️ +${la} / -${lr} lines")
    fi
    # join with " / "
    COST_INFO=" | $(IFS=' / '; echo "${parts[*]}")"
fi

# Prefer remaining_percentage; fall back to 100 - used_percentage when needed.
CONTEXT_INFO=""
if [ -n "$CONTEXT_REMAINING_PCT" ]; then
    CONTEXT_REMAINING=${CONTEXT_REMAINING_PCT%.*}
elif [ -n "$CONTEXT_USED_PCT" ]; then
    CONTEXT_REMAINING=$((100 - ${CONTEXT_USED_PCT%.*}))
else
    CONTEXT_REMAINING=""
fi

if [ -n "${CONTEXT_REMAINING:-}" ]; then
    CONTEXT_INFO=" | 🧠 ${CONTEXT_REMAINING}% left"
else
    CONTEXT_INFO=" | 🧠 ctx n/a"
fi

RATE_LIMIT_INFO=""
if [ -n "$FIVE_HOUR_USED_PCT" ] || [ -n "$SEVEN_DAY_USED_PCT" ]; then
    rate_text=""
    if [ -n "$FIVE_HOUR_USED_PCT" ]; then
        rate_text="5h used ${FIVE_HOUR_USED_PCT%.*}%"
    fi
    if [ -n "$SEVEN_DAY_USED_PCT" ]; then
        if [ -n "$rate_text" ]; then
            rate_text="${rate_text} | "
        fi
        rate_text="${rate_text}7d used ${SEVEN_DAY_USED_PCT%.*}%"
    fi
    if [ -n "$rate_text" ]; then
        RATE_LIMIT_INFO=" - ${rate_text}"
    fi
fi

# Short name for directory (basename of REPO_DIR or workspace.project_dir)
DIR_NAME=""
if [ -n "$REPO_DIR" ]; then
    DIR_NAME="${REPO_DIR##*/}"
else
    PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // empty')
    PROJECT_DIR="${PROJECT_DIR%/}"
    DIR_NAME="${PROJECT_DIR##*/}"
fi

# Compose final statusline
echo "[$MODEL_DISPLAY] 📁 ${DIR_NAME}$GIT_BRANCH${CONTEXT_INFO}${RATE_LIMIT_INFO}${COST_INFO}"
