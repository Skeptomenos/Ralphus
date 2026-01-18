# Modular Loop Architecture

> **Status**: Approved by Architect
> **Type**: Refactor
> **Estimated Reduction**: 1,154 lines -> ~450 lines (61% reduction)

## Context

The Ralphus loop scripts across 7 variants contain **~610 lines of duplicated code** (53% of total). Each variant re-implements:
- Directory setup and configuration
- Argument parsing
- Branch archiving
- Shutdown handlers
- Main loop structure
- Completion signal parsing
- Git push logic

This makes maintenance painful: bug fixes must be applied 7 times, and adding features like custom prompt injection requires touching every variant.

**Source**: `ideas/modular-loop.md`

## Technical Design

### Architecture Overview

```
ralphus/
├── lib/
│   └── loop_core.sh          # NEW: Shared library (~200 lines)
└── variants/
    └── ralphus-*/
        ├── scripts/
        │   └── loop.sh        # REFACTORED: Thin wrapper (~30-60 lines each)
        └── config.sh          # NEW: Variant configuration
```

### Shared Library: `lib/loop_core.sh`

Extracted common functions with hook points for variant-specific behavior.

**Core Functions:**
| Function | Purpose |
|----------|---------|
| `init_ralphus()` | Setup directories, config, parse common args |
| `validate_common()` | Check prompt file and templates exist |
| `archive_on_branch_change()` | Archive previous run when branch switches |
| `setup_shutdown_handler()` | Trap INT/TERM for graceful exit |
| `run_loop()` | Main loop with iteration tracking |
| `run_opencode()` | Execute opencode with standard options |
| `check_signals()` | Parse output for completion promises |
| `git_push()` | Push with retry and branch creation |

**Hook Functions (implemented by variants):**
| Hook | Purpose | Required |
|------|---------|----------|
| `validate_variant()` | Check variant-specific inputs | Optional |
| `get_templates()` | Return template file array | Required |
| `get_archive_files()` | Return files to archive | Optional |
| `build_message()` | Construct iteration message | Optional |
| `post_iteration()` | Run after each iteration | Optional |

### Variant Configuration: `config.sh`

Each variant defines its identity:

```bash
# variants/ralphus-code/config.sh
VARIANT_NAME="code"
TRACKING_FILE="IMPLEMENTATION_PLAN.md"
LAST_BRANCH_FILE=".last-branch"
DEFAULT_PROMPT="PROMPT_build.md"
PLAN_PROMPT="PROMPT_plan.md"
REQUIRED_DIRS=("specs")
ARCHIVE_FILES=("IMPLEMENTATION_PLAN.md" "AGENTS.md")
```

### Refactored Variant Loop: `loop.sh`

Thin wrapper that sources shared library:

```bash
#!/bin/bash
# Ralphus Code - Autonomous Feature Implementation Loop

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANT_DIR="$(dirname "$SCRIPT_DIR")"
RALPHUS_HOME="$(dirname "$(dirname "$VARIANT_DIR")")"

# Load configuration and shared library
source "$VARIANT_DIR/config.sh"
source "$RALPHUS_HOME/lib/loop_core.sh"

# Variant-specific hooks
get_templates() {
    echo "$TEMPLATES_DIR/IMPLEMENTATION_PLAN_REFERENCE.md"
}

validate_variant() {
    if [ "$MODE" = "build" ] && [ ! -f "$WORKING_DIR/$TRACKING_FILE" ]; then
        echo "Error: $TRACKING_FILE not found. Run: $0 plan"
        return 1
    fi
}

# Run the shared loop
run_loop "$@"
```

## Requirements

1. **Zero Breaking Changes**: All existing `ralphus <variant>` commands work identically.
2. **Custom Prompt Injection**: Propagate `ralphus-code`'s feature to all variants.
3. **Standardized Arg Parsing**: All variants use same `for` loop pattern (not `while/case`).
4. **Missing Features Added**: `ralphus-architect` gets shutdown handler.
5. **Testable**: `bash -n` and `shellcheck` pass on all scripts.

## Implementation Plan (Atomic Tasks)

### Phase 1: Create Shared Library

- [ ] Create `lib/` directory in ralphus root
- [ ] Create `lib/loop_core.sh` with header and `set -euo pipefail`
- [ ] Implement `init_ralphus()`:
  - Parse SCRIPT_DIR, VARIANT_DIR from caller
  - Set WORKING_DIR from RALPHUS_WORKING_DIR or pwd
  - Set AGENT from RALPH_AGENT (default: Sisyphus)
  - Set OPENCODE from OPENCODE_BIN (default: opencode)
  - Initialize ULTRAWORK=0, MODE="build", MAX_ITERATIONS=0, CUSTOM_PROMPT=""
- [ ] Implement `parse_common_args()`:
  - Handle: plan, ulw/ultrawork, numeric (max iterations), help, custom strings/files
  - Store results in global variables
- [ ] Implement `show_header()`:
  - Print: `=== RALPHUS $VARIANT_NAME: $MODE mode | $AGENT | $CURRENT_BRANCH ===`
  - Print ultrawork and max_iterations if set
- [ ] Implement `validate_common()`:
  - Check PROMPT_FILE exists
  - Check TEMPLATES_DIR exists
- [ ] Implement `archive_on_branch_change()`:
  - Read LAST_BRANCH_FILE, compare to CURRENT_BRANCH
  - If different, create archive dir and copy ARCHIVE_FILES
  - Write CURRENT_BRANCH to LAST_BRANCH_FILE
- [ ] Implement `setup_shutdown_handler()`:
  - Set SHUTDOWN=0
  - Trap INT TERM to set SHUTDOWN=1 with message
- [ ] Implement `check_shutdown()`:
  - If SHUTDOWN=1, echo and exit 0
- [ ] Implement `check_max_iterations()`:
  - If MAX_ITERATIONS > 0 and ITERATION >= MAX_ITERATIONS, return 1
- [ ] Implement `build_base_message()`:
  - Construct message with optional ulw suffix
  - Append CUSTOM_PROMPT if set
- [ ] Implement `run_opencode()`:
  - Accept template files as arguments
  - Execute $OPENCODE run with --agent, -f flags, capture output
- [ ] Implement `check_signals()`:
  - Check for PLAN_COMPLETE, PHASE_COMPLETE, COMPLETE, BLOCKED, APPROVED
  - Return appropriate exit codes
- [ ] Implement `git_push()`:
  - Push to origin with retry and -u fallback
- [ ] Implement `run_loop()`:
  - Main entry point calling init, parse, validate, loop
  - Call variant hooks: validate_variant, get_templates, build_message, post_iteration

### Phase 2: Create Variant Configs

- [ ] Create `variants/ralphus-code/config.sh`:
  ```bash
  VARIANT_NAME="code"
  TRACKING_FILE="IMPLEMENTATION_PLAN.md"
  LAST_BRANCH_FILE=".last-branch"
  DEFAULT_PROMPT="PROMPT_build.md"
  PLAN_PROMPT="PROMPT_plan.md"
  REQUIRED_DIRS=("specs")
  ARCHIVE_FILES=("IMPLEMENTATION_PLAN.md" "AGENTS.md")
  ```
- [ ] Create `variants/ralphus-review/config.sh`:
  ```bash
  VARIANT_NAME="review"
  TRACKING_FILE="REVIEW_PLAN.md"
  LAST_BRANCH_FILE=".last-review-branch"
  DEFAULT_PROMPT="PROMPT_review_build.md"
  PLAN_PROMPT="PROMPT_review_plan.md"
  REQUIRED_DIRS=()  # Optional: review-targets/
  ARCHIVE_FILES=("REVIEW_PLAN.md" "reviews")
  EXTRA_SIGNALS=("APPROVED")
  ```
- [ ] Create `variants/ralphus-architect/config.sh`:
  ```bash
  VARIANT_NAME="architect"
  TRACKING_FILE=""  # None
  LAST_BRANCH_FILE=".last-architect-branch"
  DEFAULT_PROMPT="PROMPT_architect.md"
  PLAN_PROMPT=""  # Uses modes: feature, triage
  REQUIRED_DIRS=()  # ideas/ or reviews/ depending on mode
  ARCHIVE_FILES=()
  LOOP_TYPE="file-iterator"  # Not open-ended loop
  ```
- [ ] Create `variants/ralphus-product/config.sh`:
  ```bash
  VARIANT_NAME="product"
  TRACKING_FILE=""
  LAST_BRANCH_FILE=""
  DEFAULT_PROMPT="PROMPT_product.md"
  PLAN_PROMPT="PROMPT_product_init.md"
  REQUIRED_DIRS=("inbox")
  ARCHIVE_FILES=()
  LOOP_TYPE="sequential"  # Not a loop
  ```
- [ ] Create `variants/ralphus-test/config.sh`
- [ ] Create `variants/ralphus-research/config.sh`
- [ ] Create `variants/ralphus-discover/config.sh`

### Phase 3: Refactor Variant Loop Scripts

- [ ] Refactor `variants/ralphus-code/scripts/loop.sh`:
  - Source config.sh and lib/loop_core.sh
  - Implement `get_templates()` returning IMPLEMENTATION_PLAN_REFERENCE.md
  - Implement `validate_variant()` checking specs/ and IMPLEMENTATION_PLAN.md
  - Call `run_loop "$@"`
- [ ] Refactor `variants/ralphus-review/scripts/loop.sh`:
  - Source config.sh and lib/loop_core.sh
  - Implement `parse_variant_args()` for pr/diff/files targets
  - Implement `validate_variant()` for PR mode branch check
  - Implement `get_templates()` returning 3 template files
  - Implement `build_message()` adding REVIEW_TARGET and MAIN_BRANCH
  - Implement `post_iteration()` for review artifact commits
  - Call `run_loop "$@"`
- [ ] Refactor `variants/ralphus-architect/scripts/loop.sh`:
  - Source config.sh and lib/loop_core.sh
  - **Add missing shutdown handler** via `setup_shutdown_handler()`
  - Implement `parse_variant_args()` for feature/triage modes
  - Implement file-iterator loop pattern
  - Call `run_loop "$@"`
- [ ] Refactor `variants/ralphus-product/scripts/loop.sh`:
  - Source config.sh and lib/loop_core.sh
  - Implement sequential (non-loop) pattern
  - Keep init/process modes
  - Call `run_sequential "$@"`
- [ ] Refactor `variants/ralphus-test/scripts/loop.sh`
- [ ] Refactor `variants/ralphus-research/scripts/loop.sh`
- [ ] Refactor `variants/ralphus-discover/scripts/loop.sh`

### Phase 4: Propagate Custom Prompt Injection

- [ ] Ensure `parse_common_args()` handles custom strings/files:
  ```bash
  elif [ -f "$arg" ]; then
      CUSTOM_PROMPT="$CUSTOM_PROMPT $(cat "$arg")"
  else
      CUSTOM_PROMPT="$CUSTOM_PROMPT $arg"
  fi
  ```
- [ ] Ensure `build_base_message()` appends CUSTOM_PROMPT:
  ```bash
  if [ -n "$CUSTOM_PROMPT" ]; then
      MESSAGE="$MESSAGE. Additional Instructions: $CUSTOM_PROMPT"
  fi
  ```
- [ ] Test custom prompt with each variant:
  - `ralphus code "focus on tests"`
  - `ralphus review "check security only"`
  - `ralphus architect feature "prioritize API design"`

### Phase 5: Validation

- [ ] Run `bash -n lib/loop_core.sh` - verify syntax
- [ ] Run `bash -n variants/*/scripts/loop.sh` - verify all scripts
- [ ] Run `shellcheck lib/loop_core.sh` - fix warnings
- [ ] Run `shellcheck variants/*/scripts/loop.sh` - fix warnings
- [ ] Test `ralphus code plan` - verify plan mode works
- [ ] Test `ralphus code` - verify build mode works
- [ ] Test `ralphus code ulw 5` - verify ultrawork and max iterations
- [ ] Test `ralphus code "custom instructions"` - verify prompt injection
- [ ] Test `ralphus review plan pr` - verify PR mode
- [ ] Test `ralphus architect feature` - verify feature mode
- [ ] Test `ralphus architect triage` - verify triage mode
- [ ] Test `ralphus product init` - verify init mode
- [ ] Test Ctrl+C during loop - verify graceful shutdown

### Phase 6: Documentation

- [ ] Update `AGENTS.md` Operational Notes with new architecture
- [ ] Add inline comments in `lib/loop_core.sh` explaining hook system
- [ ] Update usage comments in each variant's loop.sh

## Verification Steps

1. **Syntax Validation**:
   ```bash
   bash -n lib/loop_core.sh
   for f in variants/*/scripts/loop.sh; do bash -n "$f"; done
   ```

2. **Linting**:
   ```bash
   shellcheck lib/loop_core.sh
   shellcheck variants/*/scripts/loop.sh
   ```

3. **Functional Tests**:
   ```bash
   # Each command should behave identically to before
   ralphus code plan
   ralphus review plan pr
   ralphus architect feature
   ```

4. **Line Count Verification**:
   ```bash
   # Before: 1,154 lines total
   # After: ~450 lines total (lib: ~200, 7 variants: ~35 each = ~245)
   wc -l lib/loop_core.sh variants/*/scripts/loop.sh
   ```

## Risk Assessment

- **Breaking Changes**: Low - public interface unchanged
- **Performance**: None - shell sourcing is negligible
- **Complexity**: Medium - hook system requires understanding

## Appendix: Existing Code Snippets

### Current Duplication Pattern (example from ralphus-code:94-101)

```bash
SHUTDOWN=0
trap 'SHUTDOWN=1; echo -e "\n⚠ Shutdown requested. Finishing current iteration..."' INT TERM

while true; do
    if [ "$SHUTDOWN" -eq 1 ]; then
        echo "Shutting down gracefully."
        exit 0
    fi
```

### Proposed Shared Implementation

```bash
# lib/loop_core.sh
setup_shutdown_handler() {
    SHUTDOWN=0
    trap 'SHUTDOWN=1; echo -e "\n⚠ Shutdown requested. Finishing current iteration..."' INT TERM
}

check_shutdown() {
    if [ "$SHUTDOWN" -eq 1 ]; then
        echo "Shutting down gracefully."
        exit 0
    fi
}
```
