# [Feature Name]

> **Status**: Approved by Architect
> **Type**: Feature | Refactor | Fix | Migration

## Context
<!-- Explain the "Why". Reference user stories or review findings. -->
This feature enables users to X so that Y.
OR: This spec addresses security vulnerabilities found in the auth module.

## Technical Design
<!-- The Architect's research goes here. Link to existing code. -->
- **Data Model**: Extend `User` interface in `src/types/user.ts`.
- **API**: New endpoint `POST /api/settings`.
- **Components**: Reuse `Button.tsx` and `Modal.tsx`.

## Requirements
<!-- High-level functional requirements -->
1. User can toggle dark mode in settings.
2. Preference persists to database.
3. System respects system-preference by default.

## Implementation Plan (Atomic Tasks)
<!-- The "Ralphus Code" checklist. Must be checkable. -->

### Phase 1: Backend / Data
- [ ] Add `theme` column to users table migration.
- [ ] Update `User` type in `src/types/user.ts`.
- [ ] Update `updateUser` service to handle theme field.

### Phase 2: API
- [ ] Create `PATCH /api/user/preferences` endpoint.
- [ ] Add validation for theme values ('light' | 'dark' | 'system').
- [ ] Add integration test for preference update.

### Phase 3: Frontend
- [ ] Create `ThemeContext.tsx` provider.
- [ ] Update `App.tsx` to wrap with provider.
- [ ] Add toggle switch to `SettingsPage.tsx`.

## Verification Steps
<!-- How to prove it works -->
- Run `npm test src/features/settings`.
- Check database state after toggle.
