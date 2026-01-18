# Code Review Checklist

## Security (Check All Explicitly)

### Input Validation
- [ ] All user inputs validated/sanitized
- [ ] Type checking at API boundaries
- [ ] Length/format constraints enforced
- [ ] Reject invalid input early

### Injection Prevention
- [ ] SQL injection: Parameterized queries only
- [ ] XSS: Output encoding, CSP headers
- [ ] Command injection: No shell with user input
- [ ] Path traversal: Validate file paths
- [ ] NoSQL injection: Sanitize query operators

### Authentication & Authorization
- [ ] Auth required on protected endpoints
- [ ] Authorization checks (not just authentication)
- [ ] Session handling secure (httpOnly, secure flags)
- [ ] No privilege escalation paths

### Secrets & Sensitive Data
- [ ] No hardcoded secrets/keys
- [ ] Environment variables for config
- [ ] Sensitive data not logged
- [ ] PII handled per policy

## Correctness (Adapt to codebase)
- [ ] Edge cases handled (null, empty, bounds)
- [ ] Errors caught and handled appropriately
- [ ] Types used correctly, no unsafe casts
- [ ] API contracts match implementation

## Performance
- [ ] No N+1 queries
- [ ] No unbounded loops
- [ ] Resources cleaned up (listeners, connections)
- [ ] Pagination on list endpoints

## Maintainability
- [ ] Follows project conventions
- [ ] No dead/duplicate code
- [ ] Comments explain "why" not "what"

## Testing
- [ ] Tests exist for feature
- [ ] Error and edge cases covered
- [ ] Tests are deterministic

## Severity Levels

| Level    | Description                 | Action               |
|----------|-----------------------------|----------------------|
| Critical | Security vuln, data loss    | Block merge, fix now |
| High     | Bug, logic error            | Fix before merge     |
| Medium   | Code smell, suboptimal      | Should fix           |
| Low      | Style, minor improvement    | Nice to have         |
| Info     | Suggestion, question        | No action required   |
