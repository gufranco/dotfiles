# Code Reviewer Prompt

Use this as a structured checklist when reviewing a PR/MR diff. Go through every single category. Do not skip sections because the change "looks small" or "is just a refactor." Check everything.

For every issue found, explain why it matters and provide a code example showing the fix.

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

## 2. Security

### Injection and input handling
- [ ] SQL injection: all queries parameterized or using ORM? No string concatenation in queries?
- [ ] XSS: all user input escaped before rendering? Framework auto-escaping not bypassed (e.g. `dangerouslySetInnerHTML`, `v-html`, `| safe`)?
- [ ] Command injection: no user input passed to `exec`, `spawn`, or shell commands without sanitization?
- [ ] Path traversal: no user input used in file paths without validation? `../` sequences blocked?
- [ ] SSRF: no user-controlled URLs fetched without allowlist validation?
- [ ] Header injection: no user input in HTTP headers without sanitization?
- [ ] Template injection: no user input in template strings evaluated server-side?

### Authentication and authorization
- [ ] Auth check on every endpoint that needs it? No "auth by obscurity" (hidden URLs)?
- [ ] Authorization verified per-resource, not just per-role? (IDOR prevention)
- [ ] Tokens validated for expiration, signature, and audience?
- [ ] Password handling: hashed with bcrypt/argon2, never logged, never compared in plaintext?
- [ ] Session management: tokens rotated after auth state changes? Proper invalidation on logout?
- [ ] Rate limiting on auth endpoints?

### Data exposure
- [ ] No secrets, API keys, tokens, or credentials in code, comments, or config files?
- [ ] No sensitive data in logs, error messages, or stack traces?
- [ ] No PII leaked through API responses beyond what the caller needs?
- [ ] Error messages generic in production, no internal paths or query details?
- [ ] CORS configured correctly? Not using `*` with credentials?

### Cryptography
- [ ] No custom crypto implementations? Using well-known libraries?
- [ ] No weak algorithms (MD5, SHA1 for security purposes, DES)?
- [ ] Random values generated with cryptographically secure source?
- [ ] Secrets compared with constant-time comparison?

## 3. Error Handling

- [ ] Every `catch` block does something meaningful? No empty catches?
- [ ] Caught errors include context: what operation failed, with what input, and why?
- [ ] Error types distinguished? Not catching `Error` when only `ValidationError` is expected?
- [ ] Async errors handled? No unhandled promise rejections? No missing `await`?
- [ ] Error propagation consistent? Not mixing thrown exceptions with returned error codes in the same layer?
- [ ] HTTP status codes correct for each error type? (400 for bad input, 401 for unauthed, 403 for forbidden, 404 for missing, 409 for conflict, 500 for unexpected)
- [ ] Database errors wrapped with context before propagating?
- [ ] External API errors handled with specific messages, not generic "something went wrong"?
- [ ] Partial failure: if step 3 of 5 fails, are steps 1-2 rolled back or is the state consistent?
- [ ] Errors in cleanup code (finally blocks, defer) handled separately?

## 4. Performance

### Algorithmic complexity
- [ ] No O(n^2) or worse hidden in nested loops, repeated `.find()`, `.filter()` inside `.map()`?
- [ ] Data structures appropriate? Using a Set for lookups instead of array `.includes()` in a loop?
- [ ] Sorting only when necessary? Using the right algorithm for the data size?

### Database
- [ ] No N+1 query patterns? Using eager loading / joins where needed?
- [ ] No `SELECT *`? Only fetching needed columns?
- [ ] Queries filtered at the database level, not in application code?
- [ ] Pagination on list endpoints? Default and maximum page size set?
- [ ] New queries have appropriate indexes? Check `WHERE`, `JOIN`, and `ORDER BY` columns.
- [ ] Transactions used where multiple writes must be atomic?
- [ ] Connection pooling configured? No connection leak (opening without closing)?

### Memory and I/O
- [ ] No unbounded data loaded into memory? Streams used for large files?
- [ ] No allocations inside hot loops (object creation, string concatenation)?
- [ ] File handles, connections, and streams closed after use?
- [ ] Caching used where appropriate? Cache invalidation correct?
- [ ] No synchronous I/O in async code paths?
- [ ] HTTP requests to external services have timeouts configured?

### Frontend-specific (if applicable)
- [ ] No unnecessary re-renders? Dependencies in `useEffect`/`useMemo`/`useCallback` correct?
- [ ] Large lists virtualized?
- [ ] Images and assets optimized?
- [ ] No blocking operations on the main thread?
- [ ] Bundle size impact considered? No unnecessarily large dependencies added?

## 5. Concurrency and State

- [ ] Shared mutable state protected by locks, mutexes, or atomic operations?
- [ ] No TOCTOU (time-of-check-to-time-of-use) bugs? Check-then-act patterns use database constraints or CAS operations?
- [ ] Async operations awaited where the result matters?
- [ ] No fire-and-forget async calls that should be awaited or at least have error handlers?
- [ ] Database operations that must be atomic wrapped in transactions?
- [ ] Idempotency: can the same operation run twice without causing problems?
- [ ] Event ordering: does the code depend on events arriving in a specific order that isn't guaranteed?
- [ ] No deadlock potential from acquiring multiple locks?

## 6. Data Integrity

- [ ] Input validated at every system boundary (API endpoints, message handlers, file parsers)?
- [ ] Validation covers: type, format, range, length, and business rules?
- [ ] Database constraints match application-level validation? (NOT NULL, UNIQUE, CHECK, FK)
- [ ] Migrations safe? Adding columns as nullable first? No data loss on rollback?
- [ ] Soft delete used where audit trail matters?
- [ ] Timestamps in UTC? `created_at` and `updated_at` present on new tables?
- [ ] Enum values stored as strings, not integers that break when reordered?

## 7. API Design (if applicable)

- [ ] RESTful conventions followed? Correct HTTP methods and status codes?
- [ ] Request/response shapes consistent with existing endpoints?
- [ ] Breaking changes versioned or documented?
- [ ] Pagination, filtering, and sorting on list endpoints?
- [ ] Response includes only necessary data? No over-fetching?
- [ ] Error responses follow the standard format with `code`, `message`, and `requestId`?
- [ ] Content-Type headers correct?
- [ ] Idempotency keys on mutation endpoints that need them?

## 8. Testing

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
- [ ] Mocks used only for external services, time, and randomness? Database, own modules, and own services not mocked?
- [ ] Tests actually verify the thing they claim to test? (not just that no error was thrown)
- [ ] Negative tests present? (invalid input, unauthorized access, missing resources)
- [ ] Boundary value tests? (empty arrays, zero, max int, empty string, null)

### Test evidence
- [ ] PR description includes test output with coverage percentage?
- [ ] If missing, this is a blocking issue. Ask for it.

## 9. Code Quality and Design

- [ ] Functions under 30 lines? If not, can they be decomposed?
- [ ] Single responsibility: each function does one thing?
- [ ] No code duplication? DRY respected without premature abstraction?
- [ ] No magic numbers or hardcoded strings? Constants named and extracted?
- [ ] No dead code, commented-out code, or leftover debug statements?
- [ ] Dependencies flow inward? Business logic does not import framework-specific modules?
- [ ] Composition over inheritance?
- [ ] Immutability preferred? Arguments and shared state not mutated when a copy is feasible?
- [ ] Side effects isolated and explicit?
- [ ] No over-engineering? No unnecessary abstractions, factories, or patterns for a single use case?
- [ ] No under-engineering? No inline SQL strings, no god functions, no 500-line files?

## 10. Naming and Readability

- [ ] Variable names describe what the value IS, not how it was computed?
- [ ] Function names describe what the function DOES, using verbs?
- [ ] Boolean variables use `is`, `has`, `can`, `should` prefixes?
- [ ] No single-letter variables outside of trivial loops (`i`, `j`)?
- [ ] No misleading names? (e.g. `getUser` that also modifies state)
- [ ] Abbreviations avoided unless universally understood? (`url`, `id`, `html` are fine; `usr`, `mgr`, `cfg` are not)
- [ ] File and module names consistent with the project's naming convention?
- [ ] Code readable without comments? If comments are needed, do they explain WHY, not WHAT?

## 11. Architecture and Patterns

- [ ] Change follows existing patterns in the codebase?
- [ ] If a new pattern is introduced, is it justified and better than the existing one?
- [ ] Coupling between modules appropriate? Can the changed code be tested in isolation?
- [ ] No circular dependencies introduced?
- [ ] Configuration externalized? No environment-specific behavior hardcoded?
- [ ] Feature flags or gradual rollout for risky changes?
- [ ] Backward compatible with existing callers? Migration path for breaking changes?

## 12. Observability

- [ ] Logging at appropriate levels? (ERROR for failures, WARN for handled-but-unexpected, INFO for business events)
- [ ] Logs include `requestId` and enough context to trace the issue?
- [ ] No sensitive data logged (passwords, tokens, PII)?
- [ ] No logging inside tight loops?
- [ ] Metrics or monitoring for new critical paths?
- [ ] Health check endpoints updated if new dependencies added?

## 13. Dependencies

- [ ] New dependency justified? Could this be done with existing code or stdlib?
- [ ] Dependency actively maintained? Recent commits? Known vulnerabilities?
- [ ] Version pinned exactly in lockfile?
- [ ] License compatible with the project?
- [ ] Bundle size impact acceptable? (for frontend dependencies)
- [ ] Dev dependencies correctly separated from production dependencies?

## 14. Documentation and PR Quality

- [ ] PR description explains what changed and why?
- [ ] Breaking changes documented with migration steps?
- [ ] README updated if setup, env vars, or API changed?
- [ ] New env vars documented in `.env.example`?
- [ ] PR scope focused? One logical change, not a grab-bag of unrelated fixes?
- [ ] Commit history clean and logical?
