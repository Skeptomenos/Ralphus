#!/bin/bash
# =============================================================================
# loop_core.sh - Shared library for Ralphus autonomous loop variants
# =============================================================================
#
# This library extracts common functionality from all ralphus-* variant loops.
# Each variant sources this file and implements hooks for variant-specific behavior.
#
# Usage (from variant loop.sh):
#   source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/../lib/loop_core.sh"
#   source "$VARIANT_DIR/config.sh"
#   run_loop "$@"
#
# Architecture:
#   - Shared functions handle: init, arg parsing, shutdown, signals, git ops
#   - Variants provide: config.sh (variables) and hook implementations
#   - Hooks allow customization without code duplication
#
# Hook System:
#   Required:
#     get_templates()      - Return array of template files for opencode
#
#   Optional (default no-op implementations provided):
#     validate_variant()   - Check variant-specific inputs
#     get_archive_files()  - Return files to archive on branch change
#     build_message()      - Construct custom iteration message
#     post_iteration()     - Run after each iteration
#     parse_variant_args() - Handle variant-specific arguments
#
# Completion Signals:
#   <promise>PLAN_COMPLETE</promise>   - Planning phase done
#   <promise>PHASE_COMPLETE</promise>  - Single task done, continue loop
#   <promise>COMPLETE</promise>        - All tasks done, exit success
#   <promise>BLOCKED:task:reason</promise> - Stuck, exit failure
#   <promise>APPROVED</promise>        - Review approved (review variant only)
#
# =============================================================================

set -euo pipefail

# =============================================================================
# Global Variables (set by init_ralphus and parse_common_args)
# =============================================================================

# Directory paths (set by init_ralphus from caller context)
SCRIPT_DIR=""
VARIANT_DIR=""
WORKING_DIR=""
INSTRUCTIONS_DIR=""
TEMPLATES_DIR=""

# Runtime configuration
AGENT=""
OPENCODE=""
ULTRAWORK=0
MODE="build"
MAX_ITERATIONS=0
CUSTOM_PROMPT=""

# State variables
ITERATION=0
SHUTDOWN=0
CURRENT_BRANCH=""

# =============================================================================
# 1.3 init_ralphus() - Initialize Ralphus environment from caller context
# =============================================================================
# Called by variant loop.sh after sourcing this library.
# Expects SCRIPT_DIR and VARIANT_DIR to be set by the caller.
#
# Arguments:
#   $1 - SCRIPT_DIR from caller (where the variant loop.sh lives)
#   $2 - VARIANT_DIR from caller (parent of scripts/, contains config.sh)
#
# Sets:
#   SCRIPT_DIR, VARIANT_DIR - From arguments
#   WORKING_DIR - From RALPHUS_WORKING_DIR env or pwd
#   AGENT - From RALPH_AGENT env or "Sisyphus"
#   OPENCODE - From OPENCODE_BIN env or "opencode"
#   INSTRUCTIONS_DIR, TEMPLATES_DIR - Derived from VARIANT_DIR
#   ULTRAWORK, MODE, MAX_ITERATIONS, CUSTOM_PROMPT - Initialized to defaults
# =============================================================================
init_ralphus() {
    local caller_script_dir="${1:-}"
    local caller_variant_dir="${2:-}"

    # Validate required arguments
    if [[ -z "$caller_script_dir" ]]; then
        echo "ERROR: init_ralphus requires SCRIPT_DIR as first argument" >&2
        exit 1
    fi
    if [[ -z "$caller_variant_dir" ]]; then
        echo "ERROR: init_ralphus requires VARIANT_DIR as second argument" >&2
        exit 1
    fi

    # Set directory paths from caller
    SCRIPT_DIR="$caller_script_dir"
    VARIANT_DIR="$caller_variant_dir"
    INSTRUCTIONS_DIR="$VARIANT_DIR/instructions"
    TEMPLATES_DIR="$VARIANT_DIR/templates"

    # Set working directory: env var takes precedence, fallback to pwd
    WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

    # Set agent: env var takes precedence, fallback to Sisyphus
    AGENT="${RALPH_AGENT:-Sisyphus}"

    # Set opencode binary: env var takes precedence, fallback to opencode
    OPENCODE="${OPENCODE_BIN:-opencode}"

    # Initialize runtime state to defaults
    ULTRAWORK=0
    MODE="build"
    MAX_ITERATIONS=0
    CUSTOM_PROMPT=""
    ITERATION=0
    SHUTDOWN=0

    # Get current git branch for archive/tracking purposes
    if command -v git &>/dev/null && [[ -d "$WORKING_DIR/.git" ]]; then
        CURRENT_BRANCH=$(cd "$WORKING_DIR" && git branch --show-current 2>/dev/null || echo "")
    else
        CURRENT_BRANCH=""
    fi
}

# =============================================================================
# 1.4 parse_common_args() - Parse command-line arguments common to all variants
# =============================================================================
# Handles standardized argument parsing using for-loop pattern (not while/case).
# Variants can provide parse_variant_args() hook for variant-specific args.
#
# Arguments:
#   "$@" - All command-line arguments
#
# Recognizes:
#   plan         - Sets MODE="plan"
#   ulw/ultrawork - Sets ULTRAWORK=1
#   <numeric>    - Sets MAX_ITERATIONS
#   help/-h/--help - Prints usage and exits
#   <file>       - Reads file content and appends to CUSTOM_PROMPT
#   <string>     - Appends string to CUSTOM_PROMPT
#
# Sets:
#   MODE, ULTRAWORK, MAX_ITERATIONS, CUSTOM_PROMPT - Based on parsed args
#
# Note: Variants may override this behavior by defining parse_variant_args()
# which is called first. If parse_variant_args returns 0, the arg was handled.
# =============================================================================
parse_common_args() {
    for arg in "$@"; do
        # First, let variant try to handle the argument
        # parse_variant_args returns 0 if it handled the arg
        if type parse_variant_args &>/dev/null && parse_variant_args "$arg"; then
            continue
        fi

        # Common argument handling
        if [[ "$arg" = "plan" ]]; then
            MODE="plan"
        elif [[ "$arg" = "ultrawork" ]] || [[ "$arg" = "ulw" ]]; then
            ULTRAWORK=1
        elif [[ "$arg" =~ ^[0-9]+$ ]]; then
            MAX_ITERATIONS=$arg
        elif [[ "$arg" = "help" ]] || [[ "$arg" = "--help" ]] || [[ "$arg" = "-h" ]]; then
            show_usage
            exit 0
        else
            # Custom prompt injection: file or string
            if [[ -f "$arg" ]]; then
                # Argument is a file - read its content
                local content
                content=$(cat "$arg")
                CUSTOM_PROMPT="${CUSTOM_PROMPT} ${content}"
            else
                # Otherwise treat as text string
                CUSTOM_PROMPT="${CUSTOM_PROMPT} ${arg}"
            fi
        fi
    done

    # Trim leading whitespace from CUSTOM_PROMPT
    CUSTOM_PROMPT="${CUSTOM_PROMPT# }"
}

# =============================================================================
# Default hook implementations (can be overridden by variants)
# =============================================================================

# Default usage - variants should override with their own help message
show_usage() {
    echo "Usage: ralphus ${VARIANT_NAME:-variant} [plan] [ulw] [N] [\"custom prompt\"]"
    echo ""
    echo "Options:"
    echo "  plan       Run in planning mode"
    echo "  ulw        Enable ultrawork mode"
    echo "  N          Max iterations (e.g., 10)"
    echo "  <file>     Read custom prompt from file"
    echo "  <string>   Append custom prompt string"
}

# Default no-op for parse_variant_args - variants override if needed
# Returns 1 (not handled) by default, so parse_common_args handles everything
parse_variant_args() {
    return 1
}

# =============================================================================
# 1.5 show_header() - Display startup banner with current configuration
# =============================================================================
# Prints a formatted header showing the variant name, mode, agent, and branch.
# Also displays ultrawork and max_iterations if they are set.
#
# Uses globals:
#   VARIANT_NAME - From config.sh (e.g., "code", "review", "architect")
#   MODE - From parse_common_args() (e.g., "build", "plan")
#   AGENT - From init_ralphus() (default: "Sisyphus")
#   CURRENT_BRANCH - Git branch name
#   ULTRAWORK - Flag (0 or 1)
#   MAX_ITERATIONS - Iteration limit (0 = unlimited)
# =============================================================================
show_header() {
    echo ""
    echo "=== RALPHUS ${VARIANT_NAME:-unknown}: ${MODE} mode | ${AGENT} | ${CURRENT_BRANCH:-no-branch} ==="
    
    # Show optional settings if enabled
    if [[ "$ULTRAWORK" -eq 1 ]]; then
        echo "    Ultrawork: ENABLED"
    fi
    
    if [[ "$MAX_ITERATIONS" -gt 0 ]]; then
        echo "    Max iterations: ${MAX_ITERATIONS}"
    fi
    
    echo ""
}

# =============================================================================
# 1.6 validate_common() - Validate common requirements before loop starts
# =============================================================================
# Checks that essential files and directories exist for the loop to run.
# Uses config variables (DEFAULT_PROMPT, PLAN_PROMPT) to determine PROMPT_FILE.
#
# Uses globals:
#   MODE - "build" or "plan" (determines which prompt file to use)
#   INSTRUCTIONS_DIR - Path to variant's instructions directory
#   TEMPLATES_DIR - Path to variant's templates directory
#   DEFAULT_PROMPT - Filename for build mode prompt (from config.sh)
#   PLAN_PROMPT - Filename for plan mode prompt (from config.sh)
#
# Sets:
#   PROMPT_FILE - Full path to the appropriate prompt file
#
# Returns:
#   0 - Validation passed
#   1 - Validation failed (prints error and returns)
# =============================================================================
validate_common() {
    # Determine which prompt file to use based on mode
    if [[ "$MODE" = "plan" ]] && [[ -n "${PLAN_PROMPT:-}" ]]; then
        PROMPT_FILE="$INSTRUCTIONS_DIR/$PLAN_PROMPT"
    else
        PROMPT_FILE="$INSTRUCTIONS_DIR/${DEFAULT_PROMPT:-PROMPT_build.md}"
    fi

    # Check that INSTRUCTIONS_DIR exists
    if [[ ! -d "$INSTRUCTIONS_DIR" ]]; then
        echo "ERROR: Instructions directory not found: $INSTRUCTIONS_DIR" >&2
        return 1
    fi

    # Check that PROMPT_FILE exists
    if [[ ! -f "$PROMPT_FILE" ]]; then
        echo "ERROR: Prompt file not found: $PROMPT_FILE" >&2
        return 1
    fi

    # Check that TEMPLATES_DIR exists
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        echo "ERROR: Templates directory not found: $TEMPLATES_DIR" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# Remaining core functions (1.7 - 1.16) to be implemented in subsequent tasks
# =============================================================================
