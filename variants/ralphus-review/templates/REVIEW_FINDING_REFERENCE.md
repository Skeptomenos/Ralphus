<!-- Review Finding Format - Reference Only -->

# Review Finding Template

Use this format for each finding in `reviews/FILENAME_review.md`.

---

## [SEVERITY] Finding Title

> One-line summary of the issue

**File**: `path/to/file.ts:42-48`  
**Category**: Security | Correctness | Performance | Maintainability | Testing  
**Severity**: Critical | High | Medium | Low | Info  

### Description

Explain the issue clearly:
- What is wrong
- Why it matters
- What could go wrong if not fixed

### Current Code

```typescript
// The problematic code
function validateInput(data: unknown) {
  return data as ValidData; // Unsafe cast without validation
}
```

### Suggested Fix

```typescript
// The improved code
function validateInput(data: unknown): ValidData {
  if (!isValidData(data)) {
    throw new ValidationError('Invalid input data');
  }
  return data;
}

function isValidData(data: unknown): data is ValidData {
  return (
    typeof data === 'object' &&
    data !== null &&
    'requiredField' in data
  );
}
```

### Verification

How to verify the fix is correct:
1. Run existing tests: `npm test`
2. Add test case for invalid input
3. Manual test with malformed data

### References

- [OWASP Input Validation](https://owasp.org/...)
- Project convention: AGENTS.md#validation

---

# Example Findings

## [CRITICAL] SQL Injection in User Query

**File**: `src/db/users.ts:23`  
**Category**: Security  
**Severity**: Critical  

### Description

User input is directly interpolated into SQL query string, allowing SQL injection attacks.

### Current Code

```typescript
const user = await db.query(`SELECT * FROM users WHERE id = ${userId}`);
```

### Suggested Fix

```typescript
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
```

### Verification

1. Test with `userId = "1; DROP TABLE users;--"`
2. Verify parameterized query escapes input

---

## [HIGH] Missing Auth Check on Admin Endpoint

**File**: `src/api/admin.ts:45`  
**Category**: Security  
**Severity**: High  

### Description

The `/admin/users` endpoint lacks authorization check. Any authenticated user can access admin functions.

### Current Code

```typescript
router.get('/admin/users', async (req, res) => {
  const users = await getAllUsers();
  res.json(users);
});
```

### Suggested Fix

```typescript
router.get('/admin/users', requireRole('admin'), async (req, res) => {
  const users = await getAllUsers();
  res.json(users);
});
```

### Verification

1. Test as regular user - should return 403
2. Test as admin - should return user list

---

## [MEDIUM] N+1 Query in Post Listing

**File**: `src/services/posts.ts:67`  
**Category**: Performance  
**Severity**: Medium  

### Description

Each post fetches its author separately, causing N+1 queries.

### Current Code

```typescript
const posts = await db.posts.findMany();
for (const post of posts) {
  post.author = await db.users.findUnique({ where: { id: post.authorId } });
}
```

### Suggested Fix

```typescript
const posts = await db.posts.findMany({
  include: { author: true }
});
```

### Verification

1. Enable query logging
2. Verify single query with JOIN
