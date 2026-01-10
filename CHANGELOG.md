# Changelog

All notable changes to Ralphus (forked from [ClaytonFarr/ralph-playbook](https://github.com/ClaytonFarr/ralph-playbook)).

## [1.0.0] - 2025-01-10

### Added

- **OpenCode CLI Support**: Replaced Claude Code CLI with OpenCode CLI
  - New invocation: `opencode run --agent Sisyphus -f PROMPT_FILE -- "message"`
  - Configurable via `RALPH_AGENT` and `OPENCODE_BIN` environment variables
  - Note: The `--` separator before the message is CRITICAL when using `-f` flag

- **Completion Signal Detection**: Loop now detects and responds to completion signals
  - `<promise>COMPLETE</promise>` - All tasks done, loop exits cleanly (exit 0)
  - `<promise>BLOCKED:[task]:[reason]</promise>` - Stuck, needs human intervention (exit 1)

- **Error Recovery Protocol**: Added to PROMPT_build.md
  - 3 consecutive failures → document in IMPLEMENTATION_PLAN.md and move to next task
  - 15 minutes no progress → output BLOCKED signal
  - Never delete failing tests or leave code broken

- **Graceful Shutdown Handler**: Ctrl+C now finishes current task before stopping
  - Uses `trap INT TERM` to catch signals
  - Sets SHUTDOWN flag, loop exits after current iteration

- **Archive Mechanism**: Preserves state when switching branches
  - Detects branch changes via `.last-branch` file
  - Archives to `archive/YYYY-MM-DD-branchname/` before starting new work
  - Prevents state pollution between feature branches

- **State Validation**: Build mode now requires IMPLEMENTATION_PLAN.md
  - Fails fast with helpful error message if missing
  - Suggests running `./loop.sh plan` first

- **Homelab Remote Execution**: Full skill for running Ralphus on remote servers
  - `skill/SKILL.md` (890 lines) - Comprehensive tmux session management
  - `skill/config/project-mappings.json` - Project path mappings
  - Modes: PUSH_AND_START, STATUS, STOP, ATTACH, LOGS

- **Iteration Counter**: Displays current iteration number in loop output

### Changed

- **loop.sh**: Complete rewrite (128 lines)
  - Added `set -euo pipefail` for fail-fast error handling
  - Replaced `claude -p` with `opencode run --agent Sisyphus`
  - Added mode detection (plan vs build)
  - Added max iteration support

- **PROMPT_build.md**: Enhanced with signals and recovery
  - Added Completion Signals section
  - Added Error Recovery Protocol section

- **AGENTS.md template**: Updated for OpenCode
  - Added OpenCode configuration table
  - Added completion signals documentation
  - Added operational notes template

- **.gitignore**: Added entries for archive system
  - `archive/` - Archived state directories
  - `.last-branch` - Branch tracking file

### Removed

- Claude Code CLI dependencies
- `--dangerously-skip-permissions` flag (not needed in OpenCode)

### Known Issues

- PROMPT files still reference "Sonnet subagents" and "Opus subagents" (Claude-specific terminology)
  - These work but could be cleaner with OpenCode task delegation patterns
- Homelab skill references `scripts/ralph/ralph.sh` but playbook uses `loop.sh` at project root
  - Target projects need to ensure paths align

## Differences from Original ralph-playbook

| Feature | ralph-playbook | Ralphus |
|---------|----------------|---------|
| CLI | Claude Code | OpenCode |
| Agent | Claude (via -p flag) | Sisyphus (via --agent) |
| Completion detection | None | `<promise>COMPLETE</promise>` |
| Error recovery | None | 3-strike rule + BLOCKED signal |
| Graceful shutdown | None | Ctrl+C handler |
| Branch archival | None | Auto-archive on branch change |
| Remote execution | None | Homelab skill with tmux |
| State validation | None | Requires IMPLEMENTATION_PLAN.md |

## Migration from ralph-playbook

1. Replace `claude` with `opencode run --agent Sisyphus`
2. Add `--` separator before message when using `-f` flag
3. Add completion signals to your prompts
4. Copy `skill/` directory for homelab support (optional)

---

*"One must imagine Sisyphus happy. And Ralph eating paste. Both are valid."*
