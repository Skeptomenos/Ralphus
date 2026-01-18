#!/bin/bash
# =============================================================================
# Ralphus Code - Autonomous Feature Implementation Loop
# =============================================================================
# Implements features from specs/*.md by following IMPLEMENTATION_PLAN.md.
# Uses the shared library loop pattern with plan/build modes.
#
# Usage: ralphus code [plan] [ulw] [N] ["custom prompt"]
#
# Modes:
#   plan        Create IMPLEMENTATION_PLAN.md from specs/*.md
#   (default)   Execute IMPLEMENTATION_PLAN.md task by task
#
# Options:
#   ulw         Enable ultrawork mode for complex reasoning
#   N           Max iterations (e.g., 10 to stop after 10 tasks)
#   "<string>"  Append custom instructions to the prompt
#
# Examples:
#   ralphus code plan              # Analyze specs, create IMPLEMENTATION_PLAN.md
#   ralphus code                   # Execute plan, one task per iteration
#   ralphus code ulw 5             # Ultrawork mode, max 5 iterations
#   ralphus code "focus on tests"  # Custom prompt appended to message
#
# Completion Signals:
#   PHASE_COMPLETE  - Task finished, continue to next task
#   COMPLETE        - All tasks done
#   BLOCKED         - Cannot proceed, needs intervention
#
# Thin wrapper that sources the shared library and provides variant-specific hooks.
# =============================================================================

set -euo pipefail

# Determine script and variant directories
# (Use temporary vars since loop_core.sh initializes globals to empty)
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_VARIANT_DIR="$(dirname "$_SCRIPT_DIR")"

# Source variant configuration and shared library
source "$_VARIANT_DIR/config.sh"
source "$_VARIANT_DIR/../../lib/loop_core.sh"

# =============================================================================
# Hook: validate_variant() - Check variant-specific requirements
# =============================================================================
# Validates that required directories and files exist for the code variant.
# - specs/ directory must exist (contains feature specifications)
# - IMPLEMENTATION_PLAN.md must exist in build mode (created by plan mode)
# =============================================================================
validate_variant() {
    local specs_dir="$WORKING_DIR/specs"
    
    # Require specs/ directory
    if [[ ! -d "$specs_dir" ]]; then
        echo "ERROR: $specs_dir/ directory not found." >&2
        echo "Create $specs_dir/*.md files with your specifications first." >&2
        return 1
    fi
    
    # In build mode, require IMPLEMENTATION_PLAN.md
    if [[ "$MODE" = "build" ]] && [[ ! -f "$WORKING_DIR/$TRACKING_FILE" ]]; then
        echo "ERROR: $TRACKING_FILE not found in $WORKING_DIR" >&2
        echo "Run planning mode first: ralphus code plan" >&2
        return 1
    fi
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Provides the IMPLEMENTATION_PLAN_REFERENCE.md template that guides the agent
# on how to format and structure the implementation plan.
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/IMPLEMENTATION_PLAN_REFERENCE.md"
}

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
