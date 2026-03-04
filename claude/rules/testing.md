# Testing

## Philosophy

Tests should verify real behavior, not mock behavior.

## Priority

1. **Integration** (preferred): real database, real services
2. **E2E**: full user flows
3. **Unit** (fallback): pure functions only

## Mocks Policy (STRICT)

**Allowed:** External third-party APIs outside your control, Time/Date, Randomness

**NEVER Mock:**
- **Database**: connect to a real database. Add it to docker-compose for the test environment. Use `beforeAll()` to seed, `afterAll()` to clean up
- **Redis, caches, queues**: connect to real instances. Add them to docker-compose
- **Your own services and modules**: if the code calls an internal service, the test calls the real service. Mocking your own code proves the mock works, not the code

A test that mocks infrastructure it depends on may pass while the actual integration is broken. This is worse than having no test at all. During code review, mocking internal infrastructure is a **blocking issue**.

## Test Structure (AAA Pattern)

Every test MUST follow Arrange-Act-Assert with these exact comments, verbatim, with no additional text:

```
// Arrange
// Act
// Assert
```

These are bare section markers. Never append descriptions, colons, or explanations to them. Write `// Act`, never `// Act: do something`. The test name and the code itself communicate intent. If extra context is needed, the test is too complex and should be split or renamed.

## Test Data

Use a fake data generator to produce test data. Never use hardcoded static values like `"test@example.com"`, `"John Doe"`, or `"password123"` in test setup.

Static values hide implicit couplings. A test that passes with `"test@example.com"` might fail with `"María.O'Connor+tag@subdomain.example.co.uk"`. Fake data generators produce realistic variety that catches these edge cases.

**Seeding:** always seed the generator per test file or describe block to keep tests deterministic. A seeded generator produces the same sequence on every run, satisfying the deterministic test requirement.

| Language | Library |
|----------|---------|
| TypeScript / JavaScript | `@faker-js/faker` |
| Python | `faker` |
| Go | `gofakeit` |
| Ruby | `faker` |
| Rust | `fake` |
| Java / Kotlin | `datafaker` |

```typescript
// Bad: static values hide edge cases
const user = { name: 'John Doe', email: 'test@example.com' };

// Good: realistic, deterministic via seed
import { faker } from '@faker-js/faker';
faker.seed(12345);
const user = { name: faker.person.fullName(), email: faker.internet.email() };
```

During code review, static test data is a **blocking issue** with the same severity as mocking internal infrastructure.

## Test Naming

- Describe behavior, not implementation
- **NEVER** reference ticket/task IDs in test names
- Use: `should create user with valid email`

## Coverage

- New code: 80%+ coverage
- Existing code: do not reduce coverage

## Test Scenario Planning

When planning non-trivial tasks, generate test scenarios before implementing. Scenarios become acceptance criteria: the task is only done when all pass.

### Requirement Traceability

Map each requirement to specific test scenarios:

| Requirement | Test Scenario | Type | Priority |
|-------------|---------------|------|----------|
| User can create X | `should create X with valid data` | Integration | P0 |
| X validates email | `should reject invalid email format` | Unit | P0 |

### Priority Definitions

- **P0**: Critical path, core behavior. Failure means broken feature. Every requirement needs at least one.
- **P1**: Security, integration points, important edge cases.
- **P2**: Performance, accessibility, backward compatibility. Add when the task touches that area.

### Required Categories

1. **Happy path**: All success scenarios with valid inputs. One scenario per distinct success outcome.
2. **Edge cases**: Boundary values, empty/null/zero, special characters, max lengths.
3. **Error handling**: Invalid inputs, missing fields, unauthorized access, resource not found.
4. **Security**: Auth bypass attempts, injection, input sanitization. Include when the task touches APIs or auth.
5. **Integration points**: External service failures, timeouts, contract changes. Include when calling external services.

### Skip for Trivial Changes

Typos, config values, single-line fixes with no behavior change: a short list of 1-3 scenarios or "no new scenarios, existing tests cover this" is enough.

## Deterministic Tests

Every test must produce the same result on every run, on every machine. A test that passes 99% of the time is a broken test.

**Never depend on:**

| Source of flakiness | Fix |
|---------------------|-----|
| Current time | Inject a fixed clock or mock `Date.now()` |
| Random values | Seed the fake data generator per test file. Never use unseeded random generation |
| Network calls | Mock external APIs (allowed by mock policy) |
| Shared database state | Isolate per test: unique IDs, transactions that rollback, or fresh schema |
| Test execution order | No shared mutable state between tests. Each test sets up its own data |
| Timing and delays | Never use `setTimeout` or `sleep` in assertions. Use deterministic signals (events, callbacks, polling with timeout) |
| File system | Use temp directories, clean up in `afterEach` |

If a test fails intermittently, fix or delete it. Flaky tests erode trust in the entire suite and train developers to ignore failures.
