# Ralphus Product

The Technical Product Manager for your autonomous team. Converts raw brain dumps into structured idea files for the Architect.

## Capabilities

1.  **Idea Slicing**: Takes a messy text file ("I want X, Y, and Z") and splits it into atomic files (`ideas/X.md`, `ideas/Y.md`).
2.  **Assumption Making**: Unblocks the process by making reasonable assumptions (MVP mindset) instead of asking questions.

## Usage

```bash
# 1. Dump your thoughts
echo "I want a leaderboard. Top 10 users. Reset weekly." > inbox/leaderboard_dump.md

# 2. Run Product
ralphus product

# Result: 
# - inbox/leaderboard_dump.md is MOVED to inbox/archive/
# - ideas/leaderboard.md is CREATED with User Story, Scope, and Assumptions.
```

## Why use this?

-   **Garbage In, Gold Out**: Prevents the Architect from trying to engineer a messy requirement.
-   **Async Workflow**: You dump ideas when you have them. Ralphus processes them when you run the factory.
-   **Bias for Action**: Keeps the pipeline moving by making assumptions (which you can correct later in `ideas/` if needed).

## Workflow Integration

1.  **Human**: Writes `inbox/dump.md`.
2.  **Product**: Generates `ideas/*.md`.
3.  **Architect**: Generates `specs/*.md`.
4.  **Code**: Implements features.
