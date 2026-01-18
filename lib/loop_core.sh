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
# Remaining core functions (1.4 - 1.16) to be implemented in subsequent tasks
# =============================================================================
