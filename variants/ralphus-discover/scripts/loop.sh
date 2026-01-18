#!/bin/bash
# =============================================================================
# Ralphus Discover - Autonomous Codebase Discovery Loop
# =============================================================================
# Explores and documents codebase architecture, patterns, and structure.
# Produces discoveries/ documentation from systematic exploration.
#
# Usage: ralphus discover [plan] [ulw] [N] ["custom prompt"]
#
# Modes:
#   plan        Create DISCOVERY_PLAN.md (exploration objectives)
#   (default)   Execute DISCOVERY_PLAN.md, documenting discoveries iteratively
#
# Options:
#   ulw         Enable ultrawork mode for thorough exploration
#   N           Max iterations (e.g., 10 to limit discovery cycles)
#   "<string>"  Append custom instructions to the prompt
#
# Examples:
#   ralphus discover plan               # Create exploration plan
#   ralphus discover                    # Execute plan, explore iteratively
#   ralphus discover ulw 5              # Ultrawork mode, max 5 iterations
#   ralphus discover "focus on auth"    # Custom: focus on auth subsystem
#
# Completion Signals:
#   PHASE_COMPLETE  - Discovery complete, continue to next area
#   COMPLETE        - All discoveries documented
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
# Validates that required directories and files exist for the discover variant.
# - discoveries/ directory is created automatically via REQUIRED_DIRS in config
# - DISCOVERY_PLAN.md must exist in build mode (created by plan mode)
# =============================================================================
validate_variant() {
    # In build mode, require DISCOVERY_PLAN.md
    if [[ "$MODE" != "plan" ]] && [[ ! -f "$WORKING_DIR/$TRACKING_FILE" ]]; then
        echo "ERROR: $TRACKING_FILE not found in $WORKING_DIR" >&2
        echo "Run planning mode first: ralphus discover plan" >&2
        return 1
    fi
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Provides the reference templates that guide the agent on how to format
# discovery plans, individual discoveries, and codebase understanding docs.
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/DISCOVERY_PLAN_REFERENCE.md"
    echo "$TEMPLATES_DIR/DISCOVERY_REFERENCE.md"
    echo "$TEMPLATES_DIR/CODEBASE_UNDERSTANDING_REFERENCE.md"
}

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
