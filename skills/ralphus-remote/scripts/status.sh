#!/bin/bash
# status.sh - Remote version
# Usage: ./status.sh [target_dir]

[ -n "$1" ] && cd "$1"

# 1. Repo Status
if [ ! -d ".git" ]; then
    echo "STATUS: NOT_GIT_REPO"
    exit 0
fi

# 2. Preparation Status
if [ ! -f "loop.sh" ] || [ ! -f "PROMPT_plan.md" ]; then
    echo "STATUS: UNPREPARED"
    echo "NEXT: Run prepare.sh"
    exit 0
fi

# 3. Planning Status
SPECS_EXIST=false
[ -d "specs" ] && [ "$(ls -A specs 2>/dev/null)" ] && SPECS_EXIST=true

PLAN_EXISTS=false
[ -f "IMPLEMENTATION_PLAN.md" ] && PLAN_EXISTS=true

PLAN_COMPLETE=false
if [ "$PLAN_EXISTS" = true ] && [ "$SPECS_EXIST" = true ]; then
    SPECS_COUNT=$(ls specs/*.md 2>/dev/null | wc -l)
    REFS_COUNT=$(grep -c "specs/" IMPLEMENTATION_PLAN.md 2>/dev/null || echo 0)
    if [ "$REFS_COUNT" -ge "$SPECS_COUNT" ] && [ "$SPECS_COUNT" -gt 0 ]; then
        PLAN_COMPLETE=true
    fi
fi

# 4. Session Status
BRANCH=$(git branch --show-current)
SESSION_NAME="ralphus-${BRANCH//\//-}"
RUNNING=false
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    RUNNING=true
fi

echo "STATUS: READY"
echo "BRANCH: $BRANCH"
echo "SESSION_NAME: $SESSION_NAME"
echo "RUNNING: $RUNNING"
echo "PLAN_COMPLETE: $PLAN_COMPLETE"

if [ "$RUNNING" = true ]; then
    echo "NEXT: Attach to session"
elif [ "$PLAN_COMPLETE" = true ]; then
    echo "NEXT: Launch BUILD mode"
else
    echo "NEXT: Launch PLAN mode"
fi
