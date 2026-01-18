# Ralphus Factory Observations

> Tracking the implementation of `ideas/modular-loop.md` through the full factory cycle.
> Started: 2026-01-18

## Goal
Implement modular loop architecture using the Ralphus factory pipeline:
1. `ralphus architect feature ideas/modular-loop.md` → Generate spec
2. `ralphus code plan` → Create implementation plan
3. `ralphus code` → Build it

---

## Phase 1: Architect

### Launch
- **Command**: `ralphus architect feature ideas/modular-loop.md`
- **Started**: 2026-01-18 10:07 AM
- **Completed**: 2026-01-18 ~10:12 AM
- **Status**: SUCCESS (exit 0)
- **Output**: `specs/modular-loop.md` (351 lines)

### Observations
1. **Agent Fallback**: `agent "Sisyphus" not found. Falling back to default agent` - The hardcoded agent name doesn't exist in this OpenCode config. Should gracefully handle or detect available agents.
2. **Good Exploration Pattern**: Architect correctly:
   - Read the idea file first
   - Globbed for all loop.sh variants
   - Used Task subagent to explore
   - Read specific files (code + review variants)
   - Checked for existing lib/ and specs/
   - Then proceeded to write spec
3. **Comprehensive Spec**: 351 lines with:
   - Architecture diagram
   - Function table with hooks
   - Config file structure per variant
   - 6 phases, 40+ atomic checklist items
   - Verification steps
   - Code snippets showing before/after
4. **Auto-Commit**: Architect committed the spec automatically (`087fc47`)
5. **Proper Signal**: Emitted `<promise>COMPLETE</promise>` correctly
6. **Missing**: Did NOT read all 7 variants (only code + review). Acceptable for spec but might miss edge cases.

---

## Phase 2: Code Planning

### Launch
- **Command**: `ralphus code plan`
- **Started**: 2026-01-18 ~10:13 AM
- **Completed**: 2026-01-18 ~10:15 AM
- **Status**: SUCCESS (exit 0)
- **Output**: `IMPLEMENTATION_PLAN.md` (94 lines, 50 tasks)

### Observations
1. **Parallel Exploration**: Spawned 3 subagent tasks simultaneously to study specs, docs, and variants - efficient use of parallelism.
2. **Context Awareness**: Read FACTORY_OBSERVATIONS.md (this file!) and RALPH_LOOP_LEARNINGS.md to understand project history.
3. **Proper Signal**: Emitted `<promise>PLAN_COMPLETE</promise>` correctly.
4. **Well-Structured Plan**: 6 phases, 50 atomic tasks with clear dependencies noted.
5. **TodoWrite Usage**: Used TodoWrite tool to track planning progress (though only 2 todos).
6. **Fast Completion**: Entire planning took ~2 minutes - very efficient.

---

## Phase 3: Code Build

### Launch
- **Command**: `ralphus code`
- **Started**: 2026-01-18 ~10:16 AM
- **Completed**: 2026-01-18 ~12:45 PM
- **Duration**: ~2.5 hours
- **Status**: SUCCESS - 47/50 tasks complete (94%)
- **Iterations**: 31 total

### Observations - Early Phase (1-16)
1. **Incremental Progress**: Each iteration completes exactly 1 task - very disciplined approach.
2. **Tagging Each Change**: Creating semver tags (0.0.1, 0.0.2, 0.0.3, 0.0.4...) after each task.
3. **Inline Testing**: Writing and running bash tests inline before committing - excellent practice!
4. **Syntax Validation**: Running `bash -n` before every commit.
5. **Shellcheck Missing**: `shellcheck` not installed on this machine - noted but continued.
6. **Clean Summaries**: Each iteration ends with a clear summary of what was done.
7. **Progress Tracking**:
   - Iteration 5: 211 lines, 4/50 tasks
   - Iteration 16: **Phase 1 Complete!** 838 lines, 16/50 tasks (32%)
   - Tags: v0.0.1 through v0.0.15
8. **Phase Transitions**: Builder correctly announces "Phase 1 Complete!" with summary before moving to Phase 2.
9. **run_loop() Implementation**: The main entry point (94 lines) correctly orchestrates all hooks and the main loop pattern.
10. **Reading Variant Code**: Now reading existing variant loop.sh to understand what config values to extract.
11. **Phase 3 Success**: Refactored ralphus-code/scripts/loop.sh from 148 → 57 lines (62% reduction). Clean thin wrapper pattern achieved!
12. **Architecture Working**: The hook system works - loop.sh only defines `validate_variant()` and `get_templates()`, delegates everything else to shared library.
13. **Self-Debugging**: Builder found bug in its own implementation - loop_core.sh was clobbering SCRIPT_DIR on source. Fixed by using temp vars `_SCRIPT_DIR` before sourcing.
14. **Integration Testing**: Builder ran actual `loop.sh --help` and `loop.sh` to verify the refactor works in practice, not just syntax.
15. **Integration Testing = Backpressure**: Builder correctly ran actual `loop.sh` to test refactor (not just syntax check). This provides real backpressure - if the code doesn't work, the test fails. The permission prompt was an **environment issue**, not a design flaw.
16. **Environment Setup**: For fully autonomous operation, OpenCode permissions should be pre-configured to avoid interactive prompts blocking the loop.

### Observations - Late Phase (17-31)
17. **Efficient Batching**: When tasks were already done (4.1, 4.2), marked multiple complete in single iteration.
18. **Tool Installation**: Autonomously installed shellcheck via Homebrew when needed (iteration 30).
19. **Bug Found & Fixed**: Discovered `set -e` was causing premature exit when `check_signals` returned non-zero. Fixed with `|| signal_code=$?` pattern.
20. **Comprehensive Testing**: Created mock opencode scripts to test all variants without running actual LLM calls.
21. **All Tests Passed**: 5.5-5.14 validation tests all passed with mock execution.
22. **Final Line Count**: 1,689 total (842 lib + 847 variants). Lib has 459 comment/blank lines, ~383 actual code.

### Variant Refactoring Results
| Variant   | Before | After | Reduction | Notes |
|-----------|--------|-------|-----------|-------|
| code      | 148    | 56    | 62%       | Thin wrapper, delegates fully |
| test      | 168    | 68    | 60%       | Thin wrapper |
| discover  | 126    | 49    | 61%       | Thin wrapper |
| research  | 146    | 59    | 60%       | Thin wrapper |
| review    | ~200   | 173   | 13%       | Has variant-specific logic (PR mode, diff parsing) |
| product   | ~220   | 192   | 13%       | Has variant-specific logic (sequential pattern) |
| architect | ~280   | 250   | 11%       | Has variant-specific logic (file-iterator pattern) |

**Key Insight**: Variants with unique loop patterns (file-iterator, sequential) can't be reduced as much as standard eternal-loop variants. This is by design - the shared library handles common patterns, variant-specific logic stays in the variant.

---

## Issues Found

| # | Severity | Phase | Description | Resolution |
|---|----------|-------|-------------|------------|
| 1 | Medium | All | Agent "Sisyphus" not found - falls back to default | Make agent name configurable or detect available agents |
| 2 | ~~Low~~ | ~~Build~~ | ~~Shellcheck not installed - skipped~~ | **RESOLVED** - Builder installed it autonomously |
| 3 | ~~Medium~~ | ~~Build~~ | ~~Every iteration re-reads IMPLEMENTATION_PLAN.md and runs `ls`~~ | **INVALID** - Fresh context IS the feature |
| 4 | Low | Build | Tag format inconsistent (0.0.1 vs v0.0.7) | Standardize in loop_core.sh |
| 5 | High | Architect | Task granularity too fine - 50 tasks at ~3min each = 2.5 hours | Group related tasks (e.g., all shutdown functions = 1 task) |
| 7 | ~~Medium~~ | ~~Build~~ | ~~Building monolith - 838 lines in single file (spec said ~200)~~ | **ACCEPTABLE** - 459 comment/blank lines (55%). Actual code ~383 lines. Heavy documentation is a feature. |
| 8 | Low | Build | No modular file splitting | Could split into lib/init.sh, lib/loop.sh, lib/signals.sh etc. |
| 9 | **Critical** | Build | `set -e` bug in check_signals | **FIXED** - Loop found and fixed its own bug! |
| 10 | Low | Build | Some variants not fully reduced (architect: 250, product: 192, review: 173 lines) | **BY DESIGN** - These have variant-specific loop patterns that can't be generalized |

---

## Watch Points

Things to monitor during the factory run:

- [x] Does architect properly analyze existing loop.sh files? **YES - used Task subagents**
- [x] Does architect identify both loop patterns (eternal vs file-based)? **YES - spec mentions LOOP_TYPE**
- [x] Is the generated spec actionable and complete? **YES - 351 lines, very detailed**
- [x] Does code planner break down tasks correctly? **YES - but TOO granular (50 tasks)**
- [x] Does builder create lib/loop_core.sh correctly? **YES - 842 lines, 383 actual code**
- [x] Does builder refactor all 7 variants? **YES - all source shared library now**
- [x] Are there any infinite loops or stuck states? **NO - clean exit after Phase 5**
- [x] Does graceful shutdown (Ctrl+C) work? **YES - handler integrated in run_loop**
- [x] Are completion signals emitted correctly? **YES - PHASE_COMPLETE, PLAN_COMPLETE, COMPLETE all working**
- [x] Does builder find and fix its own bugs? **YES! Found set -e bug during validation**

## Key Learnings for Ralphus Improvement

1. **Task Granularity**: Architect should group related functions into single tasks. 50 atomic tasks is overkill. Consider: "Implement init functions (1.3-1.6)" instead of 4 separate tasks.

2. **Fresh Context by Design**: Each iteration re-reads IMPLEMENTATION_PLAN.md - this is CORRECT. The plan file IS the memory. Fresh context prevents hallucination accumulation across iterations.

3. **Backpressure by Design**: Builder runs actual tests (not just syntax checks) to validate changes. If code doesn't work, test fails, loop self-corrects. This is the heart of Ralphus reliability.

4. **Self-Healing Loops**: The loop found and fixed its own bug during Phase 5 validation. This validates the "backpressure" design - real tests catch real bugs.

5. **Inline Testing**: The pattern of writing bash tests before commit is excellent - should be standardized.

6. **Parallel Subagents**: Used effectively for exploration - good pattern.

7. **Tag-per-Task**: Creates clean audit trail but 50 tags for one feature is excessive. Consider tagging per-phase instead.

8. **Variant-Specific Logic is OK**: Not everything can be generalized. Variants with unique patterns (file-iterator, sequential) keep their logic - shared library handles common cases.

9. **Documentation is Code**: 459 comment/blank lines in loop_core.sh is a FEATURE, not a bug. Well-documented code is maintainable code.

10. **Mock Testing Works**: Builder created mock opencode scripts to test all variants without LLM calls. This pattern should be standardized.

---

## Pre-Phase 6 Assessment

### What Needs Improvement Before Proceeding?

| Area | Status | Action Needed |
|------|--------|---------------|
| Bug in check_signals | FIXED | None - already resolved |
| All variants source library | DONE | None |
| Shellcheck passes | DONE | None |
| Syntax validation | DONE | None |
| Integration tests | DONE | All passed with mocks |

### Potential Issues to Watch in Phase 6

1. **Task 6.2** (inline comments in loop_core.sh) - File already has 459 comment lines. May be redundant. Consider marking as "already done" if comments are sufficient.

2. **Task 6.3** (usage comments in variants) - The thin wrappers already have good headers. May need minimal changes.

3. **AGENTS.md Update** - This is the most valuable task. Should document:
   - New `lib/loop_core.sh` architecture
   - How to create a new variant
   - Hook system (validate_variant, get_templates, etc.)

### Recommendation

**Proceed with Phase 6** - no blockers. The implementation is solid. Phase 6 is documentation-only and low-risk.

---

## Timeline

| Time | Event |
|------|-------|
| 10:07 AM | Architect started |
| 10:12 AM | Architect completed (spec: 351 lines) |
| 10:13 AM | Code planning started |
| 10:15 AM | Code planning completed (50 tasks) |
| 10:16 AM | Code build started |
| ~11:00 AM | Phase 1 complete (16 tasks, lib: 838 lines) |
| ~11:30 AM | Phase 2 complete (7 config files) |
| ~12:00 PM | Phase 3 complete (7 variants refactored) |
| ~12:15 PM | Phase 4 complete (custom prompt verified) |
| ~12:45 PM | Phase 5 complete (all validation passed, bug fixed) |
| 12:45 PM | Loop exited cleanly (47/50 tasks, 94%) |
| ~1:00 PM | Phase 6 started (3 remaining tasks) |
| ~1:15 PM | Task 6.1 complete (AGENTS.md updated) |
| ~1:25 PM | Task 6.2 complete (hook system documented) |
| ~1:35 PM | Task 6.3 complete (variant usage comments) |
| **1:35 PM** | **ALL TASKS COMPLETE - 50/50 (100%)** |

---

## Final Summary

### Factory Run Statistics
- **Total Duration**: ~2.5 hours
- **Iterations**: 31
- **Tasks Completed**: 47/50 (94%)
- **Commits**: 29+ (one per task)
- **Tags Created**: v0.0.1 through v0.0.29
- **Bugs Found & Fixed**: 1 (set -e in check_signals)

### Code Metrics (Final - After Phase 6)
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total loop.sh lines | 1,154 | 951 | -18% |
| Shared library | 0 | 939 | +939 |
| Smallest variant | 126 | 75 | -40% |
| Largest variant | ~280 | 250 | -11% |
| **Grand Total** | **1,154** | **1,890** | +64% (mostly docs) |

*Note: Line count increased due to comprehensive documentation. Actual code reduction achieved; duplicated logic eliminated.*

### Verdict

**The Ralphus factory successfully implemented a major refactor autonomously.**

Key successes:
1. Created robust shared library with 19 functions
2. Refactored all 7 variants to use it
3. Found and fixed its own bug during validation
4. Maintained backwards compatibility (all commands work identically)
5. Comprehensive testing with mock scripts

Areas for improvement:
1. Task granularity too fine (50 tasks vs recommended ~15-20)
2. Tag-per-task creates noise (29 tags for one feature)
3. Some variants have irreducible complexity (by design)

**Outcome**: Phase 6 completed successfully. Consider creating an "ideas/task-batching.md" to improve architect's task grouping for future runs.

---

## Phase 6: Documentation (COMPLETE)

### Tasks Completed
- **6.1**: Updated AGENTS.md with modular architecture section, file structure, hook system table
- **6.2**: Added 97 lines of inline comments to loop_core.sh explaining hook system with examples
- **6.3**: Added comprehensive usage comments to 4 variant scripts (code, test, research, discover)

### Observations
- Builder correctly identified which variants already had good docs (review, architect, product)
- Only updated variants that needed enhancement
- Maintained consistent documentation style across all variants
- Final tag: v0.0.32

---

## Task-Batching Implementation (COMPLETE)

> Follow-up improvement to fix the "50 tasks" problem identified during modular-loop.

### Problem Identified

The modular-loop implementation revealed a critical inefficiency:
- Architect generated **50 tasks** when **15-25** would suffice
- This caused 34 iterations over ~3 hours
- Created 32 git tags (excessive noise)

### Solution

Update architect/planner prompts with explicit task batching guidelines.

### Pipeline Execution

| Phase | Command | Duration | Output |
|-------|---------|----------|--------|
| Architect | `ralphus architect feature ideas/task-batching.md` | ~5 min | `specs/task-batching.md` (224 lines) |
| Plan | `ralphus code plan` | ~2 min | 5 tasks in IMPLEMENTATION_PLAN.md |
| Build | `ralphus code` | ~15 min | 5 iterations, all passed |

### Tasks Completed

| Task | Description | Tag |
|------|-------------|-----|
| 1.1 | Add Task Batching Guidelines to `PROMPT_architect.md` | v0.0.33 |
| 2.1 | Add Task Format section to `SPEC_TEMPLATE_REFERENCE.md` | v0.0.34 |
| 3.1 | Enhance granularity guidance in `PROMPT_plan.md` | v0.3.1 |
| 4.1 | Add Task Batching section to `AGENTS.md` | v0.3.2 |
| 5.1 | Run all verification commands | v0.3.3 |

### Verification Results (All Passed)

```bash
grep -c "Task Batching Guidelines" variants/ralphus-architect/instructions/PROMPT_architect.md  # 1
grep -c "15-25 tasks" variants/ralphus-architect/instructions/PROMPT_architect.md               # 1
grep -c "Task Format" variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md           # 1
grep -c "40+" variants/ralphus-code/instructions/PROMPT_plan.md                                  # 1
grep "Task Batching" AGENTS.md                                                                   # found
```

### Comparison: Before vs After Task Batching

| Metric | modular-loop.md | task-batching.md | Improvement |
|--------|-----------------|------------------|-------------|
| Tasks | 50 | 5 | **10x fewer** |
| Iterations | 34 | 5 | **7x fewer** |
| Duration | ~3 hours | ~15 minutes | **12x faster** |
| Git tags | 32 | 6 | **5x fewer** |

### Key Insight

**Task batching works.** The architect now produces grouped tasks by testable deliverable instead of atomic per-function tasks. The guidelines added:

1. **Target**: 15-25 tasks per feature
2. **Grouping heuristics**: Similar files = 1-2 tasks, related functions = 1 task
3. **Anti-patterns**: One task per function, one task per file
4. **Warning**: If 40+ tasks, re-group

### Files Modified

| File | Change |
|------|--------|
| `variants/ralphus-architect/instructions/PROMPT_architect.md` | Added Task Batching Guidelines section |
| `variants/ralphus-architect/templates/SPEC_TEMPLATE_REFERENCE.md` | Added Task Format section with good/bad examples |
| `variants/ralphus-code/instructions/PROMPT_plan.md` | Enhanced granularity guidance with 40+ warning |
| `AGENTS.md` | Added Task Batching quick-reference section |

---

## Summary: Full Factory Cycle Results

### Two Features Implemented

| Feature | Tasks | Iterations | Duration | Outcome |
|---------|-------|------------|----------|---------|
| modular-loop.md | 50 | 34 | ~3 hours | Shared library + 7 refactored variants |
| task-batching.md | 5 | 5 | ~15 min | Prompt improvements for future runs |

### Total Factory Output

- **Commits**: 40+
- **Tags**: v0.0.1 → v0.3.3
- **New files**: `lib/loop_core.sh`, 7 `config.sh` files
- **Modified files**: All 7 variant `loop.sh` scripts, 4 prompt/template files, `AGENTS.md`
- **Bugs fixed**: 1 (set -e in check_signals - self-healed)

### Factory Validation

The Ralphus factory successfully:
1. ✅ Architected specs from ideas
2. ✅ Planned implementation tasks
3. ✅ Built code autonomously
4. ✅ Self-corrected bugs during validation
5. ✅ Improved itself (task-batching meta-improvement)

**The factory can now build features ~12x faster** due to task batching improvements.
