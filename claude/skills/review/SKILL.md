---
name: review
description: Review a pull request following the code review conventions from CLAUDE.md.
---

Review a pull request or merge request, analyzing the diff and posting structured comments following the code review conventions defined in CLAUDE.md. Supports both GitHub and GitLab.

Use the checklist in `reviewer-prompt.md` in this directory as a structured guide for the review.

## When to use

- Before merging a PR/MR to catch issues early.
- When asked to review someone else's PR/MR.
- When stuck on your own code and want a fresh perspective.

## When NOT to use

- When there is no PR/MR to review.
- For trivial changes like typo fixes that don't need formal review.

## Arguments

This skill accepts optional arguments after `/review`:

- No arguments: review the PR/MR for the current branch.
- A PR/MR number (e.g. `123`): review that specific PR/MR.
- A URL: review the PR/MR at that URL.

## Steps

1. Detect the git platform and CLI tool:
   - Run `git remote get-url origin` to get the remote URL.
   - If the URL contains `github.com`, use `gh` (GitHub CLI).
   - If the URL contains `gitlab` (e.g. `gitlab.com` or a self-hosted GitLab), use `glab` (GitLab CLI).
   - If neither matches, ask the user which platform they use.
   - Verify the CLI tool is installed with `which <tool>`. If not installed, stop and tell the user.
2. Find the PR/MR to review:
   - If a number or URL was provided, use that.
   - Otherwise, check the current branch:
     - GitHub: run `gh pr view --json number,url,title,body,baseRefName,headRefName`.
     - GitLab: run `glab mr view`.
   - If no PR/MR exists, say so and stop.
3. Get the PR/MR metadata:
   - GitHub: run `gh pr view <number> --json title,body,baseRefName,headRefName,files,commits`.
   - GitLab: run `glab mr view <number>`.
4. Get the full diff:
   - GitHub: run `gh pr diff <number>`.
   - GitLab: run `glab mr diff <number>`.
5. Read the diff carefully and analyze each changed file. For each file, consider:
   - Correctness: does the logic do what it claims?
   - Security: any vulnerabilities introduced (OWASP top 10)?
   - Error handling: are errors caught and handled properly?
   - Edge cases: are boundary conditions covered?
   - Naming: are variables, functions, and files named clearly?
   - Complexity: could anything be simplified?
   - Tests: are changes covered by tests?
   - Style: does it follow existing patterns in the codebase?
6. If the project has tests, lint, or build commands, run them locally to verify the changes pass.
7. Present the review to the user before posting anything. Format as described below.
8. After user approval, post the review with inline comments on specific lines:
   - GitHub: use `gh api repos/{owner}/{repo}/pulls/{number}/reviews` with a JSON payload containing `event`, `body`, and `comments` array. Each comment has `path`, `line`, `side`, and `body`. Always post individual comments on the exact lines, never a single big comment.
   - GitLab: use `glab mr note <number>` for comments.

## Comment Format

Do not use prefix labels like `issue:`, `suggestion:`, `nit:`, or `praise:`. Humans do not write like that. Just say what you mean directly.

Each comment should:
- Be concise and actionable.
- Explain WHY, not just WHAT.
- Sound like a real colleague wrote it.

Write every comment as if you are a coworker leaving feedback. Be direct and natural. Vary the tone between comments. Do not repeat the same sentence patterns. If something needs fixing, say so plainly. If you have a question, just ask it. If something is good, say it briefly.

Example:
```
`handleAuth` doesn't check token expiration before using it.
Expired tokens could still reach protected routes, you should
validate expiry before proceeding.

`fetchUser` and `fetchOrders` have the same retry logic. Worth
extracting to a shared helper so you don't have to maintain it
in two places.

The validation pipeline is well structured here. Each step is
easy to test on its own.
```

## Review Summary

The overall review body should be a short, natural summary. Say what the PR does well and what needs attention. Do not use structured templates with "Blocking" / "Non-blocking" headers.

Choose the verdict based on whether there are things that must be fixed before merging:
- **APPROVE**: nothing needs to change.
- **REQUEST_CHANGES**: something needs to be fixed or clarified.
- **COMMENT**: just feedback, nothing blocking.

## Test Evidence

Always check if the PR includes evidence of tests passing and coverage percentage. If missing, leave a comment asking the author to:
- Run the test suite and show the output with coverage.
- Record it with asciinema and include the URL in the PR description.

This applies to any PR that changes behavior. Do not approve without test evidence.

## Branch Freshness

Check if the branch is up to date with the base branch. If it is behind, ask the author to rebase and re-run the tests with fresh evidence. If the rebase causes conflicts, ask the author to resolve them and provide test evidence again after resolution. Stale branches should not be approved.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always present the full review to the user before posting any comments.
- Always post comments as individual inline comments on the exact lines where the change is needed. Never post a single big comment with everything.
- Never post comments without explicit user approval.
- Never approve a PR that has failing tests or lint errors.
- Never approve a PR without evidence of tests passing and coverage percentage.
- Never approve a PR whose branch is behind the base branch. Ask for rebase and fresh test evidence.
- Every comment must sound like a real person wrote it. No prefix labels, no formulaic language, no template-driven phrasing.
- If the required CLI tool (`gh` or `glab`) is not installed, stop and tell the user.
- If there is no PR/MR to review, say so and stop.
- Do not include `Co-authored-by` lines in any comments.

## Related skills

- `/pr` - Create or update the PR/MR being reviewed.
- `/checks` - Verify CI/CD pipeline status before approving.
- `/commit` - Commit fixes after addressing review feedback.
