# Ralphus Synthesis Variant

> **Role**: The Principal Architect / Librarian
> **Goal**: Distill massive amounts of raw artifacts (Discoveries, Research) into coherent Documentation.

---

## 1. Usage

```bash
# Synthesize Discovery findings only (Gap Analysis)
ralphus synthesis discover plan
ralphus synthesis discover

# Synthesize Research findings only (Technical Decisions)
ralphus synthesis research plan
ralphus synthesis research

# Synthesize Everything (Unified Architecture) - DEFAULT
ralphus synthesis all plan
ralphus synthesis all
```

## 2. Architecture: Map-Reduce

This variant uses a **Two-Phase Loop** to handle context limits when processing hundreds of files.

### Phase 1: Planning (The Map)
*   **Prompt**: `PROMPT_synthesis_plan.md`
*   **Action**: Scans input directories, clusters files into logical **Categories** (e.g., "Database", "API").
*   **Output**: `ralph-wiggum/synthesis/plan-[mode].md`

### Phase 2: Execution (The Reduce & Assemble)
*   **Prompt**: `PROMPT_synthesis_build.md`
*   **Step A (Reduce)**: Reads artifacts for *one category*, synthesizes them into a **Partial** (`ralph-wiggum/synthesis/partials/category.md`).
*   **Step B (Assemble)**: Once all categories are done, reads all Partials and compiles the **Final Docs**.
*   **Output**: `docs/architecture/[CURRENT_STATE|DECISION_LOG|GAP_ANALYSIS].md`

---

## 3. Dynamic Modes

The `scripts/loop.sh` injects context based on the mode argument:

| Mode | Input Source | Tracking File | Output Target |
| :--- | :--- | :--- | :--- |
| `discover` | `ralph-wiggum/discover/artifacts` | `plan-discover.md` | `docs/architecture/discover` |
| `research` | `ralph-wiggum/research/artifacts` | `plan-research.md` | `docs/architecture/research` |
| `all` | Both | `plan-all.md` | `docs/architecture` |

---

## 4. Current Behaviors & Known Limitations

### The "Nosy Architect" Behavior (Unified Scan)
Currently, the Planning Agent tends to **scan all available artifacts** in `ralph-wiggum/`, regardless of the requested mode.
*   **Effect**: Running `research` mode might still include `discovery` artifacts in the plan.
*   **Verdict**: This is currently considered a **Feature**, not a bug. It ensures the synthesis is holistic (e.g., matching Research theory against Discovery reality).
*   **Risk**: If the repo grows to >1,000 files, this "Scan All" approach will become slow and expensive.

### Idempotency
*   **Overwrites**: The final assembly step **overwrites** the target documents (`GAP_ANALYSIS.md`).
*   **Safety**: Rely on **Git** to track historical versions of the architecture. The variant assumes "Latest Run = Truth".

---

## 5. Future Roadmap

1.  **Strict Mode**: Enforce strict directory isolation in the Planning prompt to prevent "Scan All" when focused synthesis is needed (e.g., "Just synthesize these 5 new files").
2.  **Incremental Synthesis**: Allow updating *just* the "Database" partial without re-reading the "UI" artifacts.
3.  **Cross-Linking**: Better automatic linking between `GAP_ANALYSIS.md` items and the source `001-discovery.md` files (currently handled well, but can be improved).
