---
name: ralphus-remote
description: "Manage Ralphus autonomous coding loops on the homelab server. Spawn, monitor, attach, and control long-running Ralphus sessions via SSH and tmux. Supports multiple concurrent sessions."
triggers:
  - "run ralphus on homelab"
  - "start ralphus remotely"
  - "push and run ralphus"
  - "sync and spawn ralphus"
  - "check ralphus status"
  - "how is ralphus doing"
  - "ralphus progress"
  - "stop ralphus"
  - "ralphus remote"
  - "ralphus on homelab"
  - "remote ralphus"
  - "ralphus on server"
  - "prepare ralphus on remote"
  - "prepare ralphus remotely"
created: 2025-01-10
updated: 2025-01-13
---

# Ralphus Remote Orchestrator

**Protocol:** State-Machine Execution via SSH.
**Rule:** Always CHECK status first. NEVER assume.

**Remote Path:** `~/Repos/ralphus/skills/ralphus-remote/scripts/` (Scripts exist on server)

---

## 1. ANALYSIS PHASE (Mandatory First Step)

Run this command immediately to understand the repo state on the remote server:

```bash
# Replace {project_path} with the actual path (e.g., /docker/my-project)
ssh homelab "bash ~/Repos/ralphus/skills/ralphus-remote/scripts/status.sh {project_path}"
```

**Output Interpretation:**

| STATUS | Meaning | Action Required |
|--------|---------|-----------------|
| `NOT_GIT_REPO` | Not a git repo | **STOP**. Tell user to init git on remote. |
| `UNPREPARED` | Missing Ralphus files | **ASK**: "Remote repo not prepared. Run preparation?" |
| `READY` | Prepared, ready to run | **CHECK** `PLAN_COMPLETE` (below). |

**Plan Check (If READY):**
- `PLAN_COMPLETE: false` → **ASK**: "Planning incomplete. Start PLANNING loop?"
- `PLAN_COMPLETE: true` → **ASK**: "Planning complete. Start BUILD loop (Ultrawork)?"

**Session Check:**
- `RUNNING: true` → **STOP**. Report session exists. Tell user to attach:
  `ssh -t homelab "tmux attach -t {session_name}"`

---

## 2. EXECUTION PHASE (On User Confirmation)

**ONLY** execute these after the user confirms the action proposed in Phase 1.

### A. Prepare Repository
```bash
ssh homelab "bash ~/Repos/ralphus/skills/ralphus-remote/scripts/prepare.sh {project_path}"
```
*Action: Scaffolds files, creates branch on remote.*

### B. Launch Planning Loop
```bash
ssh homelab "bash ~/Repos/ralphus/skills/ralphus-remote/scripts/launch.sh {project_path} plan"
```
*Action: Starts tmux session in PLAN mode.*

### C. Launch Build Loop (Ultrawork)
```bash
ssh homelab "bash ~/Repos/ralphus/skills/ralphus-remote/scripts/launch.sh {project_path} build ultrawork"
```
*Action: Starts tmux session in BUILD mode with Ultrawork enabled.*

---

## CRITICAL RULES

1.  **NO AUTO-PILOT**: On first trigger, you MUST run `status.sh` and report to the user. Do NOT auto-launch.
2.  **ONE LOOP RULE**: If `RUNNING: true`, do NOT start another session.
3.  **SSH WRAPPER**: All commands must be wrapped in `ssh homelab "..."`.
4.  **REMOTE SCRIPTS**: Use the scripts at `~/Repos/ralphus/skills/ralphus-remote/scripts/`. Do not cat/echo scripts over the wire.
