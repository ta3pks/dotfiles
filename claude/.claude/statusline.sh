#!/usr/bin/env bash

# Read JSON input
input=$(cat)

# Extract needed fields
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Get git branch if in a git repo
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check if there are uncommitted changes
        if ! git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null; then
            git_info=" ±$branch"
        else
            git_info=" $branch"
        fi
    fi
fi

# Format: cyan directory + git branch
printf '\033[96m%s\033[0m%s' "$cwd" "$git_info"
