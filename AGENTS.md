# AGENTS.md - Ralphus Autonomous Development Playbook

> For AI agents operating in this repository. Keep operational, not verbose.

## Project Overview

Ralphus is a **meta-framework** for autonomous coding loops. It orchestrates LLM agents (Sisyphus/Claude) to iteratively implement features from specs. This is NOT a traditional codebase—it's a playbook meant to be copied into target projects.

**Core Philosophy**: "Let Ralphus Ralphus" — the loop is self-correcting through backpressure (failing tests).

---

## Build & Run

### Central Execution (Recommended)

```bash
# From any project directory
cd ~/my-project
ralphus code plan      # Generate implementation plan
ralphus code           # Run build loop
ralphus code ulw 20    # Ultrawork mode, max 20 iterations
ralphus test plan      # Test creation planning
ralphus discover       # Codebase understanding
```

The `ralphus` wrapper lives in `~/.local/bin/` and routes to the correct variant in `~/ralphus/variants/`.

### Direct Invocation (Alternative)

```bash
# If you copied the variant into your project
./ralphus/ralphus-code/scripts/loop.sh plan
./ralphus/ralphus-code/scripts/loop.sh

# Or from central location with explicit working dir
RALPHUS_WORKING_DIR=$(pwd) ~/ralphus/variants/ralphus-code/scripts/loop.sh plan
```

### Stop Gracefully

```bash
Ctrl+C                 # Finish current task, then stop
pkill -f opencode      # Nuclear option
```

---

## Validation

Run these after implementing to get immediate feedback:

- Syntax: `bash -n variants/*/scripts/loop.sh`
- Lint: `shellcheck variants/*/scripts/loop.sh` (if installed)

## Operational Notes

Succinct learnings about how to RUN the project:

- OpenCode CLI required: `opencode run --agent Sisyphus -f PROMPT.md "message"`
- Default agent is Sisyphus, override with `RALPH_AGENT=build`
- Remote homelab uses `~/.opencode/bin/opencode` path

### Codebase Patterns

...

```bash
# Lint shell scripts
shellcheck variants/*/scripts/loop.sh
bash -n variants/*/scripts/loop.sh    # Validate syntax
```

---

## File Structure

```
ralphus/                          # This playbook repo
├── files/                        # Copy these to target project
│   ├── loop.sh                   # The eternal loop
│   ├── PROMPT_plan.md            # Planning phase instructions
│   ├── PROMPT_build.md           # Build phase instructions
│   ├── AGENTS.md                 # Template for target project
│   └── IMPLEMENTATION_PLAN.md    # Task tracking (generated)
├── skill/                        # Homelab remote execution
│   ├── SKILL.md                  # Remote management skill
│   └── config/
│       └── project-mappings.json # Project path mappings
├── references/                   # Research & diagrams
├── PLAN.md                       # Adaptation roadmap
└── README.md                     # Philosophy & usage
```

---

## Code Style Guidelines

### Shell Scripts (loop.sh)

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

### Markdown (Prompts & Specs)

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

---

## The Ralphus Cycle

```
1. Read the tracking plan (*_PLAN.md)
2. Pick highest priority incomplete task
3. Search codebase first (don't assume not implemented)
4. Implement using parallel subagents
5. Run tests (backpressure)
6. If pass: commit, push, update plan
7. If fail: fix or document in plan
8. Context clears → repeat from step 1
```

---

## Subagent Delegation

| Operation | Subagents | Notes |
|-----------|-----------|-------|
| Search/Read | Up to 500 parallel Sonnet | Fire liberally for exploration |
| Build/Test | 1 Sonnet at a time | Prevents race conditions |
| Complex reasoning | Opus | Debugging, architecture, prioritization |

---

## Guardrails (Numbered by Importance)

```
99999.       File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999.      Document the why in code and specs
9999999.     Single sources of truth, no adapters
99999999.    Tag releases when tests pass (semver)
999999999.   Update AGENTS.md with operational learnings
9999999999.  Resolve or document ALL bugs found
99999999999. No placeholders. No stubs. Complete implementations only.
```

---

## Completion Signals

| Signal | Meaning |
|--------|---------|
| `<promise>COMPLETE</promise>` | All tasks done, loop exits cleanly |
| `<promise>BLOCKED:[task]:[reason]</promise>` | Stuck, needs human intervention |

---

## Error Recovery Protocol

1. **Test fails**: Fix the code, not the test
2. **3 consecutive failures**: Document in the tracking plan, move to next task
3. **15 min no progress**: Output `<promise>BLOCKED:[task]:[reason]</promise>`

**Never**: Delete failing tests, spin on same error, leave code broken

---

## OpenCode / Sisyphus Configuration

```bash
RALPH_AGENT="Sisyphus"           # Agent to use
OPENCODE_BIN="opencode"          # Binary path
```

| Claude Code | OpenCode |
|-------------|----------|
| `claude -p` | `opencode run --agent Sisyphus` |
| `--model opus` | `--agent Sisyphus` |

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Assume code doesn't exist | Search first with subagents |
| Implement placeholders/stubs | Complete implementations only |
| Spin on failing tests | Document and move on after 3 attempts |
| Bloat AGENTS.md with status | Status goes in the tracking plan |
| Delete failing tests | Fix the code |

---

## Operational Notes

Succinct learnings about how to RUN the project:

- OpenCode CLI required: `opencode run --agent Sisyphus -f PROMPT.md "message"`
- Default agent is Sisyphus, override with `RALPH_AGENT=build`
- Remote homelab uses `~/.opencode/bin/opencode` path

### Codebase Patterns

...

```bash
# Lint shell scripts
shellcheck variants/*/scripts/loop.sh
bash -n variants/*/scripts/loop.sh    # Validate syntax
```
