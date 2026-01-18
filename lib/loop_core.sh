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
# Core functions will be implemented in subsequent tasks (1.3 - 1.16)
# =============================================================================
