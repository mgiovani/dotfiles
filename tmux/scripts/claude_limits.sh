#!/usr/bin/env bash
# Claude Code usage display for tmux status bar
# Reads OAuth cache maintained by cc-arsenal statusline
# Output format: 5h:27% 22:30 | 7d:20% Wed 15:00 | 7dSon:14% Wed 15:00

set -euo pipefail

OAUTH_CACHE="/tmp/claude_oauth_usage_cache.json"
MODEL_CACHE="/tmp/claude_tmux_model_cache"
MODEL_CACHE_TTL=300  # 5 minutes

# Check required dependencies
if ! command -v jq &>/dev/null; then
    exit 0
fi

# Cross-platform date parsing for ISO 8601 timestamps
parse_date() {
    local ts="$1" fmt="$2"
    if [[ -z "$ts" ]]; then echo ""; return; fi
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -j -f "%Y-%m-%dT%H:%M:%S%z" "$ts" "$fmt" 2>/dev/null \
            || date -j -f "%Y-%m-%dT%H:%M:%SZ" "${ts%Z}" "$fmt" 2>/dev/null \
            || echo ""
    else
        date -d "$ts" "$fmt" 2>/dev/null || echo ""
    fi
}

# Cross-platform file modification time (seconds since epoch)
file_mtime() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f %m "$file" 2>/dev/null || echo 0
    else
        stat -c %Y "$file" 2>/dev/null || echo 0
    fi
}

# Cross-platform reverse a file (tac on Linux, tail -r on macOS)
reverse_file() {
    if command -v tac &>/dev/null; then
        tac "$1"
    else
        tail -r "$1"
    fi
}

# Find newest JSONL file cross-platform (no find -printf on macOS)
find_newest_jsonl() {
    local dir="$1"
    find "$dir" -maxdepth 2 -type f -name "*.jsonl" ! -name "*subagent*" \
        | xargs ls -t 2>/dev/null \
        | head -1
}

get_usage_data() {
    [[ ! -f "$OAUTH_CACHE" ]] && return 1

    local five_hour seven_day five_hour_resets_at seven_day_resets_at
    five_hour=$(jq -r '.five_hour.utilization // empty' "$OAUTH_CACHE" 2>/dev/null || echo "")
    seven_day=$(jq -r '.seven_day.utilization // empty' "$OAUTH_CACHE" 2>/dev/null || echo "")
    five_hour_resets_at=$(jq -r '.five_hour.resets_at // empty' "$OAUTH_CACHE" 2>/dev/null || echo "")
    seven_day_resets_at=$(jq -r '.seven_day.resets_at // empty' "$OAUTH_CACHE" 2>/dev/null || echo "")

    [[ -z "$five_hour" || -z "$seven_day" ]] && return 1

    local five_hour_reset_time seven_day_reset_time
    five_hour_reset_time=$(parse_date "$five_hour_resets_at" '+%H:%M')
    seven_day_reset_time=$(parse_date "$seven_day_resets_at" '+%a %H:%M')

    local model_limits=""
    for model in sonnet opus haiku; do
        local key label
        case "$model" in
            sonnet) label="7dSon" ;;
            opus)   label="7dOpu" ;;
            haiku)  label="7dHai" ;;
        esac
        local util reset reset_time
        util=$(jq -r ".seven_day_${model}.utilization // empty" "$OAUTH_CACHE" 2>/dev/null || echo "")
        reset=$(jq -r ".seven_day_${model}.resets_at // empty" "$OAUTH_CACHE" 2>/dev/null || echo "")
        reset_time=$(parse_date "$reset" '+%a %H:%M')
        if [[ -n "$util" ]]; then
            local display="${label}:${util}%"
            [[ -n "$reset_time" ]] && display="${display} ${reset_time}"
            [[ -n "$model_limits" ]] && model_limits="${model_limits};"
            model_limits="${model_limits}${display}"
        fi
    done

    echo "$five_hour|$seven_day|$five_hour_reset_time|$seven_day_reset_time|$model_limits"
}

get_model_name() {
    if [[ -f "$MODEL_CACHE" ]]; then
        local cache_age=$(( $(date +%s) - $(file_mtime "$MODEL_CACHE") ))
        if [[ $cache_age -lt $MODEL_CACHE_TTL ]]; then
            cat "$MODEL_CACHE"
            return 0
        fi
    fi

    local projects_dir="$HOME/.claude/projects"
    if [[ ! -d "$projects_dir" ]]; then
        echo "Unk" > "$MODEL_CACHE"
        echo "Unk"
        return 0
    fi

    local latest_jsonl
    latest_jsonl=$(find_newest_jsonl "$projects_dir")

    if [[ -z "$latest_jsonl" || ! -f "$latest_jsonl" ]]; then
        echo "Unk" > "$MODEL_CACHE"
        echo "Unk"
        return 0
    fi

    local model
    model=$(reverse_file "$latest_jsonl" | grep -m1 '"model"' | sed -n 's/.*"model":[[:space:]]*"\([^"]*\)".*/\1/p')

    local formatted_model="Unk"
    [[ "$model" =~ sonnet ]] && formatted_model="Son"
    [[ "$model" =~ opus   ]] && formatted_model="Opu"
    [[ "$model" =~ haiku  ]] && formatted_model="Hai"

    echo "$formatted_model" > "$MODEL_CACHE"
    echo "$formatted_model"
}

main() {
    local usage_data
    if ! usage_data=$(get_usage_data); then
        echo ""
        exit 0
    fi

    IFS='|' read -r five_hour seven_day five_hour_reset seven_day_reset model_limits <<< "$usage_data"

    local five_hour_display="5h:${five_hour}%"
    [[ -n "$five_hour_reset" ]] && five_hour_display="${five_hour_display} ${five_hour_reset}"

    local seven_day_display="7d:${seven_day}%"
    [[ -n "$seven_day_reset" ]] && seven_day_display="${seven_day_display} ${seven_day_reset}"

    local output="${five_hour_display} | ${seven_day_display}"

    if [[ -n "$model_limits" ]]; then
        model_limits="${model_limits//;/ | }"
        output="${output} | ${model_limits}"
    fi

    echo "$output"
}

main "$@"
