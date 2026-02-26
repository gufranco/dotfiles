# Debugging

## Iron Law

No fixes without root cause investigation first. Guessing wastes more time than investigating.

## Four Phases

### 1. Reproduce

- Can you trigger the failure reliably? If not, gather more data before proceeding.
- Find the minimal reproduction: strip away everything unrelated.
- Record the exact input, environment, and steps.
- If the bug is intermittent, look for timing, concurrency, or state dependencies.

### 2. Isolate

- Binary search the problem space. Comment out halves of the system until the failure disappears.
- Check: is this a code bug, a data bug, a config bug, or an environment bug?
- Read the full error message and stack trace. The root cause is often in the middle, not the top.
- Check recent changes: `git log --oneline -20`, `git diff HEAD~5`.
- Check if the bug exists on the default branch. If not, `git bisect` to find the introducing commit.

### 3. Root Cause

- Explain WHY it happens, not just WHERE.
- Verify your theory by predicting what will happen with a specific test input, then running it.
- If the theory doesn't hold, discard it entirely and start over. Do not patch a wrong theory.
- Common root causes to check:
  - State: shared mutable state, stale cache, missing initialization
  - Timing: race condition, missing await, event ordering
  - Data: null/undefined, wrong type, encoding, timezone, off-by-one
  - Environment: missing env var, wrong version, different OS behavior
  - Integration: API contract changed, schema mismatch, network timeout

### 4. Fix and Verify

- Fix the root cause, not the symptom.
- One change at a time. If you change two things and it works, you don't know which one fixed it.
- Write a test that fails before the fix and passes after.
- Check for other places where the same pattern exists. Fix them all.
- Run the full test suite, not just the affected test.

## Multi-Component Debugging

When the issue spans multiple services or layers:

1. Start at the boundary where the error is visible.
2. Trace the request path backward: response, handler, service, database, external API.
3. Add temporary logging at each boundary to narrow down which layer fails.
4. Remove diagnostic instrumentation after finding the root cause.

## Common Traps

- **Fixing the symptom**: adding a null check instead of understanding why the value is null.
- **Confirmation bias**: seeing what you expect in the logs instead of what's there.
- **Scope creep**: "while I'm here, let me also fix..." during debugging. Don't. File it separately.
- **Stale assumptions**: "this worked yesterday" is not evidence. Verify the current state.
- **Ignoring warnings**: warnings often become errors under different conditions.
