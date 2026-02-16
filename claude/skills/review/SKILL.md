---
name: review
description: Review a pull request or local branch changes following the code review conventions from CLAUDE.md.
---

Review a pull request, merge request, or local branch changes with an extremely rigorous, detail-oriented analysis. Every line of the diff is scrutinized for correctness, security, performance, maintainability, and adherence to best practices. This review leaves nothing to chance.

Use the checklist in `reviewer-prompt.md` in this directory as a structured guide. Go through every single category. Do not skip sections because the changes "look simple."

## When to use

- Before merging a PR/MR to catch issues early.
- When asked to review someone else's PR/MR.
- Before opening a PR, to catch issues early and save review cycles.
- When stuck on your own code and want a fresh perspective.

## When NOT to use

- For trivial changes like typo fixes that don't need formal review.
- When there are no changes to review (no PR and no local commits ahead of base).

## Arguments

This skill accepts optional arguments after `/review`:

- No arguments: review the PR/MR for the current branch. If no PR/MR exists, automatically fall back to local mode.
- A PR/MR number (e.g. `123`): review that specific PR/MR.
- A URL: review the PR/MR at that URL.
- `--local`: skip PR lookup entirely and review the local branch diff against the base branch. Useful before opening a PR.

## Steps

1. **Gather initial context.** Run these **in parallel**:
   - `git remote get-url origin` to detect the git platform.
   - `git branch --show-current` to get the current branch.
   - Determine the CLI tool from the remote URL: `github.com` means `gh`, `gitlab` means `glab`. Verify with `which <tool>`.
2. **Determine the review mode (PR or local):**
   - If `--local` was passed, go directly to **local mode** (step 3B).
   - If a PR/MR number or URL was provided, look up that specific PR/MR:
     - GitHub: `gh pr view <number> --json number,url,title,body,state,baseRefName,headRefName`.
     - GitLab: `glab mr view <number>`.
     - **Check the state immediately.** If not `OPEN` (e.g. `MERGED` or `CLOSED`), tell the user the current state and stop.
   - If no arguments were provided, check if a PR/MR exists for the current branch:
     - GitHub: `gh pr view --json number,url,title,body,state,baseRefName,headRefName`.
     - GitLab: `glab mr view`.
     - If a PR/MR exists and is `OPEN`, continue in **PR mode** (step 3A).
     - If the PR/MR exists but is not `OPEN`, tell the user the state and stop.
     - **If no PR/MR exists, automatically fall back to local mode** (step 3B). Tell the user: "No PR found for this branch, reviewing local changes."
3. **Get the diff and context.** This step differs by mode:

   **3A. PR mode.** Run these **in parallel**:
   - Metadata:
     - GitHub: `gh pr view <number> --json title,body,baseRefName,headRefName,files,commits`.
     - GitLab: `glab mr view <number>`.
   - Diff:
     - GitHub: `gh pr diff <number>`.
     - GitLab: `glab mr diff <number>`.

   **3B. Local mode.** Run these **in parallel**:
   - Detect the base branch:
     - GitHub: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`.
     - GitLab: `glab repo view --output json` and extract the default branch.
     - Fallback: `git remote show origin` for "HEAD branch", then `main`/`master`.
   - `git fetch origin` to ensure the remote is up to date.
   - Then run **in parallel**:
     - `git log --oneline origin/<base>..HEAD` to get commits. If there are no commits, say so and stop.
     - `git diff origin/<base>...HEAD --stat` for the stat summary.
     - `git diff origin/<base>...HEAD` for the full diff.
   - If the branch also has uncommitted changes (`git status --porcelain`), warn the user that only committed changes are being reviewed.

4. **Understand the context before judging the code:**
   - In PR mode: read the PR description and commit messages for intent.
   - In local mode: read the commit messages for intent. There is no PR description yet.
   - If the changes touch files you're not familiar with, read the surrounding code in those files to understand existing patterns, conventions, and architecture. Do not review code in isolation.
5. **Deep analysis of every changed file.** Go through the full checklist in `reviewer-prompt.md`. For each file, evaluate:
   - **Correctness:** Does the logic actually do what it claims? Trace through the code mentally with concrete inputs, especially edge cases. Look for off-by-one errors, null/undefined access, wrong operator precedence, incorrect boolean logic, missing return statements, unreachable code.
   - **Security:** Apply the full OWASP top 10 lens. Check for injection, broken auth, sensitive data exposure, XXE, broken access control, misconfig, XSS, insecure deserialization, known vulnerable components, insufficient logging. Check for secrets, tokens, or credentials in the diff.
   - **Error handling:** Are all error paths covered? Are errors caught with context, or silently swallowed? Are error messages helpful for debugging? Is the error propagation strategy consistent? Could a thrown exception crash a request handler?
   - **Performance:** Look for O(n^2) loops hidden as nested iterations, unnecessary allocations inside loops, missing database indexes on new queries, N+1 query patterns, unbounded list fetches, missing pagination, synchronous I/O blocking the event loop, unnecessary re-renders.
   - **Concurrency and race conditions:** Shared mutable state, missing locks, time-of-check-to-time-of-use (TOCTOU) bugs, unhandled promise rejections, missing `await`, fire-and-forget async calls that should be awaited.
   - **Data integrity:** Missing validation at system boundaries, missing database constraints, missing uniqueness checks, potential for duplicate processing, missing idempotency on mutations.
   - **Naming and readability:** Are variables, functions, and files named with precision? Could someone unfamiliar with the codebase understand this code? Are abstractions at the right level? Is the code self-documenting or does it need comments that are missing?
   - **Design:** Single responsibility respected? Coupling between modules appropriate? Dependencies flowing in the right direction? Composition over inheritance? Is this the simplest solution that works, or is it over/under-engineered?
   - **Testing:** Are the changes covered by meaningful tests? Do tests verify real behavior or just mock behavior? Are edge cases and error paths tested? Is the test structure clean (AAA pattern)? Are assertions specific enough to catch regressions?
   - **Consistency:** Does the code follow the existing patterns in the codebase? Is the style consistent with surrounding code? Are similar problems solved the same way?
6. **If the project has tests, lint, or build commands,** run them locally to verify the changes pass. Report the results.
7. **Check branch freshness and test evidence.** Do both **in parallel**:
   - Verify the branch is up to date with the base branch. If behind, this is a blocking issue.
   - In PR mode: verify the PR includes evidence of tests passing with coverage percentage. If missing, this is a blocking issue.
   - In local mode: skip the test evidence check on the PR description since there is no PR yet. Running tests locally in step 6 serves as the evidence.
8. **Present the full review to the user.** Format as described below.
   - In local mode: clearly label the review as "Local Review" so the user knows this was not posted anywhere.
9. **Ask the user what to do next.** After presenting the review:
    - If issues were found, ask the user: "Want me to fix these issues?" If yes, apply the fixes directly, then run tests to verify. After fixing, suggest `/commit` to commit and `/pr` to open the PR.
    - In PR mode: also ask if the user wants to post the review as inline comments. If yes, post after explicit approval:
      - GitHub: use `gh api repos/{owner}/{repo}/pulls/{number}/reviews` with a JSON payload containing `event`, `body`, and `comments` array. Each comment has `path`, `line`, `side`, and `body`. Always post individual comments on the exact lines, never a single big comment.
      - GitLab: use `glab mr note <number>` for comments.
    - In local mode: do NOT post anything. If the review is clean, suggest `/pr` to open the PR.

## Review Standards

This review operates at the highest standard. The bar for approval is:

- Zero bugs, zero security issues, zero data integrity risks.
- Every error path handled explicitly with context.
- Every public input validated.
- Every new behavior covered by meaningful tests.
- Performance characteristics understood and acceptable.
- Code is clear enough that a new team member could maintain it.

If something is "probably fine," that's not good enough. If you have to squint to understand what a function does, that's a problem. If a test only checks the happy path, that's incomplete.

Be demanding, but always be helpful. The goal is to make the code excellent, not to block the developer. Every issue you raise must come with a clear explanation of why it matters and a concrete code example showing how to fix it.

## Comment Format

Every comment must include three things:

1. **What's wrong:** State the issue directly.
2. **Why it matters:** Explain the concrete risk or consequence. Not "this is bad practice" but "this will cause X when Y happens."
3. **How to fix it:** Provide a code example showing the correct approach. Use fenced code blocks with the right language tag.

Write every comment as if you are a senior engineer mentoring a colleague. Be direct and precise, but generous with explanation. The developer should finish reading your comment knowing exactly what to do and why.

Do not use prefix labels like `issue:`, `suggestion:`, or `nit:`. Just say what you mean. The severity should be obvious from the content.

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

Brief positive note when something is genuinely well done:

```
Clean use of the strategy pattern here. Each payment processor
is independently testable and adding a new one doesn't touch
existing code.
```

## Review Summary

The overall review body should be a direct, honest assessment. Start with what the PR gets right, then list what needs attention. Be specific: name the files and the issues.

Choose the verdict based on what you found:
- **APPROVE**: Zero issues found. Tests pass, coverage is adequate, code is clean. This is a high bar.
- **REQUEST_CHANGES**: Any bugs, security issues, missing error handling, missing tests, stale branch, or missing test evidence. Most reviews will land here.
- **COMMENT**: Minor suggestions only, nothing that would cause problems in production.

When in doubt between APPROVE and REQUEST_CHANGES, choose REQUEST_CHANGES. It's always better to ask for one more look than to let a problem through.

## Test Evidence

Always check if the PR includes evidence of tests passing and coverage percentage. If missing, leave a comment asking the author to:
- Run the test suite and show the output with coverage.
- Record it with asciinema and include the URL in the PR description.

This applies to any PR that changes behavior. Do not approve without test evidence.

If tests exist but coverage is below 80% for the changed code, flag it. If the PR adds new behavior with zero tests, that alone is enough for REQUEST_CHANGES.

## Branch Freshness

Check if the branch is up to date with the base branch. If it is behind, ask the author to rebase and re-run the tests with fresh evidence. If the rebase causes conflicts, ask the author to resolve them and provide test evidence again after resolution. Stale branches should not be approved.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always read surrounding code to understand context before reviewing changes. Never review a diff in isolation.
- Always present the full review to the user before posting any comments.
- Always post comments as individual inline comments on the exact lines where the change is needed. Never post a single big comment with everything.
- Always include a code example in every comment that points out an issue. The developer should see exactly what the fix looks like.
- Never post comments without explicit user approval.
- Never approve a PR that has failing tests or lint errors.
- Never approve a PR without evidence of tests passing and coverage percentage.
- Never approve a PR whose branch is behind the base branch. Ask for rebase and fresh test evidence.
- Never approve a PR where new behavior is not covered by tests.
- Never let something slide because "it's a small PR" or "it's just a refactor." Small changes can introduce big bugs.
- Every comment must sound like a real person wrote it. No prefix labels, no formulaic language, no template-driven phrasing.
- If the required CLI tool (`gh` or `glab`) is not installed and a PR number/URL was given, stop and tell the user. In local mode, the CLI tool is only needed for base branch detection and is not strictly required.
- If no PR/MR exists and no local commits are ahead of the base branch, say so and stop.
- Never review a PR/MR that is not open. Check the state before doing any work. If merged or closed, tell the user and stop immediately.
- In local mode, never post comments anywhere. Present the review to the user only.
- In local mode, if the review is clean, suggest the user run `/pr` to open the PR.
- Do not include `Co-authored-by` lines in any comments.

## Related skills

- `/pr` - Create or update the PR/MR being reviewed.
- `/checks` - Verify CI/CD pipeline status before approving.
- `/commit` - Commit fixes after addressing review feedback.
