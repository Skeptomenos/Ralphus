---
name: ralphus-local
description: "Prepare any repository for Ralphus autonomous coding. Scaffolds files, creates isolation branch, and offers to launch the loop in tmux."
triggers:
  - "ralphus local"
  - "run ralphus locally"
  - "start local ralphus"
  - "ralphus-local"
  - "setup ralphus here"
  - "local ralphus"
  - "ralphus on this machine"
  - "prepare ralphus"
  - "prepare ralphus for this"
  - "setup ralphus"
created: 2025-01-13
updated: 2025-01-13
---

# Ralphus Local Orchestrator

**Protocol:** State-Machine Execution.
**Rule:** Always CHECK status first. NEVER assume.

---

## 1. ANALYSIS PHASE (Mandatory First Step)

Run this command immediately to understand the repo state:

```bash
bash ~/.config/opencode/skill/ralphus-local/scripts/status.sh
```

**Output Interpretation:**

| STATUS | Meaning | Action Required |
|--------|---------|-----------------|
| `NOT_GIT_REPO` | Not a git repo | **STOP**. Tell user to init git. |
| `UNPREPARED` | Missing Ralphus files | **ASK**: "Repo not prepared. Run preparation?" |
| `READY` | Prepared, ready to run | **CHECK** `PLAN_COMPLETE` (below). |

**Plan Check (If READY):**
- `PLAN_COMPLETE: false` → **ASK**: "Planning incomplete. Start PLANNING loop?"
- `PLAN_COMPLETE: true` → **ASK**: "Planning complete. Start BUILD loop (Ultrawork)?"

**Session Check:**
- `RUNNING: true` → **STOP**. Report session exists. Tell user to attach (`tmux attach`).

---

## 2. EXECUTION PHASE (On User Confirmation)

**ONLY** execute these after the user confirms the action proposed in Phase 1.

### A. Prepare Repository
```bash
bash ~/.config/opencode/skill/ralphus-local/scripts/prepare.sh
```
*Action: Scaffolds files, creates branch.*

### B. Launch Planning Loop
```bash
bash ~/.config/opencode/skill/ralphus-local/scripts/launch.sh plan
```
*Action: Starts tmux session in PLAN mode.*

### C. Launch Build Loop (Ultrawork)
```bash
bash ~/.config/opencode/skill/ralphus-local/scripts/launch.sh build ultrawork
```
*Action: Starts tmux session in BUILD mode with Ultrawork enabled.*

---

## CRITICAL RULES

1.  **NO AUTO-PILOT**: On first trigger, you MUST run `status.sh` and report to the user. Do NOT auto-launch `launch.sh`.
2.  **ONE LOOP RULE**: If `RUNNING: true`, do NOT start another session.
3.  **TMUX ONLY**: The scripts handle tmux. Do NOT try to run `loop.sh` manually.
