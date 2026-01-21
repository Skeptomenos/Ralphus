# Ralphus

> *"I'm learnding!" — Ralph Wiggum*
>
> *"One must imagine Sisyphus happy." — Albert Camus*

**Ralphus** is what happens when Ralph Wiggum meets Sisyphus. One keeps pushing the boulder. The other eats paste and somehow ships production code.

Together, they are unstoppable. Mostly because neither knows when to quit.

---

## The Legend

In the beginning, there was **Ralph** — Geoffrey Huntley's autonomous coding loop that reduced software development costs to less than a fast food worker's wage. Ralph was simple. Ralph was dumb. Ralph worked.

```bash
while :; do cat PROMPT.md | claude; done
```

Then came **Sisyphus** — the OpenCode agent cursed to roll context windows uphill for eternity. Every iteration, the context clears. Every iteration, Sisyphus reads the plan anew. Every iteration, he pushes the boulder a little further.

*One must imagine Sisyphus shipping features.*

**Ralphus** is their offspring. A meta-framework for autonomous development loops.

---

## Architecture

**The Ralph-Wiggum Standard:** All projects follow a unified directory structure for agent state.

```
project_root/
├── AGENTS.md                   # The Constitution (Global Rules)
├── src/                        # The Product (Codebase)
└── ralph-wiggum/               # The Factory Floor
    ├── memory/                 # Global Context (Shared)
    ├── ideas/                  # Conveyor: Product -> Architect
    ├── specs/                  # Conveyor: Architect -> Code
    ├── [variant]/              # Agent Workspaces
    │   ├── plan.md             # The Brain
    │   ├── inbox/              # User Input
    │   └── artifacts/          # Agent Output
```

See [docs/RALPH_WIGGUM_ARCHITECTURE.md](docs/RALPH_WIGGUM_ARCHITECTURE.md) for the full spec.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              VARIANTS                                   │
│             (What to do - prompts, templates, thin wrapper)             │
├──────────────────┬──────────────────┬──────────────────┬────────────────┤
│  ralphus-code    │  ralphus-test    │ ralphus-research │ ralphus-discover│
│  (features)      │  (tests)         │ (learning)       │ (onboarding)   │
└────────┬─────────┴────────┬─────────┴────────┬─────────┴────────┬───────┘
         │                 │                 │                 │
         └─────────────────┴────────┬────────┴─────────────────┘
                                    │
                        ┌───────────▼───────────┐
                        │    lib/loop_core.sh   │
                        │   (Shared Library)    │
                        └───────────┬───────────┘
                                    │
         ┌──────────────────────────┴──────────────────────────┐
         │                        SKILLS                       │
         │               (Where to run - execution)             │
         ├──────────────────────────┬──────────────────────────┤
         │       ralphus-local      │      ralphus-remote      │
         │       (tmux here)        │      (SSH to homelab)    │
         └──────────────────────────┴──────────────────────────┘
```

**Variants** define *what* to do — configuration, prompts, and templates. They are thin wrappers around the **Modular Loop Library** (`lib/loop_core.sh`).
**Skills** define *where* to run — local tmux or remote homelab via SSH.

---

## The Ralphus Factory

The complete autonomous software factory pipeline:

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
       │                      │
       ▼                      ▼
┌──────────────┐      ┌───────────────┐
│              │      │               │
│ reviews/*.md │      │ IMPLEMENTATION│
│              │      │ _PLAN.md      │
└──────────────┘      └───────────────┘
       │
       ▼
┌───────────────┐     ┌───────────────┐
│               │     │               │
│ ralphus       │────▶│ ralphus       │
│ architect     │     │ code          │
│ triage        │     │ (Fix Bugs)    │
└───────────────┘     └───────────────┘
```

### Roles & Responsibilities

| Role | Variant | Input | Output | Purpose |
|------|---------|-------|--------|---------|
| **Product** | `ralphus-product` | `inbox/` | `prds/` | Slice messy ideas into atomic PRDs. |
| **Architect** | `ralphus-architect` | `prds/` | `specs/` | Research feasibility and write rigorous specs. |
| **Builder** | `ralphus-code` | `specs/` | Code | Implement features and pass tests. |
| **Auditor** | `ralphus-review` | Code | `findings/` | Check security, style, and correctness. |
| **Fixer** | `ralphus-architect` | `findings/` | `specs/review-fixes.md` | Triage findings. |

---

## Task Batching

Ralphus uses a **grouped task strategy** to maximize efficiency. Instead of atomic per-function tasks, implementation plans are batched by **testable deliverables**.

- **Target**: 15-25 tasks per feature.
- **Efficiency**: Reduces iteration overhead and git tag noise.
- **Results**: Recent factory runs achieved **12x faster** completion times.

See [AGENTS.md](AGENTS.md) for task grouping heuristics.

---

## Lessons Learned & Gotchas

### 1. Template Name Collisions (Shadowing)
**Problem**: If a central template has the same name as a project file (e.g., `IMPLEMENTATION_PLAN.md`), the agent will prioritize the attached template and "lose" the project's actual progress.
**Fix**: All central templates must end in `_REFERENCE.md`.

### 2. Recursive Organization Trap
**Problem**: Autonomous agents may try to "clean up" the root by moving tracking files into subdirectories (e.g., moving `IMPLEMENTATION_PLAN.md` to `docs/planning/`), which breaks the loop logic.
**Fix**: Every variant includes a high-priority "File Ownership" guardrail preventing this behavior.

### 3. Directory Context
**Problem**: Scripts can get confused between the Ralphus installation and the project working directory.
**Fix**: Always use `SCRIPT_DIR` for internal Ralphus files and `$WORKING_DIR` (set via `RALPHUS_WORKING_DIR`) for project files. Ensure the script `cd`s to the project root at startup.

### 4. Modular Loop Pattern
The loop logic is centralized in `lib/loop_core.sh`. Each variant is a thin wrapper:
```
variants/ralphus-{name}/
├── config.sh           # REQUIRED: Static configuration
├── README.md           # REQUIRED: Variant documentation
├── scripts/
│   └── loop.sh         # Thin wrapper sourcing lib/loop_core.sh
├── instructions/
│   ├── PROMPT_plan.md  # Planning phase
│   └── PROMPT_build.md # Execution phase
└── templates/          # Format references (*_REFERENCE.md)
```

---

## Prerequisites

- [OpenCode](https://github.com/opencode-ai/opencode) installed
- [tmux](https://github.com/tmux/tmux) installed (`brew install tmux`)
- Sisyphus agent configured (or set `RALPH_AGENT` to your preferred agent)
- Git repository initialized in your project

## Quick Start (Central Execution)

The recommended way to use Ralphus is with **central execution** — one installation, use from any project.

### 1. Install Ralphus

```bash
# Clone the repo (default location)
git clone https://github.com/Skeptomenos/Ralphus.git ~/ralphus

# Install the wrapper command
cp ~/ralphus/bin/ralphus ~/.local/bin/
chmod +x ~/.local/bin/ralphus

# Verify installation
ralphus help
```

**Custom location?** If you clone elsewhere (e.g., `~/Repos/ralphus`), add to your `~/.zshrc`:
```bash
export RALPHUS_HOME="$HOME/Repos/ralphus"
```

### 2. Use From Any Project

```bash
cd ~/my-project

# Create specs directory
mkdir -p specs
echo "# My Feature" > specs/feature.md

# Run Ralphus
ralphus code plan      # Generate implementation plan
ralphus code           # Run build loop
ralphus code ulw 20    # Ultrawork mode, max 20 iterations
```

### Available Commands

| Command | Purpose | Required Directory |
|---------|---------|-------------------|
| `ralphus product` | Brain dump slicing | `ralph-wiggum/product/inbox/` |
| `ralphus architect` | Spec generation | `ralph-wiggum/prds/` |
| `ralphus code` | Feature implementation | `ralph-wiggum/specs/` |
| `ralphus test` | Test creation | `test-specs/` |
| `ralphus review` | Code review | (none) |
| `ralphus research` | Deep learning | `ralph-wiggum/research/inbox/` |
| `ralphus discover` | Codebase understanding | `ralph-wiggum/discover/inbox/` |
| `ralphus synthesis` | Documentation assembly | `ralph-wiggum/[variant]/artifacts/` |

### How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           YOUR PROJECT                                  │
│                         (current directory)                             │
├─────────────────────────────────────────────────────────────────────────┤
│  ralph-wiggum/                                                          │
│    specs/                  <- Your specifications                       │
│    code/plan.md            <- Generated here                            │
│  src/                      <- Your source code                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ ralphus code plan
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         ~/ralphus/variants/                             │
│                         (central storage)                               │
├─────────────────────────────────────────────────────────────────────────┤
│  Prompts, templates, and loop logic                                     │
│  Shared across all your projects                                        │
└─────────────────────────────────────────────────────────────────────────┘
```

See [docs/CENTRAL_EXECUTION.md](docs/CENTRAL_EXECUTION.md) for full details.

---

## Alternative: Copy Variant to Project

If you prefer self-contained projects:

```bash
# Copy the variant you need
mkdir -p ./ralphus
cp -r ~/ralphus/variants/ralphus-code ./ralphus/ralphus-code

# Run directly
./ralphus/ralphus-code/scripts/loop.sh plan
./ralphus/ralphus-code/scripts/loop.sh
```

---

## The Ralphus Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                         THE RALPHUS CYCLE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│    ┌──────────┐     ┌──────────┐     ┌──────────┐              │
│    │  Study   │────▶│  Build   │────▶│  Commit  │              │
│    │  Specs   │     │  Thing   │     │  Thing   │              │
│    └──────────┘     └──────────┘     └──────────┘              │
│         ▲                                  │                    │
│         │                                  │                    │
│         │         ┌──────────┐             │                    │
│         └─────────│  Fresh   │◀────────────┘                    │
│                   │ Context  │                                  │
│                   │ (forget) │                                  │
│                   └──────────┘                                  │
│                                                                 │
│    "I choo-choo-choose to implement this feature!"             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

Each iteration:
1. **Sisyphus wakes up** with no memory of previous iterations
2. **Reads the plan** to figure out what's happening
3. **Picks the next task** from the tracking file
4. **Implements it** using parallel subagents
5. **Runs tests** (backpressure)
6. **Commits** and marks complete
7. **Context clears** — loop repeats

---

## Skills (Execution Modes)

Skills define *where* Ralphus runs. They invoke variants.

### ralphus-local

Run any variant locally in tmux:
```bash
"Run ralphus-test locally for account-management"
```

### ralphus-remote

Run any variant on homelab via SSH:
```bash
"Run ralphus-code on homelab for canvas"
"How is ralphus doing?"
"Stop ralphus"
```

---

## Repository Structure

```
ralphus/
├── README.md
├── AGENTS.md                    # Operational playbook
├── CHANGELOG.md
│
├── bin/
│   └── ralphus                  # Central execution wrapper
│
├── lib/
│   └── loop_core.sh              # Shared Modular Loop Library
│
├── docs/                        # Documentation
│   ├── MODULAR_ARCHITECTURE.md   # Shared library documentation
│   ├── VARIANT_BLUEPRINT.md     # Template for creating new variants
│   ├── CENTRAL_EXECUTION.md     # Central execution architecture
│   ├── LOOP_VARIANTS.md         # Variant concept paper
│   ├── ULTRAWORK.md             # Ultrawork philosophy
│   └── references/              # Research materials
│
├── variants/                    # Loop variants (WHAT to do)
│   ├── ralphus-code/            # Feature implementation
│   ├── ralphus-test/            # Test creation
│   ├── ralphus-review/          # Code review
│   ├── ralphus-product/         # PM (Slicer)
│   ├── ralphus-architect/       # Tech Lead (Spec)
│   ├── ralphus-research/        # Deep research
│   └── ralphus-discover/        # Codebase understanding
│
└── skills/                      # Execution modes (WHERE to run)
    ├── ralphus-local/           # Local tmux execution
    └── ralphus-remote/          # Homelab SSH execution
```

---

## The Philosophy

### "Let Ralphus Ralphus"

Don't micromanage. The loop is self-correcting. If Ralphus goes in circles, that's just him warming up.

### "The Plan is Disposable"

Wrong plan? Delete it. Regenerate. The cost of one planning loop is nothing compared to implementing the wrong thing 47 times.

### "Context is Precious"

200K tokens sounds like a lot until Ralphus loads your entire codebase and forgets why he's there. Keep tasks small. Keep specs focused.

### "Backpressure is Love"

Tests that fail are not obstacles. They are Sisyphus's boulder. They give his existence meaning.

---

## Completion Signals

Ralphus knows when to stop:

```markdown
When ALL tasks are complete:
<promise>COMPLETE</promise>

When one phase/task is done (loop continues):
<promise>PHASE_COMPLETE</promise>

When stuck and need human help:
<promise>BLOCKED:[task]:[reason]</promise>
```

---

## Credits & Lineage

- **Geoffrey Huntley** ([@GeoffreyHuntley](https://x.com/GeoffreyHuntley)) — Created the original [Ralph methodology](https://ghuntley.com/ralph/)
- **Clayton Farr** ([@ClaytonFarr](https://github.com/ClaytonFarr)) — Systematized Ralph into [ralph-playbook](https://github.com/ClaytonFarr/ralph-playbook)
- **Sisyphus** — The OpenCode agent who rolls the boulder so you don't have to
- **Ralph Wiggum** — For teaching us that persistence beats intelligence
- **Opencode** — For providing the autonomous execution substrate

---

## License

MIT — Do whatever you want. Ralphus certainly will.

---

<p align="center">
  <i>"I bent my Wookiee."</i><br>
  — Ralphus, after a particularly aggressive refactor
</p>


---

## License

MIT — Do whatever you want. Ralphus certainly will.

---

<p align="center">
  <i>"I bent my Wookiee."</i><br>
  — Ralphus, after a particularly aggressive refactor
</p>
