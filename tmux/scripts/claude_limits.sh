#!/usr/bin/env bash
# Claude Code rate limit display for tmux status bar
# Reads rate_limits cache written by cc-arsenal statusline
# Output format: 5h:24% 13:00 | 7d:41% Feb 06 13:00

set -euo pipefail

RATE_LIMITS_CACHE="/tmp/claude_rate_limits_cache.json"

command -v jq &>/dev/null || exit 0
[[ -f "$RATE_LIMITS_CACHE" ]] || exit 0

# Check cache isn't stale (>10 minutes = no active session)
if [[ "$OSTYPE" == "darwin"* ]]; then
    cache_mtime=$(stat -f %m "$RATE_LIMITS_CACHE" 2>/dev/null || echo 0)
else
    cache_mtime=$(stat -c %Y "$RATE_LIMITS_CACHE" 2>/dev/null || echo 0)
fi
cache_age=$(( $(date +%s) - cache_mtime ))
[[ $cache_age -gt 600 ]] && exit 0

five_hour_pct=$(jq -r '.five_hour.used_percentage // empty' "$RATE_LIMITS_CACHE" 2>/dev/null || echo "")
[[ -z "$five_hour_pct" ]] && exit 0

# Round to integer
five_hour_pct=$(printf '%.0f' "$five_hour_pct" 2>/dev/null || echo "$five_hour_pct")

# Format reset time from epoch
five_hour_resets=$(jq -r '.five_hour.resets_at // empty' "$RATE_LIMITS_CACHE" 2>/dev/null || echo "")
five_hour_time=""
if [[ -n "$five_hour_resets" && "$five_hour_resets" != "0" ]]; then
    # Round up to next full hour
    rounded=$(( (five_hour_resets + 3599) / 3600 * 3600 ))
    five_hour_time=$(date -d "@$rounded" '+%H:%M' 2>/dev/null || date -r "$rounded" '+%H:%M' 2>/dev/null || echo "")
fi

output="5h:${five_hour_pct}%"
[[ -n "$five_hour_time" ]] && output="${output} ${five_hour_time}"

# 7-day window
seven_day_pct=$(jq -r '.seven_day.used_percentage // empty' "$RATE_LIMITS_CACHE" 2>/dev/null || echo "")
if [[ -n "$seven_day_pct" ]]; then
    seven_day_pct=$(printf '%.0f' "$seven_day_pct" 2>/dev/null || echo "$seven_day_pct")
    seven_day_resets=$(jq -r '.seven_day.resets_at // empty' "$RATE_LIMITS_CACHE" 2>/dev/null || echo "")
    seven_day_time=""
    if [[ -n "$seven_day_resets" && "$seven_day_resets" != "0" ]]; then
        rounded=$(( (seven_day_resets + 3599) / 3600 * 3600 ))
        seven_day_time=$(date -d "@$rounded" '+%a %H:%M' 2>/dev/null || date -r "$rounded" '+%a %H:%M' 2>/dev/null || echo "")
    fi
    seven_day_display="7d:${seven_day_pct}%"
    [[ -n "$seven_day_time" ]] && seven_day_display="${seven_day_display} ${seven_day_time}"
    output="${output} | ${seven_day_display}"
fi

echo "$output"
