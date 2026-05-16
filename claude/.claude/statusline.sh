#!/usr/bin/env bash
# Claude Code status line — robbyrussell-inspired, left + right aligned
# Receives JSON on stdin from Claude Code

input=$(cat)

cwd=$(echo "$input"      | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"    | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
max_tok=$(echo "$input"  | jq -r '.context_window.context_window_size // empty')
rl_5h=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_7d=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')
style=$(echo "$input"    | jq -r '.output_style.name // ""')

dir=$(basename "$cwd")

# Git info (with timeout so huge repos don't block the prompt)
git_branch=""; git_dirty=""; git_ahead=""; git_behind=""
if timeout 0.3 git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(GIT_OPTIONAL_LOCKS=0 timeout 0.3 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$(GIT_OPTIONAL_LOCKS=0 timeout 0.3 git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
        git_dirty="✗"
    fi
    ab=$(GIT_OPTIONAL_LOCKS=0 timeout 0.3 git -C "$cwd" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    if [ -n "$ab" ]; then
        git_behind=$(echo "$ab" | awk '{print $1}')
        git_ahead=$(echo  "$ab" | awk '{print $2}')
        [ "$git_behind" = "0" ] && git_behind=""
        [ "$git_ahead"  = "0" ] && git_ahead=""
    fi
fi

fmt_tokens() {
    local n=$1
    if   [ "$n" -ge 1000000 ]; then awk -v n="$n" 'BEGIN{printf "%.1fM", n/1000000}'
    elif [ "$n" -ge 1000    ]; then awk -v n="$n" 'BEGIN{printf "%dk",   n/1000}'
    else printf '%d' "$n"
    fi
}

rl_color() {
    local p=$1
    if   [ "$p" -lt 50 ]; then printf '\033[32m'
    elif [ "$p" -lt 80 ]; then printf '\033[33m'
    else                       printf '\033[31m'
    fi
}

# ── LEFT side ────────────────────────────────────────────────────────────
left=""
left+=$(printf '\033[36m%s\033[0m' "$dir")

if [ -n "$git_branch" ]; then
    left+=$(printf ' \033[34mgit:(\033[31m%s\033[34m)\033[0m' "$git_branch")
    [ -n "$git_dirty" ] && left+=$(printf ' \033[33m%s\033[0m' "$git_dirty")
    if [ -n "$git_ahead" ] || [ -n "$git_behind" ]; then
        left+=' '
        [ -n "$git_ahead"  ] && left+=$(printf '\033[32m↑%s\033[0m' "$git_ahead")
        [ -n "$git_behind" ] && left+=$(printf '\033[31m↓%s\033[0m' "$git_behind")
    fi
fi

[ -n "$model" ] && left+=$(printf ' \033[2m%s\033[0m' "$model")

if [ -n "$style" ] && [ "$style" != "default" ]; then
    left+=$(printf ' \033[35m[%s]\033[0m' "$style")
fi

# ── RIGHT side ───────────────────────────────────────────────────────────
right=""
if [ -n "$rl_7d" ]; then
    c=$(rl_color "$rl_7d"); right+=$(printf '%s7d:%d%%\033[0m ' "$c" "$rl_7d")
fi
if [ -n "$rl_5h" ]; then
    c=$(rl_color "$rl_5h"); right+=$(printf '%s5h:%d%%\033[0m ' "$c" "$rl_5h")
fi

if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    if   [ "$used_int" -lt 50 ]; then bar_color='\033[32m'
    elif [ "$used_int" -lt 80 ]; then bar_color='\033[33m'
    else                              bar_color='\033[31m'
    fi
    filled=$(( used_int * 20 / 100 ))
    empty=$((  20 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty;  i++)); do bar+="░"; done
    right+=$(printf "${bar_color}[%s] %d%%" "$bar" "$used_int")
    if [ -n "$max_tok" ] && [ "$max_tok" != "null" ] && [ "$max_tok" -gt 0 ]; then
        used_tok=$(( used_int * max_tok / 100 ))
        right+=$(printf ' · %s/%s' "$(fmt_tokens "$used_tok")" "$(fmt_tokens "$max_tok")")
    fi
    right+=$(printf '\033[0m')
fi

# ── JOIN with right-alignment ────────────────────────────────────────────
# Terminal width: prefer tput via /dev/tty, then stty, then $COLUMNS, then 120.
cols=$(stty size 2>/dev/null </dev/tty | awk '{print $2}')
[ -z "$cols" ] && cols=${COLUMNS:-}
[ -z "$cols" ] && cols=$(tput cols 2>/dev/null)
[ -z "$cols" ] && cols=120
# Claude Code renders the statusline inside a framed UI — reserve a margin
# so the right edge doesn't get clipped. Tune via STATUSLINE_MARGIN.
cols=$(( cols - ${STATUSLINE_MARGIN:-6} ))
[ "$cols" -lt 40 ] && cols=40

# Visible length = string with ANSI stripped, counted in chars (not bytes).
visible_len() {
    local s=$1
    # Strip CSI sequences: ESC [ ... letter
    s=$(printf '%s' "$s" | sed $'s/\x1b\\[[0-9;]*[a-zA-Z]//g')
    printf '%s' "$s" | awk '{print length($0)}'
}

left_len=$(visible_len "$left")
right_len=$(visible_len "$right")
pad=$(( cols - left_len - right_len ))
[ "$pad" -lt 1 ] && pad=1

spaces=$(printf '%*s' "$pad" '')

printf '%s%s%s' "$left" "$spaces" "$right"
