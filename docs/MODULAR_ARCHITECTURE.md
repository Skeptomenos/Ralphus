# Modular Loop Architecture

Ralphus uses a shared library pattern to minimize code duplication and ensure consistent behavior across all autonomous variants.

## Overview

The core logic of the Ralphus loop (argument parsing, signal handling, git operations, iteration control) resides in `lib/loop_core.sh`. Each variant is a "thin wrapper" that configures the library via a `config.sh` file and custom "hooks" in its `loop.sh` script.

## File Structure

```
ralphus/
├── lib/
│   └── loop_core.sh          # The shared "Engine"
└── variants/
    └── ralphus-{name}/       # The "Chassis"
        ├── config.sh         # Static configuration
        └── scripts/loop.sh   # Dynamic hooks + library entry point
```

## The shared library (`lib/loop_core.sh`)

The library provides the `run_loop` function which orchestrates the following lifecycle:

1.  **Initialization**: Sets up directories and standard environment variables.
2.  **Argument Parsing**: Handles `plan`, `ulw`, iteration counts, and custom prompts.
3.  **Validation**: Checks for required files and directories.
4.  **Main Loop**:
    - Build Agent message.
    - Resolve template files.
    - Execute `opencode`.
    - Parse completion signals (`PHASE_COMPLETE`, `COMPLETE`, etc.).
    - Handle git commits and pushes.
    - Check for shutdown requests (Ctrl+C).

## The Variant Wrapper

A variant interacts with the library through:

### 1. `config.sh`
Defines the variant's identity:
- `VARIANT_NAME`: Display name.
- `TRACKING_FILE`: The `.md` file used for tracking progress.
- `DEFAULT_PROMPT_FILE`: Prompt used for the main execution mode.
- `PLAN_PROMPT_FILE`: Prompt used for the `plan` mode.
- `REQUIRED_DIRS`: Directories that must exist in the working directory.

### 2. Hooks (in `loop.sh`)

Hooks are bash functions defined in the variant's `loop.sh` that the library calls at specific points.

| Hook | Purpose |
|------|---------|
| `get_templates()` | **Required**. Returns paths to template files the agent should use. |
| `validate_variant()` | Optional. Additional pre-checks before starting the loop. |
| `build_message()` | Optional. Customizes the prompt message sent to the agent. |
| `post_iteration()` | Optional. Logic to run after a successful iteration. |
| `parse_variant_args()`| Optional. Handle variant-specific command line arguments. |

## Benefits

1.  **Consistency**: Bug fixes in `loop_core.sh` (like signal parsing or shutdown handling) automatically apply to all variants.
2.  **Maintainability**: Adding features like "Custom Prompt Injection" only requires updating the library once.
3.  **Efficiency**: Variants are reduced by ~60% in line count, making them much easier to read and audit.
4.  **Reliability**: Centralized error handling and git safety protocols.
