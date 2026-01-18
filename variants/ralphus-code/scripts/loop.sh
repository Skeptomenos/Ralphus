#!/bin/bash
# Ralphus Code - Autonomous Feature Implementation Loop
# Usage: ralphus code [plan] [ulw] [N] ["custom prompt"]
#
# Thin wrapper that sources the shared library and provides variant-specific hooks.

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
