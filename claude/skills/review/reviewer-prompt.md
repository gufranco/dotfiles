# Code Reviewer Prompt

Use this as a structured checklist when reviewing a PR/MR diff. Go through every single category. Do not skip sections because the change "looks small" or "is just a refactor." Check everything.

For every issue found, explain why it matters and provide a code example showing the fix.

This prompt has two parts:

1. **Review-only categories** (below): 12 categories for correctness, style, backward compatibility, and test coverage.
2. **Shared engineering checklist** (`../../checklists/engineering.md`): 32 architecture, resilience, and infrastructure categories used by both `/review` and `/assessment`. Apply every category relevant to the change.

## 1. Correctness

- [ ] Does every function do exactly what its name promises?
- [ ] Trace through the logic with at least three inputs: a normal case, an edge case, and an invalid case. Does it behave correctly?
- [ ] Off-by-one errors in loops, slices, or array access?
- [ ] Null, undefined, or empty values handled on every code path?
- [ ] Boolean logic correct? No inverted conditions, missing negations, or wrong operator precedence?
- [ ] Return values checked on every call that can fail?
- [ ] Type coercion traps? Loose equality (`==`) where strict (`===`) is needed?
- [ ] Unreachable code after early returns, throws, or breaks?
- [ ] Switch statements: missing `break`, missing `default` case?
- [ ] Regex patterns correct and anchored? Could they match unintended input?
- [ ] Date/time handling: timezone-aware? Daylight saving edge cases?
- [ ] Floating point comparisons done with epsilon tolerance?
- [ ] String handling: encoding-safe? Unicode edge cases?
- [ ] Recursive functions: guaranteed to terminate? Stack depth bounded?

## 2. Algorithmic Performance

- [ ] No O(n^2) or worse hidden in nested loops, repeated `.find()`, `.filter()` inside `.map()`?
- [ ] Data structures appropriate? Using a Set for lookups instead of array `.includes()` in a loop?
- [ ] Sorting only when necessary? Using the right algorithm for the data size?
- [ ] No unbounded data loaded into memory? Streams used for large files?
- [ ] No allocations inside hot loops (object creation, string concatenation)?
- [ ] File handles, connections, and streams closed after use?
- [ ] No synchronous I/O in async code paths?

## 3. Frontend Performance (if applicable)

- [ ] No unnecessary re-renders? Dependencies in `useEffect`/`useMemo`/`useCallback` correct?
- [ ] Large lists virtualized?
- [ ] Images and assets optimized?
- [ ] No blocking operations on the main thread?
- [ ] Bundle size impact considered? No unnecessarily large dependencies added?

## 4. Testing

### Coverage
- [ ] Every new function/method has tests?
- [ ] Every code branch tested? (success, each error case, each edge case)
- [ ] Coverage on changed code at 80% or above?
- [ ] Integration tests for database operations, not just mocked unit tests?

### Test quality
- [ ] Tests follow AAA pattern (Arrange, Act, Assert) with those exact comments?
- [ ] Test names describe behavior, not implementation? ("should reject expired token" not "test validateToken")
- [ ] Assertions specific enough to catch regressions? Not just `toBeTruthy()` when a specific value matters?
- [ ] No test-only backdoors in production code?
- [ ] Tests independent? No shared mutable state between tests? No ordering dependency?
- [ ] Tests actually verify the thing they claim to test? (not just that no error was thrown)
- [ ] Negative tests present? (invalid input, unauthorized access, missing resources)
- [ ] Boundary value tests? (empty arrays, zero, max int, empty string, null)
- [ ] Contract tests at service boundaries? Consumer expectations verified against provider responses?
- [ ] Property-based tests for complex logic? Invariants hold across randomized inputs, not just hand-picked examples?

### Mock policy (STRICT, blocking issue if violated)
Per `rules/testing.md` mock policy. Verify:
- [ ] Database, Redis, queues, and caches use real connections via docker-compose, with `beforeAll()` seed and `afterAll()` cleanup?
- [ ] Own services and modules tested with real implementations, not mocks?
- [ ] Only external third-party APIs, time, and randomness are mocked?
- [ ] Any mock of internal infrastructure flagged as a **blocking issue**?

### Test evidence
- [ ] Test evidence present per `rules/code-review.md` "Test Evidence" policy? CI passing counts. Manual output only when tests are not automated.

## 5. Code Quality and Design

- [ ] Functions under 30 lines? If not, can they be decomposed?
- [ ] Single responsibility: each function does one thing?
- [ ] No code duplication? DRY respected without premature abstraction?
- [ ] No magic numbers or hardcoded strings? Constants named and extracted?
- [ ] No dead code, commented-out code, or leftover debug statements?
- [ ] Dependencies flow inward? Business logic does not import framework-specific modules?
- [ ] Composition over inheritance?
- [ ] Side effects isolated and explicit?
- [ ] No over-engineering? No unnecessary abstractions, factories, or patterns for a single use case?
- [ ] No under-engineering? No inline SQL strings, no god functions, no 500-line files?

## 6. Naming and Readability

- [ ] Variable names describe what the value IS, not how it was computed?
- [ ] Function names describe what the function DOES, using verbs?
- [ ] Boolean variables use `is`, `has`, `can`, `should` prefixes?
- [ ] No single-letter variables outside of trivial loops (`i`, `j`)?
- [ ] No misleading names? (e.g. `getUser` that also modifies state)
- [ ] Abbreviations avoided unless universally understood? (`url`, `id`, `html` are fine; `usr`, `mgr`, `cfg` are not)
- [ ] File and module names consistent with the project's naming convention?
- [ ] Code readable without comments? If comments are needed, do they explain WHY, not WHAT?

## 7. Architecture and Patterns

- [ ] Change follows existing patterns in the codebase?
- [ ] If a new pattern is introduced, is it justified and better than the existing one?
- [ ] Coupling between modules appropriate? Can the changed code be tested in isolation?
- [ ] No circular dependencies introduced?
- [ ] Configuration externalized? No environment-specific behavior hardcoded?
- [ ] Decision reversibility considered? One-way doors (hard to undo: public API shape, database schema, data deletion) get extra scrutiny. Two-way doors (easy to change: internal implementation, feature flags) can move faster.
- [ ] Coupling measurable? Module depends only on abstractions it needs, not concrete implementations it happens to know about. Fan-out (number of dependencies) kept low.

## 8. Backward Compatibility

- [ ] Does this change break existing callers, consumers, or clients? Check function signatures, API responses, event payloads, and configuration formats.
- [ ] If a public function signature changed, are all callers in the codebase updated?
- [ ] If an API response shape changed, are frontend consumers and external integrations updated?
- [ ] If a database column was renamed, removed, or retyped, does the migration follow the safe migration pattern (add new, dual-write, migrate readers, drop old)?
- [ ] If a message or event schema changed, can existing consumers still process old messages in flight?
- [ ] If environment variables were renamed or removed, are deployment configs, CI pipelines, and documentation updated?
- [ ] If a feature was removed, is there a deprecation path or migration guide?

## 9. Dependencies

- [ ] New dependency justified? Could this be done with existing code or stdlib?
- [ ] Dependency actively maintained? Recent commits? Known vulnerabilities?
- [ ] Version pinned exactly in lockfile?
- [ ] License compatible with the project?
- [ ] Bundle size impact acceptable? (for frontend dependencies)
- [ ] Dev dependencies correctly separated from production dependencies?

## 10. Documentation and PR Quality

- [ ] PR description explains what changed and why?
- [ ] Breaking changes documented with migration steps?
- [ ] README updated if setup, env vars, or API changed?
- [ ] New env vars documented in `.env.example`?
- [ ] PR scope focused? One logical change, not a grab-bag of unrelated fixes?
- [ ] Commit history clean and logical?

## 11. Cross-File Consistency

This section applies after all per-file checks are done. Review the diff as a whole, looking for contradictions between files.

- [ ] Design assumptions consistent? If one file assumes graceful degradation, no other file in the diff enforces a hard dependency on the same resource.
- [ ] Module-level side effects traced? New imports do not trigger connections, env validation throws, or scheduled tasks that change startup behavior for the entire application.
- [ ] Configuration complete? Every new env var, dependency, or infrastructure requirement introduced in the diff is also added to `.env.example`, Docker configs, CI pipelines, and documentation.
- [ ] Contracts aligned across boundaries? Frontend sends data in the exact format backend expects: header names, field names, parameter types, and positions all match.
- [ ] Error types flow correctly? Errors thrown in one module are caught and handled correctly by callers. No unhandled error types crossing module boundaries.
- [ ] Symmetry maintained? Resources acquired are released on all paths. Features enabled can be disabled. Data written can be read back consistently.

## 12. Cascading Fix Analysis

For every issue found in sections 1-11, evaluate the downstream effects of the suggested fix.

- [ ] Would the fix introduce a new dependency, env var, or startup requirement?
- [ ] Would the fix change a function signature or public interface, breaking callers not in this diff?
- [ ] Would the fix require coordinated changes in files not touched by this PR?
- [ ] Would the fix change error behavior that other code relies on?
- [ ] Would the fix need new tests that are not mentioned in the review comment?

When any answer is yes, the review comment must include a "When implementing this fix, also..." note. The goal is that the author can address the issue and all its downstream effects in a single iteration.

## Shared Engineering Checklist

After checking all review-only categories above, apply every relevant category from `../../checklists/engineering.md`. The 32 categories cover:

1. Idempotency and deduplication
2. Atomicity and transactions
3. Error classification and retry
4. Caching
5. Consistency model
6. Back pressure and load management
7. Bulkhead isolation
8. Concurrency control
9. Saga and cross-service coordination
10. Event ordering and delivery
11. Distributed locking
12. Schema evolution
13. Immutability
14. Query optimization
15. Observability
16. Security and access control
17. API contract design
18. External dependency resilience
19. Async processing resilience
20. Deployment readiness
21. Graceful degradation
22. Data modeling
23. Capacity planning
24. Testability
25. Cost awareness
26. Multi-tenancy
27. Migration strategy
28. Infrastructure as Code
29. Networking and service discovery
30. Container orchestration
31. CI/CD pipeline design
32. Cloud architecture

Not all categories apply to every change. Check only those relevant to the system and the scope of the diff.

## Comment Format

Every comment must include three things:

1. **What's wrong:** State the issue directly.
2. **Why it matters:** Explain the concrete risk or consequence. Not "this is bad practice" but "this will cause X when Y happens."
3. **How to fix it:** Provide a code example showing the correct approach. Use fenced code blocks with the right language tag.

Write every comment as if you are a senior engineer mentoring a colleague. Be direct and precise, but generous with explanation. The developer should finish reading your comment knowing exactly what to do and why.

Do not use prefix labels like `issue:`, `suggestion:`, or `nit:`. Just say what you mean. The severity should be obvious from the content.

Code examples in review comments must comply with all project coding standards defined in `rules/code-style.md`. A fix suggestion that introduces a rule violation, like using `any` as a type, bare `catch` blocks, magic numbers, or inline string literal unions, is itself a review defect. Hold your own examples to the same standard as the code you are reviewing.

### Example comments

Detailed issue with fix:

````
This handler doesn't validate `userId` before passing it to the database query.
If someone sends a request with `userId=; DROP TABLE users`, the ORM might not
parameterize this correctly depending on how `findByRawId` is implemented
internally. Even if the current ORM handles it, this is a defense-in-depth
problem: the next person who touches this code might swap the query method.

Validate and type-cast at the boundary:

```typescript
const userId = parseInt(req.params.userId, 10);
if (Number.isNaN(userId) || userId <= 0) {
  return res.status(400).json({ error: { code: 'INVALID_ID', message: 'userId must be a positive integer' } });
}
const user = await userRepository.findById(userId);
```
````

Performance concern with alternative:

````
`getAllUsers()` fetches every user from the database and then filters in memory
with `.filter()`. Right now there are 500 users so it's fine, but this is O(n)
memory and O(n) time on every request. When the user table grows, this becomes
a real problem, and it's easy to forget this is happening since the code looks
innocent.

Push the filter down to the database:

```typescript
const activeUsers = await userRepository.find({
  where: { status: 'active', role },
  take: pageSize,
  skip: (page - 1) * pageSize,
});
```
````

Missing test coverage:

````
This function has three branches: success, validation error, and database error.
The test only covers the success case. If someone refactors the error handling
later, there's no test to catch a regression.

Add tests for the other two paths:

```typescript
it('should return 400 when email format is invalid', () => {
  // Arrange
  const invalidPayload = { email: 'not-an-email', name: 'Test' };

  // Act
  const response = await request(app).post('/users').send(invalidPayload);

  // Assert
  expect(response.status).toBe(400);
  expect(response.body.error.code).toBe('VALIDATION_ERROR');
});

it('should return 500 and log the error when the database is unavailable', () => {
  // Arrange
  jest.spyOn(userRepository, 'save').mockRejectedValue(new Error('connection refused'));

  // Act
  const response = await request(app).post('/users').send(validPayload);

  // Assert
  expect(response.status).toBe(500);
  expect(logger.error).toHaveBeenCalledWith(
    expect.stringContaining('connection refused'),
    expect.objectContaining({ requestId: expect.any(String) }),
  );
});
```
````

Concurrency issue:

````
There's a race condition between the `findOne` check and the `save` call. Two
requests hitting this endpoint at the same time with the same email could both
pass the uniqueness check, and you'd end up with duplicate records. This is a
classic TOCTOU bug.

Use a database-level unique constraint and handle the conflict:

```typescript
try {
  const user = userRepository.create({ email, name });
  await userRepository.save(user);
} catch (error) {
  if (error.code === '23505') { // PostgreSQL unique violation
    return res.status(409).json({
      error: { code: 'DUPLICATE_EMAIL', message: 'A user with this email already exists' },
    });
  }
  throw error;
}
```

And make sure the migration includes the constraint:

```sql
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);
```
````

Cascading fix warning (when the fix itself could introduce a new problem):

````
This handler doesn't validate `userId` before passing it to the query.

Validate and type-cast at the boundary:

```typescript
const userId = parseInt(req.params.userId, 10);
if (Number.isNaN(userId) || userId <= 0) {
  return res.status(400).json({ error: { code: 'INVALID_ID', message: 'userId must be a positive integer' } });
}
```

When implementing this fix, also update the integration tests in
`users.test.ts` to cover the new 400 response path. The existing tests
only send valid IDs, so without a new test case, the validation could
regress silently.
````

Brief positive note when something is genuinely well done:

```
Clean use of the strategy pattern here. Each payment processor
is independently testable and adding a new one doesn't touch
existing code.
```
