#!/bin/bash
# Ralphus Architect - Specification Generator
# Usage: ralphus architect [feature <file> | triage] [ulw] [N] ["custom prompt"]
#
# Modes:
#   feature <file>   - Convert raw idea file to rigorous spec (or all ideas/ if no file)
#   triage           - Convert reviews/ findings to fix spec
#
# Examples:
#   ralphus architect feature ideas/dark-mode.md
#   ralphus architect triage
#
# Thin wrapper that sources the shared library and provides variant-specific hooks.
# Uses file-iterator pattern (processes files until none remain, not open-ended loop).

set -euo pipefail

# Determine script and variant directories
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_VARIANT_DIR="$(dirname "$_SCRIPT_DIR")"

# Source variant configuration and shared library
source "$_VARIANT_DIR/config.sh"
source "$_VARIANT_DIR/../../lib/loop_core.sh"

# =============================================================================
# Variant-specific state (set by parse_variant_args)
# =============================================================================
ARCHITECT_MODE=""         # feature or triage
INPUT_FILE=""             # Specific file for feature mode (optional)
SPECS_DIR=""
IDEAS_DIR=""
REVIEWS_DIR=""
CURRENT_INPUT=""          # File being processed in current iteration

# =============================================================================
# Hook: parse_variant_args() - Handle architect-specific arguments
# =============================================================================
# Handles feature and triage mode selection. Returns 0 if arg was handled.
# =============================================================================
parse_variant_args() {
    local arg="$1"
    case "$arg" in
        feature)
            ARCHITECT_MODE="feature"
            return 0
            ;;
        triage)
            ARCHITECT_MODE="triage"
            return 0
            ;;
        *)
            # Check if this is a file path for feature mode
            if [[ "$ARCHITECT_MODE" = "feature" ]] && [[ -z "$INPUT_FILE" ]] && [[ ! "$arg" =~ ^(ulw|ultrawork|plan|[0-9]+)$ ]]; then
                INPUT_FILE="$arg"
                return 0
            fi
            ;;
    esac
    return 1
}

# =============================================================================
# Hook: show_usage() - Architect-specific help message
# =============================================================================
show_usage() {
    echo "Usage: ralphus architect [feature <file> | triage] [ulw] [N] [\"custom prompt\"]"
    echo ""
    echo "Modes:"
    echo "  feature <file>   Convert raw idea file to rigorous spec"
    echo "  triage           Convert reviews/ findings to fix spec"
    echo ""
    echo "Options:"
    echo "  ulw              Ultrawork mode"
    echo "  N                Max iterations (e.g., 10)"
    echo "  <string>         Append custom prompt string"
}

# =============================================================================
# Hook: validate_variant() - Check architect-specific requirements
# =============================================================================
# Validates based on ARCHITECT_MODE:
# - feature: ideas/ must exist (or INPUT_FILE must exist)
# - triage: reviews/ must exist with unprocessed files
# =============================================================================
validate_variant() {
    SPECS_DIR="$WORKING_DIR/specs"
    IDEAS_DIR="$WORKING_DIR/ideas"
    REVIEWS_DIR="$WORKING_DIR/reviews"
    
    # Default to interactive help if no mode
    if [[ -z "$ARCHITECT_MODE" ]]; then
        show_usage
        exit 1
    fi
    
    # Feature mode validation
    if [[ "$ARCHITECT_MODE" = "feature" ]]; then
        if [[ -n "$INPUT_FILE" ]]; then
            # Specific file provided - check it exists
            if [[ ! -f "$INPUT_FILE" ]] && [[ ! -f "$WORKING_DIR/$INPUT_FILE" ]]; then
                echo "ERROR: Input file '$INPUT_FILE' not found." >&2
                return 1
            fi
        else
            # No file provided - check ideas/ directory exists
            if [[ ! -d "$IDEAS_DIR" ]]; then
                echo "ERROR: No input file provided and $IDEAS_DIR not found." >&2
                return 1
            fi
        fi
    fi
    
    # Triage mode validation
    if [[ "$ARCHITECT_MODE" = "triage" ]]; then
        if [[ ! -d "$REVIEWS_DIR" ]]; then
            echo "ERROR: $REVIEWS_DIR not found. Run 'ralphus review' first." >&2
            return 1
        fi
        mkdir -p "$REVIEWS_DIR/processed"
        
        # Check for unprocessed reviews
        local finding_count
        finding_count=$(find "$REVIEWS_DIR" -maxdepth 1 -name "*_review.md" 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$finding_count" -eq 0 ]]; then
            echo "No unprocessed review files found in $REVIEWS_DIR."
            echo "Check $REVIEWS_DIR/processed/ for completed items."
            exit 0
        fi
    fi
    
    # Prepare specs output directory
    mkdir -p "$SPECS_DIR"
    
    # Export for prompt access
    export ARCHITECT_MODE
    export SPECS_DIR
    export IDEAS_DIR
    export REVIEWS_DIR
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Note: PROJECT_CONTEXT.md is not attached - agent reads it directly from working dir
get_templates() {
    echo "$TEMPLATES_DIR/SPEC_TEMPLATE_REFERENCE.md"
    echo "$TEMPLATES_DIR/ARCHITECT_PLAN_REFERENCE.md"
}

# =============================================================================
# Hook: build_message() - Construct message with architect context
# =============================================================================
# Determines CURRENT_INPUT and builds mode-specific message.
# =============================================================================
build_message() {
    CURRENT_INPUT=""
    
    if [[ "$ARCHITECT_MODE" = "feature" ]]; then
        if [[ -n "$INPUT_FILE" ]]; then
            # Single file mode
            CURRENT_INPUT="$INPUT_FILE"
        else
            # Directory scan mode - find first unprocessed idea
            for idea in "$IDEAS_DIR"/*.md; do
                if [[ ! -f "$idea" ]]; then continue; fi
                
                local filename spec_path
                filename=$(basename "$idea")
                spec_path="$SPECS_DIR/$filename"
                
                if [[ ! -f "$spec_path" ]]; then
                    CURRENT_INPUT="$idea"
                    break
                fi
            done
            
            if [[ -z "$CURRENT_INPUT" ]]; then
                echo "No unprocessed ideas found in $IDEAS_DIR/"
                echo "All ideas have corresponding specs in $SPECS_DIR/"
                exit 0
            fi
        fi
        
        MESSAGE="Act as Senior Architect. Analyze '$CURRENT_INPUT' and existing codebase. Create a technical specification in '$SPECS_DIR/$(basename "$CURRENT_INPUT")'."
        
    else
        # Triage mode - find first unprocessed review
        CURRENT_INPUT=$(find "$REVIEWS_DIR" -maxdepth 1 -name "*_review.md" 2>/dev/null | head -n 1)
        
        if [[ -z "$CURRENT_INPUT" ]]; then
            echo "All reviews processed!"
            exit 0
        fi
        
        echo "Triaging: $(basename "$CURRENT_INPUT")"
        MESSAGE="Act as Senior Architect. Analyze '$CURRENT_INPUT'. Extract actionable fixes and APPEND them to 'specs/review-fixes.md'. Use the format in @SPEC_TEMPLATE_REFERENCE.md."
    fi
    
    # Export for prompt access
    export CURRENT_INPUT
    
    echo "Task: $MESSAGE"
    
    # Append ultrawork suffix if enabled
    if [[ "$ULTRAWORK" -eq 1 ]]; then
        MESSAGE="$MESSAGE ulw"
    fi
    
    # Append custom prompt if provided
    if [[ -n "${CUSTOM_PROMPT:-}" ]]; then
        MESSAGE="$MESSAGE Additional Instructions: $CUSTOM_PROMPT"
    fi
}

# =============================================================================
# Hook: post_iteration() - Post-processing for triage mode
# =============================================================================
# Moves processed review files to processed/ directory.
# For feature mode with specific file, exits after first iteration.
# =============================================================================
post_iteration() {
    # Triage mode: move processed file to processed/
    if [[ "$ARCHITECT_MODE" = "triage" ]] && [[ -f "$CURRENT_INPUT" ]]; then
        mv "$CURRENT_INPUT" "$REVIEWS_DIR/processed/"
        echo "Moved $(basename "$CURRENT_INPUT") to processed/"
    fi
    
    # Feature mode with specific file: exit after first iteration
    if [[ "$ARCHITECT_MODE" = "feature" ]] && [[ -n "$INPUT_FILE" ]]; then
        echo "Single file processing complete."
        exit 0
    fi
}

# =============================================================================
# Override check_signals for architect-specific behavior
# =============================================================================
# In triage mode, COMPLETE signals completion of current item, not all items.
# The loop continues to next file unless no more files remain.
# =============================================================================

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
