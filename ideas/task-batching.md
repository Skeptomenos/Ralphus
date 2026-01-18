# Task Batching: Improve Architect's Task Grouping

## Problem Statement

The Ralphus Architect generates overly granular implementation plans. For the `modular-loop` feature:
- Generated: **50 tasks** across 6 phases
- Expected: **15-20 tasks** across 6 phases
- Result: 34 iterations (~3 hours) instead of ~12-15 iterations (~1 hour)

Each task creates overhead: file re-reads, validation, commits, tags. Excessive granularity wastes time without improving quality.

## Root Cause

The architect treats each **function** or **file** as a separate task. But implementation tasks should be grouped by **testable deliverable**, not by code unit.

### Bad Example (Current)
```markdown
## Phase 1: Create Shared Library

- [ ] 1.1 Create `lib/` directory in ralphus root
- [ ] 1.2 Create `lib/loop_core.sh` with shebang, header comment, and `set -euo pipefail`
- [ ] 1.3 Implement `init_ralphus()`: Parse SCRIPT_DIR, VARIANT_DIR from caller...
- [ ] 1.4 Implement `parse_common_args()`: Handle plan, ulw/ultrawork, numeric...
- [ ] 1.5 Implement `show_header()`: Print variant name, mode, agent, current branch...
- [ ] 1.6 Implement `validate_common()`: Check PROMPT_FILE exists; check TEMPLATES_DIR exists
```

This generates 6 tasks for work that is **one logical unit** (create the library file with its core functions).

### Good Example (Target)
```markdown
## Phase 1: Create Shared Library

- [ ] 1.1 Create `lib/loop_core.sh` with initialization functions
      Includes: init_ralphus(), parse_common_args(), show_header(), validate_common()
      Test: `bash -n lib/loop_core.sh` passes, sourcing works from any variant
      
- [ ] 1.2 Add shutdown handling and iteration control
      Includes: setup_shutdown_handler(), check_shutdown(), check_max_iterations()
      Test: Ctrl+C sets SHUTDOWN=1, iteration limit respected
```

## Proposed Solution

### 1. Update PROMPT_architect.md with Batching Rules

Add a new section to the architect prompt:

```markdown
## Task Batching Guidelines

Group implementation tasks by **testable deliverable**, not by code unit.

**Rules:**
1. One task = one thing you can test in isolation
2. Multiple functions in the same file = usually one task
3. Multiple files with shared purpose = one task if tested together
4. Config files that all follow the same pattern = one task

**Anti-patterns to avoid:**
- One task per function (too granular)
- One task per file (too granular if files are related)
- Tasks with no clear test criteria

**Good task grouping:**
| Scope | Task Count | Example |
|-------|------------|---------|
| Create a new module | 1 | "Create lib/signals.sh with all signal handling" |
| Create 7 similar config files | 1-2 | "Create config.sh for all variants" |
| Refactor 7 similar scripts | 2-3 | "Refactor simple variants (code, test, discover)" + "Refactor complex variants (review, architect)" |
| Add documentation | 1 | "Update AGENTS.md and add inline comments" |

**Target:** 15-25 tasks per feature. If you have 40+, you're too granular.
```

### 2. Update SPEC_TEMPLATE_REFERENCE.md

Add task format guidance:

```markdown
## Task Format

Each task should include:
1. **What to build** (files, functions, components)
2. **Test criteria** (how to verify it works)
3. **Dependencies** (what must exist first)

Example:
- [ ] 2.3 Create variant config files for all 7 variants
      Files: variants/*/config.sh (code, review, architect, product, test, research, discover)
      Pattern: VARIANT_NAME, TRACKING_FILE, DEFAULT_PROMPT, REQUIRED_DIRS
      Test: Each config.sh sources without error, required vars are set
      Depends: 2.1 (shared library exists)
```

### 3. Add Batching Heuristics

The architect should apply these heuristics:

| Signal | Action |
|--------|--------|
| "Create X for each of the 7 variants" | Group into 1-2 tasks |
| "Implement functions A, B, C, D in file X" | Group into 1 task |
| "Add X to the shared library" | Group related functions into 1 task |
| "Test X, Y, Z" | Group all tests for a phase into 1 task |
| "Document X" | One task for all documentation in a phase |

## Success Criteria

After implementing this improvement:

1. **Task Count**: Features generate 15-25 tasks (not 40-50)
2. **Iteration Time**: Average feature completes in 12-15 iterations (not 30+)
3. **Tag Noise**: One tag per phase or major milestone (not per task)
4. **Test Coverage**: Each task has clear verification criteria

## Implementation Checklist

- [ ] Update `variants/ralphus-architect/instructions/PROMPT_architect.md` with batching section
- [ ] Update `variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md` with task format
- [ ] Add batching heuristics table to architect prompt
- [ ] Test with a new feature idea to verify improvement
- [ ] Update AGENTS.md with task batching guidelines

## Notes

- This is a **prompt engineering** change, not a code change
- The builder (`ralphus-code`) doesn't need changes - it just follows the plan
- Fewer tasks = fewer iterations = faster completion = less token usage
