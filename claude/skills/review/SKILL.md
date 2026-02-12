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
8. After user approval, post the comments:
   - GitHub: use `gh api` to post review comments on specific lines, or `gh pr review <number>` for the overall review.
   - GitLab: use `glab mr note <number>` for comments.

## Comment Format

Use these prefixes for every comment, as defined in CLAUDE.md:

| Prefix | Meaning | Blocking? |
|--------|---------|-----------|
| `issue:` | Must be addressed | Yes |
| `question:` | Need clarification | Yes |
| `suggestion:` | Optional improvement | No |
| `nit:` | Minor style | No |
| `praise:` | Highlight good practices | No |

Each comment should:
- Start with the prefix.
- Reference the file and line number.
- Be concise and actionable.
- Explain WHY, not just WHAT.

Example:
```
issue: `handleAuth` doesn't validate the token expiration before use.
This could allow expired tokens to access protected routes.

suggestion: Consider extracting this retry logic into a shared helper,
since `fetchUser` and `fetchOrders` use the same pattern.

praise: Clean separation of the validation pipeline here. Each step
is easy to test independently.
```

## Review Summary

After all file-level comments, provide an overall summary:

```
## Summary

<1-2 sentences on the overall quality and purpose of the PR>

### Blocking
- <list of issues that must be addressed>

### Non-blocking
- <list of suggestions and nits>

### Verdict
APPROVE | REQUEST_CHANGES | COMMENT
```

Choose the verdict based on:
- **APPROVE**: no blocking issues found.
- **REQUEST_CHANGES**: one or more `issue:` or `question:` comments exist.
- **COMMENT**: only non-blocking feedback.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always present the full review to the user before posting any comments.
- Never post comments without explicit user approval.
- Never approve a PR that has failing tests or lint errors.
- If the required CLI tool (`gh` or `glab`) is not installed, stop and tell the user.
- If there is no PR/MR to review, say so and stop.
- Do not include `Co-authored-by` lines in any comments.

## Related skills

- `/pr` - Create or update the PR/MR being reviewed.
- `/checks` - Verify CI/CD pipeline status before approving.
- `/commit` - Commit fixes after addressing review feedback.
