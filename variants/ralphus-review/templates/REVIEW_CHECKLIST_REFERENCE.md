<!-- Standard Review Checklist - Reference Only -->

# Code Review Checklist

## Security (Always Check)

### Input Validation
- [ ] All user inputs validated/sanitized
- [ ] Type checking on API boundaries
- [ ] Length/format constraints enforced
- [ ] Reject invalid input early

### Injection Prevention
- [ ] SQL: Parameterized queries only (no string concatenation)
- [ ] XSS: Output encoding, CSP headers
- [ ] Command injection: No shell commands with user input
- [ ] Path traversal: Validate file paths

### Authentication & Authorization
- [ ] Auth required on protected endpoints
- [ ] Authorization checks (not just auth)
- [ ] Session handling secure (httpOnly, secure flags)
- [ ] No privilege escalation paths

### Secrets & Sensitive Data
- [ ] No hardcoded secrets/keys
- [ ] Environment variables for config
- [ ] Sensitive data not logged
- [ ] PII handled per policy

## Correctness

### Logic
- [ ] Code does what it's supposed to do
- [ ] Edge cases handled (null, empty, zero, negative, max)
- [ ] Boundary conditions correct
- [ ] Off-by-one errors checked

### Error Handling
- [ ] Errors caught and handled appropriately
- [ ] No swallowed exceptions
- [ ] User-facing errors are helpful but not leaky
- [ ] Cleanup on error paths (transactions, resources)

### Types & Contracts
- [ ] Types used correctly
- [ ] No unsafe type assertions without validation
- [ ] Nullability handled
- [ ] API contracts match implementation

## Performance

### Queries & Data
- [ ] No N+1 queries
- [ ] Appropriate indexes assumed/documented
- [ ] Pagination on list endpoints
- [ ] Batch operations where appropriate

### Algorithms & Loops
- [ ] No unbounded loops
- [ ] Appropriate data structures
- [ ] Time complexity reasonable
- [ ] Space complexity considered

### Resources
- [ ] Event listeners cleaned up
- [ ] Subscriptions unsubscribed
- [ ] Connections/handles closed
- [ ] Caching considered

## Maintainability

### Code Style
- [ ] Follows project conventions
- [ ] Consistent naming
- [ ] No magic numbers/strings
- [ ] Comments explain "why" not "what"

### Structure
- [ ] Functions are focused (SRP)
- [ ] Reasonable function length (<50 lines)
- [ ] No deep nesting (>3 levels)
- [ ] Dependencies injected/mockable

### Cleanliness
- [ ] No dead code
- [ ] No commented-out code
- [ ] No TODO/FIXME without tracking
- [ ] No duplicate code

## Testing

### Coverage
- [ ] Tests exist for the feature
- [ ] Happy path tested
- [ ] Error cases tested
- [ ] Edge cases tested

### Quality
- [ ] Tests are readable
- [ ] Tests are deterministic
- [ ] Tests don't depend on external state
- [ ] Mocks are appropriate

## Severity Levels

| Level | Description | Action Required |
|-------|-------------|-----------------|
| **Critical** | Security vulnerability, data loss risk | Block merge, fix immediately |
| **High** | Bug, logic error, significant issue | Fix before merge |
| **Medium** | Code smell, suboptimal approach | Should fix, can defer |
| **Low** | Style, minor improvement | Nice to have |
| **Info** | Suggestion, question, FYI | No action required |
