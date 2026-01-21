#!/bin/bash
# =============================================================================
# Ralphus Research - Autonomous Learning Loop
# =============================================================================
# Researches topics from questions/ directory, producing summaries, quizzes,
# and knowledge connections. Uses the shared library loop pattern.
#
# Usage: ralphus research [plan] [ulw] [N] ["custom prompt"]
#
# Modes:
#   plan        Create RESEARCH_PLAN.md from questions/*.md
#   (default)   Execute RESEARCH_PLAN.md, answering questions iteratively
#
# Options:
#   ulw         Enable ultrawork mode for deep research
#   N           Max iterations (e.g., 10 to limit research cycles)
#   "<string>"  Append custom instructions to the prompt
#
# Examples:
#   ralphus research plan              # Analyze questions, create plan
#   ralphus research                   # Execute plan, research iteratively
#   ralphus research ulw               # Deep research with ultrawork
#   ralphus research "include papers"  # Custom: include academic papers
#
# Completion Signals:
#   PHASE_COMPLETE  - Research item complete, continue to next
#   COMPLETE        - All research complete
#   BLOCKED         - Cannot proceed, needs intervention
#
# Thin wrapper that sources the shared library and provides variant-specific hooks.
# =============================================================================

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
# Validates that required directories and files exist for the research variant.
# - questions/ directory must exist (contains research questions)
# - RESEARCH_PLAN.md must exist in build mode (created by plan mode)
# =============================================================================
validate_variant() {
    local questions_dir="$WORKING_DIR/ralph-wiggum/research/inbox"
    
    # Require inbox directory
    if [[ ! -d "$questions_dir" ]]; then
        echo "ERROR: $questions_dir/ directory not found." >&2
        echo "Run 'mkdir -p ralph-wiggum/research/inbox' and add questions/*.md files." >&2
        return 1
    fi
    
    # In build mode, require plan.md
    if [[ "$MODE" != "plan" ]] && [[ ! -f "$WORKING_DIR/$TRACKING_FILE" ]]; then
        echo "ERROR: $TRACKING_FILE not found in $WORKING_DIR" >&2
        echo "Run planning mode first: ralphus research plan" >&2
        return 1
    fi
    
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Provides the reference templates that guide the agent on how to format
# research plans, summaries, quizzes, and connections.
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/RESEARCH_PLAN_REFERENCE.md"
    echo "$TEMPLATES_DIR/SUMMARY_REFERENCE.md"
    echo "$TEMPLATES_DIR/QUIZ_REFERENCE.md"
    echo "$TEMPLATES_DIR/CONNECTIONS_REFERENCE.md"
}

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
