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

## Immutability and Explicit Side Effects

- Prefer immutable data: avoid mutating arguments or shared state when a copy is feasible.
- Make side effects explicit: I/O, network, DB, logging. Isolate them so logic is easy to test.

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
