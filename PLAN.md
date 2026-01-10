# Ralphus: Adaptation Plan

> *When Ralph met Sisyphus, they realized they had a lot in common. Neither knows when to quit.*

**Goal:** Adapt the ClaytonFarr/ralph-playbook for OpenCode CLI + Sisyphus agent, while integrating homelab remote execution capabilities from ralph-shepherd.

**Source:** ClaytonFarr/ralph-playbook (Claude Code focused)
**Target:** OpenCode CLI + Sisyphus agent + Homelab remote execution

**The Story:** Ralph Wiggum's autonomous loop methodology meets Sisyphus's eternal determination. The result is Ralphus — an agent that keeps pushing the boulder uphill, one commit at a time, blissfully unaware that the context window will clear and he'll have to start reading the plan again.

---

## Current Status (Updated 2025-01-10)

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Core CLI | ✅ DONE | loop.sh rewritten for OpenCode |
| Phase 2: Homelab | ✅ DONE | skill/SKILL.md already complete |
| Phase 3: Archive | ✅ DONE | Branch detection + archival implemented |
| Phase 4: Docs | 🔄 PARTIAL | AGENTS.md done, README/CHANGELOG pending |
| Phase 5: Testing | ❌ NOT STARTED | Needs real project testing |

### Remaining Work
1. **Phase 4.1**: Update README.md to remove Claude Code references
2. **Phase 4.3**: Create CHANGELOG.md
3. **Phase 5**: Test with real project (canvas or thoth)

---

## OpenCode CLI Reference (CRITICAL)

**Correct invocation syntax:**
```bash
opencode run --agent Sisyphus -f PROMPT_FILE -- "Read the attached prompt file and execute the instructions"
```

**Key learnings:**
- `-f` attaches files but a message argument is STILL required
- `--` separator needed before message when using flags
- No permission flags needed (unlike Claude Code's `--dangerously-skip-permissions`)
- `--format json` available but default (human-readable) works fine
- Binary path on homelab: `~/.opencode/bin/opencode`

**Environment variables:**
- `RALPH_AGENT` - Override agent (default: Sisyphus)
- `OPENCODE_BIN` - Override binary path (default: opencode)

---

## Known Issues / Gotchas

1. **Homelab skill path mismatch**: skill/SKILL.md references `scripts/ralph/ralph.sh` but playbook uses `loop.sh` at project root. Target projects need to either:
   - Copy loop.sh to project root, OR
   - Update skill to reference correct path

2. **PROMPT templates still reference Claude subagents**: PROMPT_build.md mentions "Sonnet subagents" and "Opus subagents" - these are Claude-specific. OpenCode uses different agent/task patterns.

3. **prism mapping differs**: In project-mappings.json, prism has different local vs remote paths. Always check the config.

---

## Phase 1: Core CLI Adaptation (Priority: P0)

### 1.1 Update loop.sh for OpenCode ✅ DONE

**File:** `files/loop.sh`

**Changes:**
- [x] Replace `claude -p` with `opencode run`
- [x] Update CLI flags for OpenCode equivalents
- [x] Add completion signal detection: `<promise>COMPLETE</promise>`
- [x] Add blocked signal detection: `<promise>BLOCKED:[task]:[reason]</promise>`
- [x] Add `set -euo pipefail` for fail-fast behavior
- [x] Add OpenCode binary path handling via `OPENCODE_BIN` env var
- [x] Add graceful shutdown handler (trap INT TERM)
- [x] Add iteration counter display

**Actual implementation (128 lines):**
```bash
#!/bin/bash
set -euo pipefail

AGENT="${RALPH_AGENT:-Sisyphus}"
OPENCODE="${OPENCODE_BIN:-opencode}"

# ... mode detection, header, validation ...

# Graceful shutdown handler
SHUTDOWN=0
trap 'SHUTDOWN=1; echo "Shutdown requested..."' INT TERM

while true; do
    # CRITICAL: -f attaches file, but message is still required after --
    OUTPUT=$("$OPENCODE" run --agent "$AGENT" -f "$PROMPT_FILE" -- "Read the attached prompt file and execute the instructions" 2>&1 | tee /dev/stderr) || true
    
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        exit 0
    fi
    
    if echo "$OUTPUT" | grep -q "<promise>BLOCKED:"; then
        exit 1
    fi
    
    # git push after each iteration
done
```

### 1.2 Update Prompt Templates for OpenCode ✅ PARTIAL

**Files:** `files/PROMPT_plan.md`, `files/PROMPT_build.md`

**Changes:**
- [x] Add completion signal instruction to PROMPT_build.md
- [x] Add error recovery protocol to PROMPT_build.md
- [x] Keep numbered guardrails (99999...) - these work universally
- [ ] **TODO**: Replace Claude-specific subagent references (Sonnet/Opus) with OpenCode patterns

**Note:** PROMPT_build.md still references "Sonnet subagents" and "Opus subagents" which are Claude-specific. OpenCode uses different task delegation. This works but could be cleaner.

### 1.3 Add Error Recovery ✅ DONE

**File:** `files/PROMPT_build.md`

Added sections:
- Error Recovery Protocol (3 attempts, then document and move on)
- Completion Signals (`<promise>COMPLETE</promise>` and `<promise>BLOCKED:[task]:[reason]</promise>`)

---

## Phase 2: Homelab Integration (Priority: P1) ✅ DONE

**Status:** Already complete before this adaptation. skill/SKILL.md is 890 lines and fully functional.

### 2.1-2.3 Skill Directory ✅ EXISTS

```
ralphus/
├── skill/
│   ├── SKILL.md              # 890 lines, comprehensive homelab management
│   └── config/
│       └── project-mappings.json  # 4 project mappings (canvas, prism, ralph, thoth)
```

**Known issue:** SKILL.md references `scripts/ralph/ralph.sh` but playbook uses `loop.sh` at project root. When using with target projects, ensure paths align.

---

## Phase 3: Archive & State Management (Priority: P1) ✅ DONE

### 3.1 Add Archive Mechanism ✅ DONE

Implemented in `files/loop.sh`. Archives to `archive/YYYY-MM-DD-branchname/` when branch changes.

### 3.2 Add State Validation ✅ DONE

Build mode now requires `IMPLEMENTATION_PLAN.md` to exist. Fails fast with helpful error message.

### 3.3 Add .gitignore ✅ DONE

Added `archive/` and `.last-branch` to `.gitignore`.

---

## Phase 4: Documentation Updates (Priority: P2) 🔄 PARTIAL

### 4.1 Update README.md ❌ TODO

**Changes needed:**
- [ ] Replace all `claude` references with `opencode`
- [ ] Add OpenCode installation instructions
- [ ] Add homelab skill documentation section
- [ ] Add archive mechanism documentation
- [ ] Update CLI flags documentation
- [ ] Add "Differences from original playbook" section

**Note:** README.md currently mentions OpenCode in philosophy but loop.sh examples may still show old syntax.

### 4.2 Update AGENTS.md Template ✅ DONE

**File:** `files/AGENTS.md` - Rewritten with:
- OpenCode configuration table
- Completion signals documentation
- Operational notes template

### 4.3 Create CHANGELOG.md ❌ TODO

**File:** `CHANGELOG.md`

Should document:
- OpenCode CLI adaptation (from Claude Code)
- Homelab skill integration
- Archive mechanism
- Completion signal detection
- Error recovery additions
- Graceful shutdown handler

---

## Phase 5: Testing & Validation (Priority: P2) ❌ NOT STARTED

### 5.1 Local Testing

- [x] Bash syntax validation (`bash -n files/loop.sh` passes)
- [x] Script executes and shows header correctly
- [x] OpenCode CLI invocation works (tested, runs until timeout)
- [ ] Test plan mode with real specs
- [ ] Test build mode with real IMPLEMENTATION_PLAN.md
- [ ] Test completion signal detection end-to-end
- [ ] Test blocked signal detection end-to-end
- [ ] Test archive mechanism (switch branches)

### 5.2 Remote Testing

- [ ] Test homelab skill PUSH_AND_START mode
- [ ] Test homelab skill STATUS mode
- [ ] Test homelab skill STOP mode
- [ ] Verify state file sync
- [ ] Test with real project (canvas or thoth)

### 5.3 Integration Testing

- [ ] Copy files to a real project
- [ ] Run `./loop.sh plan 1` successfully
- [ ] Run `./loop.sh 1` successfully
- [ ] Verify git push works
- [ ] Verify graceful shutdown (Ctrl+C)

---

## File Change Summary

| File | Action | Status |
|------|--------|--------|
| `files/loop.sh` | Major rewrite | ✅ DONE |
| `files/PROMPT_build.md` | Add signals + error recovery | ✅ DONE |
| `files/PROMPT_plan.md` | Minor updates | ⚠️ Still has Claude subagent refs |
| `files/AGENTS.md` | Add OpenCode section | ✅ DONE |
| `skill/SKILL.md` | Port from ralph-shepherd | ✅ Already existed |
| `skill/config/project-mappings.json` | Create new | ✅ Already existed |
| `README.md` | Major updates | ❌ TODO |
| `CHANGELOG.md` | Create new | ❌ TODO |
| `.gitignore` | Add archive/, .last-branch | ✅ DONE |
| `AGENTS.md` (root) | Update with build instructions | ✅ DONE |

---

## Success Criteria

1. **Local execution works:** `./loop.sh` runs with OpenCode and completes tasks
2. **Remote execution works:** `/homelab-ralph` skill spawns and manages sessions
3. **Completion detection works:** Loop exits cleanly when `<promise>COMPLETE</promise>` detected
4. **Error recovery works:** Blocked tasks are documented, loop doesn't spin
5. **Archive works:** Branch changes trigger state archival
6. **Documentation complete:** README explains all differences from original

---

## Estimated Effort

| Phase | Effort | Dependencies |
|-------|--------|--------------|
| Phase 1: Core CLI | 2-3 hours | None |
| Phase 2: Homelab | 2 hours | Phase 1 |
| Phase 3: Archive | 1 hour | Phase 1 |
| Phase 4: Docs | 1-2 hours | Phase 1-3 |
| Phase 5: Testing | 2 hours | Phase 1-3 |

**Total: ~8-10 hours**

---

## Notes

- Keep the playbook's philosophy: "Let Ralphus Ralphus", disposable plans, subagent orchestration
- The numbered guardrails (99999...) work with any LLM - keep them
- OpenCode's agent system may handle subagents differently - test and adapt
- The homelab skill is the key differentiator - make it first-class
- Remember: One must imagine Sisyphus happy. And Ralph eating paste. Both are valid.

---

## Session Log

### 2025-01-10: Initial Implementation
- Rewrote `files/loop.sh` for OpenCode CLI (128 lines)
- Added completion/blocked signal detection
- Added graceful shutdown handler
- Added archive mechanism for branch changes
- Updated `files/PROMPT_build.md` with error recovery and signals
- Updated `files/AGENTS.md` template
- Updated root `AGENTS.md` with build instructions
- Updated `.gitignore`

**Key discovery:** OpenCode CLI requires `--` separator before message when using `-f` flag:
```bash
opencode run --agent Sisyphus -f PROMPT.md -- "message here"
```

**Remaining:** README.md updates, CHANGELOG.md creation, real project testing
