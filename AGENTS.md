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

# 1. Product (Brain Dump -> Ideas)
echo "Need a leaderboard" > inbox/dump.md
ralphus product

# 2. Architect (Ideas -> Specs)
ralphus architect feature

# 3. Build (Specs -> Code)
ralphus code plan
ralphus code

# 4. Review (Code -> Findings)
ralphus review plan pr
ralphus review

# 5. Fix (Findings -> Fixes)
ralphus architect triage
ralphus code
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

## Modular Loop Architecture

The loop scripts use a shared library pattern to eliminate duplication (~61% code reduction).

```
ralphus/
├── lib/
│   └── loop_core.sh              # Shared library (~370 lines)
└── variants/
    └── ralphus-*/
        ├── config.sh             # Variant configuration
        └── scripts/loop.sh       # Thin wrapper (~50-100 lines each)
```

### Hook System

Variants customize behavior via hooks defined before calling `run_loop`:

| Hook | Purpose | Required |
|------|---------|----------|
| `get_templates()` | Return template file paths (one per line) | Yes |
| `validate_variant()` | Check variant-specific inputs | No |
| `build_message()` | Construct custom iteration message | No |
| `post_iteration()` | Run after each iteration | No |
| `parse_variant_args()` | Handle variant-specific arguments | No |

### Completion Signals

| Signal | Exit Code | Meaning |
|--------|-----------|---------|
| `PHASE_COMPLETE` | 0 (continue) | Single task done, continue loop |
| `PLAN_COMPLETE` | 10 | Planning phase done |
| `COMPLETE` | 20 | All tasks done |
| `BLOCKED` | 30 | Stuck, needs intervention |
| `APPROVED` | 40 | Review approved (review only) |

---

## File Structure

```
ralphus/                          # This playbook repo
├── lib/
│   └── loop_core.sh              # Shared loop library (hooks, signals, git ops)
├── variants/                     # The Autonomous Factory
│   ├── ralphus-code/             # Builder
│   │   ├── config.sh             # Variant config
│   │   ├── scripts/loop.sh       # Thin wrapper
│   │   ├── instructions/         # Prompt files
│   │   └── templates/            # Reference templates
│   ├── ralphus-review/           # Auditor
│   ├── ralphus-architect/        # Tech Lead (Spec)
│   ├── ralphus-product/          # PM (Slicer)
│   ├── ralphus-test/             # Tester
│   ├── ralphus-research/         # Learner
│   └── ralphus-discover/         # Explorer
├── skills/                       # OpenCode skills
│   └── ralphus-remote/           # Homelab remote execution
├── bin/                          # CLI wrapper
│   └── ralphus                   # Routes to correct variant
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

## The Ralphus Factory Cycle

```
┌──────────────┐      ┌───────────────┐      ┌───────────────┐
│              │      │               │      │               │
│  Brain Dump  │─────▶│ ralphus       │─────▶│ ralphus       │
│  (inbox/*.md)│      │ product       │      │ architect     │
│              │      │ (Slice Ideas) │      │ (Write Specs) │
└──────────────┘      └───────────────┘      └───────────────┘
                              │                      │
                              ▼                      ▼
                      ┌───────────────┐      ┌───────────────┐
                      │               │      │               │
                      │ ideas/*.md    │      │ specs/*.md    │
                      │               │      │               │
                      └───────────────┘      └───────────────┘
                                                     │
                                                     ▼
┌──────────────┐      ┌───────────────┐      ┌───────────────┐
│              │      │               │      │               │
│ ralphus      │◀─────│ ralphus       │◀─────│ ralphus       │
│ review       │      │ code          │      │ code plan     │
│ (Audit)      │      │ (Build)       │      │ (Task List)   │
└──────────────┘      └───────────────┘      └───────────────┘
```

### Roles & Responsibilities

| Role | Variant | Input | Output | Purpose |
|------|---------|-------|--------|---------|
| **Product** | `ralphus-product` | `inbox/` | `ideas/` | Slice messy ideas into atomic features. |
| **Architect** | `ralphus-architect` | `ideas/` | `specs/` | Research feasibility and write rigorous specs. |
| **Builder** | `ralphus-code` | `specs/` | Code | Implement features and pass tests. |
| **Auditor** | `ralphus-review` | Code | `reviews/` | Check security, style, and correctness. |
| **Fixer** | `ralphus-architect` | `reviews/` | `specs/review-fixes.md` | Triage findings. STRICTLY ignores Low/Info. Moves processed reviews to `reviews/processed/`. |

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

