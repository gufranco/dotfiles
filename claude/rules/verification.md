# Verification

## Core Rule

No completion claims without fresh verification evidence. Previous runs, cached results, and "it should work" are not evidence.

## Gate Function

Before declaring any task complete:

1. **Identify** what proves the claim. What command, test, or check would fail if the work were wrong?
2. **Run** it. In the current session, right now.
3. **Read** the output. The full output, not just the exit code.
4. **Verify** the output matches the expected result.
5. **Only then** claim the task is done.

## What Counts as Evidence

| Claim | Required evidence |
|-------|------------------|
| "Tests pass" | Test command output showing 0 failures, run in this session |
| "Build succeeds" | Build command output with no errors, run in this session |
| "Lint is clean" | Lint command output with 0 warnings and 0 errors |
| "Bug is fixed" | Reproduction steps that previously failed now succeed |
| "Feature works" | Demonstration with specific inputs and expected outputs |
| "No regressions" | Full test suite output, not just the changed test |
| "File was updated" | Read the file and confirm the changes are present |
| "Endpoint returns X" | Actual response from the endpoint, not the code that should return X |

## Common Failures to Catch

- "Tests pass" based on a previous run, but code changed since then
- "It should work" based on reading the code, without executing it
- "Build succeeds" based on no syntax errors, without actually building
- "Fixed the bug" based on the fix looking correct, without reproducing
- Conflating "no errors" with "works correctly" (silent failures)

## Verification by Task Type

**Code changes**: run tests + lint + build. All three.

**Configuration changes**: verify the config loads correctly. Start the relevant service or run a validation command.

**Infrastructure changes**: `terraform plan` shows expected diff. After apply, verify the resource exists with a direct query.

**Documentation changes**: verify links work, code examples run, and referenced files exist.

**Dependency changes**: lockfile committed, tests pass, build succeeds. No version conflicts.

## Partial Completion

If you cannot verify everything:

- State what was verified and what was not.
- Explain why full verification was not possible.
- Never round up. 80% done is not done.
