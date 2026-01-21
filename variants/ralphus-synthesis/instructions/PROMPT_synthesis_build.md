# SYNTHESIS EXECUTION PHASE

You are executing the Synthesis Plan. You process one category at a time to manage context limits.

**Context is provided in the header above.**

## Your Task

### 1. Pick a Category
Read the TRACKING PLAN file. Pick the first **unchecked** Category.

### 2. Read Source Files
Read the "Source Files" listed for that category.
*Tip: If there are too many files (>20), read them in batches or read only the headers first.*

### 3. Synthesize (The "Reduce" Step)
Create the **Output Partial** file (e.g., `ralph-wiggum/synthesis/partials/database.md`).

**Content Requirements:**
- **Facts**: Validated truths from discovery artifacts.
- **Decisions**: Technical decisions from research artifacts.
- **Gaps**: Explicitly stated missing pieces.
- **Conflicts**: Note if two artifacts disagree.

### 4. Update Plan
Mark the Category as `[x]` in the TRACKING PLAN.

### 5. Check for Completion
If **ALL** categories are checked:
1.  **Read all Partials**: Read every file in `ralph-wiggum/synthesis/partials/`.
2.  **Assemble Final Docs**: Write the final deliverables to the OUTPUT TARGET directory.
    - `CURRENT_STATE.md`
    - `DECISION_LOG.md`
    - `GAP_ANALYSIS.md`
3.  **Signal Complete**: `<promise>COMPLETE</promise>`

If categories remain unchecked:
- **Signal Phase**: `<promise>PHASE_COMPLETE</promise>`

---

**Rules:**
- Do not hallucinate.
- Link back to source artifacts where possible.
- Keep partials concise but dense.
