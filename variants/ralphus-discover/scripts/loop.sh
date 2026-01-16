#!/bin/bash
# Ralphus Discover - Autonomous Codebase Discovery Loop
# Usage: ./ralphus/ralphus-discover/scripts/loop.sh [plan] [ultrawork|ulw] [max_iterations]

set -euo pipefail

# Central location (where prompts/templates live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPHUS_DISCOVER_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$RALPHUS_DISCOVER_DIR/instructions"
TEMPLATES_DIR="$RALPHUS_DISCOVER_DIR/templates"

# Working directory (where project files live)
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Configuration
AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"
ULTRAWORK=0

MODE="discover"
PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_discover_build.md"
MAX_ITERATIONS=0

for arg in "$@"; do
    if [ "$arg" = "plan" ]; then
        MODE="plan"
        PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_discover_plan.md"
    elif [ "$arg" = "ultrawork" ] || [ "$arg" = "ulw" ]; then
        ULTRAWORK=1
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS=$arg
    fi
done

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "=== RALPHUS DISCOVER: $MODE mode | $AGENT | $CURRENT_BRANCH ==="
[ "$ULTRAWORK" -eq 1 ] && echo "Ultrawork: enabled"
[ "$MAX_ITERATIONS" -gt 0 ] && echo "Max iterations: $MAX_ITERATIONS"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "Error: $TEMPLATES_DIR/ directory not found."
    exit 1
fi

if [ "$MODE" = "discover" ] && [ ! -f "$WORKING_DIR/DISCOVERY_PLAN.md" ]; then
    echo "Error: DISCOVERY_PLAN.md not found in $WORKING_DIR"
    echo "Run planning mode first: $0 plan"
    exit 1
fi

mkdir -p "$WORKING_DIR/discoveries"

LAST_BRANCH_FILE="$WORKING_DIR/.last-branch"
if [ -f "$LAST_BRANCH_FILE" ]; then
    LAST_BRANCH=$(cat "$LAST_BRANCH_FILE")
    if [ "$LAST_BRANCH" != "$CURRENT_BRANCH" ]; then
        ARCHIVE_DIR="$WORKING_DIR/archive/$(date +%Y-%m-%d)-$LAST_BRANCH"
        mkdir -p "$ARCHIVE_DIR"
        cp "$WORKING_DIR/DISCOVERY_PLAN.md" "$ARCHIVE_DIR/" 2>/dev/null || true
        cp -r "$WORKING_DIR/discoveries/" "$ARCHIVE_DIR/" 2>/dev/null || true
        echo "Archived previous run to $ARCHIVE_DIR"
    fi
fi
echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"

SHUTDOWN=0
trap 'SHUTDOWN=1; echo -e "\n⚠ Shutdown requested. Finishing current iteration..."' INT TERM

while true; do
    if [ "$SHUTDOWN" -eq 1 ]; then
        echo "Shutting down gracefully."
        exit 0
    fi

    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    ITERATION=$((ITERATION + 1))
    echo -e "\n======================== ITERATION $ITERATION ========================\n"

    if [ "$ULTRAWORK" -eq 1 ]; then
        MESSAGE="Read the attached prompt file and execute the instructions. ulw"
    else
        MESSAGE="Read the attached prompt file and execute the instructions"
    fi

    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        -f "$PROMPT_FILE" \
        -f "$TEMPLATES_DIR/DISCOVERY_PLAN.md" \
        -f "$TEMPLATES_DIR/DISCOVERY.md" \
        -f "$TEMPLATES_DIR/CODEBASE_UNDERSTANDING.md" \
        -- "$MESSAGE" 2>&1 | tee /dev/stderr) || true

    if echo "$OUTPUT" | grep -q "<promise>PLAN_COMPLETE</promise>"; then
        echo "=== PLANNING COMPLETE ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>PHASE_COMPLETE</promise>"; then
        echo "=== DISCOVERY COMPLETE - next iteration ==="
    fi
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo "=== ALL DISCOVERIES COMPLETE ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>BLOCKED:"; then
        echo "=== BLOCKED ===" && echo "$OUTPUT" | grep -o "<promise>BLOCKED:[^<]*</promise>" && exit 1
    fi

    if git rev-parse --git-dir > /dev/null 2>&1; then
        git push origin "$CURRENT_BRANCH" 2>/dev/null || {
            echo "Note: Failed to push. Creating remote branch..."
            git push -u origin "$CURRENT_BRANCH" 2>/dev/null || echo "Warning: Could not push to remote"
        }
    fi
done

echo "=== Loop finished after $ITERATION iterations ==="
