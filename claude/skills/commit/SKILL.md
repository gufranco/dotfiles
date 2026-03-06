---
name: commit
description: Analyze all uncommitted changes and create semantic commits following conventional commit format.
---

Analyze all uncommitted changes in the repository and create semantic commits following the commit format defined in CLAUDE.md and the template in `git/.gitmessage`.

## When to use

- After completing a task or feature and ready to save progress.
- When there are multiple unrelated changes that need separate commits.
- Before creating a PR/MR, to ensure clean commit history.

## When NOT to use

- When there are no uncommitted changes.

## Arguments

This skill accepts optional arguments after `/commit`:

- No arguments: commit changes and ask whether to push afterward.
- `--push`: commit and push to remote automatically without asking.
- `--pipeline`: commit, push, and monitor CI/CD checks until they pass or fail. Implies push. If `--push` is not also passed, asks for confirmation before pushing. On failure, offers to diagnose, fix, and re-push automatically.

Arguments can be combined: `/commit --push --pipeline`.

## Steps

1. Run these four commands **in parallel** to gather all context in one round:
   - `git status` to identify all modified, added, and deleted files.
   - `git diff` to understand the actual changes in each file.
   - `git diff --cached` to check for already staged changes.
   - `git log --oneline -10` to understand the existing commit style.
2. Group related changes into logical units. Each group becomes one commit. Consider:
   - Changes to the same feature or module belong together.
   - Unrelated changes to different areas must be separate commits.
   - Renames, moves, and formatting changes are separate from logic changes.
   - Test changes go with the code they test, not in a separate commit.
3. For each group, in dependency order:
   - Stage only the relevant files using `git add <file1> <file2> ...`. Never use `git add -A` or `git add .`.
   - Commit following the message format below.
4. After all commits, run `git status` and `git log --oneline` **in parallel** to verify clean tree and show summary.
5. **Push to remote:**
   - If `--push` or `--pipeline` was passed:
     - If `--push` was passed, push immediately without asking.
     - If only `--pipeline` was passed (no `--push`), ask the user: "Push to remote and monitor pipeline?"
     - If the user declines the push, stop here. `--pipeline` requires push to work.
   - Otherwise (no flags), ask the user: "Want me to push to remote?"
   - When pushing:
     - Check if an upstream exists: `git rev-parse --abbrev-ref @{upstream}`.
     - If no upstream, push with `git push -u origin <branch>`.
     - If upstream exists, push with `git push`.
   - If the user declines, stop. Suggest `/pr` if they want to open a pull request.
6. **If `--pipeline` was passed, enter the pipeline monitoring loop** (see "Pipeline Monitoring" section below).

## Commit Message Format

Follow the conventional commit format from `rules/git-workflow.md` and `git/.gitmessage`. The format, types, subject rules, body rules, and footer conventions are defined there. Below are examples showing how to choose the right level of detail:

**Subject-only, no body:** when the change is simple and the subject says it all.

```
chore(zsh): disable cursor-onyx alias
```

**Short sentence body:** when a bit of context helps but the change is small.

```
chore(zsh): remove cursor-coperniq profile alias

Keep only cursor-onyx profile; coperniq alias was unused.
```

**Bullet list body:** when the commit touches multiple files or areas. Each bullet names the file or module and briefly describes the change.

```
feat(brew): add Logitech apps and enable displaylink/jdownloader

- Add logi-options+, logitech-camera-settings, logitech-g-hub, logitech-presentation
- Enable displaylink for Apple Silicon
- Enable jdownloader
```

Body rules:
- Separate from subject with a blank line.
- Wrap at 72 characters.
- Explain WHAT and WHY, not HOW.
- Use `- ` for bullet points.
- Keep bullets concise and direct. No filler prose.

### Footer

Only when needed:
- `BREAKING CHANGE: <description>` for breaking changes.
- `Fixes #123`, `Closes #456`, `Refs #789` for issue references.

## Pipeline Monitoring

This section applies when `--pipeline` was passed. It runs after push completes successfully.

### Step 1: Detect platform, resolve account, and locate checks

Run **in parallel**:
- `git remote get-url origin` to detect the git platform.
- `git branch --show-current` to get the current branch.
- Determine the CLI tool: `github.com` means `gh`, `gitlab` means `glab`. Verify with `which <tool>`.

**Resolve account** per `rules/borrow-restore.md`: match the remote URL against authenticated `gh`/`glab` accounts, switch if needed, record the original to restore later.

Then check if a PR/MR exists for the branch:
- GitHub: `gh pr view --json number,url,statusCheckRollup`.
- GitLab: `glab mr view`.
- If no PR/MR exists, use branch pipeline checks instead.

### Step 2: Wait for checks

- **With PR/MR:**
  - GitHub: `timeout 600 gh pr checks --watch`.
  - GitLab: `timeout 600 glab ci status --wait`.
- **Without PR/MR (branch pipelines):**
  - GitHub: `gh run list --branch <branch> --limit 1` to find the latest run, then `timeout 600 gh run watch <id>`.
  - GitLab: `timeout 600 glab ci status --wait`.
- If the timeout is reached (exit code 124), report that checks are still running, show the URL, and stop.

### Step 3: Evaluate results

- **All checks pass:** report success with a summary and stop. The task is done.
- **Any check fails:** proceed to Step 4.

### Step 4: Diagnose failures

For each failed check:

- **GitHub:** fetch logs with `gh run view <id> --log-failed`. Fetch all failed runs **in parallel**.
- **GitLab:** fetch logs with `glab ci trace <job-id>`. Fetch all failed jobs **in parallel**.

Before suggesting a fix, search for existing fixes:
- Recent commits on the branch: `git log --oneline -5`.
- Open PRs/MRs that might address it:
  - GitHub: `gh pr list --search "<failed check name>"`.
  - GitLab: `glab mr list --search "<failed check name>"`.
- If an existing fix is found, report it and stop.

Present the diagnosis:

```
### <check name>
**URL:** <direct link to the failed check>
**Error:**
<relevant error message, file/line if available>

**Log excerpt:**
<the most relevant 10-20 lines from the failure log>
```

### Step 5: Offer to fix

After presenting all failures, ask the user:

- **"Fix and re-push"**: apply the fix, stage the changed files (specific files, never `git add -A`), commit with an appropriate message (e.g., `fix(ci): correct linting errors`), push, and go back to Step 2.
- **"Stop monitoring"**: show a summary of what passed and what failed, then stop.

### Guardrails

- **Max 3 fix-and-retry cycles.** After 3 attempts, stop and report the current state. Infinite loops help nobody.
- **Only fix what you can confidently fix.** If the failure is ambiguous, unclear, or requires domain knowledge you don't have, present the diagnosis and stop. Don't guess.
- **Each fix is its own commit.** Never amend the user's original commits. CI fixes get their own commit with a clear message.
- **Never skip hooks.** No `--no-verify` on any commit or push. If a hook blocks the fix, report it.

## Rules

- Never combine unrelated changes into a single commit.
- Never use `git add -A` or `git add .`.
- Never include files that contain secrets or credentials.
- If there are no changes to commit, say so and stop.
- `--pipeline` without a push is meaningless. If the user declines to push, skip monitoring entirely.
- Always restore the original account per `rules/borrow-restore.md`, even if earlier steps fail.

## Related skills

- `/pr` - After committing, create or update a pull request.
- `/checks` - Monitor CI/CD pipeline status independently (without the fix loop).
