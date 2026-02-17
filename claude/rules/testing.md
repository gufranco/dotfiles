# Testing

## Philosophy

Tests should verify real behavior, not mock behavior.

## Priority

1. **Integration** (preferred): real database, real services
2. **E2E**: full user flows
3. **Unit** (fallback): pure functions only

## Mocks Policy (STRICT)

**Allowed:** External APIs, Time/Date, Randomness

**NEVER Mock:** Database, your own services, your own modules

## Test Structure (AAA Pattern)

Every test MUST follow Arrange-Act-Assert with these exact comments:

```
// Arrange
// Act
// Assert
```

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
