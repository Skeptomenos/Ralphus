# Variant Blueprint

> Structural template for creating new Ralphus loop variants.

## Directory Structure (Required)

Every variant MUST follow this exact structure:

```
variants/ralphus-{name}/
├── scripts/
│   └── loop.sh              # The eternal loop (REQUIRED)
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

### 1. loop.sh (Required)

```bash
#!/bin/bash
# Ralphus {Name} - {One-line description}
# Usage: ./ralphus/ralphus-{name}/scripts/loop.sh [plan] [ultrawork|ulw] [max_iterations]

set -euo pipefail

# Central location (where prompts/templates live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPHUS_{NAME}_DIR="$(dirname "$SCRIPT_DIR")"
INSTRUCTIONS_DIR="$RALPHUS_{NAME}_DIR/instructions"
TEMPLATES_DIR="$RALPHUS_{NAME}_DIR/templates"

# Working directory (where project files live)
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"

# Configuration
AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"

# Variant-specific directories (in working dir)
{SPECS_DIR}="$WORKING_DIR/{specs-folder}"  # e.g., specs/, questions/, test-specs/

ULTRAWORK=0

# Parse arguments
MODE="{default-mode}"  # e.g., "build", "discover", "research"
PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_{name}_build.md"
MAX_ITERATIONS=0

for arg in "$@"; do
    if [ "$arg" = "plan" ]; then
        MODE="plan"
        PROMPT_FILE="$INSTRUCTIONS_DIR/PROMPT_{name}_plan.md"
    elif [ "$arg" = "ultrawork" ] || [ "$arg" = "ulw" ]; then
        ULTRAWORK=1
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS=$arg
    fi
done

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Header
echo "=== RALPHUS {NAME}: $MODE mode | $AGENT | $CURRENT_BRANCH ==="
[ "$ULTRAWORK" -eq 1 ] && echo "Ultrawork: enabled"
[ "$MAX_ITERATIONS" -gt 0 ] && echo "Max iterations: $MAX_ITERATIONS"

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

# Verify templates directory exists
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "Error: $TEMPLATES_DIR/ directory not found."
    exit 1
fi

# Verify variant-specific requirements
if [ ! -d "${SPECS_DIR}" ]; then
    echo "Error: {specs-folder}/ directory not found in $WORKING_DIR"
    echo "Create {specs-folder}/*.md files first."
    exit 1
fi

# Build mode: check for tracking file
if [ "$MODE" = "{default-mode}" ] && [ ! -f "$WORKING_DIR/{TRACKING_FILE}.md" ]; then
    echo "Error: {TRACKING_FILE}.md not found in $WORKING_DIR"
    echo "Run planning mode first: $0 plan"
    exit 1
fi

# Archive previous run if branch changed
LAST_BRANCH_FILE="$WORKING_DIR/.last-branch"
if [ -f "$LAST_BRANCH_FILE" ]; then
    LAST_BRANCH=$(cat "$LAST_BRANCH_FILE")
    if [ "$LAST_BRANCH" != "$CURRENT_BRANCH" ]; then
        ARCHIVE_DIR="$WORKING_DIR/archive/$(date +%Y-%m-%d)-$LAST_BRANCH"
        mkdir -p "$ARCHIVE_DIR"
        cp "$WORKING_DIR/{TRACKING_FILE}.md" "$ARCHIVE_DIR/" 2>/dev/null || true
        # Add other files to archive as needed
        echo "Archived previous run to $ARCHIVE_DIR"
    fi
fi
echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"

# Graceful shutdown handler
SHUTDOWN=0
trap 'SHUTDOWN=1; echo -e "\n⚠ Shutdown requested. Finishing current iteration..."' INT TERM

# Main loop
while true; do
    if [ "$SHUTDOWN" -eq 1 ]; then
        echo "Shutting down gracefully."
        exit 0
    fi

    if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    ITERATION=$((ITERATION + 1))
    echo -e "\n======================== ITERATION $ITERATION ========================\n"

    if [ "$ULTRAWORK" -eq 1 ]; then
        MESSAGE="Read the attached prompt file and execute the instructions. ulw"
    else
        MESSAGE="Read the attached prompt file and execute the instructions"
    fi

    # Run OpenCode with prompt and reference template files
    OUTPUT=$("$OPENCODE" run --agent "$AGENT" \
        -f "$PROMPT_FILE" \
        -f "$TEMPLATES_DIR/{TEMPLATE1}_REFERENCE.md" \
        -- "$MESSAGE" 2>&1 | tee /dev/stderr) || true

    # Check completion signals
    if echo "$OUTPUT" | grep -q "<promise>PLAN_COMPLETE</promise>"; then
        echo "=== PLANNING COMPLETE ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>PHASE_COMPLETE</promise>"; then
        echo "=== PHASE COMPLETE - next iteration ==="
    fi
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo "=== ALL TASKS COMPLETE ===" && exit 0
    fi
    if echo "$OUTPUT" | grep -q "<promise>BLOCKED:"; then
        echo "=== BLOCKED ===" && echo "$OUTPUT" | grep -o "<promise>BLOCKED:[^<]*</promise>" && exit 1
    fi

    # Push changes after each iteration
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git push origin "$CURRENT_BRANCH" 2>/dev/null || {
            echo "Note: Failed to push. Creating remote branch..."
            git push -u origin "$CURRENT_BRANCH" 2>/dev/null || echo "Warning: Could not push to remote"
        }
    fi
done

echo "=== Loop finished after $ITERATION iterations ==="
```

### 2. PROMPT_{name}_plan.md (Required)

```markdown
# {Variant Name} - Planning Phase

You are an autonomous agent in a Ralphus loop. Your task is to create a plan for {variant purpose}.

## Context

- Working directory: Current project
- Specs location: `{specs-folder}/`
- Output: `{TRACKING_FILE}.md`

## Instructions

1. Read all files in `{specs-folder}/`
2. Analyze the requirements
3. Create `{TRACKING_FILE}.md` with prioritized tasks
4. Use the format from @{TEMPLATE}.md

## Completion Signal

When planning is complete, output:
```
<promise>PLAN_COMPLETE</promise>
```

## Guardrails

99999. Study existing codebase patterns before planning
999999. Break down into atomic, independently completable tasks
9999999. Prioritize by dependencies and impact
```

### 3. PROMPT_{name}_build.md (Required)

```markdown
# {Variant Name} - Build Phase

You are an autonomous agent in a Ralphus loop. Your task is to execute ONE task from the plan.

## Context

- Working directory: Current project
- Plan: `{TRACKING_FILE}.md`
- Templates: See attached files

## Instructions

1. Read `{TRACKING_FILE}.md`
2. Find the first incomplete task (marked `[ ]` or similar)
3. Execute that ONE task completely
4. Mark it complete in the tracking file
5. Commit your changes
6. Output completion signal

## Completion Signals

After completing ONE task:
```
<promise>PHASE_COMPLETE</promise>
```

When ALL tasks are done:
```
<promise>COMPLETE</promise>
```

If stuck for 3+ attempts:
```
<promise>BLOCKED:[task]:[reason]</promise>
```

## Guardrails

99999. ONE task per iteration. Never batch.
999999. Search codebase before implementing (don't assume not implemented)
9999999. Match existing patterns in the codebase
99999999. Commit after each task
999999999. No placeholders. No stubs. Complete implementations only.
```

### 4. README.md (Required)

```markdown
# Ralphus {Name}

> *"{Tagline}"*

**Ralphus {Name}** {one paragraph description of what this variant does}.

## How It Works

{Diagram showing the cycle}

## Quick Start

```bash
# Create required directory
mkdir -p {specs-folder}
echo "# My Spec" > {specs-folder}/example.md

# Run planning
ralphus {name} plan

# Run build loop
ralphus {name}
```

## Directory Requirements

Your project must have:
```
your-project/
├── {specs-folder}/           # REQUIRED: Your specifications
│   └── *.md
├── {TRACKING_FILE}.md        # Generated by plan mode
└── ...
```

## Completion Signals

| Signal | Meaning |
|--------|---------|
| `<promise>PLAN_COMPLETE</promise>` | Planning done |
| `<promise>PHASE_COMPLETE</promise>` | One task done, loop continues |
| `<promise>COMPLETE</promise>` | All tasks done |
| `<promise>BLOCKED:[task]:[reason]</promise>` | Stuck, needs help |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RALPH_AGENT` | `Sisyphus` | OpenCode agent to use |
| `OPENCODE_BIN` | `opencode` | Path to OpenCode binary |
```

---

## Variant Configuration Table

| Variant | Specs Dir | Tracking File | Default Mode | Templates |
|---------|-----------|---------------|--------------|-----------|
| code | `specs/` | `IMPLEMENTATION_PLAN.md` | build | `IMPLEMENTATION_PLAN_REFERENCE.md` |
| test | `test-specs/` | `TEST_PLAN.md` | test | `TEST_PLAN_REFERENCE.md`, `SPEC_FORMAT_REFERENCE.md` |
| research | `questions/` | `RESEARCH_PLAN.md` | research | `SUMMARY_REFERENCE.md`, `QUIZ_REFERENCE.md` |
| discover | (none) | `DISCOVERY_PLAN.md` | discover | `DISCOVERY_REFERENCE.md`, `CODEBASE_UNDERSTANDING_REFERENCE.md` |

---

## Checklist for New Variants

- [ ] Create `variants/ralphus-{name}/` directory
- [ ] Create `scripts/loop.sh` following template above
- [ ] Create `instructions/PROMPT_{name}_plan.md`
- [ ] Create `instructions/PROMPT_{name}_build.md`
- [ ] Create at least one template in `templates/`
- [ ] Create `README.md` with usage instructions
- [ ] Test with `bash -n scripts/loop.sh` (syntax check)
- [ ] Test with `ralphus {name} --help` (wrapper discovery)
- [ ] Test plan mode: `ralphus {name} plan`
- [ ] Test build mode: `ralphus {name}`

---

## Key Design Decisions

### 1. Central vs Working Directory

```bash
# Central (prompts/templates) - resolved from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTRUCTIONS_DIR="$RALPHUS_{NAME}_DIR/instructions"

# Working (project files) - from RALPHUS_WORKING_DIR or pwd
WORKING_DIR="${RALPHUS_WORKING_DIR:-$(pwd)}"
SPECS_DIR="$WORKING_DIR/{specs-folder}"
```

### 2. Mode Handling

Each variant handles its own modes. The wrapper just passes arguments through:
- `plan` → switches to planning prompt
- `ulw` / `ultrawork` → enables ultrawork mode
- Numbers → max iterations

### 3. Completion Signals

All variants use the same signal format:
- `<promise>PLAN_COMPLETE</promise>` — planning done
- `<promise>PHASE_COMPLETE</promise>` — one task done
- `<promise>COMPLETE</promise>` — all done
- `<promise>BLOCKED:[task]:[reason]</promise>` — stuck

### 4. Graceful Shutdown

All variants handle Ctrl+C gracefully:
```bash
SHUTDOWN=0
trap 'SHUTDOWN=1; echo "Finishing current iteration..."' INT TERM
```

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Hardcode paths to working directory | Use `$WORKING_DIR` variable |
| Skip the planning phase | Always have plan + build modes |
| Use different completion signals | Stick to the standard signals |
| Forget graceful shutdown | Always include the trap handler |
| Name templates generic names | Use `_REFERENCE.md` suffix |
| Let agent reorganize tracking files | Include "File Ownership" guardrail |
| Skip README.md | Document usage for humans |
