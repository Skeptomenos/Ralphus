# [Feature Name]

> **Status**: Approved by Architect
> **Type**: Feature | Refactor | Fix | Migration

## Context
This feature enables users to X so that Y.

## Technical Design
- **Data Model**: Extend `User` in `src/types/user.ts`
- **API**: New endpoint `POST /api/settings`
- **Components**: Reuse existing components

## Requirements
1. User can toggle dark mode
2. Preference persists to database

## Implementation Plan (Atomic Tasks)

### Phase 1: Backend
- [ ] Add `theme` column migration
- [ ] Update `User` type

### Phase 2: API
- [ ] Create `PATCH /api/preferences` endpoint
- [ ] Add validation and tests

### Phase 3: Frontend
- [ ] Create `ThemeContext.tsx` provider
- [ ] Add toggle to settings

## Task Format

Each task should include:
1. **What to build** (files, functions)
2. **Test criteria** (how to verify)
3. Optional: **Dependencies**

**Good Example:**
- [ ] 2.3 Create config files for all variants
      Files: variants/*/config.sh
      Test: Each sources without error
      Depends: 2.1

**Bad Example (too granular):**
- [ ] 2.3 Create config.sh for ralphus-code
- [ ] 2.4 Create config.sh for ralphus-test
... (separate tasks for identical work)

## Verification
- Run `npm test`
- Check database state
