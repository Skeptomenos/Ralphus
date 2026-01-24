# AGENTS.md - Ralphus Autonomous Development Playbook

> For AI agents. Keep operational, not verbose.

## What Is This?

Ralphus is a **meta-framework** for autonomous coding loops. It orchestrates LLM agents to implement features from specs.

**Core Philosophy**: "Let Ralphus Ralphus" — self-correcting through backpressure (failing tests).

See [docs/references/](docs/references/) for deep background.

---

## Build & Run

```bash
ralphus code plan    # Specs -> Task list
ralphus code         # Task list -> Code
ralphus review       # Code -> Findings
```

Stop: `Ctrl+C` (graceful) or `pkill -f opencode` (nuclear)

Validate: `bash -n variants/*/scripts/loop.sh`

---

## Guardrails (by importance)

```
99999.       File Ownership: tracking files (*plan.md) stay in variant root
999999.      Document the why in code and specs
9999999.     Single sources of truth, no adapters
99999999.    Tag releases when tests pass (semver)
9999999999.  Resolve or document ALL bugs found
99999999999. No placeholders. No stubs. Complete implementations only.
```

---

## Error Recovery

1. **Test fails** → Fix code, not test
2. **3 failures** → Document in plan, move on
3. **15 min stuck** → `<promise>BLOCKED:[task]:[reason]</promise>`

**Never**: Delete failing tests, spin on same error, leave code broken

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Assume code exists | Search first with subagents |
| Overwrite variant files | Surgical edits + check git history |
| Spin on failures | Document after 3 attempts |
| Bloat AGENTS.md with status | Status goes in plan.md |

**Critical**: Never overwrite entire variant files. Check `git log -5 -- <file>` first. Overwriting causes regression.

---

## Subagent Delegation

| Task | Agent | Notes |
|------|-------|-------|
| Search/Read | explore | Fire liberally (parallel) |
| Build/Test | sonnet | One at a time |
| Complex reasoning | oracle | Architecture, debugging |

---

## Deep Dives

- [Modular Architecture](docs/MODULAR_ARCHITECTURE.md) — Hooks, signals, loop_core.sh
- [Ralph-Wiggum Standard](docs/RALPH_WIGGUM_ARCHITECTURE.md) — Project layout
- [Factory Cycle](docs/FACTORY_CYCLE.md) — Variant roles, data flow
- [Code Style](docs/CODE_STYLE.md) — Shell + Markdown conventions

---

## Operational Notes

- OpenCode CLI: `opencode run -f PROMPT.md "message"`
- Remote homelab: `~/.opencode/bin/opencode`
- Override agent: `RALPH_AGENT=<agent-name>`
