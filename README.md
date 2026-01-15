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

```
┌─────────────────────────────────────────────────────────────┐
│                        VARIANTS                             │
│         (What to do - prompts, templates, loop)             │
├─────────────────┬─────────────────┬─────────────────────────┤
│  ralphus-code   │  ralphus-test   │  ralphus-research       │
│  (features)     │  (tests)        │  (research)             │
└────────┬────────┴────────┬────────┴────────┬────────────────┘
         │                 │                 │
         └────────────┬────┴────────┬────────┘
                      │             │
         ┌────────────▼─────────────▼────────────┐
         │              SKILLS                   │
         │      (Where to run - execution)       │
         ├───────────────────┬───────────────────┤
         │   ralphus-local   │  ralphus-remote   │
         │   (tmux here)     │  (SSH to homelab) │
         └───────────────────┴───────────────────┘
```

**Variants** define *what* to do — the prompts, templates, and loop logic.
**Skills** define *where* to run — local tmux or remote homelab via SSH.

---

## Variants

| Variant | Purpose | Spec Directory | Tracking |
|---------|---------|----------------|----------|
| `ralphus-code` | Implement features from specs | `specs/` | `IMPLEMENTATION_PLAN.md` |
| `ralphus-test` | Create tests from test specs | `test-specs/` | Test spec checkboxes |
| `ralphus-research` | Deep research on topics | `questions/` | `RESEARCH_PLAN.md` |

Each variant contains:
```
variants/ralphus-{name}/
├── README.md           # Variant-specific docs
├── scripts/
│   └── loop.sh         # The eternal loop
├── instructions/
│   ├── PROMPT_plan.md  # Planning phase
│   └── PROMPT_build.md # Execution phase
└── templates/          # Format references
```

---

## Quick Start

### Using a Variant

```bash
# Copy variant to your project
cp -r path/to/ralphus/variants/ralphus-code ./ralphus/ralphus-code

# Create specs directory
mkdir -p specs
echo "# Feature Spec" > specs/my-feature.md

# Run planning phase
./ralphus/ralphus-code/scripts/loop.sh plan

# Run build phase
./ralphus/ralphus-code/scripts/loop.sh
```

### Variant-Specific Usage

**ralphus-code** (feature implementation):
```bash
./ralphus/ralphus-code/scripts/loop.sh plan    # Generate IMPLEMENTATION_PLAN.md
./ralphus/ralphus-code/scripts/loop.sh         # Build features
```

**ralphus-test** (test creation):
```bash
./ralphus/ralphus-test/scripts/loop.sh plan    # Prepare test spec with checkboxes
./ralphus/ralphus-test/scripts/loop.sh         # Create tests one by one
```

**ralphus-research** (deep research):
```bash
./ralphus/ralphus-research/scripts/loop.sh plan   # Create research plan
./ralphus/ralphus-research/scripts/loop.sh        # Execute research
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
├── AGENTS.md                    # Template for target projects
├── CHANGELOG.md
│
├── docs/                        # Documentation
│   ├── ULTRAWORK.md             # Ultrawork philosophy
│   ├── LOOP_VARIANTS.md         # Variant concept paper
│   └── references/              # Research materials
│
├── variants/                    # Loop variants (WHAT to do)
│   ├── ralphus-code/            # Feature implementation
│   ├── ralphus-test/            # Test creation
│   └── ralphus-research/        # Deep research
│
└── skills/                      # Execution modes (WHERE to run)
    ├── ralphus-local/           # Local tmux execution
    └── ralphus-remote/          # Homelab SSH execution
        └── config/
            └── project-mappings.json
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

---

## License

MIT — Do whatever you want. Ralphus certainly will.

---

<p align="center">
  <i>"I bent my Wookiee."</i><br>
  — Ralphus, after a particularly aggressive refactor
</p>
