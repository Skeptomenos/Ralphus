#!/bin/bash
# Ralphus Reviewer - Autonomous Code Review Loop
# Usage: ./ralphus/ralphus-reviewer/scripts/loop.sh [plan] [pr|diff|files] [ultrawork|ulw] [max_iterations]
#
# Modes:
#   plan         - Analyze codebase and create review plan
#   (default)    - Execute review tasks from REVIEW_PLAN.md
#
# Review Targets (optional):
#   pr           - Review changes in current PR/branch vs main
#   diff         - Review uncommitted changes
#   files        - Review specific files (from review-targets/)
#
# Examples:
#   ./loop.sh plan                    # Create review plan for codebase
#   ./loop.sh plan pr                 # Plan review for PR changes only
#   ./loop.sh                         # Execute review (from plan)
#   ./loop.sh pr                      # Review PR changes
#   ./loop.sh 10                      # Max 10 review iterations

set -euo pipefail

# Central location (where prompts/templates live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPHUS_REVIEWER_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$RALPHUS_REVIEWER_DIR/instructions"
TEMPLATES_DIR="$RALPHUS_REVIEWER_DIR/templates"

# Working directory (where project files live)
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Configuration
AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"
REVIEW_TARGETS_DIR="$WORKING_DIR/review-targets"
ULTRAWORK=0

# Default mode and settings
MODE="review"
PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_review_build.md"
MAX_ITERATIONS=0
REVIEW_TARGET="codebase"  # codebase, pr, diff, or files

# Parse arguments
for arg in "$@"; do
    if [ "$arg" = "plan" ]; then
        MODE="plan"
        PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_review_plan.md"
    elif [ "$arg" = "pr" ]; then
        REVIEW_TARGET="pr"
    elif [ "$arg" = "diff" ]; then
        REVIEW_TARGET="diff"
    elif [ "$arg" = "files" ]; then
        REVIEW_TARGET="files"
    elif [ "$arg" = "ultrawork" ] || [ "$arg" = "ulw" ]; then
        ULTRAWORK=1
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS=$arg
    fi
done

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Header
echo "=== RALPHUS REVIEWER: $MODE mode | target=$REVIEW_TARGET | $AGENT | $CURRENT_BRANCH ==="
[ "$ULTRAWORK" -eq 1 ] && echo "Ultrawork: enabled"
[ "$MAX_ITERATIONS" -gt 0 ] && echo "Max iterations: $MAX_ITERATIONS"

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

# Verify templates directory exists
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "Error: $TEMPLATES_DIR/ directory not found."
    exit 1
fi

# For PR mode, ensure we have changes to review
if [ "$REVIEW_TARGET" = "pr" ]; then
    if [ "$CURRENT_BRANCH" = "$MAIN_BRANCH" ]; then
        echo "Error: Cannot review PR on $MAIN_BRANCH branch."
        echo "Check out a feature branch first."
        exit 1
    fi
    DIFF_COUNT=$(git diff --name-only "$MAIN_BRANCH"..."$CURRENT_BRANCH" 2>/dev/null | wc -l || echo "0")
    if [ "$DIFF_COUNT" -eq 0 ]; then
        echo "No changes detected between $CURRENT_BRANCH and $MAIN_BRANCH"
        exit 0
    fi
    echo "PR mode: $DIFF_COUNT files changed vs $MAIN_BRANCH"
fi

# For diff mode, check for uncommitted changes
if [ "$REVIEW_TARGET" = "diff" ]; then
    DIFF_COUNT=$(git diff --name-only 2>/dev/null | wc -l || echo "0")
    STAGED_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l || echo "0")
    TOTAL=$((DIFF_COUNT + STAGED_COUNT))
    if [ "$TOTAL" -eq 0 ]; then
        echo "No uncommitted changes to review."
        exit 0
    fi
    echo "Diff mode: $TOTAL files with uncommitted changes"
fi

# For files mode, verify review-targets directory
if [ "$REVIEW_TARGET" = "files" ]; then
    if [ ! -d "$REVIEW_TARGETS_DIR" ]; then
        echo "Error: $REVIEW_TARGETS_DIR/ directory not found."
        echo "Create $REVIEW_TARGETS_DIR/*.md with file lists to review."
        exit 1
    fi
fi

# Review mode: check for REVIEW_PLAN.md
if [ "$MODE" = "review" ] && [ ! -f "$WORKING_DIR/REVIEW_PLAN.md" ]; then
    echo "Error: REVIEW_PLAN.md not found in $WORKING_DIR"
    echo "Run planning mode first: $0 plan"
    exit 1
fi

# Archive previous run if branch changed
LAST_BRANCH_FILE="$WORKING_DIR/.last-review-branch"
if [ -f "$LAST_BRANCH_FILE" ]; then
    LAST_BRANCH=$(cat "$LAST_BRANCH_FILE")
    if [ "$LAST_BRANCH" != "$CURRENT_BRANCH" ]; then
        ARCHIVE_DIR="$WORKING_DIR/archive/reviews/$(date +%Y-%m-%d)-$LAST_BRANCH"
        mkdir -p "$ARCHIVE_DIR"
        cp "$WORKING_DIR/REVIEW_PLAN.md" "$ARCHIVE_DIR/" 2>/dev/null || true
        cp -r "$WORKING_DIR/reviews" "$ARCHIVE_DIR/" 2>/dev/null || true
        echo "Archived previous review to $ARCHIVE_DIR"
    fi
fi
echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"

# Create reviews output directory
mkdir -p "$WORKING_DIR/reviews"

# Graceful shutdown handler
SHUTDOWN=0
trap 'SHUTDOWN=1; echo -e "\n⚠ Shutdown requested. Finishing current review..."' INT TERM

# Export review target for prompts to use
export REVIEW_TARGET
export MAIN_BRANCH

# Main loop
while true; do
    # Check for shutdown request
    if [ "$SHUTDOWN" -eq 1 ]; then
        echo "Shutting down gracefully."
        exit 0
    fi

    # Check iteration limit
    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    ITERATION=$((ITERATION + 1))
    echo -e "\n======================== REVIEW ITERATION $ITERATION ========================\n"

    if [ "$ULTRAWORK" -eq 1 ]; then
        MESSAGE="Read the attached prompt file and execute the instructions. Review target: $REVIEW_TARGET. Main branch: $MAIN_BRANCH. ulw"
    else
        MESSAGE="Read the attached prompt file and execute the instructions. Review target: $REVIEW_TARGET. Main branch: $MAIN_BRANCH."
    fi

    # Run OpenCode with the prompt file and templates
    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        -f "$PROMPT_FILE" \
        -f "$TEMPLATES_DIR/REVIEW_PLAN_REFERENCE.md" \
        -f "$TEMPLATES_DIR/REVIEW_CHECKLIST_REFERENCE.md" \
        -f "$TEMPLATES_DIR/REVIEW_FINDING_REFERENCE.md" \
        -- "$MESSAGE" 2>&1 | tee /dev/stderr) || true

    # Check completion signals
    if echo "$OUTPUT" | grep -q "<promise>PLAN_COMPLETE</promise>"; then
        echo "=== REVIEW PLANNING COMPLETE ==="
        echo "Review plan created. Run: $0"
        exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>PHASE_COMPLETE</promise>"; then
        echo "=== REVIEW ITEM COMPLETE - next iteration ==="
    fi
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo "=== ALL REVIEWS COMPLETE ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>APPROVED</promise>"; then
        echo "=== CODE APPROVED - No issues found ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>BLOCKED:"; then
        echo "=== BLOCKED ===" && echo "$OUTPUT" | grep -o "<promise>BLOCKED:[^<]*</promise>" && exit 1
    fi

    # Push review artifacts after each iteration (if in a git repo)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only commit review artifacts, not code changes
        git add REVIEW_PLAN.md reviews/ 2>/dev/null || true
        git commit -m "Review iteration $ITERATION" 2>/dev/null || true
        git push origin "$CURRENT_BRANCH" 2>/dev/null || {
            echo "Note: Failed to push review artifacts."
            git push -u origin "$CURRENT_BRANCH" 2>/dev/null || echo "Warning: Could not push to remote"
        }
    fi
done

echo "=== Review loop finished after $ITERATION iterations ==="
