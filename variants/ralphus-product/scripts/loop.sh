#!/bin/bash
# Ralphus Product - Idea Processor
# Usage: ./ralphus/ralphus-product/scripts/loop.sh [ultrawork|ulw]

set -euo pipefail

# Central location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPHUS_PRODUCT_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$RALPHUS_PRODUCT_DIR/instructions"
TEMPLATES_DIR="$RALPHUS_PRODUCT_DIR/templates"

# Working directory
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Configuration
AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"
INBOX_DIR="$WORKING_DIR/inbox"
ARCHIVE_DIR="$INBOX_DIR/archive"
IDEAS_DIR="$WORKING_DIR/ideas"
MODE="process"
ULTRAWORK=0

# Arguments
if [ "${1:-}" = "init" ]; then
    MODE="init"
    shift
elif [ "${1:-}" = "help" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Usage: ralphus product [init] [ulw]"
    echo ""
    echo "Modes:"
    echo "  (default)   Process inbox/ -> ideas/"
    echo "  init        Establish PROJECT_CONTEXT.md from docs"
    exit 0
elif [ "${1:-}" = "ultrawork" ] || [ "${1:-}" = "ulw" ]; then
    ULTRAWORK=1
fi

if [ "${1:-}" = "ultrawork" ] || [ "${1:-}" = "ulw" ]; then
    ULTRAWORK=1
fi

# Ensure directories exist
mkdir -p "$INBOX_DIR" "$ARCHIVE_DIR" "$IDEAS_DIR"

if [ "$MODE" = "init" ]; then
    echo "=== RALPHUS PRODUCT: Initialization Mode ==="
    MESSAGE="Act as Head of Product. Read documentation and existing specs to establish PROJECT_CONTEXT.md. Do NOT process inbox yet."
    
    if [ "$ULTRAWORK" -eq 1 ]; then MESSAGE="$MESSAGE ulw"; fi

    "$OPENCODE" run --agent "$AGENT" \
        -f "$INSTRUCTIONS_DIR/PROMPT_product_init.md" \
        -f "$TEMPLATES_DIR/CONTEXT_TEMPLATE_REFERENCE.md" \
        -- "$MESSAGE"
        
    echo "Context initialized. Run 'ralphus product' to process inbox."
    exit 0
fi

# Check for files
FILES=$(find "$INBOX_DIR" -maxdepth 1 -name "*.md")
if [ -z "$FILES" ]; then
    echo "No files found in $INBOX_DIR"
    exit 0
fi

echo "=== RALPHUS PRODUCT: Processing Inbox ==="

# Process each file
for file in $FILES; do
    echo -e "\nProcessing: $(basename "$file")"
    
    if [ "$ULTRAWORK" -eq 1 ]; then
        MESSAGE="Act as Product Manager. Read 'PROJECT_CONTEXT.md'. Analyze this file, slice into atomic ideas in '$IDEAS_DIR/', update the Context roadmap, and archive the input. ulw"
    else
        MESSAGE="Act as Product Manager. Read 'PROJECT_CONTEXT.md'. Analyze this file, slice into atomic ideas in '$IDEAS_DIR/', update the Context roadmap, and archive the input."
    fi

    # We pass the content of the file implicitly by attaching it? 
    # Or explicitly instructing the agent to read it.
    # PROMPT_product.md instructs to "Read the file at {INPUT_FILE}".
    
    # Export for prompt interpolation (if needed) or just rely on instruction
    export INPUT_FILE="$file"
    export ARCHIVE_DIR="$ARCHIVE_DIR"

    # Prepare arguments
    OPTS=(
        -f "$INSTRUCTIONS_DIR/PROMPT_product.md"
        -f "$TEMPLATES_DIR/IDEA_TEMPLATE_REFERENCE.md"
    )
    
    # Attach Context if it exists
    if [ -f "$WORKING_DIR/PROJECT_CONTEXT.md" ]; then
        OPTS+=(-f "$WORKING_DIR/PROJECT_CONTEXT.md")
    fi

    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        "${OPTS[@]}" \
        -- "$MESSAGE Input file: $file" 2>&1 | tee /dev/stderr) || true

    # Move processed file to archive (if agent didn't do it)
    if [ -f "$file" ]; then
        mv "$file" "$ARCHIVE_DIR/"
        echo "Archived $(basename "$file")"
    fi
done

echo "=== PRODUCT CYCLE COMPLETE ==="
