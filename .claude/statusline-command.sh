#!/usr/bin/env bash
# Claude Code status line for job-portal-ui
# Shows: git branch · model name · context progress bar · estimated session cost

input=$(cat)

# ANSI helpers
reset='\033[0m'
dim='\033[2m'
cyan='\033[36m'
blue='\033[34m'
green='\033[32m'
yellow='\033[33m'
orange='\033[38;5;214m'
red='\033[31m'

sep="${dim} · ${reset}"

segments=()

# ── 1. Git branch ─────────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    unstaged=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -c '^.[^ ]')
    staged=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -c '^[^ ].')

    indicator=""
    if [ "$staged" -gt 0 ] && [ "$unstaged" -gt 0 ]; then
      indicator="$(printf "${yellow}+${reset}${orange}*${reset}")"
    elif [ "$staged" -gt 0 ]; then
      indicator="$(printf "${yellow}+${reset}")"
    elif [ "$unstaged" -gt 0 ]; then
      indicator="$(printf "${orange}*${reset}")"
    fi

    segments+=("$(printf "${cyan}%s${reset}%s" "$branch" "$indicator")")
  fi
fi

# ── 2. Model name ─────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model" ]; then
  segments+=("$(printf "${blue}%s${reset}" "$model")")
fi

# ── 3. Context progress bar ───────────────────────────────────────────────────
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")

  if [ "$pct" -ge 80 ]; then
    bar_color="$red"
  elif [ "$pct" -ge 50 ]; then
    bar_color="$yellow"
  else
    bar_color="$green"
  fi

  bar_width=10
  filled=$(( pct * bar_width / 100 ))
  empty=$(( bar_width - filled ))

  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty; i++));  do bar="${bar}░"; done

  segments+=("$(printf "${bar_color}%s${reset} ${dim}%s%%${reset}" "$bar" "$pct")")
fi

# ── 4. Estimated session cost ─────────────────────────────────────────────────
# Pricing per 1M tokens (claude-sonnet-4 class):
#   Plain input: $3.00 | Cache write: $3.75 | Cache read: $0.30 | Output: $15.00
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

if [ "$total_input" -gt 0 ] || [ "$total_output" -gt 0 ]; then
  cost=$(echo "$total_input $total_output $cache_write $cache_read" | awk '{
    inp   = $1; out = $2; cw = $3; cr = $4
    plain = inp - cw - cr
    if (plain < 0) plain = 0
    cost  = (plain / 1000000 * 3.00) \
          + (cw    / 1000000 * 3.75) \
          + (cr    / 1000000 * 0.30) \
          + (out   / 1000000 * 15.00)
    printf "%.4f", cost
  }')
  segments+=("$(printf "${dim}\$%s${reset}" "$cost")")
fi

# ── Join segments with dim · separators ───────────────────────────────────────
result=""
for i in "${!segments[@]}"; do
  if [ "$i" -eq 0 ]; then
    result="${segments[$i]}"
  else
    result="${result}${sep}${segments[$i]}"
  fi
done

printf "%b" "$result"
