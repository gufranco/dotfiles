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
- `--base <branch>`: target a specific base branch instead of the default. Useful for stacked PRs or release branches.
- `--reviewer <user>`: request review from a specific user. Can be repeated for multiple reviewers.
- `--assignee <user>`: assign the PR/MR to a user.
- `--label <name>`: add a label. Can be repeated for multiple labels.
- `update` or an existing PR/MR number: update the title and description of an existing PR/MR.

Arguments can be combined: `/pr --draft --base develop --reviewer alice --label bugfix`.

## Steps

1. **Gather initial context.** Run these three commands **in parallel**:
   - `git status --porcelain` to check for uncommitted changes.
   - `git remote get-url origin` to detect the git platform.
   - `git branch --show-current` to get the current branch.
   - If there are uncommitted changes, stop and suggest `/commit`.
   - If on `main` or `master`, stop and tell the user PRs are for feature branches.
   - Determine the CLI tool from the remote URL: `github.com` means `gh`, `gitlab` means `glab`. Verify it is installed with `which <tool>`.
2. **Check existing PR and detect base branch.** Run these **in parallel**:
   - Check if a PR/MR already exists:
     - GitHub: `gh pr view --json number,url,state`.
     - GitLab: `glab mr view`.
   - Detect the base branch (unless `--base` was provided):
     - GitHub: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`.
     - GitLab: `glab repo view --output json` and extract the default branch.
     - Fallback: `git remote show origin` for "HEAD branch", then `main`/`master`.
   - If a PR/MR already exists and the user did NOT pass `update` or a number, show the existing URL and ask whether to update it or stop.
3. **Fetch and check for commits:**
   - Run `git fetch origin` to ensure the remote is up to date.
   - Run `git log --oneline origin/<base>..HEAD` to check for commits ahead of the base.
   - If there are no commits, say so and stop.
7. **If the project has tests, lint, or build commands,** run them to verify the changes pass before pushing. If they fail, stop and tell the user.
8. **Rebase on the base branch:**
   - First, check if the branch has already been pushed: run `git rev-parse --abbrev-ref @{upstream}` to detect an upstream tracking branch.
   - Run `git rebase origin/<base>`.
   - If there are conflicts, run `git rebase --abort` to restore a clean state, then stop and tell the user to resolve conflicts manually.
   - If the rebase rewrote commits and the branch was already pushed, use `git push --force-with-lease` in the push step. This is the only acceptable force push scenario, since rebase rewrites history.
   - If the rebase was a fast-forward (no commits rewritten), a normal push is sufficient.
9. **Check PR size and read the diff.** Run these two commands **in parallel**:
   - `git diff origin/<base>...HEAD --stat` for the stat summary.
   - `git diff origin/<base>...HEAD` for the full diff.
   - If the stat shows more than 400 lines changed, warn the user the PR is large. If over 1000, ask for confirmation.
   - If the full diff exceeds 2000 lines, rely on the stat output plus reading the most-changed files individually.
10. **Self-review the diff:**
    - Scan the changes for common issues before creating the PR:
      - Debug statements: `console.log`, `debugger`, `print(`, `binding.pry`, `import pdb`.
      - TODO/FIXME/HACK comments that might be unintentional.
      - Accidentally committed files: `.env`, `.DS_Store`, `node_modules`, editor config.
      - Large binary files.
    - If any issues are found, list them and ask the user whether to proceed or fix first.
12. **Extract issue references and check for UI changes** from the diff you already have. Do both at the same time:
    - Check the branch name and commit messages for ticket/issue patterns like `PROJ-123`, `Fixes #123`, `Closes #`, `Refs #`.
    - Check if the diff touches frontend files (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`, `.html`). If so, remind the user to include screenshots.
13. **Push the branch to the remote:**
    - If no upstream exists, push with `git push -u origin <branch>`.
    - If upstream exists and rebase rewrote history, push with `git push --force-with-lease`.
    - Otherwise, push with `git push`.
14. **Build the PR/MR title and description** following the format below.
15. **Create or update the PR/MR:**
    - Write the description to a temp file first to avoid shell escaping issues.
    - **Create (GitHub):** `gh pr create --title "<title>" --body-file <tmpfile>`. Add `--draft`, `--base`, `--reviewer`, `--assignee`, `--label` flags as provided.
    - **Create (GitLab):** `glab mr create --title "<title>" --description-file <tmpfile>`. Fall back to `--description "$(cat <tmpfile>)"` if `--description-file` is not supported. Add `--draft`, `--target-branch`, `--reviewer`, `--assignee`, `--label` flags as provided.
    - **Update (GitHub):** `gh pr edit <number> --title "<title>" --body-file <tmpfile>`. Add `--add-reviewer`, `--add-assignee`, `--add-label` if provided.
    - **Update (GitLab):** `glab mr update <number> --title "<title>" --description-file <tmpfile>`. Fall back to `--description "$(cat <tmpfile>)"` if `--description-file` is not supported.
    - Always clean up the temp file after the command completes, whether it succeeded or failed. Use a trap or finally block.
16. **Show the PR/MR URL when done.**

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

If issue references were found in the branch name or commits, add them at the end of the description: `Closes #123`, `Refs PROJ-456`.

### Description rules

- Be concise and direct. No filler prose.
- Use bullet points for lists.
- Do not include `Co-authored-by` lines.
- Do not hard-wrap lines. Let the markdown render naturally in the web UI.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always detect the base branch dynamically unless `--base` was provided. Never hardcode it.
- Always check for uncommitted changes before doing anything. Stop early if dirty.
- Always check for an existing PR/MR before attempting to create one.
- Always check for repo PR/MR templates before generating the description.
- Always write the body to a temp file to avoid shell escaping issues. Clean up the temp file on both success and failure.
- Always run `git rebase --abort` if a rebase hits conflicts. Never leave the repo in a mid-rebase state.
- Only force push with `--force-with-lease`, and only after a rebase that rewrote history. Never force push otherwise.
- If the required CLI tool (`gh` or `glab`) is not installed, stop and tell the user.
- If there are no commits ahead of the base branch, say so and stop.
- Warn the user if the PR exceeds 400 lines. Ask for confirmation if it exceeds 1000 lines.
- Do not merge the PR/MR. Only create or update it.

## Related skills

- `/commit` - Create semantic commits before opening a PR.
- `/checks` - Monitor CI/CD pipeline status after pushing.
- `/review` - Review a PR/MR before merging.
