# Task Batching: Improve Architect Task Grouping

> **Status**: Approved by Architect
> **Type**: Feature (Prompt Engineering)
> **Effort**: ~1-2 hours

## Context

The Ralphus Architect generates overly granular implementation plans. Evidence from `FACTORY_OBSERVATIONS.md`:

- **Observed**: `modular-loop` feature generated **50 tasks** across 6 phases
- **Expected**: 15-20 tasks would have been sufficient
- **Impact**: 31 iterations (~2.5 hours) instead of ~12-15 iterations (~1 hour)

Each task creates overhead: file re-reads, validation, commits, tags. Excessive granularity wastes time and tokens without improving quality.

**Root Cause**: The architect prompt lacks explicit guidance on task grouping. It treats each function or file as a separate task rather than grouping by **testable deliverable**.

## Technical Design

This is a **prompt engineering change** targeting the architect variant. No code changes required.

### Files to Modify

| File | Purpose | Change |
|------|---------|--------|
| `variants/ralphus-architect/instructions/PROMPT_architect.md` | Main architect prompt | Add Task Batching Guidelines section |
| `variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md` | Spec output format | Add Task Format guidance with examples |
| `variants/ralphus-code/instructions/PROMPT_plan.md` | Plan mode prompt | Strengthen existing granularity guidance |
| `AGENTS.md` | Operational playbook | Add task batching heuristics |

### Existing Patterns (What Works)

From `PROMPT_plan.md` lines 9-13 (already exists, but insufficient):
```markdown
**Task Granularity: Cohesive Units**
Break phases into atomic, deployable tasks. Each task must be a **complete logic unit**.
- Scope: 1 feature/endpoint + tests + verification.
- Constraint: Must be implementable in one continuous session (~30 mins).
```

This guidance exists but is too vague. The architect still creates 50+ tasks because it lacks:
1. Explicit anti-patterns to avoid
2. Concrete grouping heuristics
3. Target task count per feature

## Requirements

1. Architect generates 15-25 tasks per medium feature (not 40-50)
2. Each task has clear verification criteria
3. Related functions in the same file are grouped into one task
4. Similar operations across multiple files are grouped (e.g., "create config.sh for all variants")
5. Documentation tasks are consolidated (not one per file)

## Implementation Plan (Atomic Tasks)

### Phase 1: Update Architect Prompt

- [ ] 1.1 Add "Task Batching Guidelines" section to `PROMPT_architect.md`
      File: `variants/ralphus-architect/instructions/PROMPT_architect.md`
      Location: After "Phase 2: Architect the Solution", before "Phase 3: Write the Specification"
      Content: Include rules, anti-patterns, grouping heuristics table, and target task count (15-25)
      Includes:
        - Batching rules (one task = one testable deliverable)
        - Anti-patterns to avoid (one task per function, one task per file)
        - Grouping heuristics table (see idea file for content)
        - Target task count: 15-25 per medium feature
      Test: Read file and verify section exists

### Phase 2: Update Spec Template

- [ ] 2.1 Add "Task Format" section to `SPEC_TEMPLATE_REFERENCE.md`
      File: `variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md`
      Location: Before "## Verification Steps"
      Content: Task format with examples showing Files, Pattern, Test, Depends fields
      Includes:
        - Required fields: What to build, Test criteria
        - Optional fields: Dependencies, Pattern (for repetitive tasks)
        - Good example showing grouped variant config creation
        - Bad example showing overly granular function-by-function breakdown
      Test: Read file and verify examples are clear

### Phase 3: Strengthen Plan Mode Prompt

- [ ] 3.1 Enhance granularity guidance in `PROMPT_plan.md`
      File: `variants/ralphus-code/instructions/PROMPT_plan.md`
      Location: Replace lines 9-13 with expanded guidance
      Content:
        - Keep existing "Task Granularity: Cohesive Units" header
        - Add explicit batching rules that match architect prompt
        - Add warning: "If you have 40+ tasks, you're too granular"
        - Add self-check: "Review task count before emitting PLAN_COMPLETE"
      Test: `grep -c "40+" variants/ralphus-code/instructions/PROMPT_plan.md` returns 1

### Phase 4: Update Operational Playbook

- [ ] 4.1 Add Task Batching section to `AGENTS.md`
      File: `AGENTS.md`
      Location: After "## The Ralphus Factory Cycle" section
      Content: Condensed version of batching heuristics for operational reference
      Includes:
        - Target task count (15-25 per feature)
        - Quick-reference grouping table
        - Link to architect prompt for full guidance
      Test: `grep "Task Batching" AGENTS.md` returns match

### Phase 5: Validation

- [ ] 5.1 Create test idea file and run architect to verify improvement
      Action: Create `ideas/test-batching-validation.md` with a simple 3-component feature
      Run: `ralphus architect feature ideas/test-batching-validation.md`
      Verify: Generated spec has 10-15 tasks (not 25+)
      Cleanup: Remove test files after validation
      Test: Task count in generated spec is within target range

## Verification Steps

1. **Prompt Content Check**:
   ```bash
   grep -c "Task Batching Guidelines" variants/ralphus-architect/instructions/PROMPT_architect.md
   # Expected: 1
   
   grep -c "15-25 tasks" variants/ralphus-architect/instructions/PROMPT_architect.md
   # Expected: 1+
   ```

2. **Template Content Check**:
   ```bash
   grep -c "Task Format" variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md
   # Expected: 1
   ```

3. **Plan Mode Check**:
   ```bash
   grep -c "40+" variants/ralphus-code/instructions/PROMPT_plan.md
   # Expected: 1
   ```

4. **AGENTS.md Check**:
   ```bash
   grep "Task Batching" AGENTS.md
   # Expected: match found
   ```

5. **Live Validation** (optional, run manually):
   - Create a test idea file
   - Run `ralphus architect feature ideas/test-feature.md`
   - Count tasks in generated spec
   - Expected: 15-25 tasks (not 40+)

## Success Criteria

After implementing this improvement:

| Metric | Before | Target | How to Measure |
|--------|--------|--------|----------------|
| Task count per feature | 40-50 | 15-25 | Count checkboxes in spec |
| Iterations per feature | 30+ | 12-15 | Count PHASE_COMPLETE signals |
| Time per feature | 2.5+ hours | ~1 hour | Wall clock time |
| Tags per feature | 29+ | 6-10 | `git tag --list` |

## Notes

- This is **prompt engineering only** - no shell script or code changes
- The `ralphus-code` builder doesn't need changes - it just follows the plan
- Fewer tasks = fewer iterations = faster completion = less token usage
- The existing "Task Granularity" guidance in `PROMPT_plan.md` is insufficient because it lacks concrete examples and anti-patterns

## Appendix: Content to Add

### A. Task Batching Guidelines (for PROMPT_architect.md)

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
| Create a new module with 5 functions | 1 | "Create lib/signals.sh with all signal handling" |
| Create 7 similar config files | 1-2 | "Create config.sh for all variants" |
| Refactor 7 similar scripts | 2-3 | "Refactor simple variants" + "Refactor complex variants" |
| Add documentation to multiple files | 1 | "Update AGENTS.md and add inline comments" |

**Target:** 15-25 tasks per feature. If you have 40+, you're too granular. Re-group.
```

### B. Task Format (for SPEC_TEMPLATE_REFERENCE.md)

```markdown
## Task Format

Each task should include:
1. **What to build** (files, functions, components)
2. **Test criteria** (how to verify it works)
3. Optional: **Dependencies** (what must exist first)

**Good Example:**
- [ ] 2.3 Create variant config files for all 7 variants
      Files: variants/*/config.sh (code, review, architect, product, test, research, discover)
      Pattern: VARIANT_NAME, TRACKING_FILE, DEFAULT_PROMPT, REQUIRED_DIRS
      Test: Each config.sh sources without error, required vars are set
      Depends: 2.1 (shared library exists)

**Bad Example (too granular):**
- [ ] 2.3 Create config.sh for ralphus-code
- [ ] 2.4 Create config.sh for ralphus-test
- [ ] 2.5 Create config.sh for ralphus-discover
- [ ] 2.6 Create config.sh for ralphus-research
... (4 separate tasks for identical work)
```
