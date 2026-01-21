# Ralph-Wiggum Architecture: The Agent Operating System

> **Version**: 1.0.0 (Proposed)
> **Goal**: Unified, isolated, and consistent file structure for all Ralphus autonomous agents.

---

## 1. Core Philosophy

**"Clean Factory, Clean Product"**

- **Isolation**: Agents operate in their own namespaced directories (`ralph-wiggum/[variant]/`).
- **Standardization**: Every agent has an `inbox` (input), `plan` (state), and `artifacts` (output).
- **Handoffs**: Agents communicate via shared "conveyor belts" (`ideas/`, `specs/`).
- **Constitution**: `AGENTS.md` remains the immutable root law.

---

## 2. Universal Directory Structure

```text
project_root/
├── AGENTS.md                   # The Constitution (Global Rules)
├── src/                        # The Product (Codebase)
└── ralph-wiggum/               # The Factory Floor
    ├── memory/                 # Global Context (Shared)
    │   ├── context.md          # Project tech stack, patterns
    │   └── learnings.md        # Accumulated knowledge
    │
    ├── ideas/                  # Conveyor: Product -> Architect
    │   └── feature-[name].md   # Raw feature requests/slices
    │
    ├── specs/                  # Conveyor: Architect -> Code
    │   └── spec-[name].md      # Rigorous technical specs
    │
    ├── [variant-name]/         # Agent Workspaces
    │   ├── plan.md             # The Brain: State machine & Tasks
    │   ├── inbox/              # User Input (Questions, Dumps)
    │   └── artifacts/          # Agent Output (Findings, Knowledge)
```

---

## 3. Variant Mappings

Each variant maps to the universal schema as follows:

| Variant | Role | Workspace | Input Source | State File | Output Destination |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`research`** | Learner | `ralph-wiggum/research/` | `inbox/questions.md` | `plan.md` | `artifacts/knowledge/` |
| **`discover`** | Explorer | `ralph-wiggum/discover/` | `inbox/seeds.md` | `plan.md` | `artifacts/findings/` |
| **`product`** | Slicer | `ralph-wiggum/product/` | `inbox/dump.md` | `plan.md` | `../ideas/` (Shared) |
| **`architect`** | Planner | `ralph-wiggum/architect/` | `../ideas/*.md` | `plan.md` | `../specs/` (Shared) |
| **`code`** | Builder | `ralph-wiggum/code/` | `../specs/*.md` | `plan.md` | `../../src/` (The Code) |
| **`review`** | Auditor | `ralph-wiggum/review/` | `../../src/` | `plan.md` | `artifacts/findings/` |

---

## 4. The `ralph init` Protocol

A new initialization script will scaffold the factory.

**Usage:**
```bash
ralphus init [variant]   # Init specific variant
ralphus init --all       # Init full factory
```

**Behavior:**
1. Creates `ralph-wiggum/` directory structure.
2. Creates `.gitignore` inside `ralph-wiggum/`:
   ```gitignore
   # Ignore transient state, keep valuable artifacts
   */plan.md        # Ignore running state? (Decision needed: usually keep for resumption)
   */inbox/*        # User inputs
   !*/artifacts/    # KEEP outputs
   ```
3. Copies `AGENTS.md` template to root if missing.

---

## 5. Workflow Example: The "Dark Mode" Loop

1.  **Input**: User creates `ralph-wiggum/product/inbox/dump.md`: "We need dark mode."
2.  **Product**: Runs, reads inbox, writes `ralph-wiggum/ideas/dark-mode.md`.
3.  **Architect**: Runs, reads idea, writes `ralph-wiggum/specs/dark-mode.md`.
4.  **Code**: User initializes `ralph-wiggum/code/plan.md` pointing to the spec. Agent runs, edits `src/`.
5.  **Review**: Runs, checks `src/` against spec, writes `ralph-wiggum/review/artifacts/report.md`.

---

## 6. Migration Plan (Inspect Repo)

To migrate the existing `inspect` repository:

1.  `mkdir -p ralph-wiggum/{research,discover}/{inbox,artifacts}`
2.  `mv questions/technical-spikes.md ralph-wiggum/research/inbox/`
3.  `mv discoveries/* ralph-wiggum/discover/artifacts/`
4.  `mv knowledge/* ralph-wiggum/research/artifacts/`
5.  `mv DISCOVERY_PLAN.md ralph-wiggum/discover/plan.md`
6.  `mv RESEARCH_PLAN.md ralph-wiggum/research/plan.md`
7.  **Crucial**: Update `config.sh` in the `ralphus` variants repo to support this pathing.

