# AGENTS.md - Project Operational Guide

> For AI agents operating in this repository. Keep operational, not verbose.

## Build & Run

```bash
# Validate (if applicable)
[test command]
[typecheck command]
[lint command]
```

## OpenCode Configuration

| Setting | Value | Override |
|---------|-------|----------|
| Agent | Sisyphus | `RALPH_AGENT=build` |
| Binary | opencode | `OPENCODE_BIN=~/.opencode/bin/opencode` |

## Completion Signals

The loop detects these signals to control execution:

| Signal | Meaning |
|--------|---------|
| `<promise>COMPLETE</promise>` | All tasks done, loop exits cleanly |
| `<promise>BLOCKED:[task]:[reason]</promise>` | Stuck, needs human intervention |

## Operational Notes

Succinct learnings about how to RUN the project:

- (Add learnings here as you discover them)

### Codebase Patterns

- (Document patterns discovered during operation)

### Known Issues

- (Document issues encountered)
