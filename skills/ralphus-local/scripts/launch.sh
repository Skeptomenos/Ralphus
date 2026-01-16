#!/bin/bash
# launch.sh - Starts the loop in tmux
# Usage: ./launch.sh [plan|build] [ultrawork]

MODE="${1:-plan}"
ULTRAWORK="${2:-}"

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
