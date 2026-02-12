---
name: pr
description: Create or update a pull request with a clear title and structured description following CLAUDE.md conventions.
---

Create or update a pull request (or merge request) for the current branch following the PR format defined in CLAUDE.md. Supports both GitHub and GitLab.

## When to use

- After committing changes to a feature branch and ready for review.
- When updating an existing PR/MR description after changes.
- When creating a draft PR/MR for early feedback.

## When NOT to use

- On the main/master branch. PRs are for feature branches.
- When there are uncommitted changes. Use `/commit` first.
- When there are no commits ahead of the base branch.

## Arguments

This skill accepts optional arguments after `/pr`:

- No arguments: create a new PR/MR.
- `--draft`: create as a draft PR/MR.
- `update` or an existing PR/MR number: update the title and description of an existing PR/MR.

## Steps

1. Detect the git platform and CLI tool:
   - Run `git remote get-url origin` to get the remote URL.
   - If the URL contains `github.com`, use `gh` (GitHub CLI).
   - If the URL contains `gitlab` (e.g. `gitlab.com` or a self-hosted GitLab), use `glab` (GitLab CLI).
   - If neither matches, ask the user which platform they use.
   - Verify the CLI tool is installed with `which <tool>`. If not installed, stop and tell the user.
2. Run `git branch --show-current` to get the current branch name.
3. Check if a PR/MR already exists for this branch:
   - GitHub: run `gh pr view --json number,url,state` (exit code 0 means it exists).
   - GitLab: run `glab mr view` (exit code 0 means it exists).
   - If a PR/MR already exists and the user did NOT pass `update` or a number, show the existing URL and ask whether to update it or stop.
4. Detect the base branch:
   - GitHub: run `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`.
   - GitLab: run `glab repo view --output json` and extract the default branch.
   - If both fail, run `git remote show origin` and look for "HEAD branch".
   - Last resort: fall back to `main` or `master` based on what exists locally.
5. Run `git fetch origin` to ensure the remote is up to date.
6. If the project has tests, lint, or build commands, run them to verify the changes pass before pushing. If they fail, stop and tell the user.
7. Rebase on the base branch before pushing:
   - Run `git rebase origin/<base>`.
   - If there are conflicts, stop and tell the user to resolve them manually.
8. Run `git log --oneline origin/<base>..HEAD` to see all commits that will be in the PR.
9. Run `git diff origin/<base>...HEAD --stat` to see which files changed.
10. Run `git diff origin/<base>...HEAD` to understand the actual changes.
11. Push the branch to the remote:
    - Run `git rev-parse --abbrev-ref @{upstream}` to check for a tracking branch.
    - If no upstream exists, push with `git push -u origin <branch>`.
    - If upstream exists but is behind, push with `git push`.
12. Build the PR/MR title and description following the format below.
13. Create or update the PR/MR:
    - **Create (GitHub):** `gh pr create --title "<title>" --body-file <tmpfile>`. Add `--draft` if requested.
    - **Create (GitLab):** `glab mr create --title "<title>" --description "$(cat <tmpfile>)"`. Add `--draft` if requested.
    - **Update (GitHub):** `gh pr edit <number> --title "<title>" --body-file <tmpfile>`.
    - **Update (GitLab):** `glab mr update <number> --title "<title>" --description "$(cat <tmpfile>)"`.
    - Always write the description to a temp file first and use `--body-file` (GitHub) or read from it (GitLab) to avoid shell escaping issues with multi-line content.
    - Clean up the temp file after the command succeeds.
14. Show the PR/MR URL when done.

## PR Title

- Clear, specific summary of what the PR accomplishes.
- Describe the outcome, not the process.
- Use conventional commit style when it fits: `type(scope): subject`.
- When a ticket ID is available in the branch name, prefix it: `TICKET-ID: description`.
- Max 70 characters.

Good: `feat(auth): add SSO login with Google and GitHub providers`
Bad: `update auth`, `fix stuff`, `changes`

## PR Description

### Template detection

Before generating the description, check if the repo has a PR/MR template:

- GitHub: look for `.github/PULL_REQUEST_TEMPLATE.md` or `.github/PULL_REQUEST_TEMPLATE/` directory.
- GitLab: look for `.gitlab/merge_request_templates/` directory or a `merge_request_template.md` at the repo root.

If a template exists, use it as the base structure and fill in the sections with the actual changes. If no template exists, use the default structure below.

### Default structure

Scale the description to the size of the PR:

**Small PR (1-2 commits, single concern):** A short paragraph explaining what changed and why. No section headers needed.

**Standard PR (multiple commits or files):** Use this structure:

```
## What

One paragraph explaining what changed and why. A reviewer reading only
this paragraph should understand the full picture.

## How

Key implementation decisions, trade-offs, and anything non-obvious.
Skip trivial details the diff already shows.

## Testing

How the changes were verified. Include commands, screenshots, or steps
to reproduce.
```

Add a `## Breaking changes` section only if there are breaking changes, with migration steps.

### Description rules

- Wrap at 72 characters.
- Be concise and direct. No filler prose.
- Use bullet points for lists.
- Do not include `Co-authored-by` lines.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always detect the base branch dynamically. Never hardcode it.
- Always rebase on the base branch and push before creating the PR/MR.
- Always check for an existing PR/MR before attempting to create one.
- Always check for repo PR/MR templates before generating the description.
- Always write the body to a temp file to avoid shell escaping issues.
- If the required CLI tool (`gh` or `glab`) is not installed, stop and tell the user.
- If there are no commits ahead of the base branch, say so and stop.
- If rebase has conflicts, stop and tell the user. Do not force push or skip conflicts.
- Do not merge the PR/MR. Only create or update it.

## Related skills

- `/commit` - Create semantic commits before opening a PR.
- `/checks` - Monitor CI/CD pipeline status after pushing.
- `/review` - Review a PR/MR before merging.
