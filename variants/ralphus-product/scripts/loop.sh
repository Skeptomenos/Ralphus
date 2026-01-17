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
ULTRAWORK=0

# Arguments
if [ "${1:-}" = "ultrawork" ] || [ "${1:-}" = "ulw" ]; then
    ULTRAWORK=1
fi

# Ensure directories exist
mkdir -p "$INBOX_DIR" "$ARCHIVE_DIR" "$IDEAS_DIR"

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
        MESSAGE="Act as Product Manager. Analyze this file, slice into atomic ideas in '$IDEAS_DIR/', and archive the input. ulw"
    else
        MESSAGE="Act as Product Manager. Analyze this file, slice into atomic ideas in '$IDEAS_DIR/', and archive the input."
    fi

    # We pass the content of the file implicitly by attaching it? 
    # Or explicitly instructing the agent to read it.
    # PROMPT_product.md instructs to "Read the file at {INPUT_FILE}".
    
    # Export for prompt interpolation (if needed) or just rely on instruction
    export INPUT_FILE="$file"
    export ARCHIVE_DIR="$ARCHIVE_DIR"

    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        -f "$INSTRUCTIONS_DIR/PROMPT_product.md" \
        -f "$TEMPLATES_DIR/IDEA_TEMPLATE_REFERENCE.md" \
        -- "$MESSAGE Input file: $file" 2>&1 | tee /dev/stderr) || true

    # Move processed file to archive (if agent didn't do it)
    if [ -f "$file" ]; then
        mv "$file" "$ARCHIVE_DIR/"
        echo "Archived $(basename "$file")"
    fi
done

echo "=== PRODUCT CYCLE COMPLETE ==="
