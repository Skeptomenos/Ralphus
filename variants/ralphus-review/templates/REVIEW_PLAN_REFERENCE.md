# Code Review Plan

## Summary

| Metric | Value |
|--------|-------|
| **Review Target** | pr / diff / codebase |
| **Branch** | feature/branch |
| **Files** | 0 reviewed / 0 total |
| **Findings** | 0 (0 critical, 0 high) |
| **Status** | In Progress |

## Review Items

### Priority 0 - Critical (Security, Auth, Payments)
| Status | File | Focus Areas | Findings |
|--------|------|-------------|----------|
| [ ] | `src/auth/login.ts` | Input validation, session | - |

### Priority 1 - Core Logic (Business Logic, APIs)
| Status | File | Focus Areas | Findings |
|--------|------|-------------|----------|
| [ ] | `src/api/routes.ts` | Auth checks, edge cases | - |

### Priority 2 - Integration (External Services, DB)
| Status | File | Focus Areas | Findings |
|--------|------|-------------|----------|
| [ ] | `src/db/queries.ts` | SQL injection, N+1 | - |

### Priority 3 - UI/Presentation
| Status | File | Focus Areas | Findings |
|--------|------|-------------|----------|
| [ ] | `src/components/Form.tsx` | XSS, accessibility | - |

### Priority 4 - Configuration
| Status | File | Focus Areas | Findings |
|--------|------|-------------|----------|
| [ ] | `config.ts` | Secrets, env exposure | - |

## Approval Criteria
- [ ] No critical/high severity findings unaddressed
- [ ] All security concerns documented
- [ ] Code follows project conventions

## Review Log
| Date | File | Result |
|------|------|--------|
| - | - | - |
