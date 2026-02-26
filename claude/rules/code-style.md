# Code Style

- DRY, SOLID, KISS
- Small functions (< 30 lines)
- Meaningful names
- No magic numbers
- Single export per file
- For functions with many arguments, pass one options object. Return objects.
- File order: main export first, then subcomponents, helpers, static content, types
- Design for change: isolate business logic from the framework. Prefer dependency inversion.
- Prefer composition over inheritance
- Use braces for all control structures
- **Never swallow errors**: no empty catch; log with context, rethrow or handle
- **No deep nesting**: max 3 levels of indentation. Use guard clauses and early returns to flatten control flow. If a function needs deeper nesting, extract the inner logic into a separate function
- **Strong typing**: use explicit types for function parameters, return values, and public interfaces. Never use `any` as a type. If the type is truly unknown, use `unknown` and narrow it. Enable strict mode in TypeScript projects

## Immutability and Explicit Side Effects

Make side effects explicit: I/O, network, DB, logging. Isolate them so logic is easy to test.

### Functions

- Never mutate arguments. Copy first, modify the copy, return it.
- Return new values instead of modifying state in place. `map`/`filter`/`reduce` over `forEach` with push.
- If a function reads and writes external state, split it: one pure function for the logic, one impure wrapper for the I/O.

### Objects and Collections

- Use `const` by default. `let` only when reassignment is genuinely needed, never `var`.
- Spread or structured clone instead of in-place mutation: `{ ...obj, field: newValue }` not `obj.field = newValue`.
- For arrays: `[...arr, item]`, `.filter()`, `.map()` instead of `.push()`, `.splice()`, `.sort()` on the original.
- Freeze shared configuration and constant objects: `Object.freeze()` or `as const`.
- Deep nesting that requires deep copies is a design smell. Flatten the structure or use an immutability library.

### State Management

- State transitions produce new state, never mutate the previous one. This applies to frontend stores, domain models, and state machines.
- Derive values from state with selectors or computed properties. Never cache derived values as mutable fields that can drift.
- When a framework requires mutation internally, like Immer or MobX, confine it to the framework boundary. The rest of the code should treat state as read-only.

### Database

- Default to append-only for audit-sensitive data: insert new rows instead of updating existing ones. Use a `version` or `effective_at` column to track history.
- Soft delete (`deleted_at`) over hard delete when recoverability matters.
- For event-driven systems, store events as immutable facts. Derive current state by replaying or from a materialized view.
- Updates are fine for mutable operational data like counters, status fields, and caches. Do not force append-only where it adds complexity without value.

## Data Safety

Before writing any code that mutates state, whether database, API, queue, file, or cache, answer three questions:

### 1. Is this idempotent?

Can this operation run twice with the same input without causing damage? If not, add a guard:

| Layer | Guard |
|-------|-------|
| API endpoint | `Idempotency-Key` header, return cached response on duplicate |
| Event/message handler | Deduplicate by message ID before processing |
| Database write | Upsert, `ON CONFLICT DO NOTHING`, or conditional expression |
| State transition | Check current state before transitioning, reject duplicates |
| File/object write | Precondition check (ETag, version) or write to temp + atomic rename |

### 2. Is this atomic?

If multiple writes must succeed or fail together, they need a transaction. No exceptions.

| Scope | Pattern |
|-------|---------|
| Single SQL database | Transaction |
| Single NoSQL item | Conditional expression |
| Multiple NoSQL items | `TransactWriteItems` or equivalent batch |
| Cross-service | Outbox table + event, or saga with compensating actions |

### 3. Can duplicates reach this code?

Networks retry. Queues redeliver. Users double-click. Cron jobs overlap. If any of these apply:

- Extract a natural deduplication key: request ID, event ID, or composite like user + action + date
- Check before processing, record after processing
- Use a durable store for dedup state, never in-memory only

See `rules/resilience.md` for retry and dedup strategies, `rules/database.md` for conditional write and transaction patterns.

## Error Classification

Every `catch` block and error callback must classify the error before deciding what to do. A bare catch that logs and rethrows without classification is a bug.

| Classification | Action |
|---------------|--------|
| Transient: timeout, 429, 503, connection reset, lock contention | Log as warn, retry with exponential backoff + jitter |
| Permanent: 400, 404, validation failure, auth rejected | Log as error with context, fail immediately, never retry |
| Ambiguous: 500, unknown exception | Retry up to 3 times, then treat as permanent |

Classify at the boundary where the error originates. Propagate the classification upstream so callers know whether to retry. See `rules/resilience.md` for retry strategies, circuit breakers, and timeout budgets.

## Comments Policy

**Code should be self-explanatory.** Only add comments when:

- Complex algorithm that cannot be simplified
- Non-obvious business rule
- Workaround for external issue
- Doc comments for public APIs

## Backward Compatibility

- Do not break existing callers, APIs, or config without a plan
- Document breaking changes and migration steps

## Automation-Friendly Workflows

- Prefer **idempotent** operations for scripts, migrations, and deploys
- Prefer **non-interactive** commands for CI and scripts
- When adding scripts or CLI, document required env, exit codes, and how to run in CI

## Dependencies

1. **Ask permission.** Never add without approval.
2. **Check existing.** Maybe already solved natively.
3. **Evaluate.** Recent commits? Vulnerabilities?
4. **Size.** Avoid heavy packages for simple tasks.
5. Pin exact versions. Separate dev dependencies. Commit lockfile.
6. Prefer native/stdlib over third-party when equivalent.
