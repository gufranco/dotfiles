# Git Workflow

## Commit Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Subject Rules:**

- Imperative mood: "add" not "added" or "adds"
- No caps at start, no period at end
- Max 50 characters

**Body:** Wrap at 72 characters. Explain WHAT and WHY, not HOW.

**Footer:**

- `BREAKING CHANGE:` for breaking changes, or `!` after type/scope
- `Fixes #123`, `Closes #456`, `Refs #789`
- **NEVER** add `Co-authored-by` lines referencing any AI

## Branch Naming

```
<type>/<ticket-id>-<description>
```

Types: `feature/`, `bugfix/`, `hotfix/`, `release/`, `chore/`

## CI/CD Monitoring (MANDATORY)

After ANY push:

1. Run `gh pr checks --watch`
2. Wait for ALL checks
3. If failed: `gh run view <id> --log-failed`
4. Before fixing: search for an existing fix in source branch, open PRs, and remote branches
5. If no existing fix: Fix, push, repeat until green

**Never** mark task complete with failing/running pipeline.

## PR/MR Creation

**Title:** Clear, specific summary of what the PR accomplishes. Describe the outcome, not the process.
- Good: `feat(auth): add SSO login with Google and GitHub providers`
- Bad: `update auth`, `fix stuff`, `changes`

When a ticket ID exists, prefix it: `<TICKET-ID>: <description>`

**Description structure:**

- **What**: One paragraph explaining what changed and why. A reviewer reading only this paragraph should understand the full picture.
- **How**: Key implementation decisions, trade-offs, and anything non-obvious. Skip trivial details the diff already shows.
- **Testing**: How the changes were verified. Include commands, screenshots, or steps to reproduce.
- **Breaking changes**: If any, list them with migration steps.

Before opening:

1. Identify the base branch from git, never hardcode it
2. Fetch and rebase: `git fetch origin && git rebase origin/<base>`
3. Resolve conflicts if any, run tests locally

Prefer CLI over web UI:

```bash
gh pr create --title "<desc>" --body-file pr.md
gh pr create --draft --title "<TICKET-ID>: WIP"
gh pr merge <number> --squash --delete-branch
```

## Conflict Resolution

```bash
git fetch origin && git rebase origin/<base>
# Resolve conflicts manually
git add <file> && git rebase --continue
# Test locally, then:
git push --force-with-lease
```

## Post-Task Workflow

After completing significant features:

1. Stage and commit with conventional message
2. Push to remote: `git push`
3. Verify remote is updated

**Keep remote in sync.** Do not accumulate local-only commits.

## Rollback Strategy

If a change causes problems:

1. `git revert <commit>`, then push
2. Analyze what went wrong
3. Fix properly in new commit

**Never** force push or amend pushed commits.
