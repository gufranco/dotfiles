# Code Style

- DRY, SOLID, KISS
- Small functions (< 30 lines)
- Meaningful names
- No magic numbers
- Single export per file
- For functions with many arguments, pass one options object. Return objects.
- File order: main export first, then subcomponents, helpers, static content, types
- Design for change: isolate business logic from the framework. Prefer dependency inversion.
- **Domain exception boundary**: services and domain logic throw domain-specific error classes, never framework HTTP exceptions. An exception filter or middleware at the boundary maps domain errors to HTTP responses. This keeps business logic testable without an HTTP context.
- **Validation infrastructure**: in NestJS projects, register validation globally via interceptor + method decorator, not per-parameter pipes. Controllers should have no validation imports or logic. The decorator declares the schema, the interceptor enforces it.
- Prefer composition over inheritance
- Use braces for all control structures
- **Never swallow errors**: no empty catch; log with context, rethrow or handle
- **No deep nesting**: max 3 levels of indentation. Use guard clauses and early returns to flatten control flow. If a function needs deeper nesting, extract the inner logic into a separate function
- **Strong typing**: use explicit types for function parameters, return values, and public interfaces. Never use `any` as a type. If the type is truly unknown, use `unknown` and narrow it. Enable strict mode in TypeScript projects
- **Enums over string literal unions**: never use inline string literal unions for domain values like statuses, roles, or categories. Define a string enum instead. Enums exist at runtime, can be iterated, validated, and referenced as values, not just types. They are the single source of truth for the set of allowed values

```typescript
// Bad: type-only, vanishes at runtime, duplicated at every usage site
declare status: 'new' | 'in_progress' | 'terminated';

// Good: single source of truth, usable as both type and value
enum ContractStatus {
  New = 'new',
  InProgress = 'in_progress',
  Terminated = 'terminated',
}
declare status: ContractStatus;
```

## TypeScript Type Constructs

Use the right construct for the job. Do not default to `type` for everything.

| Construct | When to use |
|-----------|------------|
| `interface` | Object shapes: DTOs, props, service contracts, anything a class might implement. Prefer for public APIs |
| `type` | Unions, intersections, mapped types, conditional types, tuples, function signatures. Anything `interface` cannot express |
| `enum` (string) | Fixed sets of domain values that need runtime existence: statuses, roles, categories, event types |
| `as const` object | Lookup tables and config maps where each value carries metadata or when you need both keys and values as derived types |

### Rules

- **`interface` for object shapes, `type` for the rest.** This is the dividing line. Do not mix them for the same purpose in the same codebase.
- **Consistency within a codebase.** If DTOs use `interface`, all DTOs use `interface`. No exceptions.
- **Never use `type` to alias a single primitive.** `type UserId = string` adds indirection without safety. If you need a branded/opaque type, use a branded pattern that the compiler actually enforces.
- **Prefer `interface` when either works.** `interface` produces clearer error messages, supports declaration merging, and signals "this is a shape" at a glance.
- **`as const` objects for rich enumerations.** When each value needs associated metadata, a `const` object with a derived union type beats a parallel enum plus map.

```typescript
// interface: object shapes
interface CreateUserDto {
  email: string;
  name: string;
}

// type: unions, intersections, function signatures
type Result<T> = { ok: true; data: T } | { ok: false; error: AppError };
type Handler = (req: Request, res: Response) => Promise<void>;

// enum: domain value sets with runtime presence
enum Role {
  Admin = 'admin',
  Member = 'member',
  Guest = 'guest',
}

// as const: lookup tables with metadata
const HTTP_STATUS = {
  OK: { code: 200, message: 'OK' },
  NOT_FOUND: { code: 404, message: 'Not Found' },
  INTERNAL: { code: 500, message: 'Internal Server Error' },
} as const;

type HttpStatusKey = keyof typeof HTTP_STATUS;
```

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

Can this operation run twice with the same input without causing damage? If not, add a guard. See `rules/resilience.md` (Idempotency) for patterns by layer: API, event handler, database, state machine, file storage.

### 2. Is this atomic?

If multiple writes must succeed or fail together, they need a transaction. No exceptions. See `rules/database.md` (Transactions and Atomic Writes) for patterns by scope: SQL, NoSQL, cross-service.

### 3. Can duplicates reach this code?

Networks retry. Queues redeliver. Users double-click. Cron jobs overlap. If any of these apply, extract a natural deduplication key and use a durable store for dedup state. See `rules/resilience.md` (Deduplication) for message processing and database-level dedup patterns.

## Error Classification

Every `catch` block and error callback must classify the error before deciding what to do. A bare catch that logs and rethrows without classification is a bug. Classify as transient (retry with backoff), permanent (fail immediately), or ambiguous (retry with limit, then treat as permanent). See `rules/resilience.md` for the full classification table, retry strategies, circuit breakers, and timeout budgets.

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

## Validation

- **Zod** is the preferred validation library for TypeScript projects
- Validate semantically, not just syntactically: verify monetary values are positive, dates are valid and in expected ranges, enums match allowed values
- Validate both input and output schemas at system boundaries

## File Naming

For projects using domain-driven structure, follow the `name-of-content.type.ts` pattern:

- `user-credentials.service.ts`
- `create-order.dto.ts`
- `payment-status.enum.ts`

Group by domain context in folders: `schemas/`, `services/`, `controllers/`, etc.

## Versions

- Always use the latest stable or LTS version of languages, runtimes, and dependencies
- When a platform has version constraints (AWS Lambda, Vercel), use the latest version available on that platform
- Check for available upgrades during assessment or project setup

## Code Examples

Every code snippet produced in any context must follow every rule in this file and all other project rules. This applies to review comments, PR descriptions, documentation, chat responses, commit messages, and any other output that contains code.

A code example that violates a rule is a defect, regardless of where it appears. Common violations to watch for:

- `any` as a type. Use `unknown` and narrow, or provide the correct type
- Bare `catch` blocks that log and rethrow without classifying the error
- Missing error handling on operations that can fail
- Magic numbers instead of named constants
- Inline string literal unions instead of enums for domain values
- Empty catch blocks that swallow errors silently

If a fix suggestion in a review comment introduces a rule violation, the suggestion itself is a review defect. The reviewer must hold their own examples to the same standard as the code they are reviewing.
