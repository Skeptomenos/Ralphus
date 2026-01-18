# Implementation Plan

> **Active Spec**: `specs/task-batching.md`
> **Goal**: Improve architect task grouping to reduce 40-50 tasks to 15-25 per feature
> **Type**: Prompt Engineering (no code changes)

---

## Phase 1: Update Architect Prompt

- [x] 1.1 Add "Task Batching Guidelines" section to `PROMPT_architect.md`
      File: `variants/ralphus-architect/instructions/PROMPT_architect.md`
      Location: After "Phase 2: Architect the Solution", before "Phase 3: Write the Specification"
      Content: Include rules, anti-patterns, grouping heuristics table, and target task count (15-25)
      Test: `grep -c "Task Batching Guidelines" variants/ralphus-architect/instructions/PROMPT_architect.md` returns 1

---

## Phase 2: Update Spec Template

- [x] 2.1 Add "Task Format" section to `SPEC_TEMPLATE_REFERENCE.md`
      File: `variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md`
      Location: Before "## Verification Steps"
      Content: Task format with good/bad examples showing grouped vs granular tasks
      Test: `grep -c "Task Format" variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md` returns 1

---

## Phase 3: Strengthen Plan Mode Prompt

- [ ] 3.1 Enhance granularity guidance in `PROMPT_plan.md`
      File: `variants/ralphus-code/instructions/PROMPT_plan.md`
      Location: Expand existing "Task Granularity" section (lines 9-13)
      Content: Add explicit batching rules, anti-patterns, and warning for 40+ tasks
      Test: `grep -c "40+" variants/ralphus-code/instructions/PROMPT_plan.md` returns 1

---

## Phase 4: Update Operational Playbook

- [ ] 4.1 Add Task Batching section to `AGENTS.md`
      File: `AGENTS.md`
      Location: After "## The Ralphus Factory Cycle" section
      Content: Condensed task batching heuristics for operational reference
      Test: `grep "Task Batching" AGENTS.md` returns match

---

## Phase 5: Validation

- [ ] 5.1 Run all verification commands from spec
      Tests:
        - `grep -c "Task Batching Guidelines" variants/ralphus-architect/instructions/PROMPT_architect.md`
        - `grep -c "15-25 tasks" variants/ralphus-architect/instructions/PROMPT_architect.md`
        - `grep -c "Task Format" variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md`
        - `grep -c "40+" variants/ralphus-code/instructions/PROMPT_plan.md`
        - `grep "Task Batching" AGENTS.md`

---

## Completed Specs

### modular-loop.md (COMPLETE)

All 50+ tasks completed. See `specs/modular-loop.md` for details.

Key deliverables:
- `lib/loop_core.sh` - Shared library (~373 lines)
- 7 variant configs (`config.sh`) and thin wrapper scripts
- Hook system: `get_templates()`, `validate_variant()`, `build_message()`, `post_iteration()`
- Signal system: PLAN_COMPLETE, PHASE_COMPLETE, COMPLETE, BLOCKED, APPROVED

---

## Notes

- **Priority**: task-batching is prompt-only, low risk, high impact
- **Appendix content**: Use content from `specs/task-batching.md` Appendix A and B
- **Success criteria**: 15-25 tasks per feature instead of 40-50
