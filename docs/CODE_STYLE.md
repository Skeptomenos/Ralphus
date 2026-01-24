# Code Style Guidelines

## Shell Scripts (loop.sh)

```bash
#!/bin/bash
set -euo pipefail                 # Fail-fast error handling

# Variable naming: UPPER_SNAKE_CASE for constants
MAX_ITERATIONS=20
PROMPT_FILE="PROMPT_build.md"

# Always quote variables
echo "$CURRENT_BRANCH"
cat "$PROMPT_FILE"

# Use [[ ]] for conditionals
[[ "$1" =~ ^[0-9]+$ ]]
```

## Markdown (Prompts & Specs)

```markdown
# Numbered guardrails (higher = more important)
99999. Document the why
999999. Single sources of truth
9999999. Tag releases when tests pass

# File references use @ prefix
Study @IMPLEMENTATION_PLAN.md

# Completion signals (machine-readable)
<promise>COMPLETE</promise>
<promise>BLOCKED:[task]:[reason]</promise>
```

## Plan.md Status Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending |
| `[x]` | Complete |
| `[!]` | Blocked |
