# Ralphus Gap Analysis & Roadmap

> Assessment of Ralphus against the [Ralph Loop Philosophy](references/RALPH_LOOP_PHILOSOPHY.md) and [Gas Town Orchestration](references/GAS_TOWN_ORCHESTRATION.md).

**Current Status**: Stage 5-6 (CLI Multi-Agent, Hand-Managed)
**Target Status**: Stage 7-8 (Orchestrated Factory)

---

## 1. Assessment: What is Good (On Track)

### A. Core Loop Architecture
The `lib/loop_core.sh` is fundamentally sound and aligns with the philosophy:
- **"300 lines in a loop"**: The shared library is ~370 lines, hitting the sweet spot of complexity vs maintainability.
- **One task per iteration**: Correctly uses `PHASE_COMPLETE` signals and atomic commits.
- **Fresh context**: Launches a new `opencode` process every iteration, preventing context pollution.
- **Graceful shutdown**: Handles `SIGINT`/`SIGTERM` to finish current iterations before stopping.
- **Persistence**: Work is tracked in git-backed files (`IMPLEMENTATION_PLAN.md`), sessions are ephemeral.

### B. Signal System
The completion signal hierarchy is well-designed and maps to "exhaustion conditions":
- `PHASE_COMPLETE` → Continue (one task done)
- `COMPLETE` → Exit success (all done)
- `BLOCKED` → Exit failure (stuck)
- `APPROVED` → Exit success (review-specific)

### C. Guardrails
The numbered guardrail system (99999, 999999) is effective for LLM prioritization:
- **File Ownership**: Prevents agents from "cleaning up" tracking files.
- **No Placeholders**: Enforces complete implementation.
- **Documentation**: Mandates documenting the "why".

### D. The Factory Pipeline
The roles match Geoffrey's vision of a software factory:
- **Product** (Slicer) → `inbox/` to `ideas/`
- **Architect** (Spec) → `ideas/` to `specs/`
- **Builder** (Code) → `specs/` to Code
- **Auditor** (Review) → Code to `reviews/`
- **Fixer** (Triage) → `reviews/` to `specs/review-fixes.md`

### E. Backpressure Implementation
- **Code**: Enforced via tests and Oracle fallback.
- **Review**: Severity prioritization (Critical > High > Medium).
- **Research**: Quiz validation with >80% threshold (excellent implementation of self-quiz pattern).
- **Discover**: Exhaustion counter (3 iterations with 0 follow-ups).

---

## 2. Assessment: What Needs Improvement

### A. Core Architecture Gaps

#### 1. Missing GUPP (Universal Propulsion Principle)
**The Gap**: Agents don't "self-nudge" or automatically resume interrupted work. If opencode stops mid-iteration (context exhaustion, crash), the loop just blindly moves to the next iteration without checking if the previous task was truly done.
**Impact**: Work loss, manual intervention required, loss of autonomy.
**Gas Town Reference**: *"If there is work on your hook, YOU MUST RUN IT."*
**Recommendation**: Add a "hook check" at iteration start to validate tracking file state.

#### 2. No Molecule/Workflow Chaining (Convoys)
**The Gap**: Each variant runs in isolation. You manually run `product` → `architect` → `code`. No way to define a "feature convoy" that runs the whole pipeline overnight.
**Impact**: Humans must act as the manual glue between stages. Limits "while you sleep" productivity.
**Gas Town Reference**: *"A Convoy is a special bead that wraps a bunch of work into a unit that you track for delivery."*
**Recommendation**: Create a `ralphus convoy` command to orchestrate variant sequencing.

#### 3. No Tracking for Architect
**The Gap**: `ralphus-architect` has `TRACKING_FILE=""`. It operates as a stateless file iterator.
**Impact**: No visibility into progress, no history of what was spec'd, hard to resume if interrupted. Violates "persistent work" principle.
**Ralph Reference**: *"All work is expressed as molecules... each step executed by AI."*
**Recommendation**: Add `ARCHITECT_PLAN.md` to track ideas processed and specs generated.

#### 4. Product Variant Divergence
**The Gap**: `ralphus-product` implements its own 190-line `run_sequential()` instead of using the shared `run_loop()`.
**Impact**: Maintenance burden, feature drift, lacks standard signal handling and git safety.
**Engineering Principle**: DRY (Don't Repeat Yourself) violation.
**Recommendation**: Refactor to use `run_loop()` with a "single-iteration" or iterator pattern.

#### 5. No Witness/Patrol Pattern
**The Gap**: No monitoring agent to watch over the loop. If an agent spins (same error 3x) or gets stuck, only `BLOCKED` signal or human intervention helps.
**Impact**: Loops can burn tokens uselessly on infinite errors.
**Gas Town Reference**: *"The Witness patrols help smooth this out so it's almost perfect."*
**Recommendation**: Implement a `ralphus-witness` variant to monitor and restart stuck loops.

#### 6. Missing Real-Time Messaging/Signals
**The Gap**: Variants are completely isolated silos. Review findings require manual handoff to Architect. No way for Review to tell Code "I'm done".
**Impact**: High latency between stages.
**Gas Town Reference**: *"All Gas Town workers... have mail inboxes."*
**Recommendation**: Implement a file-based signal bus in `signals/`.

#### 7. No Dashboard/Activity Feed
**The Gap**: No visibility into what's happening across variants. You have to `tail -f` multiple logs or tmux panes.
**Impact**: Hard to manage more than 2-3 variants. "Where is my feature?" is hard to answer.
**Gas Town Reference**: *"The focus is throughput... Convoys show up in a dashboard."*
**Recommendation**: Create `ralphus status` to aggregate state from all tracking files.

#### 8. Ultrawork Integration is Shallow
**The Gap**: Ultrawork mode just appends "ulw" to the message string. It doesn't change loop behavior.
**Impact**: Misses the opportunity for deeper focus or batching in ultrawork sessions.
**Recommendation**: Ultrawork should increase iteration limits and enable batch processing.

---

## 3. Assessment: What is Missing

### 1. No Swarm/Polecat Support
**The Gap**: Ralphus is strictly single-agent per variant. No parallelization.
**Gas Town Reference**: *"Polecats are ephemeral per-rig workers that spin up on demand."*
**Impact**: Throughput is limited to one serial stream of thought.

### 2. No Merge Queue/Refinery
**The Gap**: When multiple variants produce changes, manual merging is required.
**Gas Town Reference**: *"The Refinery: the engineer agent responsible for intelligently merging all changes."*
**Impact**: Race conditions if running parallel loops (e.g., Code + Review).

### 3. No Oracle Tool Integration
**The Gap**: Prompts mention "Consult Oracle" but there's no actual Oracle tool or MCP server.
**Workshop Reference**: *"The Oracle is just GPT wired in as a tool that Claude Sonnet can function call for guidance."*
**Impact**: Agents lack a high-reasoning fallback when stuck.

### 4. No Formulas/Protomolecules
**The Gap**: Workflows are hardcoded in prompts, not composable templates.
**Gas Town Reference**: *"Formulas provide a way for you to describe and compose pretty much all knowledge work."*
**Impact**: Hard to share or evolve workflow patterns without editing prompts.

---

## 4. Quick Wins (High Value, Low Effort)

These can be implemented immediately to improve quality at current Stage 5-6.

| Task | Description | Value |
|------|-------------|-------|
| **Add ARCHITECT_PLAN.md** | Modify `ralphus-architect/config.sh` to use a tracking file. Log every idea processed and spec generated. | **High** - Visibility & Resume capability |
| **GUPP-Lite Check** | Add `check_unfinished_work()` to `lib/loop_core.sh`. Warn or pause if tracking file shows incomplete tasks at start. | **High** - Prevents work loss |
| **Unified Status Command** | Create `bin/ralphus-status` script that greps `ITERATION` and tracking files across all active loops. | **High** - Visibility |
| **Review Signal Hand-off** | Update `ralphus-review` post-hook to touch a `signals/review-complete` file. Update `architect` to watch for it. | **Med** - Basic coordination |
| **Standardize Product Loop** | Refactor `ralphus-product` to use `run_loop()` with a `SEQUENTIAL=1` flag in the library. | **Med** - Maintainability |

---

## 5. Improving Quality at Stage 5-6

To maximize the current "Hand-Managed" stage before full orchestration:

### A. Deepen Backpressure
- **Pre-commit Hooks**: Add `prek` or similar to the loop. If lint fails, commit is rejected, agent fixes it immediately.
- **Test-Driven Loop**: Enforce "Test First" in `ralphus-code` prompt. Agent must commit failing test before implementation.
- **Oracle Integration**: Add a dedicated skill for "Oracle Consultation" (using Opus/reasoning model) for complex blocking issues.

### B. Strengthen Guardrails
- **Reference Check**: Add a pre-flight check in `loop_core.sh` that verifies `*_REFERENCE.md` files haven't been modified by agents (a common failure mode).
- **Anti-Hallucination**: Update prompts to explicitly forbid inventing libraries. Require `glob` search before import.

### C. Enhance Visibility
- **Iteration Summaries**: Update `post_iteration` hook to append a one-line summary to a `HISTORY.md` log.
- **Tmux Integration**: Add helper scripts to set up a standard tmux layout (4 panes: code, review, architect, status).

---

## 6. Visionary Roadmap: Reaching Stage 7-8

To reach the "Orchestrated Software Factory" (Gas Town) level:

### Phase 1: Connectivity (The Roads)
- **Signal Bus**: Implement a file-based event bus in `signals/`.
- **Mailboxes**: Give each variant an `inbox/` (Beads-lite).
- **Global Config**: Central `RALPHUS_CONFIG.md` defining the topology.

### Phase 2: Orchestration (The Traffic Lights)
- **Convoy Command**: `ralphus convoy <feature>` command that orchestrates the sequence.
- **Dependency Graph**: Ability to say "Code waits for Architect which waits for Product".
- **Refinery**: A dedicated merge-queue agent that handles the git chaos of multiple variants.

### Phase 3: Autonomy (The City)
- **Witness Agent**: A always-on monitor that restarts stuck loops and reallocates resources.
- **Self-Healing**: Tests fail → Witness sees it → Dispatch Code agent → Fix → Verify.
- **Continuous Evolution**: Agents updating their own prompts (with strict oversight) based on learnings.

---

## 7. Summary

We are currently **manual operators of powerful tools** (Stage 5-6). 
We want to become **city planners** (Stage 7-8).

The bridge is **Orchestration**:
1. **Tracking** (Know what is happening)
2. **Signaling** (Let parts talk to each other)
3. **Chaining** (Automate the sequence)

Let's start with the **Quick Wins** to stabilize our current level, then build the **Roads** (Phase 1) for the future city.
