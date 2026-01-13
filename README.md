<!-- Tested by MyInspect session -->

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

**Ralphus** is their offspring. A playbook for autonomous development that combines:
- Ralph's "just keep looping" philosophy
- Sisyphus's "I will not stop until the tests pass" determination
- The shared delusion that eventually, the code will be complete

---

## How It Works

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
2. **Reads the plan** (IMPLEMENTATION_PLAN.md) to figure out what's happening
3. **Picks the most important task** (like Ralph picking his nose, but productive)
4. **Implements it** using parallel subagents (Sisyphus delegates, he's learned)
5. **Runs tests** (backpressure — the boulder fights back)
6. **Commits** (the boulder reaches the top!)
7. **Context clears** (the boulder rolls back down)
8. **Repeat** (one must imagine Sisyphus happy)

---

## The Philosophy

### "Let Ralphus Ralphus"

Don't micromanage. The loop is self-correcting. If Ralphus goes in circles, that's just him warming up. Eventually, through sheer persistence and the heat death of your API budget, features will emerge.

### "The Plan is Disposable"

Wrong plan? Delete it. Regenerate. The cost of one planning loop is nothing compared to Ralphus implementing the wrong thing 47 times.

> *"My cat's breath smells like cat food."* — Ralph, on technical debt

### "Context is Precious"

200K tokens sounds like a lot until Ralphus loads your entire codebase and forgets why he's there. Keep tasks small. Keep specs focused. Keep Sisyphus in the "smart zone" (40-60% context utilization).

### "Backpressure is Love"

Tests that fail are not obstacles. They are Sisyphus's boulder. They give his existence meaning. Without failing tests, what would he push against?

---

## Quick Start

### Prerequisites

- [OpenCode](https://opencode.ai) with Sisyphus agent installed
- A project with specs in `specs/*.md`
- The will to let go and trust the loop

### Installation

```bash
# Clone Ralphus
git clone https://github.com/Skeptomenos/Ralphus.git
cd your-project

# Copy the essentials from the skill folder
cp ~/Repos/ralphus/skill/ralphus/scripts/loop.sh .
cp ~/Repos/ralphus/skill/ralphus/instructions/PROMPT_plan.md .
cp ~/Repos/ralphus/skill/ralphus/instructions/PROMPT_build.md .

# Make it executable
chmod +x loop.sh
```

### Install the Skill (for remote homelab execution)

```bash
# Copy skill to OpenCode config
cp -r ~/Repos/ralphus/skill/ralphus ~/.config/opencode/skill/ralphus
```

### Running Ralphus

```bash
# Phase 1: Let Ralphus understand what needs to be built
./loop.sh plan

# Phase 2: Let Ralphus build it
./loop.sh

# Phase 3: Go touch grass. Ralphus has this.
```

### Stopping Ralphus

```bash
# Gentle (Ctrl+C)
# Ralphus will finish current task and stop

# Nuclear
pkill -f opencode
git reset --hard  # Undo whatever chaos occurred
```

---

## The Loop

### Minimal Form (The OG Ralph)

```bash
while :; do cat PROMPT.md | opencode run --agent Sisyphus; done
```

### Enhanced Form (Ralphus)

```bash
./loop.sh              # Build mode, unlimited iterations
./loop.sh 20           # Build mode, max 20 iterations  
./loop.sh plan         # Planning mode
./loop.sh plan 5       # Planning mode, max 5 iterations
./loop.sh ultrawork    # Ultrawork mode (aggressive parallel agents)
./loop.sh ulw 10       # Ultrawork mode, max 10 iterations
```

**Ultrawork mode** appends "ulw" to the agent message, triggering Sisyphus's aggressive parallelism: multiple background explore agents, 5+ simultaneous tool calls, and proactive context cleanup.

### Completion Detection

Ralphus knows when to stop (unlike his namesakes):

```markdown
When ALL tasks are complete, output:
<promise>COMPLETE</promise>

When stuck and need human help:
<promise>BLOCKED:[task]:[reason]</promise>
```

---

## File Structure

### Your Project (after setup)
```
your-project/
├── loop.sh                    # The eternal loop
├── PROMPT_plan.md             # "Figure out what to build"
├── PROMPT_build.md            # "Build the thing"
├── AGENTS.md                  # Project-specific (yours, not copied)
├── IMPLEMENTATION_PLAN.md     # The boulder (generated by Ralphus)
├── specs/                     # What success looks like
│   ├── auth.md
│   └── dashboard.md
└── src/                       # Where the code goes
```

### Ralphus Repository
```
ralphus/
└── skill/
    └── ralphus/
        ├── SKILL.md               # Homelab remote execution skill
        ├── config/
        │   ├── oh-my-opencode.json
        │   └── project-mappings.json
        ├── instructions/
        │   ├── PROMPT_build.md
        │   └── PROMPT_plan.md
        ├── scripts/
        │   └── loop.sh
        └── templates/
            └── IMPLEMENTATION_PLAN.md
```

---

## Remote Execution (Homelab)

Ralphus can run on a remote server while you sleep. Because Sisyphus never sleeps.

```bash
# Push local changes and spawn Ralphus on homelab
"Push and run ralphus for canvas"

# Check on him
"How is ralphus doing?"

# He's been at it for 6 hours, give him a break
"Stop ralphus"
```

Use the `/ralphus` skill for full remote orchestration (triggers: "run ralphus on homelab", "ralphus progress", "stop ralphus").

---

## Troubleshooting

| Symptom | Diagnosis | Treatment |
|---------|-----------|-----------|
| Ralphus implementing same thing twice | "Don't assume not implemented" guardrail missing | Add to prompt |
| Ralphus in infinite loop | Tests always failing | Fix the tests, not Ralphus |
| Ralphus went silent | Context exhaustion | Reduce task size |
| Ralphus committed crimes against architecture | Plan was wrong | Delete plan, re-run planning |
| Ralphus ate paste | That's just Ralph | Let him cook |

---

## The Guardrails

Ralphus uses numbered guardrails to ensure critical rules are never forgotten:

```markdown
99999. Capture the why in documentation
999999. Single sources of truth, no adapters
9999999. Tag releases when tests pass
99999999. Keep IMPLEMENTATION_PLAN.md current
999999999. Update AGENTS.md with operational learnings
9999999999. Resolve or document bugs, even unrelated ones
99999999999. No placeholders. No stubs. Complete implementations only.
```

The higher the number, the more important. It's like Ralph counting — he might not get far, but he remembers the big ones.

---

## Credits & Lineage

This project stands on the shoulders of giants (and one paste-eating child):

- **Geoffrey Huntley** ([@GeoffreyHuntley](https://x.com/GeoffreyHuntley)) — The mad genius who realized a dumb loop could replace a dev team. Created the original [Ralph methodology](https://ghuntley.com/ralph/).
- **Clayton Farr** ([@ClaytonFarr](https://github.com/ClaytonFarr)) — Who systematized Ralph into the excellent [ralph-playbook](https://github.com/ClaytonFarr/ralph-playbook) that this project is forked from.
- **Sisyphus** — The OpenCode agent who rolls the boulder so you don't have to.
- **Ralph Wiggum** — For teaching us that persistence beats intelligence.

### What's Different Here?

Ralphus adapts the ralph-playbook for **OpenCode** (instead of Claude Code) and adds:

- **Sisyphus integration** — OpenCode's agent system with oh-my-opencode
- **Completion signals** — `<promise>COMPLETE</promise>` for clean loop termination
- **Homelab remote execution** — Run Ralphus on a server via SSH/tmux
- **Archive mechanism** — Preserve state when switching branches
- **Error recovery** — Blocked task detection and documentation

See [PLAN.md](PLAN.md) for the full adaptation roadmap.

---

## Philosophy Corner

> *"The struggle itself toward the heights is enough to fill a man's heart."*
> — Albert Camus, The Myth of Sisyphus

> *"Me fail English? That's unpossible!"*
> — Ralph Wiggum, on debugging

Both are valid approaches to software development.

---

## License

MIT — Do whatever you want. Ralphus certainly will.

---

<p align="center">
  <i>"I bent my Wookiee."</i><br>
  — Ralphus, after a particularly aggressive refactor
</p>
