#!/bin/bash
# Ralphus Test - Autonomous Test Creation Loop
# Usage: ralphus test [plan] [ulw] [N] ["custom prompt"]
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
# Validates that required directories exist and there's work to do.
# - test-specs/ directory must exist (contains test specifications)
# - In build mode, checks for incomplete tests ([ ] checkboxes)
# =============================================================================
validate_variant() {
    local test_specs_dir="$WORKING_DIR/test-specs"
    
    # Require test-specs/ directory
    if [[ ! -d "$test_specs_dir" ]]; then
        echo "ERROR: $test_specs_dir/ directory not found." >&2
        echo "Create $test_specs_dir/*.md files with your test specifications." >&2
        return 1
    fi
    
    # In build mode, check for incomplete tests
    if [[ "$MODE" = "build" ]]; then
        echo "Test specs directory: $test_specs_dir/"
        
        # Check if any spec has incomplete tests ([ ] checkboxes)
        if ! grep -rq "\[ \]" "$test_specs_dir/" 2>/dev/null; then
            if grep -rq "\[x\]" "$test_specs_dir/" 2>/dev/null; then
                echo "=== ALL TESTS COMPLETE ==="
                exit 0
            else
                echo "Warning: No checkboxes found in test specs." >&2
                echo "Run planning mode first: ralphus test plan" >&2
                return 1
            fi
        fi
    fi
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Provides the template files that guide the agent on test creation and format.
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/TEST_PLAN_REFERENCE.md"
    echo "$TEMPLATES_DIR/SPEC_FORMAT_REFERENCE.md"
    echo "$TEMPLATES_DIR/SUMMARY_HEADER_REFERENCE.md"
    echo "$TEMPLATES_DIR/TEST_UTILITIES_REFERENCE.md"
}

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
