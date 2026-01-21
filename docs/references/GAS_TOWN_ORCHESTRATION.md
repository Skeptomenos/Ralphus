# Gas Town: Agent Orchestration at Scale

> Distilled from [Steve Yegge's "Welcome to Gas Town"](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04) — January 2026

Gas Town represents the next evolution beyond single-agent loops. It's what happens when you need to manage 10-30 Claude Code instances simultaneously.

---

## The Evolution Ladder

Before using Gas Town (or any orchestrator), know where you are:

| Stage | Description | Ready for Orchestration? |
|-------|-------------|--------------------------|
| 1 | Zero/Near-Zero AI (code completions, chat) | No |
| 2 | Agent in IDE, permissions on | No |
| 3 | Agent in IDE, YOLO mode | No |
| 4 | Wide agent in IDE, code just for diffs | No |
| 5 | CLI single agent, YOLO, diffs scroll by | No |
| 6 | CLI multi-agent, 3-5 parallel instances | Maybe |
| 7 | 10+ agents, hand-managed | Yes |
| 8 | Building your own orchestrator | You're already here |

> *"If you're not at least Stage 7, or maybe Stage 6 and very brave, you will not be able to use Gas Town."*

---

## Core Architecture

### The Town & Rigs

```
~/gt/                    # The Town (HQ)
├── gastown/             # Rig 1
├── beads/               # Rig 2  
├── wyvern/              # Rig 3
└── ...                  # More project rigs
```

- **Town**: Your headquarters, manages all workers across all rigs
- **Rigs**: Each project (git repo) under Gas Town management

### The Seven Worker Roles

| Role | Symbol | Scope | Purpose |
|------|--------|-------|---------|
| **Overseer** | 👤 | Town | You, the human. Has an inbox, sends/receives mail |
| **Mayor** | 🎩 | Town | Main agent you talk to. Concierge and chief-of-staff |
| **Deacon** | 🐺 | Town | The daemon beacon. Runs patrol loops, propagates heartbeats |
| **Dogs** | 🐶 | Town | Deacon's personal crew for maintenance and handyman work |
| **Witness** | 🦉 | Rig | Watches over polecats, helps them get unstuck |
| **Refinery** | 🏭 | Rig | Manages the Merge Queue, intelligently merges changes |
| **Polecats** | 😺 | Rig | Ephemeral workers that swarm work and produce MRs |
| **Crew** | 👷 | Rig | Long-lived agents you work with directly (like Mayor but per-rig) |

---

## GUPP: The Propulsion Principle

**Gastown Universal Propulsion Principle:**

> *"If there is work on your hook, YOU MUST RUN IT."*

Every Gas Town worker has a persistent identity (a Bead) with a **hook** where work molecules hang. When a session starts:

1. Agent checks its hook
2. If hooked work exists, start working immediately
3. No waiting for user input

### The GUPP Nudge

Claude Code is sometimes too polite and waits for input. Gas Town works around this:

- Workers get nudged 30-60 seconds after startup
- `gt nudge` sends tmux notifications
- Kicks the worker into reading mail/hook and taking action

---

## The MEOW Stack

**Molecular Expression of Work** — Gas Town's workflow foundation:

```
┌─────────────────────────────────────────────────────────────┐
│                      THE MEOW STACK                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Formulas (TOML)                                            │
│      │ "cook"                                               │
│      ▼                                                       │
│  Protomolecules (templates)                                 │
│      │ "instantiate"                                        │
│      ▼                                                       │
│  Molecules (workflows)                                      │
│      │                                                       │
│      ▼                                                       │
│  Beads (atomic work units)                                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Components

| Layer | Description |
|-------|-------------|
| **Beads** | Atomic work units. Issue-tracker issues in Git (JSON, one per line) |
| **Epics** | Beads with children. Top-down plans with parallel/sequential deps |
| **Molecules** | Workflows chained with Beads. Complex shapes, loops, gates. Turing-complete |
| **Protomolecules** | Templates made of actual Beads. Variable substitution on instantiation |
| **Formulas** | TOML source form for workflows. Composable, "cooked" into protomolecules |
| **Wisps** | Ephemeral Beads. In database but not persisted to Git. Burned after use |

### Example: 20-Step Release Process

Instead of hoping an agent follows 20 steps (they skip steps):

1. Create 20 beads for release steps
2. Chain them together in order
3. Agent walks the chain, one issue at a time
4. Produces activity feed automatically
5. Survives crashes, restarts, interruptions

---

## Nondeterministic Idempotence (NDI)

Gas Town's durability guarantee:

> *"Even though the path is fully nondeterministic, the outcome—the workflow you wanted—eventually finishes, 'guaranteed', as long as you keep throwing agents at it."*

Why it works:
1. **Agent is persistent**: A Bead backed by Git
2. **Hook is persistent**: Also a Bead in Git
3. **Molecule is persistent**: Chain of Beads in Git

If Claude Code crashes:
1. New session starts for this agent role
2. Finds its place in the molecule via GUPP
3. Figures out crash recovery
4. Continues working

---

## Convoys: The Work Order System

Everything rolls up into **Convoys** — Gas Town's ticketing system:

```
┌─────────────────────────────────────────────────────────────┐
│  CONVOY: wy-a7je4 "Add dark mode support"                   │
├─────────────────────────────────────────────────────────────┤
│  Status: In Progress                                         │
│  Tracked Issues:                                             │
│    ├── wy-b2kf8 "Design dark theme colors" ✓                │
│    ├── wy-c3lg9 "Implement CSS variables" ✓                 │
│    ├── wy-d4mh0 "Update component styles" (in progress)     │
│    └── wy-e5ni1 "Add theme toggle" (pending)                │
│  Swarms: 2 completed, 1 active                              │
└─────────────────────────────────────────────────────────────┘
```

- Wraps work into trackable delivery units
- Multiple swarms can "attack" a convoy
- Witness keeps recycling polecats until complete

---

## Patrols: Automated Workflows

Patrol workers run ephemeral workflows in loops:

### Refinery Patrol
1. Preflight cleanup
2. Process Merge Queue until empty
3. Postflight handoff

### Witness Patrol
1. Check polecat wellbeing
2. Check refinery status
3. Peek at Deacon
4. Run rig-level plugins

### Deacon Patrol
1. Run town-level plugins
2. Handle `gt handoff` protocol
3. Ensure worker cleanup
4. Delegate to Dogs for complex work

---

## Key Commands

| Command | Purpose |
|---------|---------|
| `gt sling` | Sling work to workers (goes on their hook) |
| `gt handoff` | Graceful cleanup and restart |
| `gt nudge` | Send real-time tmux notification |
| `gt seance` | Talk to predecessor in role (uses `/resume`) |
| `gt rig add` | Add project to Gas Town management |

---

## Kubernetes Comparison

| Kubernetes | Gas Town |
|------------|----------|
| kube-scheduler | Mayor/Deacon |
| Nodes | Rigs |
| kubelet | Witness |
| Pods | Polecats |
| etcd | Beads |
| "Is it running?" | "Is it done?" |
| Optimizes uptime | Optimizes completion |
| Pods are cattle | Sessions are cattle, agents are persistent |

> *"K8s reconciles toward a continuous desired state; Gas Town proceeds toward a terminal goal."*

---

## Working Style in Gas Town

> *"Work in Gas Town can be chaotic and sloppy... Some bugs get fixed 2 or 3 times, and someone has to pick the winner. Other fixes get lost. Designs go missing and need to be redone. It doesn't matter, because you are churning forward relentlessly on huge, huge piles of work."*

Gas Town optimizes for **throughput**:
- Creation and correction at the speed of thought
- Fish fall out of the barrel—more fish will come
- Not 100% efficient, but *flying*

> *"In Gas Town, you let Claude Code do its thing. You are a Product Manager, and Gas Town is an Idea Compiler."*

---

## Prerequisites & Warnings

**Required**:
- Managing 5+ Claude Code instances daily
- Don't care about money (multiple accounts needed)
- Comfortable with tmux
- Using Beads as the data plane

**Warnings**:
- 3 weeks old (as of Jan 2026)
- 100% vibe coded
- "Industrialized coding factory manned by superintelligent robot chimps"
- "They'll rip your face off if you aren't already an experienced chimp-wrangler"

---

## The Gas Town Levels (Geoffrey's Reference)

In "Everything is a Ralph Loop," Geoffrey Huntley references Steve Yegge's levels:

| Level | Description |
|-------|-------------|
| **Level 8** | Spinning plates and orchestration (Gas Town) |
| **Level 9** | Autonomous loops that evolve products and optimize for revenue |

Level 9 is **evolutionary software**—also known as a **software factory**.

---

## How This Maps to Ralphus

| Gas Town Concept | Ralphus Equivalent |
|------------------|-------------------|
| Town | `~/ralphus/` installation |
| Rigs | Target project repositories |
| Mayor | Interactive `opencode` session |
| Polecats | Subagent delegation via Task tool |
| Witness | The human reviewing progress |
| Refinery | Git commit/merge handling in loop |
| GUPP | Fresh context each iteration + tracking files |
| Molecules | Specs + Implementation Plans |
| Convoys | Feature branches with specs |
| Beads | Tracking file tasks (`- [ ]` items) |

Ralphus is a simpler, earlier-stage approach that shares the same philosophy: persistent work, ephemeral sessions, backpressure-driven quality.

---

## Key Quotes

> *"Claude Code is just a building block. It's going to be all about AI workflows and 'Kubernetes for agents'."*

> *"The focus is throughput: creation and correction at the speed of thought."*

> *"You are a Product Manager, and Gas Town is an Idea Compiler."*

> *"17 days, 75k lines of code, 2000 commits."*

---

## Source

[Welcome to Gas Town](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04) — Steve Yegge, January 1, 2026
