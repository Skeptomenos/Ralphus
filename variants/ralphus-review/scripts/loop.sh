#!/bin/bash
# Ralphus Review - Autonomous Code Review Loop
# Usage: ralphus review [plan] [pr|diff|files] [ulw] [N] ["custom prompt"]
#
# Review Targets:
#   pr     - Review changes in current PR/branch vs main
#   diff   - Review uncommitted changes
#   files  - Review specific files (from review-targets/)
#
# Thin wrapper that sources the shared library and provides variant-specific hooks.

set -euo pipefail

# Determine script and variant directories
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_VARIANT_DIR="$(dirname "$_SCRIPT_DIR")"

# Source variant configuration and shared library
source "$_VARIANT_DIR/config.sh"
source "$_VARIANT_DIR/../../lib/loop_core.sh"

# =============================================================================
# Variant-specific state (set by parse_variant_args)
# =============================================================================
REVIEW_TARGET="codebase"  # codebase, pr, diff, or files
MAIN_BRANCH=""
REVIEW_TARGETS_DIR=""

# =============================================================================
# Hook: parse_variant_args() - Handle review-specific arguments
# =============================================================================
# Handles pr, diff, and files target selection. Returns 0 if arg was handled.
# =============================================================================
parse_variant_args() {
    local arg="$1"
    case "$arg" in
        pr)
            REVIEW_TARGET="pr"
            return 0
            ;;
        diff)
            REVIEW_TARGET="diff"
            return 0
            ;;
        files)
            REVIEW_TARGET="files"
            return 0
            ;;
    esac
    return 1
}

# =============================================================================
# Hook: validate_variant() - Check review-specific requirements
# =============================================================================
# Validates based on MODE and REVIEW_TARGET:
# - In review mode (not plan), REVIEW_PLAN.md must exist
# - In PR mode, cannot be on main branch and must have changes
# - In diff mode, must have uncommitted changes
# - In files mode, review-targets/ directory must exist
# =============================================================================
validate_variant() {
    REVIEW_TARGETS_DIR="$WORKING_DIR/review-targets"
    
    # Determine main branch
    MAIN_BRANCH=$(cd "$WORKING_DIR" && git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    
    # PR mode checks
    if [[ "$REVIEW_TARGET" = "pr" ]]; then
        if [[ "$CURRENT_BRANCH" = "$MAIN_BRANCH" ]]; then
            echo "ERROR: Cannot review PR on $MAIN_BRANCH branch." >&2
            echo "Check out a feature branch first." >&2
            return 1
        fi
        local diff_count
        diff_count=$(cd "$WORKING_DIR" && git diff --name-only "$MAIN_BRANCH"..."$CURRENT_BRANCH" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        if [[ "$diff_count" -eq 0 ]]; then
            echo "No changes detected between $CURRENT_BRANCH and $MAIN_BRANCH"
            exit 0
        fi
        echo "PR mode: $diff_count files changed vs $MAIN_BRANCH"
    fi
    
    # Diff mode checks
    if [[ "$REVIEW_TARGET" = "diff" ]]; then
        local diff_count staged_count total
        diff_count=$(cd "$WORKING_DIR" && git diff --name-only 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        staged_count=$(cd "$WORKING_DIR" && git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        total=$((diff_count + staged_count))
        if [[ "$total" -eq 0 ]]; then
            echo "No uncommitted changes to review."
            exit 0
        fi
        echo "Diff mode: $total files with uncommitted changes"
    fi
    
    # Files mode checks
    if [[ "$REVIEW_TARGET" = "files" ]]; then
        if [[ ! -d "$REVIEW_TARGETS_DIR" ]]; then
            echo "ERROR: $REVIEW_TARGETS_DIR/ directory not found." >&2
            echo "Create $REVIEW_TARGETS_DIR/*.md with file lists to review." >&2
            return 1
        fi
    fi
    
    # In review mode (not plan), require REVIEW_PLAN.md
    if [[ "$MODE" = "build" ]] && [[ ! -f "$WORKING_DIR/$TRACKING_FILE" ]]; then
        echo "ERROR: $TRACKING_FILE not found in $WORKING_DIR" >&2
        echo "Run planning mode first: ralphus review plan" >&2
        return 1
    fi
    
    # Create reviews output directory
    mkdir -p "$WORKING_DIR/reviews"
    
    # Export for prompt access
    export REVIEW_TARGET
    export MAIN_BRANCH
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Note: PROJECT_CONTEXT.md is not attached - agent reads it directly from working dir
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/REVIEW_PLAN_REFERENCE.md"
    echo "$TEMPLATES_DIR/REVIEW_CHECKLIST_REFERENCE.md"
    echo "$TEMPLATES_DIR/REVIEW_FINDING_REFERENCE.md"
}

# =============================================================================
# Hook: build_message() - Construct message with review context
# =============================================================================
# Adds REVIEW_TARGET and MAIN_BRANCH to the standard message.
# =============================================================================
build_message() {
    MESSAGE="Read the attached prompt file and execute the instructions. Review target: $REVIEW_TARGET. Main branch: $MAIN_BRANCH."
    
    if [[ "$ULTRAWORK" -eq 1 ]]; then
        MESSAGE="$MESSAGE ulw"
    fi
    
    if [[ -n "${CUSTOM_PROMPT:-}" ]]; then
        MESSAGE="$MESSAGE Additional Instructions: $CUSTOM_PROMPT"
    fi
}

# =============================================================================
# Hook: post_iteration() - Commit review artifacts after each iteration
# =============================================================================
# Commits only review artifacts (REVIEW_PLAN.md, reviews/) not code changes.
# =============================================================================
post_iteration() {
    # Only commit if in a git repo
    if ! (cd "$WORKING_DIR" && git rev-parse --git-dir > /dev/null 2>&1); then
        return 0
    fi
    
    # Stage and commit review artifacts only
    (cd "$WORKING_DIR" && git add "$TRACKING_FILE" reviews/ 2>/dev/null) || true
    (cd "$WORKING_DIR" && git commit -m "Review iteration $ITERATION" 2>/dev/null) || true
}

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
