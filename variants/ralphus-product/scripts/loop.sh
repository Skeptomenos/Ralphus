#!/bin/bash
# =============================================================================
# Ralphus Product - Brain Dump Slicer
# =============================================================================
# Processes inbox/*.md files into atomic ideas in ideas/.
# Uses sequential (non-looping) pattern - processes files once and exits.
#
# Usage: ralphus product [init] [ulw] [N] ["custom prompt"]
#
# Modes:
#   (default)   Process inbox/*.md -> ideas/
#   init        Establish PROJECT_CONTEXT.md from existing docs
# =============================================================================

set -euo pipefail

# Determine directories (temp vars since loop_core.sh sets globals)
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_VARIANT_DIR="$(dirname "$_SCRIPT_DIR")"

# Source config and shared library
source "$_VARIANT_DIR/config.sh"
source "$_VARIANT_DIR/../../lib/loop_core.sh"

# =============================================================================
# Variant-specific overrides
# =============================================================================

# Override show_usage for product-specific help
show_usage() {
    echo "Usage: ralphus product [init] [ulw]"
    echo ""
    echo "Modes:"
    echo "  (default)   Process inbox/*.md -> ideas/"
    echo "  init        Establish PROJECT_CONTEXT.md from docs"
    echo ""
    echo "Options:"
    echo "  ulw         Enable ultrawork mode"
}

# Handle 'init' mode argument
parse_variant_args() {
    if [[ "$1" = "init" ]]; then
        MODE="init"
        return 0  # Handled - don't pass to parse_common_args
    fi
    return 1  # Not handled - let parse_common_args process it
}

# Ensure required directories exist
validate_variant() {
    mkdir -p "$WORKING_DIR/inbox" "$WORKING_DIR/inbox/archive" "$WORKING_DIR/ideas"
    return 0
}

# Get template files based on mode
# Note: PROJECT_CONTEXT.md is not attached - agent reads it directly from working dir
get_templates() {
    if [[ "$MODE" = "init" ]]; then
        echo "$TEMPLATES_DIR/CONTEXT_TEMPLATE_REFERENCE.md"
    else
        echo "$TEMPLATES_DIR/IDEA_TEMPLATE_REFERENCE.md"
    fi
}

# Build custom message based on mode
build_message() {
    if [[ "$MODE" = "init" ]]; then
        MESSAGE="Act as Head of Product. Read documentation and existing specs to establish PROJECT_CONTEXT.md. Do NOT process inbox yet."
    else
        MESSAGE="Act as Product Manager. Read 'PROJECT_CONTEXT.md'. Analyze this file, slice into atomic ideas in 'ideas/', update the Context roadmap, and archive the input. Input file: $CURRENT_FILE"
    fi
    
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
# run_sequential() - Main entry point for sequential file-iterator pattern
# =============================================================================
# Unlike run_loop(), this processes files once and exits.
# No infinite loop, no shutdown handler needed.
# =============================================================================
run_sequential() {
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

    # 4. Validate variant-specific requirements
    if ! validate_variant; then
        exit 1
    fi

    # 5. Display startup header (adjust for init mode)
    show_header

    # 6. Handle init mode separately
    if [[ "$MODE" = "init" ]]; then
        echo "Initializing project context..."
        
        # Set message for init mode
        CURRENT_FILE=""
        build_message
        
        # Get templates for init mode
        local templates=()
        while IFS= read -r template; do
            [[ -n "$template" ]] && templates+=("$template")
        done < <(get_templates)
        
        # Run opencode
        run_opencode "${templates[@]}"
        
        echo ""
        echo "Context initialized. Run 'ralphus product' to process inbox."
        exit 0
    fi

    # 7. Process mode: iterate over inbox files
    local inbox_dir="$WORKING_DIR/inbox"
    local archive_dir="$WORKING_DIR/inbox/archive"
    
    # Find all markdown files in inbox (not in subdirectories)
    local files
    files=$(find "$inbox_dir" -maxdepth 1 -name "*.md" 2>/dev/null || true)
    
    if [[ -z "$files" ]]; then
        echo "No files found in inbox/"
        exit 0
    fi

    # Export archive directory for prompt interpolation
    export ARCHIVE_DIR="$archive_dir"
    
    # Process each file
    local file_count=0
    for file in $files; do
        file_count=$((file_count + 1))
        echo -e "\n====================== FILE $file_count: $(basename "$file") ======================"
        
        # Set current file for build_message
        CURRENT_FILE="$file"
        export INPUT_FILE="$file"  # For prompt interpolation
        
        # Build the message
        build_message
        
        # Get templates for process mode
        local templates=()
        while IFS= read -r template; do
            [[ -n "$template" ]] && templates+=("$template")
        done < <(get_templates)
        
        # Run opencode
        run_opencode "${templates[@]}"
        
        # Archive the file if agent didn't move it
        if [[ -f "$file" ]]; then
            mv "$file" "$archive_dir/"
            echo "Archived: $(basename "$file")"
        fi
    done

    echo ""
    echo "=== PRODUCT CYCLE COMPLETE: Processed $file_count file(s) ==="
}

# =============================================================================
# Main entry point
# =============================================================================
run_sequential "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
