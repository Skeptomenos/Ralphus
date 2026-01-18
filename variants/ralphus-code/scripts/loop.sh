#!/bin/bash
# Ralphus Code - Autonomous Feature Implementation Loop
# Usage: ./ralphus/ralphus-code/scripts/loop.sh [plan] [ultrawork|ulw] [max_iterations]

set -euo pipefail

# Central location (where prompts/templates live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPHUS_CODE_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$RALPHUS_CODE_DIR/instructions"
TEMPLATES_DIR="$RALPHUS_CODE_DIR/templates"

# Working directory (where project files live)
# Set by wrapper, or defaults to current directory for direct invocation
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Configuration
AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"
SPECS_DIR="$WORKING_DIR/specs"
ULTRAWORK=0

MODE="build"
PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_build.md"
MAX_ITERATIONS=0
CUSTOM_PROMPT=""

for arg in "$@"; do
    if [ "$arg" = "plan" ]; then
        MODE="plan"
        PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_plan.md"
    elif [ "$arg" = "ultrawork" ] || [ "$arg" = "ulw" ]; then
        ULTRAWORK=1
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS=$arg
    elif [ "$arg" = "help" ] || [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
        echo "Usage: ralphus code [plan] [ulw] [N] [\"custom prompt\"]"
        exit 0
    else
        # Custom prompt injection
        if [ -f "$arg" ]; then
            # If argument is a file, read its content
            CONTENT=$(cat "$arg")
            CUSTOM_PROMPT="$CUSTOM_PROMPT $CONTENT"
        else
            # Otherwise treat as text string
            CUSTOM_PROMPT="$CUSTOM_PROMPT $arg"
        fi
    fi
done

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "=== RALPHUS CODE: $MODE mode | $AGENT | $CURRENT_BRANCH ==="
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

if [ ! -d "$SPECS_DIR" ]; then
    echo "Error: $SPECS_DIR/ directory not found."
    echo "Create $SPECS_DIR/*.md files with your specifications first."
    exit 1
fi

if [ "$MODE" = "build" ] && [ ! -f "$WORKING_DIR/IMPLEMENTATION_PLAN.md" ]; then
    echo "Error: IMPLEMENTATION_PLAN.md not found in $WORKING_DIR"
    echo "Run planning mode first: $0 plan"
    exit 1
fi

LAST_BRANCH_FILE="$WORKING_DIR/.last-branch"
if [ -f "$LAST_BRANCH_FILE" ]; then
    LAST_BRANCH=$(cat "$LAST_BRANCH_FILE")
    if [ "$LAST_BRANCH" != "$CURRENT_BRANCH" ]; then
        ARCHIVE_DIR="$WORKING_DIR/archive/$(date +%Y-%m-%d)-$LAST_BRANCH"
        mkdir -p "$ARCHIVE_DIR"
        cp "$WORKING_DIR/IMPLEMENTATION_PLAN.md" "$ARCHIVE_DIR/" 2>/dev/null || true
        cp "$WORKING_DIR/AGENTS.md" "$ARCHIVE_DIR/" 2>/dev/null || true
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
    
    if [ -n "$CUSTOM_PROMPT" ]; then
        MESSAGE="$MESSAGE. Additional Instructions: $CUSTOM_PROMPT"
    fi

    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        -f "$PROMPT_FILE" \
        -f "$TEMPLATES_DIR/IMPLEMENTATION_PLAN_REFERENCE.md" \
        -- "$MESSAGE" 2>&1 | tee /dev/stderr) || true

    if echo "$OUTPUT" | grep -q "<promise>PLAN_COMPLETE</promise>"; then
        echo "=== PLANNING COMPLETE ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>PHASE_COMPLETE</promise>"; then
        echo "=== PHASE COMPLETE - next iteration ==="
    fi
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo "=== ALL TASKS COMPLETE ===" && exit 0
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
