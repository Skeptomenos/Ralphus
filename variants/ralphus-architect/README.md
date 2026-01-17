# Ralphus Architect

The Senior Technical Architect for your autonomous team. Converts raw ideas or bug reports into rigorous technical specifications for `ralphus-code`.

## Capabilities

1.  **Feature Architect**: Takes a raw user story (`ideas/foo.md`) -> Researches codebase -> Writes `specs/foo.md`.
2.  **Triage Architect**: Reads `reviews/*.md` -> Groups fixes -> Writes `specs/review-fixes.md`.

## Usage

```bash
# 1. New Feature
# Create a raw idea file first
echo "I want users to log in with GitHub" > ideas/social-auth.md

# Run Architect
ralphus architect feature ideas/social-auth.md

# Result: specs/social-auth.md is created with DB schema, API endpoints, and tasks.


# 2. Fix Bugs (Closing the Loop)
# Run Reviewer first
ralphus review

# Run Architect to triage
ralphus architect triage

# Result: specs/review-fixes.md is created with tasks to fix the bugs.
```

## Why use this?

-   **Reduced Hallucinations**: The Architect explicitly searches the codebase *before* writing specs, ensuring the Builder (Code) doesn't try to use libraries that don't exist.
-   **Standardization**: Output specs are guaranteed to be in the format `ralphus-code` prefers.
-   **Automation**: You don't have to copy-paste findings from reviews to specs manually.

## Workflow Integration

The full autonomous cycle:

1.  **Human**: Writes `ideas/feature.md`.
2.  **Architect**: Generates `specs/feature.md`.
3.  **Code**: Implements feature.
4.  **Review**: Finds issues (`reviews/*.md`).
5.  **Architect**: Generates `specs/review-fixes.md`.
6.  **Code**: Implements fixes.
