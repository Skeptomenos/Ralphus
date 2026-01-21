#!/bin/bash
# =============================================================================
# Ralphus Synthesis - Architectural Distillation Loop
# =============================================================================
# Usage: ralphus synthesis [mode] [plan]
# Modes: discover, research, all (default)
# =============================================================================

set -euo pipefail

# Determine script and variant directories
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_VARIANT_DIR="$(dirname "$_SCRIPT_DIR")"

# 1. PARSE MODE ARGUMENT (Before sourcing config/lib)
# We need to peek at $1 to set the tracking file
MODE_ARG="${1:-all}"

# If user typed "plan" as first arg, default to "all" mode
if [[ "$MODE_ARG" == "plan" ]]; then
    MODE_ARG="all"
    # Don't shift, let the loop_core handle 'plan'
else
    # Valid modes: discover, research, all
    if [[ "$MODE_ARG" =~ ^(discover|research|all)$ ]]; then
        shift # Consume the mode arg
    else
        # If unknown arg, assume 'all' and pass it through (maybe it's 'ulw' or 'help')
        MODE_ARG="all"
    fi
fi

# 2. CONFIGURE BASED ON MODE
case "$MODE_ARG" in
    discover)
        export RALPH_INPUT_DIR="ralph-wiggum/discover/artifacts"
        export RALPH_TRACKING_FILE="ralph-wiggum/synthesis/plan-discover.md"
        export RALPH_OUTPUT_DIR="docs/architecture/discover"
        ;;
    research)
        export RALPH_INPUT_DIR="ralph-wiggum/research/artifacts"
        export RALPH_TRACKING_FILE="ralph-wiggum/synthesis/plan-research.md"
        export RALPH_OUTPUT_DIR="docs/architecture/research"
        ;;
    *)
        MODE_ARG="all"
        export RALPH_INPUT_DIR="ralph-wiggum/discover/artifacts ralph-wiggum/research/artifacts"
        export RALPH_TRACKING_FILE="ralph-wiggum/synthesis/plan-all.md"
        export RALPH_OUTPUT_DIR="docs/architecture"
        ;;
esac

# 3. EXPORT FOR CONFIG.SH TO CONSUME
export TRACKING_FILE="$RALPH_TRACKING_FILE"

# Source configuration and shared library
source "$_VARIANT_DIR/config.sh"
source "$_VARIANT_DIR/../../lib/loop_core.sh"

# =============================================================================
# Hook: build_message() - Inject Dynamic Context
# =============================================================================
build_message() {
    echo "# SYNTHESIS CONTEXT: $MODE_ARG"
    echo "You are running in '$MODE_ARG' mode."
    echo "INPUT SOURCES: $RALPH_INPUT_DIR"
    echo "TRACKING PLAN: $RALPH_TRACKING_FILE"
    echo "OUTPUT TARGET: $RALPH_OUTPUT_DIR"
    echo ""
    echo "---"
    echo ""
    cat "$PROMPT_FILE"
}

# =============================================================================
# Hook: validate_variant() - Check inputs exist
# =============================================================================
validate_variant() {
    # Check if input dirs exist
    for dir in $RALPH_INPUT_DIR; do
        if [[ ! -d "$WORKING_DIR/$dir" ]]; then
            echo "WARNING: Input directory '$dir' not found." >&2
        fi
    done
    
    # Ensure synthesis dir exists
    mkdir -p "$WORKING_DIR/ralph-wiggum/synthesis/partials"
    mkdir -p "$WORKING_DIR/$(dirname "$RALPH_TRACKING_FILE")"
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/SYNTHESIS_PLAN_REFERENCE.md"
}

# Run the shared loop
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
