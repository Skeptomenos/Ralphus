# The Ralphus Factory Cycle

## Data Flow

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

## Roles & Responsibilities

| Role | Variant | Input | Output | Purpose |
|------|---------|-------|--------|---------|
| **Product** | `ralphus-product` | `inbox/` | `prds/` | Slice messy ideas into atomic PRDs. |
| **Architect** | `ralphus-architect` | `prds/` | `specs/` | Research feasibility and write rigorous specs. |
| **Builder** | `ralphus-code` | `specs/` | Code | Implement features and pass tests. |
| **Auditor** | `ralphus-review` | Code | `findings/` | Check security, style, and correctness. |
| **Fixer** | `ralphus-architect` | `findings/` | `specs/review-fixes.md` | Triage findings. STRICTLY ignores Low/Info. |
| **Learner** | `ralphus-research` | `inbox/` | `knowledge/` | Deep dive into technologies. |
| **Explorer** | `ralphus-discover` | `inbox/` | `findings/` | Map the codebase. |
| **Librarian** | `ralphus-synthesis` | `artifacts/` | `docs/` | Consolidate knowledge into architecture docs. |

## Task Batching

Group implementation tasks by **testable deliverable**, not by code unit. Target: **15-25 tasks per feature**.

| Scope | Tasks | Example |
|-------|-------|---------|
| New module with multiple functions | 1 | "Create lib/signals.sh with all signal handling" |
| Similar config files (5-7 files) | 1-2 | "Create config.sh for all variants" |
| Refactor similar scripts | 2-3 | "Refactor simple variants" + "Refactor complex variants" |
| Documentation across files | 1 | "Update AGENTS.md and add inline comments" |

**Anti-patterns**: One task per function, one task per file (when files are related), tasks without test criteria.

**Warning**: If you have 40+ tasks, you're too granular. Re-group.

See `variants/ralphus-architect/instructions/PROMPT_architect.md` for full Task Batching Guidelines.
