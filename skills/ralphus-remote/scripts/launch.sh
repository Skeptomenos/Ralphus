#!/bin/bash
# launch.sh - Remote version
# Usage: ./launch.sh [target_dir] [plan|build] [ultrawork]

[ -n "$1" ] && cd "$1"

MODE="${2:-plan}"
ULTRAWORK="${3:-}"

BRANCH=$(git branch --show-current)
SESSION_NAME="ralphus-${BRANCH//\//-}"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "SESSION_EXISTS"
    exit 0
fi

# Launch
tmux new-session -d -s "$SESSION_NAME" "./loop.sh $MODE $ULTRAWORK"
echo "SESSION_STARTED"
echo "ID: $SESSION_NAME"
