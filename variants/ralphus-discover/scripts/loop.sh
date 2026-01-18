#!/bin/bash
# Ralphus Discover - Autonomous Codebase Discovery Loop
# Usage: ralphus discover [plan] [ulw] [N] ["custom prompt"]
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
