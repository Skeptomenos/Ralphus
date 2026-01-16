# Central Execution Architecture

> Concept paper for running Ralphus variants from a central location while operating on any project directory.

## Problem Statement

Currently, using Ralphus requires copying the entire variant folder (`variants/ralphus-code/`, etc.) into each project. This leads to:

- **Duplication**: Same files copied across many projects
- **Drift**: Updates to Ralphus don't propagate to existing projects
- **Maintenance burden**: Updating N projects requires N copy operations

## Desired Behavior

```bash
# From any project directory
cd ~/my-project
ralphus code plan      # Uses central ralphus-code variant
ralphus test ulw       # Uses central ralphus-test variant
ralphus discover 20    # Uses central ralphus-discover variant
```

The wrapper should:
1. Resolve prompts and templates from central Ralphus installation
2. Operate on files in the current working directory (specs, plans, source code)
3. Remain backwards compatible with direct `loop.sh` invocation

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           USER'S PROJECT                                │
│                         (current working dir)                           │
├─────────────────────────────────────────────────────────────────────────┤
│  specs/                    <- Project-specific specs                    │
│  IMPLEMENTATION_PLAN.md    <- Generated/tracked here                    │
│  src/                      <- Source code lives here                    │
│  ...                                                                    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ ralphus code plan
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         ~/.local/bin/ralphus                            │
│                           (wrapper script)                              │
├─────────────────────────────────────────────────────────────────────────┤
│  1. Parse variant name and args                                         │
│  2. Discover variant from variants.json or directory scan               │
│  3. Set RALPHUS_WORKING_DIR=$(pwd)                                      │
│  4. Execute variant's loop.sh                                           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ RALPHUS_WORKING_DIR=/Users/.../my-project
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    ~/ralphus/variants/ralphus-code/                     │
│                         (central storage)                               │
├─────────────────────────────────────────────────────────────────────────┤
│  scripts/loop.sh           <- Execution logic                           │
│  instructions/PROMPT_*.md  <- Agent prompts                             │
│  templates/*.md            <- Format references                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Variant Discovery

### Option A: Hardcoded Mapping (Simple)
```bash
case "$VARIANT" in
    code)     VARIANT_DIR="ralphus-code" ;;
    test)     VARIANT_DIR="ralphus-test" ;;
    # ... must update wrapper for each new variant
esac
```

### Option B: Configuration File (Extensible) ✓ Recommended
```
variants/
├── variants.json          <- Variant registry
├── ralphus-code/
├── ralphus-test/
└── ralphus-custom/        <- Just add entry to variants.json
```

**variants.json**:
```json
{
  "code": {
    "path": "ralphus-code",
    "description": "Feature implementation from specs",
    "requires": ["specs/"]
  },
  "test": {
    "path": "ralphus-test", 
    "description": "Test creation from test specs",
    "requires": ["test-specs/"]
  },
  "research": {
    "path": "ralphus-research",
    "description": "Deep research on topics",
    "requires": ["questions/"]
  },
  "discover": {
    "path": "ralphus-discover",
    "description": "Codebase understanding",
    "requires": []
  }
}
```

### Option C: Directory Convention (Zero Config)
```bash
# Auto-discover: any folder matching ralphus-* becomes a variant
# Short name = folder name minus "ralphus-" prefix
ls variants/ | grep "^ralphus-" | sed 's/ralphus-//'
# => code, test, research, discover
```

**Recommendation**: Option C with Option B as override. Auto-discover by convention, but allow `variants.json` for metadata (description, requirements, aliases).

---

## Backwards Compatibility

The architecture preserves both usage patterns:

### New Way (Wrapper)
```bash
cd ~/my-project
ralphus code plan
```

### Old Way (Direct)
```bash
cd ~/my-project
# If you copied the variant into your project
./ralphus/ralphus-code/scripts/loop.sh plan

# Or from central location with explicit working dir
RALPHUS_WORKING_DIR=$(pwd) ~/ralphus/variants/ralphus-code/scripts/loop.sh plan
```

The `loop.sh` scripts check for `RALPHUS_WORKING_DIR`:
- If set: use it for project files
- If not set: use `$(pwd)` (current behavior when running directly)

---

## Implementation Changes

### 1. Wrapper Script (`~/.local/bin/ralphus`)

```bash
#!/bin/bash
set -euo pipefail

RALPHUS_HOME="${RALPHUS_HOME:-$HOME/ralphus}"
VARIANTS_DIR="$RALPHUS_HOME/variants"

# Parse variant name
VARIANT="${1:-}"
if [ -z "$VARIANT" ]; then
    echo "Usage: ralphus <variant> [plan] [ulw] [max_iterations]"
    echo ""
    echo "Available variants:"
    for dir in "$VARIANTS_DIR"/ralphus-*/; do
        name=$(basename "$dir" | sed 's/ralphus-//')
        echo "  $name"
    done
    exit 1
fi
shift

# Resolve variant directory
VARIANT_DIR="$VARIANTS_DIR/ralphus-$VARIANT"
if [ ! -d "$VARIANT_DIR" ]; then
    echo "Error: Unknown variant '$VARIANT'"
    echo "Available: $(ls "$VARIANTS_DIR" | grep "^ralphus-" | sed 's/ralphus-//' | tr '\n' ' ')"
    exit 1
fi

# Execute with working directory context
export RALPHUS_WORKING_DIR="$(pwd)"
exec "$VARIANT_DIR/scripts/loop.sh" "$@"
```

### 2. Modified loop.sh Pattern

Each variant's `loop.sh` needs this change at the top:

```bash
#!/bin/bash
set -euo pipefail

# Central location (where prompts/templates live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANT_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$VARIANT_DIR/instructions"
TEMPLATES_DIR="$VARIANT_DIR/templates"

# Working directory (where project files live)
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Project-specific paths (relative to working dir)
SPECS_DIR="$WORKING_DIR/specs"
PLAN_FILE="$WORKING_DIR/IMPLEMENTATION_PLAN.md"
# ... etc
```

Key principle: **Prompts from central, project files from working dir.**

---

## Extensibility

### Adding a New Variant

1. Create `variants/ralphus-myvariant/` with standard structure:
   ```
   ralphus-myvariant/
   ├── scripts/loop.sh
   ├── instructions/
   │   ├── PROMPT_myvariant_plan.md
   │   └── PROMPT_myvariant_build.md
   ├── templates/
   │   └── *.md
   └── README.md
   ```

2. The wrapper auto-discovers it:
   ```bash
   ralphus myvariant plan  # Just works
   ```

3. Optionally add metadata to `variants.json` for help text.

**See [VARIANT_BLUEPRINT.md](VARIANT_BLUEPRINT.md) for complete templates and guidelines.**

### No Wrapper Changes Required

The directory convention (`ralphus-*`) means zero wrapper modifications for new variants.

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `RALPHUS_HOME` | `~/ralphus` | Central Ralphus installation |
| `RALPHUS_WORKING_DIR` | `$(pwd)` | Project directory (set by wrapper) |
| `RALPH_AGENT` | `Sisyphus` | OpenCode agent to use |
| `OPENCODE_BIN` | `opencode` | Path to OpenCode binary |

---

## Usage Examples

```bash
# Basic usage
cd ~/projects/my-app
ralphus code plan          # Generate implementation plan
ralphus code               # Run build loop
ralphus code 20            # Max 20 iterations
ralphus code ulw           # Ultrawork mode

# Other variants
ralphus test plan          # Plan test creation
ralphus discover           # Discover codebase
ralphus research ulw 10    # Research with limits

# Help
ralphus                    # List available variants
ralphus --help             # Same as above
```

---

## Migration Path

### For Existing Projects (with copied variants)

No action required. Direct `./ralphus/ralphus-code/scripts/loop.sh` still works.

### To Adopt Central Execution

1. Install wrapper: `cp ralphus ~/.local/bin/ && chmod +x ~/.local/bin/ralphus`
2. Set `RALPHUS_HOME` if not using `~/ralphus`
3. Delete copied variant folders from projects (optional)
4. Use `ralphus <variant>` instead of `./ralphus/.../loop.sh`

---

## Mode Handling (plan/build/ulw)

The wrapper is intentionally **dumb** about modes. It only:
1. Resolves the variant directory
2. Sets `RALPHUS_WORKING_DIR`
3. Passes all remaining arguments to `loop.sh`

```bash
# User runs:
ralphus code plan ulw 10

# Wrapper does:
export RALPHUS_WORKING_DIR="$(pwd)"
exec ~/ralphus/variants/ralphus-code/scripts/loop.sh plan ulw 10
#                                                    ^^^^^^^^^^^^
#                                                    passed through as "$@"
```

**Each variant's `loop.sh` handles its own argument parsing:**

| Variant  | Default Mode | `plan` switches to | Prompt files                                      |
| -------- | ------------ | ------------------ | ------------------------------------------------- |
| code     | `build`      | `plan`             | `PROMPT_build.md`, `PROMPT_plan.md`               |
| discover | `discover`   | `plan`             | `PROMPT_discover_build.md`, `PROMPT_discover_plan.md` |
| test     | `build`      | `plan`             | `PROMPT_test_build.md`, `PROMPT_test_plan.md`     |
| research | `build`      | `plan`             | `PROMPT_research_build.md`, `PROMPT_research_plan.md` |

This means:
- **No wrapper changes** for new modes
- **Each variant can have custom modes** (e.g., `ralphus research deep`)
- **Fully extensible** without touching the wrapper

---

## Summary

| Aspect | Approach |
|--------|----------|
| Discovery | Directory convention (`ralphus-*`) with optional JSON metadata |
| Backwards compat | `RALPHUS_WORKING_DIR` env var, defaults to pwd |
| Extensibility | Add folder, auto-discovered, no wrapper changes |
| Installation | Single script in PATH + central repo |
