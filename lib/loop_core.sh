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
# 1.7 archive_on_branch_change() - Archive files when switching branches
# =============================================================================
# Detects when the git branch has changed since the last run and archives
# relevant files to prevent overwriting work from a previous branch.
#
# Uses globals:
#   WORKING_DIR - Project working directory
#   CURRENT_BRANCH - Current git branch name (from init_ralphus)
#   LAST_BRANCH_FILE - Filename to store last branch (from config.sh)
#   ARCHIVE_FILES - Array of files to archive (from config.sh)
#
# Behavior:
#   1. Reads LAST_BRANCH_FILE from WORKING_DIR to get previous branch
#   2. Compares to CURRENT_BRANCH
#   3. If different, creates archive/<date>-<last-branch>/ and copies ARCHIVE_FILES
#   4. Writes CURRENT_BRANCH to LAST_BRANCH_FILE for next run
#
# Note: Uses || true for copy operations to avoid failure if files don't exist.
# =============================================================================
archive_on_branch_change() {
    # Skip if no LAST_BRANCH_FILE configured
    if [[ -z "${LAST_BRANCH_FILE:-}" ]]; then
        return 0
    fi

    # Skip if no current branch (not a git repo or detached HEAD)
    if [[ -z "${CURRENT_BRANCH:-}" ]]; then
        return 0
    fi

    local last_branch_path="$WORKING_DIR/$LAST_BRANCH_FILE"
    local last_branch=""

    # Read the last branch if the file exists
    if [[ -f "$last_branch_path" ]]; then
        last_branch=$(cat "$last_branch_path")

        # Check if branch has changed
        if [[ "$last_branch" != "$CURRENT_BRANCH" ]]; then
            # Create archive directory with date and last branch name
            local archive_dir="$WORKING_DIR/archive/$(date +%Y-%m-%d)-$last_branch"
            mkdir -p "$archive_dir"

            # Copy each file in ARCHIVE_FILES array
            # Uses || true to ignore errors if files don't exist
            if [[ -n "${ARCHIVE_FILES:-}" ]]; then
                for file in "${ARCHIVE_FILES[@]}"; do
                    local source_path="$WORKING_DIR/$file"
                    if [[ -e "$source_path" ]]; then
                        cp -r "$source_path" "$archive_dir/" 2>/dev/null || true
                    fi
                done
            fi

            echo "Archived previous run to $archive_dir"
        fi
    fi

    # Always write current branch to the file for next run
    echo "$CURRENT_BRANCH" > "$last_branch_path"
}

# =============================================================================
# 1.8 setup_shutdown_handler() - Configure graceful shutdown on INT/TERM signals
# =============================================================================
# Sets up a trap handler for INT (Ctrl+C) and TERM signals. When triggered,
# sets SHUTDOWN=1 to signal the main loop to exit after the current iteration.
#
# Uses globals:
#   SHUTDOWN - Set to 0 initially, becomes 1 when shutdown requested
#
# Behavior:
#   - Sets SHUTDOWN=0 to initialize
#   - Traps INT and TERM signals
#   - When signal received: sets SHUTDOWN=1 and prints warning message
#
# Note: This allows the loop to complete its current iteration before exiting,
# preventing partial operations or data corruption.
# =============================================================================
setup_shutdown_handler() {
    SHUTDOWN=0
    trap 'SHUTDOWN=1; echo -e "\n⚠ Shutdown requested. Finishing current iteration..."' INT TERM
}

# =============================================================================
# 1.9 check_shutdown() - Exit gracefully if shutdown was requested
# =============================================================================
# Called at the beginning of each loop iteration to check if a shutdown signal
# (INT/TERM) was received during the previous iteration.
#
# Uses globals:
#   SHUTDOWN - Set to 1 by setup_shutdown_handler() trap when signal received
#
# Behavior:
#   - If SHUTDOWN=1, prints shutdown message and exits with code 0
#   - If SHUTDOWN=0, returns immediately (loop continues)
#
# Note: This function is called by run_loop() at the start of each iteration.
# It ensures the loop completes cleanly after receiving Ctrl+C or TERM signal.
# =============================================================================
check_shutdown() {
    if [[ "$SHUTDOWN" -eq 1 ]]; then
        echo "Shutting down gracefully."
        exit 0
    fi
}

# =============================================================================
# 1.10 check_max_iterations() - Check if iteration limit has been reached
# =============================================================================
# Called at the beginning of each loop iteration to check if the maximum number
# of iterations has been reached. Used to limit runaway loops.
#
# Uses globals:
#   MAX_ITERATIONS - Maximum allowed iterations (0 = unlimited)
#   ITERATION - Current iteration count
#
# Returns:
#   0 - Continue looping (limit not reached or unlimited)
#   1 - Stop looping (iteration limit reached)
#
# Example usage in run_loop():
#   if ! check_max_iterations; then
#       echo "Max iterations ($MAX_ITERATIONS) reached."
#       exit 0
#   fi
# =============================================================================
check_max_iterations() {
    # If MAX_ITERATIONS is 0 or unset, no limit - always continue
    if [[ "${MAX_ITERATIONS:-0}" -eq 0 ]]; then
        return 0
    fi

    # Check if we've reached or exceeded the limit
    if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
        return 1
    fi

    return 0
}

# =============================================================================
# 1.11 build_base_message() - Construct the base message for opencode execution
# =============================================================================
# Builds the standard message sent to opencode with optional ultrawork suffix
# and custom prompt injection.
#
# Uses globals:
#   ULTRAWORK - Flag (0 or 1) to append "ulw" suffix
#   CUSTOM_PROMPT - Additional instructions to append (optional)
#
# Sets:
#   MESSAGE - The constructed message string for opencode
#
# Behavior:
#   1. Starts with standard "Read the attached prompt file..." message
#   2. If ULTRAWORK=1, appends " ulw" suffix
#   3. If CUSTOM_PROMPT is set, appends ". Additional Instructions: $CUSTOM_PROMPT"
#
# Note: Variants can override this by defining their own build_message() hook.
# The run_loop() function calls build_message() first if defined, otherwise
# uses this default implementation.
# =============================================================================
build_base_message() {
    # Standard base message used by most variants
    MESSAGE="Read the attached prompt file and execute the instructions"
    
    # Append ultrawork suffix if enabled
    if [[ "$ULTRAWORK" -eq 1 ]]; then
        MESSAGE="$MESSAGE ulw"
    fi
    
    # Append custom prompt if provided
    if [[ -n "${CUSTOM_PROMPT:-}" ]]; then
        MESSAGE="$MESSAGE. Additional Instructions: $CUSTOM_PROMPT"
    fi
}

# =============================================================================
# 1.12 run_opencode() - Execute opencode with prompt and template files
# =============================================================================
# Runs the opencode CLI with the configured agent, prompt file, and any
# additional template files. Captures output while also displaying it.
#
# Arguments:
#   $@ - Additional template files to include via -f flags
#
# Uses globals:
#   OPENCODE - Path to opencode binary (from init_ralphus)
#   AGENT - Agent name to use (from init_ralphus)
#   PROMPT_FILE - Main prompt file path (from validate_common)
#   MESSAGE - The message to send (from build_base_message or build_message)
#   WORKING_DIR - Directory to run opencode in
#
# Returns:
#   Sets OUTPUT global with captured stdout/stderr
#   Returns the exit code from opencode (or 0 if using || true pattern)
#
# Behavior:
#   1. Builds command with --agent and -f flags for prompt and templates
#   2. Executes in WORKING_DIR context
#   3. Uses tee to both capture output and display in real-time
#   4. Suppresses exit code failures (|| true) since signals indicate completion
#
# Example:
#   build_base_message
#   run_opencode "$TEMPLATES_DIR/IMPLEMENTATION_PLAN_REFERENCE.md"
#   check_signals
# =============================================================================
run_opencode() {
    local template_files=("$@")
    
    # Build the command arguments
    local cmd_args=()
    cmd_args+=(run --agent "$AGENT")
    
    # Add the main prompt file
    cmd_args+=(-f "$PROMPT_FILE")
    
    # Add all template files
    for template in "${template_files[@]}"; do
        if [[ -n "$template" && -f "$template" ]]; then
            cmd_args+=(-f "$template")
        fi
    done
    
    # Add separator and message
    cmd_args+=(-- "$MESSAGE")
    
    # Execute opencode in WORKING_DIR, capture output while displaying
    # Uses || true to prevent exit on non-zero return (signals indicate completion)
    OUTPUT=$(cd "$WORKING_DIR" && "$OPENCODE" "${cmd_args[@]}" 2>&1 | tee /dev/stderr) || true
}

# =============================================================================
# 1.13 check_signals() - Check opencode output for completion signals
# =============================================================================
# Parses the OUTPUT from run_opencode() for completion promise tags.
# Returns an exit code indicating the signal found (or 0 for no signal).
#
# Uses globals:
#   OUTPUT - Captured output from run_opencode()
#   EXTRA_SIGNALS - Optional array of additional signals to check (from config.sh)
#
# Sets globals:
#   SIGNAL_FOUND - The signal that was detected (empty if none)
#   BLOCKED_REASON - Extracted reason from BLOCKED signal (if applicable)
#
# Returns:
#   0 - Continue looping (no signal or PHASE_COMPLETE)
#   10 - PLAN_COMPLETE (exit with success)
#   20 - COMPLETE (exit with success)
#   30 - BLOCKED (exit with failure)
#   40 - APPROVED (exit with success, review variant only)
#
# Signal precedence (checked in order):
#   1. BLOCKED - Most critical, indicates failure
#   2. PLAN_COMPLETE - Planning phase done
#   3. COMPLETE - All tasks done
#   4. APPROVED - Review approved (if in EXTRA_SIGNALS)
#   5. PHASE_COMPLETE - Single task done, continue loop
#
# Example usage in run_loop():
#   run_opencode "${templates[@]}"
#   check_signals
#   case $? in
#       10) echo "=== PLANNING COMPLETE ===" && exit 0 ;;
#       20) echo "=== ALL TASKS COMPLETE ===" && exit 0 ;;
#       30) echo "=== BLOCKED ===" && echo "$BLOCKED_REASON" && exit 1 ;;
#       40) echo "=== APPROVED ===" && exit 0 ;;
#       0)  continue ;;  # PHASE_COMPLETE or no signal
#   esac
# =============================================================================
check_signals() {
    # Initialize signal tracking variables
    SIGNAL_FOUND=""
    BLOCKED_REASON=""

    # Early return if OUTPUT is empty
    if [[ -z "${OUTPUT:-}" ]]; then
        return 0
    fi

    # Check for BLOCKED signal first (highest priority - indicates failure)
    if echo "$OUTPUT" | grep -q "<promise>BLOCKED:"; then
        SIGNAL_FOUND="BLOCKED"
        # Extract the blocked reason between the tags
        BLOCKED_REASON=$(echo "$OUTPUT" | grep -o "<promise>BLOCKED:[^<]*</promise>" | head -1)
        return 30
    fi

    # Check for PLAN_COMPLETE signal
    if echo "$OUTPUT" | grep -q "<promise>PLAN_COMPLETE</promise>"; then
        SIGNAL_FOUND="PLAN_COMPLETE"
        return 10
    fi

    # Check for COMPLETE signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        SIGNAL_FOUND="COMPLETE"
        return 20
    fi

    # Check for APPROVED signal (typically only in review variant via EXTRA_SIGNALS)
    # Also check directly for variants that define it in config
    if [[ -n "${EXTRA_SIGNALS:-}" ]]; then
        for signal in "${EXTRA_SIGNALS[@]}"; do
            if [[ "$signal" = "APPROVED" ]] && echo "$OUTPUT" | grep -q "<promise>APPROVED</promise>"; then
                SIGNAL_FOUND="APPROVED"
                return 40
            fi
        done
    fi

    # Check for PHASE_COMPLETE signal (continues loop)
    if echo "$OUTPUT" | grep -q "<promise>PHASE_COMPLETE</promise>"; then
        SIGNAL_FOUND="PHASE_COMPLETE"
        echo "=== PHASE COMPLETE - next iteration ==="
        return 0
    fi

    # No signal found - continue loop
    return 0
}

# =============================================================================
# 1.14 git_push() - Push with retry and -u fallback
# =============================================================================
# Pushes current branch to origin. Falls back to -u flag if branch doesn't exist
# on remote (creates upstream tracking). Non-fatal - logs warning on failure.
#
# Uses globals:
#   WORKING_DIR - Directory to run git commands in
#   CURRENT_BRANCH - Branch name to push
#
# Returns:
#   0 - Always (non-fatal, continues even on failure)
#
# Behavior:
#   1. Checks if we're in a git repository
#   2. Attempts normal push to origin
#   3. On failure, retries with -u flag to set upstream tracking
#   4. On second failure, prints warning but doesn't exit
#
# Example usage:
#   git add -A && git commit -m "task complete"
#   git_push
# =============================================================================
git_push() {
    # Skip if not in a git repository
    if ! (cd "$WORKING_DIR" && git rev-parse --git-dir > /dev/null 2>&1); then
        return 0
    fi

    # Skip if no branch name available
    if [[ -z "${CURRENT_BRANCH:-}" ]]; then
        return 0
    fi

    # Attempt to push, fallback to -u if branch doesn't exist on remote
    (cd "$WORKING_DIR" && git push origin "$CURRENT_BRANCH" 2>/dev/null) || {
        echo "Note: Failed to push. Creating remote branch..."
        (cd "$WORKING_DIR" && git push -u origin "$CURRENT_BRANCH" 2>/dev/null) || \
            echo "Warning: Could not push to remote"
    }

    return 0
}

# =============================================================================
# 1.16 Default no-op implementations for optional hooks
# =============================================================================
# These provide default behavior for hooks that variants may choose not to define.
# Variants override these by defining their own functions before sourcing this file
# or after sourcing but before calling run_loop().
#
# Required hook (must be defined by variant):
#   get_templates() - Returns list of template files (one per line)
#
# Optional hooks (default implementations provided here):
#   validate_variant() - Return 0 (success) by default
#   get_archive_files() - Return empty (use ARCHIVE_FILES from config)
#   build_message() - Use build_base_message() by default
#   post_iteration() - No-op by default
# =============================================================================

# Default validate_variant: always succeeds
# Variants override this to check for tracking files, required directories, etc.
validate_variant() {
    return 0
}

# Default get_archive_files: returns nothing (relies on ARCHIVE_FILES config)
# Variants override to dynamically determine which files to archive
get_archive_files() {
    :  # No-op
}

# Default build_message: delegates to build_base_message
# Variants override to add custom message content (e.g., REVIEW_TARGET)
build_message() {
    build_base_message
}

# Default post_iteration: no-op
# Variants override for post-processing (e.g., review artifact commits)
post_iteration() {
    :  # No-op
}

# =============================================================================
# 1.15 run_loop() - Main entry point for variant loop scripts
# =============================================================================
# Orchestrates the complete loop lifecycle: initialization, parsing, validation,
# and the main iteration loop. Calls variant hooks at appropriate points.
#
# Arguments:
#   $1 - SCRIPT_DIR from the calling variant loop.sh
#   $2 - VARIANT_DIR from the calling variant loop.sh
#   $@ - Remaining arguments are passed to parse_common_args
#
# Expected variant setup (before calling run_loop):
#   1. Source lib/loop_core.sh
#   2. Source config.sh (sets VARIANT_NAME, TRACKING_FILE, etc.)
#   3. Define required hook: get_templates()
#   4. Optionally define: validate_variant(), build_message(), post_iteration()
#
# Lifecycle:
#   1. init_ralphus() - Set up directories and defaults
#   2. parse_common_args() - Parse command-line arguments
#   3. validate_common() - Check prompt and template files exist
#   4. validate_variant() - [Hook] Check variant-specific requirements
#   5. setup_shutdown_handler() - Trap INT/TERM signals
#   6. archive_on_branch_change() - Archive if branch changed
#   7. show_header() - Display startup banner
#   8. Loop:
#      a. check_shutdown() - Exit if shutdown requested
#      b. check_max_iterations() - Exit if limit reached
#      c. Increment ITERATION counter
#      d. build_message() - [Hook] Construct message (or build_base_message)
#      e. get_templates() - [Hook] Get template file list
#      f. run_opencode() - Execute the agent
#      g. check_signals() - Parse output for completion signals
#      h. Handle exit codes (PLAN_COMPLETE, COMPLETE, BLOCKED, APPROVED)
#      i. post_iteration() - [Hook] Run post-processing
#      j. git_push() - Push changes to remote
#
# Example variant usage (variants/ralphus-code/scripts/loop.sh):
#   #!/bin/bash
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   VARIANT_DIR="$(dirname "$SCRIPT_DIR")"
#   source "$VARIANT_DIR/../../lib/loop_core.sh"
#   source "$VARIANT_DIR/config.sh"
#   get_templates() { echo "$TEMPLATES_DIR/IMPLEMENTATION_PLAN_REFERENCE.md"; }
#   run_loop "$SCRIPT_DIR" "$VARIANT_DIR" "$@"
# =============================================================================
run_loop() {
    local caller_script_dir="$1"
    local caller_variant_dir="$2"
    shift 2  # Remove first two args, leave the rest for parse_common_args

    # 1. Initialize the environment
    init_ralphus "$caller_script_dir" "$caller_variant_dir"

    # 2. Parse command-line arguments
    parse_common_args "$@"

    # 3. Validate common requirements
    if ! validate_common; then
        exit 1
    fi

    # 4. Validate variant-specific requirements (hook)
    if ! validate_variant; then
        exit 1
    fi

    # 5. Set up graceful shutdown handler
    setup_shutdown_handler

    # 6. Archive previous run if branch changed
    archive_on_branch_change

    # 7. Display startup header
    show_header

    # 8. Main loop
    while true; do
        # 8a. Check for shutdown request
        check_shutdown

        # 8b. Check iteration limit
        if ! check_max_iterations; then
            echo "Reached max iterations: $MAX_ITERATIONS"
            break
        fi

        # 8c. Increment iteration counter
        ITERATION=$((ITERATION + 1))
        echo -e "\n======================== ITERATION $ITERATION ========================\n"

        # 8d. Build the message (hook or default)
        build_message

        # 8e. Get template files from variant hook (required)
        local templates=()
        while IFS= read -r template; do
            [[ -n "$template" ]] && templates+=("$template")
        done < <(get_templates)

        # 8f. Run opencode with prompt and templates
        run_opencode "${templates[@]}"

        # 8g. Check for completion signals
        check_signals
        local signal_code=$?

        # 8h. Handle exit codes based on signals
        case $signal_code in
            10)
                echo "=== PLANNING COMPLETE ==="
                exit 0
                ;;
            20)
                echo "=== ALL TASKS COMPLETE ==="
                exit 0
                ;;
            30)
                echo "=== BLOCKED ==="
                echo "$BLOCKED_REASON"
                exit 1
                ;;
            40)
                echo "=== APPROVED ==="
                exit 0
                ;;
            0)
                # PHASE_COMPLETE or no signal - continue loop
                ;;
        esac

        # 8i. Run post-iteration hook
        post_iteration

        # 8j. Push changes to remote
        git_push
    done

    echo "=== Loop finished after $ITERATION iterations ==="
}
