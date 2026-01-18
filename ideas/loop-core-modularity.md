# Loop Core Modularity (Future Consideration)

## Status: DEFERRED

This idea is documented for future reference but **not recommended for immediate implementation**.

## Current State

`lib/loop_core.sh` is a single 940-line file:
- ~460 lines of comments/documentation (49%)
- ~100 blank lines (11%)
- ~380 lines of actual code (40%)

The file contains 19 functions organized into logical sections with clear headers.

## The Question

Should we split `loop_core.sh` into multiple smaller files?

## Analysis

### Arguments For Splitting

1. **Smaller files are easier to read** - Each module has single responsibility
2. **Selective sourcing** - Variants could source only what they need
3. **Easier unit testing** - Test signal handling without loading git ops
4. **Unix philosophy** - "Do one thing well"

### Arguments Against Splitting (Current Winner)

1. **Well-organized already** - Clear section headers, extensive docs
2. **380 lines is manageable** - Not a 2000-line monolith
3. **Tight coupling** - `run_loop()` depends on almost every function
4. **Variant simplicity** - Each variant just needs `source lib/loop_core.sh`
5. **AI-friendly** - Single file is easier for agents to reason about
6. **No source order issues** - Shell requires careful ordering when splitting

## When To Revisit

Split the file if any of these become true:

1. **Size threshold**: File exceeds ~600 lines of actual code
2. **Reuse need**: Other tools need subsets (e.g., just signal handling)
3. **Testing need**: Functions become independently testable units
4. **Maintenance pain**: Changes frequently break unrelated sections

## Potential Future Structure

If we decide to split later:

```
lib/
├── loop_core.sh          # Main entry, sources all others
├── init.sh               # init_ralphus, parse_common_args (~100 lines)
├── hooks.sh              # Default hook implementations (~80 lines)
├── signals.sh            # check_signals, completion handling (~90 lines)
├── git.sh                # git_push, archive_on_branch_change (~70 lines)
└── utils.sh              # show_header, build_base_message (~50 lines)
```

The main `loop_core.sh` would become a loader:

```bash
#!/bin/bash
# loop_core.sh - Loader for modular loop library

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$_LIB_DIR/init.sh"
source "$_LIB_DIR/hooks.sh"
source "$_LIB_DIR/signals.sh"
source "$_LIB_DIR/git.sh"
source "$_LIB_DIR/utils.sh"

# run_loop() stays here as the main orchestrator
run_loop() {
    # ... existing implementation
}
```

Variants would still just source `loop_core.sh` - the modularity would be internal.

## Decision

**Do not implement now.** The current single-file structure is working well and the overhead of splitting doesn't justify the benefits at this scale.

Revisit after:
- 2-3 more features are added to the library
- A concrete need for selective sourcing arises
- Maintenance becomes painful
