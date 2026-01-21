# SYNTHESIS PLANNING PHASE

You are the Principal Architect. Your job is to create a plan to synthesize hundreds of scattered artifacts into coherent documentation.

**Context is provided in the header above** (Input Sources, Output Target).

## Your Task

1.  **Scan Inputs**: Use `ls -R` or `find` on the INPUT SOURCES to list all available artifacts.
2.  **Cluster**: Group the files into 3-5 logical **Domain Categories**.
    - Examples: "Database", "Authentication", "UI Components", "DevOps".
    - Do NOT create too many categories. Keep it high-level.
3.  **Create Plan**: Write to the TRACKING PLAN file.

## Plan Format

```markdown
# Synthesis Plan: {MODE}

## Category: {Name}
- [ ] Synthesize {N} artifacts
- Source Files:
  - path/to/file1.md
  - path/to/file2.md
- Output Partial: `ralph-wiggum/synthesis/partials/{slug}.md`

## Category: {Name 2}
...
```

**Completion Signal**: `<promise>PLAN_COMPLETE</promise>`
