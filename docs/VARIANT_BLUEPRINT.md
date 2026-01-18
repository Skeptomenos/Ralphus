# Variant Blueprint

> Structural template for creating new Ralphus loop variants.

## Directory Structure (Required)

Every variant MUST follow this exact structure:

```
variants/ralphus-{name}/
├── config.sh                # Variant configuration (REQUIRED)
├── scripts/
│   └── loop.sh              # Thin wrapper script (REQUIRED)
├── instructions/
│   ├── PROMPT_{name}_plan.md    # Planning phase prompt (REQUIRED)
│   └── PROMPT_{name}_build.md   # Execution phase prompt (REQUIRED)
├── templates/               # Format references for the agent
│   └── *_REFERENCE.md       # REQUIRED: Unique suffix to avoid project name collisions
└── README.md                # Variant documentation (REQUIRED)
```

**Naming Convention**: `ralphus-{name}` where `{name}` is a single lowercase word (e.g., `code`, `test`, `discover`, `research`).

---

## Technical Standards

### 1. Template Naming (Shadow File Avoidance)
To prevent `opencode` from prioritizing central templates over project files, all template files MUST have the `_REFERENCE.md` suffix. 
*   **Bad**: `templates/IMPLEMENTATION_PLAN.md`
*   **Good**: `templates/IMPLEMENTATION_PLAN_REFERENCE.md`

### 2. File Ownership Guardrail
Every prompt MUST include a high-priority guardrail to prevent agents from moving tracking files.
> `99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.`

---

## File Templates

### 1. config.sh (Required)

This file defines the basic identity and requirements of the variant.

```bash
#!/bin/bash
# config.sh - Configuration for ralphus-{name}

VARIANT_NAME="{name}"
TRACKING_FILE="{TRACKING_FILE}.md"  # e.g., IMPLEMENTATION_PLAN.md
DEFAULT_PROMPT_FILE="PROMPT_{name}_build.md"
PLAN_PROMPT_FILE="PROMPT_{name}_plan.md"

# Directories that must exist or be created in the working directory
REQUIRED_DIRS=("{specs-folder}") # e.g., "specs", "questions"
```

### 2. loop.sh (Required)

The `loop.sh` is now a thin wrapper that sources the shared library and implements variant-specific hooks.

```bash
#!/bin/bash
# Ralphus {Name} - {One-line description}
# Usage: ralphus {name} [plan] [ulw] [N] ["custom prompt"]

set -euo pipefail

# Determine script and variant directories
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_VARIANT_DIR="$(dirname "$_SCRIPT_DIR")"

# Source variant configuration and shared library
source "$_VARIANT_DIR/config.sh"
source "$_VARIANT_DIR/../../lib/loop_core.sh"

# =============================================================================
# Hook: validate_variant() - Check variant-specific requirements
# =============================================================================
# Validates that required directories and files exist for the variant.
# =============================================================================
validate_variant() {
    # Add custom validation logic here
    # e.g., if [[ "$MODE" = "build" ]] && [[ ! -f "$WORKING_DIR/$TRACKING_FILE" ]]; then ...
    return 0
}

# =============================================================================
# Hook: get_templates() - Return template files for opencode
# =============================================================================
# Provides the reference templates that guide the agent.
# =============================================================================
get_templates() {
    echo "$TEMPLATES_DIR/{TEMPLATE}_REFERENCE.md"
}

# Run the shared loop with all arguments
run_loop "$_SCRIPT_DIR" "$_VARIANT_DIR" "$@"
```

### 3. Optional Hooks

You can also override these hooks in `loop.sh`:

- `build_message()`: Customize the message sent to the agent.
- `post_iteration()`: Run code after each iteration (e.g., custom commits).
- `parse_variant_args()`: Handle extra command line arguments.

---

## Checklist for New Variants

- [ ] Create `variants/ralphus-{name}/` directory
- [ ] Create `config.sh`
- [ ] Create `scripts/loop.sh` using the modular wrapper template
- [ ] Create `instructions/PROMPT_{name}_plan.md`
- [ ] Create `instructions/PROMPT_{name}_build.md`
- [ ] Create required templates in `templates/` with `_REFERENCE.md` suffix
- [ ] Create `README.md` with usage instructions
- [ ] Test with `bash -n scripts/loop.sh` (syntax check)
- [ ] Test with `ralphus {name} --help`
- [ ] Test plan mode: `ralphus {name} plan`
- [ ] Test build mode: `ralphus {name}`
