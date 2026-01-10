---
name: homelab-ralph
description: "Manage Ralph autonomous agent loops on the homelab server. Spawn, monitor, attach, and control long-running Ralph sessions via SSH and tmux. Supports multiple concurrent sessions."
triggers:
  - "run ralph on homelab"
  - "start ralph remotely"
  - "push and run ralph"
  - "sync and spawn ralph"
  - "check ralph status"
  - "how is ralph doing"
  - "ralph progress"
  - "stop ralph"
created: 2025-01-10
updated: 2025-01-10
---

<!--
ARCHITECTURE: Workflow skill with local and remote phases
BASELINE FAILURES ADDRESSED:
- No local/remote path mapping → Added PROJECT_MAPPINGS section
- No unified push+run flow → Added PUSH_AND_START mode with PHASE L0
- Missing opencode path knowledge → Documented in ENVIRONMENT
- No commit message convention → Specified [ralph] sync convention
-->

# Homelab Ralph Management

**Core principle:** One command syncs local changes and spawns remote ralph. No manual git operations.

Spawn and manage Ralph autonomous agent loops on the homelab server (Fedora Linux).
Supports multiple concurrent sessions across different repos or parallel runs in the same repo.

---

## When to Use

- Run autonomous coding loops on homelab server
- Sync local changes to remote before spawning ralph
- Monitor long-running ralph sessions
- Manage multiple concurrent ralph loops

**Do NOT use when:**
- Running ralph locally (use `./scripts/ralph/ralph.sh` directly)
- Project not cloned on homelab yet

---

## MODE DETECTION (FIRST STEP)

Analyze the user's request to determine operation mode:

| User Request Pattern | Mode | Jump To |
|---------------------|------|---------|
| "push and run ralph", "sync and spawn ralph", "push to homelab" | `PUSH_AND_START` | Phase L0, then S1-S4 |
| "run ralph", "start ralph", "spawn ralph" (no push keyword) | `START` | Phase S1-S4 |
| "check ralph", "ralph status", "how is ralph" | `STATUS` | Phase T1-T2 |
| "stop ralph", "kill ralph", "cancel ralph" | `STOP` | Phase K1-K2 |
| "attach to ralph", "show ralph output" | `ATTACH` | Phase A1 |
| "ralph progress", "what did ralph do" | `PROGRESS` | Phase P1-P2 |
| "list aliases", "ralph projects" | `ALIASES` | Phase L1 |

**CRITICAL**: Parse the actual request. Don't default to START mode.

**PUSH KEYWORD DETECTION**: If request contains "push", "sync", or "push to homelab" → use `PUSH_AND_START` mode.

---

## ENVIRONMENT

| Property | Value |
|----------|-------|
| SSH alias | `homelab` |
| OS | Fedora Linux |
| Shell | zsh |
| Default SSH directory | `/docker/` (MUST cd to ~ first!) |
| OpenCode binary | `~/.opencode/bin/opencode` |
| Session manager | tmux |
| Projects location | `~/Repos/` |
| Ralph scripts | `{project}/scripts/ralph/` |
| State file | `~/.ralph-sessions.json` |
| Session naming | `ralph-{alias}` or `ralph-{alias}-N` for parallel |
| Default agent | `Sisyphus` (oh-my-opencode v2.14.0 installed) |

**CRITICAL**: Every SSH command MUST start with `cd ~` because default entry is `/docker/`:
```bash
ssh homelab "cd ~ && <actual command>"
```

---

## PROJECT MAPPINGS

**CONFIG FILE:** `config/project-mappings.json` (relative to this skill folder)

**MANDATORY FIRST STEP:** Read the config file to get current mappings:
```bash
cat {skill_folder}/config/project-mappings.json
```

The config contains:
- `mappings.{alias}.local` - Local path on Mac
- `mappings.{alias}.remote` - Remote path on homelab
- `defaults.iterations` - Default iteration count (20)
- `defaults.agent` - Default agent (Sisyphus)
- `defaults.commit_message` - Auto-commit message convention
- `homelab.*` - SSH alias, opencode path, state file location

**Usage**: 
- "Push and run ralph for prism" → pushes from local, pulls on remote, spawns ralph
- "Start ralph for canvas" → just spawns on remote (no local push)

**CRITICAL**: The `prism` alias has DIFFERENT local and remote paths. Always read the config.

---

## STATE FILE STRUCTURE

Location: `~/.ralph-sessions.json` on homelab (path from `config/project-mappings.json`)

```json
{
  "aliases": { "{alias}": "{remote_path}", ... },
  "project_mappings": { "{alias}": { "local": "...", "remote": "..." }, ... },
  "sessions": {
    "{session_name}": {
      "project": "{remote_path}",
      "alias": "{alias}",
      "started": "{ISO_TIMESTAMP}",
      "iterations": {N},
      "status": "running|stopped|completed"
    }
  }
}
```

**Note:** The `project_mappings` in state file should mirror `config/project-mappings.json`.

---

## STATE FILE COMMANDS

### Initialize State File (if not exists)
```bash
# Read config/project-mappings.json first, then create state file with matching structure
ssh homelab 'cd ~ && cat > ~/.ralph-sessions.json << '\''EOF'\''
{
  "aliases": { ... },
  "project_mappings": { ... },
  "sessions": {}
}
EOF'
```

### Read State File
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json 2>/dev/null || echo '{\"aliases\":{},\"sessions\":{}}'"
```

### Read Aliases
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq -r '.aliases'"
```

### Resolve Alias to Path
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq -r '.aliases.{ALIAS} // empty'"
```

### Add/Update Session in State
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq '.sessions.\"{SESSION_NAME}\" = {\"project\": \"{PROJECT_PATH}\", \"alias\": \"{ALIAS}\", \"started\": \"{ISO_TIMESTAMP}\", \"iterations\": {N}, \"status\": \"running\"}' > ~/.ralph-sessions.json.tmp && mv ~/.ralph-sessions.json.tmp ~/.ralph-sessions.json"
```

### Update Session Status
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq '.sessions.\"{SESSION_NAME}\".status = \"{STATUS}\"' > ~/.ralph-sessions.json.tmp && mv ~/.ralph-sessions.json.tmp ~/.ralph-sessions.json"
```

### Remove Session from State
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq 'del(.sessions.\"{SESSION_NAME}\")' > ~/.ralph-sessions.json.tmp && mv ~/.ralph-sessions.json.tmp ~/.ralph-sessions.json"
```

### Get All Running Sessions
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq -r '.sessions | to_entries[] | select(.value.status == \"running\") | .key'"
```

### Get Sessions for Alias
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq -r '.sessions | to_entries[] | select(.value.alias == \"{ALIAS}\") | .key'"
```

---

---

# PUSH_AND_START MODE (Phase L0 + S1-S4)

## PHASE L0: Local Sync (runs on LOCAL machine, before SSH)

<local_sync>
**This phase runs ONLY when user request contains "push", "sync", or "push to homelab".**

### Step 1: Resolve Local Path

Read `config/project-mappings.json` and get `mappings.{alias}.local`.

**If alias not found in config → ASK user for local path.**

### Step 2: Check Git Status (LOCAL)

```bash
cd {local_path} && git status --porcelain
```

**Decision tree:**
- Empty output → safe to push, go to Step 4
- Non-empty output → uncommitted changes detected, go to Step 3

### Step 3: Handle Uncommitted Changes

```
LOCAL CHANGES DETECTED
======================
{git status output}

Options:
1. Auto-commit with message "[ralph] sync before remote run"
2. Let me commit manually first (abort)
3. Push anyway (uncommitted changes stay local)

What would you like to do?
```

**If user chooses option 1:**
```bash
cd {local_path} && git add -A && git commit -m "[ralph] sync before remote run"
```

### Step 4: Git Push (LOCAL)

```bash
cd {local_path} && git push origin HEAD
```

**If push fails:**
```
GIT PUSH FAILED
===============
{error output}

Common causes:
- Remote has changes you don't have locally → run `git pull --rebase` first
- Branch doesn't exist on remote → run `git push -u origin {branch}`
- Authentication issue → check SSH keys or credentials

Options:
1. Abort (fix manually)
2. Continue without push (use whatever is on remote)

What would you like to do?
```

### Step 5: Verify Push Succeeded

```bash
cd {local_path} && git log origin/HEAD -1 --oneline
```

**MANDATORY OUTPUT after local sync:**

```
LOCAL SYNC COMPLETE
===================
Project: {local_path} (alias: {alias})
Branch: {branch_name}
Commit: {short_hash} {commit_message}
Status: PUSHED

Proceeding to remote spawn...
```

**After PHASE L0 completes → continue to PHASE 0 (remote context gathering)**
</local_sync>

---

## PHASE 0: Parallel Context Gathering (MANDATORY FIRST STEP)

<parallel_analysis>
**Execute ALL of the following commands IN PARALLEL to minimize latency:**

```bash
# Group 1: Server state + state file (ALWAYS cd ~ first!)
ssh homelab "cd ~ && cat ~/.ralph-sessions.json 2>/dev/null || echo '{\"aliases\":{},\"sessions\":{}}'"
ssh homelab "cd ~ && tmux ls 2>/dev/null || echo 'NO_SESSIONS'"
ssh homelab "cd ~ && ~/.opencode/bin/opencode --version || echo 'OPENCODE_NOT_INSTALLED'"

# Group 2: Active ralph sessions (from tmux)
ssh homelab "cd ~ && tmux ls 2>/dev/null | grep ralph || echo 'NO_RALPH_SESSIONS'"

# Group 3: System resources (optional, for long runs)
ssh homelab "cd ~ && uptime && free -h | head -2"
```

**Capture these data points simultaneously:**
1. State file contents (aliases, sessions)
2. Whether tmux server is running
3. Whether opencode is installed
4. Active ralph sessions (tmux)
5. System load (for capacity planning)

**After gathering, sync state file with tmux reality:**
- If tmux shows session running but state says "completed" → update state to "running"
- If tmux shows no session but state says "running" → update state to "completed"
</parallel_analysis>

---

# START MODE (Phase S1-S4)

## PHASE S1: Validate Parameters (BLOCKING)

<start_validation>
**REQUIRED parameters - ask if not provided:**

| Parameter | Required | Default | Example |
|-----------|----------|---------|---------|
| Project (alias or path) | YES | - | `canvas`, `~/Repos/opencode-canvas` |
| Iterations | NO | 20 | 30, 50, 100 |
| Agent | NO | Sisyphus | build, Sisyphus |
| --no-pull | NO | false | Skip git pull |

**Alias Resolution:**
1. Check if input matches known alias (canvas, ralph, prism, thoth)
2. If alias → resolve to full path from state file
3. If full path → use directly
4. If unknown → ASK user

**Session Naming:**
1. Base name: `ralph-{alias}` (e.g., `ralph-canvas`)
2. If session exists and running → use `ralph-{alias}-2`, `ralph-{alias}-3`, etc.
3. Check both tmux AND state file for existing sessions

**MANDATORY OUTPUT before proceeding:**

```
START PARAMETERS
================
Project: {project_path} (alias: {alias})
Iterations: {iterations}
Agent: {agent}
Session name: {session_name}
Git pull: {yes | skipped (--no-pull)}

Validation:
  [ ] Alias resolved or path confirmed
  [ ] Ralph scripts exist at {project_path}/scripts/ralph/
  [ ] Session name available (no collision)
```

**IF project not provided or unknown alias -> ASK. Do not guess.**
</start_validation>

---

## PHASE S2: Git Pull (unless --no-pull)

<git_pull>
**Skip this phase if --no-pull flag is set.**

```bash
# Check for local changes first
ssh homelab "cd ~ && cd {project_path} && git status --porcelain"
```

**Decision tree:**
- Empty output → safe to pull
- Non-empty output → LOCAL CHANGES DETECTED

**If local changes detected:**
```
WARNING: Local changes detected in {project_path}
=========================================
{git status output}

Options:
1. Proceed anyway (changes will be preserved, pull may fail if conflicts)
2. Skip git pull (--no-pull)
3. Abort

What would you like to do?
```

**If safe to pull:**
```bash
ssh homelab "cd ~ && cd {project_path} && git pull --ff-only"
```

**If pull fails:**
```
GIT PULL FAILED
===============
{error output}

Options:
1. Continue without pulling (use current state)
2. Abort

What would you like to do?
```
</git_pull>

---

## PHASE S3: Pre-flight Checks

<preflight>
```bash
# Verify ralph is set up in project (ALWAYS cd ~ first!)
ssh homelab "cd ~ && ls {project_path}/scripts/ralph/ralph.sh && echo 'RALPH_OK' || echo 'RALPH_MISSING'"

# Check for existing session with same name (avoid collision)
ssh homelab "cd ~ && tmux has-session -t {session_name} 2>/dev/null && echo 'SESSION_EXISTS' || echo 'SESSION_FREE'"

# Verify opencode + Sisyphus available
ssh homelab "cd ~ && ~/.opencode/bin/opencode --version && ~/.opencode/bin/opencode debug agent Sisyphus >/dev/null 2>&1 && echo 'SISYPHUS_OK' || echo 'SISYPHUS_MISSING'"
```

**BLOCKING conditions:**
- `RALPH_MISSING` -> STOP. Tell user to set up ralph first:
  ```
  Ralph scripts not found at {project_path}/scripts/ralph/
  
  To set up ralph, copy from ralph-opencode:
    ssh homelab "cd ~ && mkdir -p {project_path}/scripts/ralph && cp ~/Repos/ralph-opencode/{ralph.sh,prompt.md,prd.json.example} {project_path}/scripts/ralph/"
  ```
- `SESSION_EXISTS` -> Increment session name (ralph-canvas → ralph-canvas-2)
- `SISYPHUS_MISSING` -> WARN. Ralph will use default agent.
</preflight>

---

## PHASE S4: Start Session & Update State

<start_session>
```bash
# Start ralph in detached tmux session (ALWAYS cd ~ first, use full opencode path)
ssh homelab "cd ~ && tmux new-session -d -s {session_name} -c {project_path} 'export PATH=~/.opencode/bin:\$PATH && RALPH_AGENT=Sisyphus ./scripts/ralph/ralph.sh {iterations}'"

# Verify session started
ssh homelab "cd ~ && tmux has-session -t {session_name} 2>/dev/null && echo 'STARTED' || echo 'FAILED'"

# Update state file with new session
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq '.sessions.\"{session_name}\" = {\"project\": \"{project_path}\", \"alias\": \"{alias}\", \"started\": \"{ISO_TIMESTAMP}\", \"iterations\": {iterations}, \"status\": \"running\"}' > ~/.ralph-sessions.json.tmp && mv ~/.ralph-sessions.json.tmp ~/.ralph-sessions.json"

# Capture initial output (first 10 lines)
sleep 3
ssh homelab "cd ~ && tmux capture-pane -t {session_name} -p -S 0 -E 10"
```

**MANDATORY OUTPUT after start:**

```
RALPH SESSION STARTED
=====================
Session: {session_name}
Project: {project_path} (alias: {alias})
Iterations: {iterations}
Agent: Sisyphus
Git: {pulled | skipped | had local changes}

Status: RUNNING

To attach (live view):
  ssh homelab -t "tmux attach -t {session_name}"

To check progress:
  "How is ralph doing?" or "Ralph progress"

To stop:
  "Stop ralph on {alias}"
```
</start_session>

---

# STATUS MODE (Phase T1-T2)

## PHASE T1: Gather Status (Parallel)

<status_gather>
```bash
# Execute in parallel (ALWAYS cd ~ first!)

# Get state file
ssh homelab "cd ~ && cat ~/.ralph-sessions.json"

# Get all ralph tmux sessions
ssh homelab "cd ~ && tmux ls 2>/dev/null | grep ralph || echo 'NO_RALPH_SESSIONS'"

# Capture output from ALL ralph sessions
ssh homelab "cd ~ && for s in \$(tmux ls 2>/dev/null | grep ralph | cut -d: -f1); do echo \"=== \$s ===\"; tmux capture-pane -t \$s -p -S -20; done"
```

**Sync state with reality:**
- Cross-reference tmux sessions with state file
- Update status for any mismatches
</status_gather>

---

## PHASE T2: Report Status

<status_report>
**MANDATORY OUTPUT:**

```
RALPH STATUS REPORT
===================
Active sessions: N

SESSION: ralph-canvas
  Project: ~/Repos/opencode-canvas
  Started: 2025-01-10 11:30:00 (2h 15m ago)
  Iterations: 30
  Status: RUNNING
  
  Last output (20 lines):
  {captured output}
  
  Current iteration: X of Y (parsed from output)

SESSION: ralph-thoth
  Project: ~/Repos/thoth
  Started: 2025-01-10 11:45:00 (2h ago)
  Iterations: 50
  Status: RUNNING
  
  Last output (20 lines):
  {captured output}

COMMANDS:
  Attach: ssh homelab -t "tmux attach -t {session}"
  Stop one: "Stop ralph on {alias}"
  Stop all: "Stop all ralph sessions"
```

**If no sessions running:**
```
RALPH STATUS: No active sessions

Known projects: (from config/project-mappings.json)
  {list aliases and remote paths from config}

To start a new session:
  "Run ralph on homelab for {alias}"
```
</status_report>

---

# PROGRESS MODE (Phase P1-P2)

## PHASE P1: Gather Progress Data (Parallel)

<progress_gather>
**First, read state file to get all sessions:**
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json"
```

**Then, for EACH session in state file with status "running":**
```bash
# Execute in parallel for each session
ssh homelab "cd ~ && cat {project_path}/scripts/ralph/prd.json 2>/dev/null | jq '.userStories[] | {id, title, passes}' || echo 'NO_PRD'"
ssh homelab "cd ~ && tail -50 {project_path}/scripts/ralph/progress.txt 2>/dev/null || echo 'NO_PROGRESS'"
ssh homelab "cd ~ && tmux capture-pane -t {session_name} -p -S -30 2>/dev/null || echo 'SESSION_NOT_RUNNING'"
```

**If user specified an alias (e.g., "progress on canvas"):**
- Filter to only sessions matching that alias
</progress_gather>

---

## PHASE P2: Report Progress

<progress_report>
**MANDATORY OUTPUT (for each session):**

```
RALPH PROGRESS REPORT
=====================

SESSION: ralph-canvas
Project: ~/Repos/opencode-canvas
Status: RUNNING (iteration 15 of 30)
Started: 2025-01-10 11:30:00 (2h 15m ago)

STORIES:
  [✓] US-001: {title} - PASSED
  [✓] US-002: {title} - PASSED  
  [ ] US-003: {title} - pending
  [ ] US-004: {title} - pending

Progress: 2/4 stories complete (50%)

RECENT ACTIVITY (from progress.txt):
  {last 10 lines of progress.txt}

CURRENT OUTPUT:
  {last 20 lines of tmux capture}

---

SESSION: ralph-thoth
Project: ~/Repos/thoth
Status: RUNNING (iteration 8 of 50)
...
```
</progress_report>

---

# STOP MODE (Phase K1-K2)

## PHASE K1: Identify Sessions to Stop

<stop_identify>
**Parse user request:**
- "Stop ralph" (no qualifier) → If 1 session, stop it. If multiple, list and ask.
- "Stop ralph on canvas" → Stop all ralph-canvas* sessions
- "Stop all ralph" → Stop ALL ralph sessions
- "Stop ralph-canvas-2" → Stop specific session

```bash
# Get current sessions
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq -r '.sessions | to_entries[] | select(.value.status == \"running\") | .key'"
ssh homelab "cd ~ && tmux ls 2>/dev/null | grep ralph"
```

**If multiple sessions and no qualifier:**
```
Multiple ralph sessions running:
  1. ralph-canvas (~/Repos/opencode-canvas) - 2h 15m
  2. ralph-thoth (~/Repos/thoth) - 2h
  3. ralph-canvas-2 (~/Repos/opencode-canvas) - 30m

Which to stop?
  - "Stop ralph on canvas" (stops 1 and 3)
  - "Stop ralph-thoth" (stops 2)
  - "Stop all ralph" (stops all)
```
</stop_identify>

---

## PHASE K2: Stop Session(s)

<stop_session>
**For each session to stop:**
```bash
# Graceful stop (Ctrl+C) - ALWAYS cd ~ first!
ssh homelab "cd ~ && tmux send-keys -t {session_name} C-c"

# Wait and verify
sleep 2
ssh homelab "cd ~ && tmux has-session -t {session_name} 2>/dev/null && echo 'STILL_RUNNING' || echo 'STOPPED'"

# If still running, force kill
ssh homelab "cd ~ && tmux kill-session -t {session_name} 2>/dev/null"

# Update state file
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq '.sessions.\"{session_name}\".status = \"stopped\"' > ~/.ralph-sessions.json.tmp && mv ~/.ralph-sessions.json.tmp ~/.ralph-sessions.json"
```

**MANDATORY OUTPUT:**

```
RALPH SESSION(S) STOPPED
========================
Stopped: {session_name_1}, {session_name_2}
Method: graceful

Final progress saved to:
  {project_path}/scripts/ralph/progress.txt

To view final state:
  "Ralph progress on {alias}"
```
</stop_session>

---

# ATTACH MODE (Phase A1)

## PHASE A1: Provide Attach Instructions

<attach_mode>
**First, list available sessions:**
```bash
ssh homelab "cd ~ && tmux ls 2>/dev/null | grep ralph || echo 'NO_RALPH_SESSIONS'"
```

**If multiple sessions:**
```
AVAILABLE RALPH SESSIONS
========================
1. ralph-canvas - ~/Repos/opencode-canvas
2. ralph-thoth - ~/Repos/thoth

Which session to attach to?
```

**For interactive attach, the user must run this themselves:**

```
ATTACH TO RALPH SESSION
=======================
Session: {session_name}
Project: {project_path}

Run this command in your terminal:
  ssh homelab -t "tmux attach -t {session_name}"

Controls:
  Ctrl+B, D     - Detach (session keeps running)
  Ctrl+B, [     - Scroll mode (q to exit)
  Ctrl+C        - Stop ralph (careful!)

Alternative - peek without attaching:
  ssh homelab "tmux capture-pane -t {session_name} -p -S -100"
```

**NOTE**: Cannot attach interactively from this agent. User must run SSH command.
</attach_mode>

---

# ALIASES MODE (Phase L1)

## PHASE L1: List Aliases

<list_aliases>
```bash
ssh homelab "cd ~ && cat ~/.ralph-sessions.json | jq -r '.aliases | to_entries[] | \"\(.key)\t→ \(.value)\"'"
```

**MANDATORY OUTPUT:**

```
RALPH PROJECT ALIASES
=====================
{list from config/project-mappings.json - show alias → remote path}

To add a new alias:
  1. Edit config/project-mappings.json (local skill config)
  2. Update ~/.ralph-sessions.json on homelab to match
```
</list_aliases>

---

## TROUBLESHOOTING

| Problem | Diagnosis | Solution |
|---------|-----------|----------|
| "session not found" | Session ended | Check `progress.txt` for final state |
| "no server running" | tmux not started | Start any tmux session first |
| "connection refused" | SSH issue | Verify `ssh homelab` works |
| "opencode not found" | Not installed | Install opencode on homelab |
| "Sisyphus not found" | oh-my-opencode missing | Install plugin or use `RALPH_AGENT=build` |
| Ralph stuck | Context exhaustion | Check iteration count, may need restart |
| State file missing | First run | Initialize with PHASE 0 command |
| State/tmux mismatch | Crash or manual kill | Sync state in PHASE 0 |

**Recovery commands:**
```bash
# Check what happened
ssh homelab "cd ~ && cat {project}/scripts/ralph/progress.txt | tail -50"

# Check git state
ssh homelab "cd ~ && cd {project} && git status && git log --oneline -5"

# Re-initialize state file (use values from config/project-mappings.json)
ssh homelab 'cd ~ && cat > ~/.ralph-sessions.json << '\''EOF'\''
{
  "aliases": { ... },
  "project_mappings": { ... },
  "sessions": {}
}
EOF'

# Restart from where it left off
ssh homelab "cd ~ && tmux new-session -d -s ralph-{project} -c {project} 'export PATH=~/.opencode/bin:\$PATH && ./scripts/ralph/ralph.sh 20'"
```

---

## COMMON MISTAKES

| Mistake | Prevention |
|---------|------------|
| Guessing local/remote paths | Always use PROJECT MAPPINGS table |
| Running git commands without checking status | Always `git status --porcelain` first |
| Using generic commit messages | Use `[ralph] sync before remote run` convention |
| Forgetting prism has different paths | Check config - local ≠ remote for prism |
| Pushing without verifying | Check exit code and `git log origin/HEAD` |
| Skipping PHASE L0 when "push" keyword present | Always detect push/sync keywords |

---

## RED FLAGS - STOP

- User says "push" but you're skipping PHASE L0
- Local path doesn't exist (wrong mapping?)
- Git push fails with merge conflict (user must resolve)
- Remote path doesn't match local repo (wrong project?)
- Uncommitted changes and user didn't choose how to handle

**All mean: STOP. Ask user before proceeding.**

---

## ANTI-PATTERNS (AUTOMATIC FAILURE)

1. **NEVER start without project alias or path** - Always resolve or ask
2. **NEVER ignore existing session** - Check first, increment name if needed
3. **NEVER assume opencode is installed** - Verify in preflight
4. **NEVER attach interactively from agent** - Provide command for user
5. **NEVER skip state file update** - Always sync after start/stop
6. **NEVER forget to report session name** - User needs it to attach later
7. **NEVER git pull without checking for local changes** - Ask first
8. **NEVER assume single session** - Always check for multiple
9. **NEVER skip PHASE L0 when push keyword detected** - Local sync is mandatory
10. **NEVER hardcode paths** - Always use PROJECT MAPPINGS

---

## QUICK REFERENCE

### Local Commands (PHASE L0)

| Goal | Command |
|------|---------|
| Check local status | `cd {local_path} && git status --porcelain` |
| Auto-commit | `cd {local_path} && git add -A && git commit -m "[ralph] sync before remote run"` |
| Push to origin | `cd {local_path} && git push origin HEAD` |
| Verify push | `cd {local_path} && git log origin/HEAD -1 --oneline` |

### Remote Commands (SSH to homelab)

**ALL SSH commands must start with `cd ~` due to /docker/ default entry!**

| Goal | Command |
|------|---------|
| Init state file | `ssh homelab 'cd ~ && cat > ~/.ralph-sessions.json << ...` (see STATE FILE COMMANDS) |
| Read state | `ssh homelab "cd ~ && cat ~/.ralph-sessions.json"` |
| Resolve alias | `ssh homelab "cd ~ && cat ~/.ralph-sessions.json \| jq -r '.aliases.canvas'"` |
| Check remote changes | `ssh homelab "cd ~ && cd {path} && git status --porcelain"` |
| Git pull | `ssh homelab "cd ~ && cd {path} && git pull --ff-only"` |
| Start ralph | `ssh homelab "cd ~ && tmux new-session -d -s {sess} -c {path} 'export PATH=~/.opencode/bin:\$PATH && RALPH_AGENT=Sisyphus ./scripts/ralph/ralph.sh {n}'"` |
| Check running | `ssh homelab "cd ~ && tmux ls \| grep ralph"` |
| Peek output | `ssh homelab "cd ~ && tmux capture-pane -t {sess} -p -S -50"` |
| Attach (user runs) | `ssh homelab -t "tmux attach -t {sess}"` |
| Stop graceful | `ssh homelab "cd ~ && tmux send-keys -t {sess} C-c"` |
| Stop force | `ssh homelab "cd ~ && tmux kill-session -t {sess}"` |
| Update state | `ssh homelab "cd ~ && cat ~/.ralph-sessions.json \| jq '...' > ~/.ralph-sessions.json.tmp && mv ~/.ralph-sessions.json.tmp ~/.ralph-sessions.json"` |
| Check progress | `ssh homelab "cd ~ && cat {path}/scripts/ralph/prd.json \| jq '.userStories[]'"` |
| View log | `ssh homelab "cd ~ && tail -50 {path}/scripts/ralph/progress.txt"` |

---

## VERIFICATION CHECKLIST

Before reporting task complete:

- [ ] Mode correctly detected (especially PUSH_AND_START vs START)
- [ ] Local path resolved from PROJECT MAPPINGS (if push mode)
- [ ] Local git status checked before push
- [ ] Uncommitted changes handled (committed or user chose to skip)
- [ ] Git push succeeded (if push mode)
- [ ] Remote git pull succeeded
- [ ] Ralph scripts exist at remote path
- [ ] Session started and verified
- [ ] State file updated
- [ ] Session ID reported to user
