#!/bin/bash
# Ralphus Architect - Specification Generator
# Usage: ./ralphus/ralphus-architect/scripts/loop.sh [feature|triage] [file_path] [ultrawork|ulw]
#
# Modes:
#   feature <file>   - Convert raw idea file to rigorous spec
#   triage           - Convert reviews/ findings to fix spec
#
# Examples:
#   ralphus architect feature ideas/dark-mode.md
#   ralphus architect triage

set -euo pipefail

# Central location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPHUS_ARCHITECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$RALPHUS_ARCHITECT_DIR/instructions"
TEMPLATES_DIR="$RALPHUS_ARCHITECT_DIR/templates"

# Working directory
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Configuration
AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"
SPECS_DIR="$WORKING_DIR/specs"
IDEAS_DIR="$WORKING_DIR/ideas"
REVIEWS_DIR="$WORKING_DIR/reviews"
ULTRAWORK=0

# Arguments
MODE=""
INPUT_FILE=""

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        feature)
            MODE="feature"
            shift
            if [[ -n "${1:-}" ]] && [[ ! "$1" =~ ^ulw$ ]]; then
                INPUT_FILE="$1"
                shift
            fi
            ;;
        triage)
            MODE="triage"
            shift
            ;;
        ultrawork|ulw)
            ULTRAWORK=1
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Default to interactive help if no mode
if [ -z "$MODE" ]; then
    echo "Usage: ralphus architect [feature <file> | triage]"
    exit 1
fi

# Validation
if [ "$MODE" = "feature" ]; then
    # If explicit file provided, check it
    if [ -n "$INPUT_FILE" ]; then
        if [ ! -f "$INPUT_FILE" ] && [ ! -f "$WORKING_DIR/$INPUT_FILE" ]; then
            echo "Error: Input file '$INPUT_FILE' not found."
            exit 1
        fi
    else
        # No file provided, check if ideas/ directory exists
        if [ ! -d "$IDEAS_DIR" ]; then
            echo "Error: No input file provided and $IDEAS_DIR not found."
            exit 1
        fi
    fi
fi

if [ "$MODE" = "triage" ]; then
    if [ ! -d "$REVIEWS_DIR" ]; then
        echo "Error: $REVIEWS_DIR not found. Run 'ralphus review' first."
        exit 1
    fi
    mkdir -p "$REVIEWS_DIR/processed"
    
    # Check if there are any unprocessed reviews
    # find reviews/ -maxdepth 1 -name "*.md"
    FINDING_COUNT=$(find "$REVIEWS_DIR" -maxdepth 1 -name "*_review.md" | wc -l)
    if [ "$FINDING_COUNT" -eq 0 ]; then
        echo "No unprocessed review files found in $REVIEWS_DIR."
        echo "Check $REVIEWS_DIR/processed/ for completed items."
        exit 0
    fi
fi

# Prepare directories
mkdir -p "$SPECS_DIR"

ITERATION=0
MAX_ITERATIONS=10 # Allow batch processing up to 10 ideas by default

echo "=== RALPHUS ARCHITECT: $MODE | $AGENT ==="

# Execution Loop
while true; do
    ITERATION=$((ITERATION + 1))
    if [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
        break
    fi

    echo -e "\n--- Processing Iteration $ITERATION ---\n"

    # Context Message Selection
    CURRENT_INPUT=""
    
    if [ "$MODE" = "feature" ]; then
        if [ -n "$INPUT_FILE" ]; then
            # Single file mode
            CURRENT_INPUT="$INPUT_FILE"
            if [ "$ITERATION" -gt 1 ]; then break; fi # Only one pass for specific file
        else
            # Directory scan mode
            # Find first markdown file in ideas/ that does NOT have a corresponding spec in specs/
            # Logic: For each idea file, check if specs/$(basename) exists
            FOUND_WORK=0
            for idea in "$IDEAS_DIR"/*.md; do
                if [ ! -f "$idea" ]; then continue; fi
                
                filename=$(basename "$idea")
                spec_path="$SPECS_DIR/$filename"
                
                if [ ! -f "$spec_path" ]; then
                    CURRENT_INPUT="$idea"
                    FOUND_WORK=1
                    break
                fi
            done
            
            if [ "$FOUND_WORK" -eq 0 ]; then
                echo "No unprocessed ideas found in $IDEAS_DIR/"
                echo "All ideas have corresponding specs in $SPECS_DIR/"
                exit 0
            fi
        fi
        
        MESSAGE="Act as Senior Architect. Analyze '$CURRENT_INPUT' and existing codebase. Create a technical specification in '$SPECS_DIR/$(basename "$CURRENT_INPUT")'."
        
    else
        # Triage mode (Processed Folder Pattern)
        # 1. Find first unprocessed review
        CURRENT_INPUT=$(find "$REVIEWS_DIR" -maxdepth 1 -name "*_review.md" | head -n 1)
        
        if [ -z "$CURRENT_INPUT" ]; then
            echo "All reviews processed!"
            exit 0
        fi
        
        echo "Triaging: $(basename "$CURRENT_INPUT")"
        
        MESSAGE="Act as Senior Architect. Analyze '$CURRENT_INPUT'. Extract actionable fixes and APPEND them to 'specs/review-fixes.md'. Use the format in @SPEC_TEMPLATE_REFERENCE.md."
    fi
    
    echo "Task: $MESSAGE"
    
    if [ "$ULTRAWORK" -eq 1 ]; then
        MESSAGE="$MESSAGE ulw"
    fi

    # Export for prompt
    export CURRENT_INPUT="$CURRENT_INPUT"

    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        -f "$INSTRUCTIONS_DIR/PROMPT_architect.md" \
        -f "$TEMPLATES_DIR/SPEC_TEMPLATE_REFERENCE.md" \
        -f "$TEMPLATES_DIR/ARCHITECT_PLAN_REFERENCE.md" \
        -- "$MESSAGE" 2>&1 | tee /dev/stderr) || true

    # Post-processing for Triage: Move to processed
    if [ "$MODE" = "triage" ] && [ -f "$CURRENT_INPUT" ]; then
        mv "$CURRENT_INPUT" "$REVIEWS_DIR/processed/"
        echo "Moved $(basename "$CURRENT_INPUT") to processed/"
        
        # Don't exit loop, continue to next file until max iterations
        if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
            echo "Item complete."
        fi
        continue
    fi

    # Check signals (for Feature mode)
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo "=== ARCHITECT COMPLETE ==="
        exit 0
    fi
done
