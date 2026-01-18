# Review Finding Format

## [SEVERITY] Finding Title

**File**: `path/to/file.ts:42-48`
**Category**: Security | Correctness | Performance | Maintainability | Testing
**Severity**: Critical | High | Medium | Low | Info

### Description
What is wrong and why it matters.

### Current Code
```
// problematic code
```

### Suggested Fix
```
// improved code
```

### Verification
1. How to verify the fix

---

## Example

## [CRITICAL] SQL Injection in User Query

**File**: `src/db/users.ts:23`
**Category**: Security
**Severity**: Critical

### Description
User input directly interpolated into SQL query, allowing injection attacks.

### Current Code
```sql
SELECT * FROM users WHERE id = ${userId}
```

### Suggested Fix
```sql
SELECT * FROM users WHERE id = $1', [userId]
```

### Verification
1. Test with malicious input: `1; DROP TABLE users;--`
2. Verify parameterized query escapes input
