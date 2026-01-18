# Modular Loop Architecture & Custom Prompts

> **Status**: Idea (Handover)
> **Goal**: Enable custom prompt injection across all variants and reduce code duplication.

## Context
Currently, every Ralphus variant (`code`, `test`, `review`, `architect`, `product`) has its own `loop.sh`.
We want to add the ability to inject custom prompts (e.g., `ralphus code "focus on performance"`).
Adding this logic to 7+ scripts individually is a maintenance nightmare.

## Requirements

### 1. Custom Prompt Injection
- **Feature**: Users can pass extra arguments to any variant.
- **Behavior**:
    - Strings (`"foo"`) -> Appended to prompt.
    - Files (`instructions.md`) -> Content read and appended.
- **Status**: Implemented in `ralphus-code` (Pilot), needs revert or propagation.

### 2. Shared Library (`lib/loop_core.sh`)
Refactor the common logic out of individual `loop.sh` files.

**Shared Logic:**
- Argument parsing (plan, ulw, help, numbers, custom strings)
- Directory validation
- Environment setup (`OPENCODE`, `AGENT`)
- The main execution loop (iteration tracking, signal parsing)

**Variant Logic (To keep in `loop.sh`):**
- Default `PROMPT_FILE`
- Variant-specific templates
- Specific pre-checks (e.g., "Reviewer needs a diff")

## Proposed Architecture

```bash
# variants/ralphus-code/scripts/loop.sh

source "$RALPHUS_HOME/lib/loop_core.sh"

# Configure Variant
VARIANT_NAME="code"
DEFAULT_PROMPT="$INSTRUCTIONS_DIR/PROMPT_build.md"
PLAN_PROMPT="$INSTRUCTIONS_DIR/PROMPT_plan.md"

# Define validation hook
validate_variant() {
    if [ ! -f "IMPLEMENTATION_PLAN.md" ]; then ... fi
}

# Run Shared Loop
run_ralphus_loop "$@"
```

## Next Steps
1.  Review `ralphus-code/scripts/loop.sh` (currently patched with custom prompt logic).
2.  Design `lib/loop_core.sh`.
3.  Refactor all variants to use the shared library.
