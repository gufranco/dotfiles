---
name: worktree
description: Manage git worktrees for parallel development. Create isolated worktrees from task descriptions, deliver changes as PRs, check status, and clean up merged branches.
---

Manage git worktrees for working on multiple tasks in parallel. Each worktree gets its own branch, working directory, and task file. Useful when you want to run multiple Claude instances on separate features simultaneously.

## When to use

- When starting multiple independent tasks that can be worked on in parallel.
- When you need to context-switch between tasks without stashing or committing incomplete work.
- When delivering a completed worktree as a PR.
- When cleaning up worktrees for merged branches.

## When NOT to use

- For simple linear workflows where one branch is enough.
- When already inside a worktree (nest detection is not supported).

## Arguments

This skill accepts a subcommand after `/worktree`:

- `init <task1> | <task2> | <task3>`: create worktrees from pipe-separated task descriptions.
- `deliver`: from inside a worktree, commit, push, and create a PR.
- `check`: show status of all worktrees.
- `cleanup`: remove worktrees for merged branches.
- `cleanup --all`: remove all worktrees regardless of merge status.
- `cleanup --branch <name>`: remove a specific worktree by branch name.
- `cleanup --dry-run`: show what would be removed without removing it.

## Steps

### `init` subcommand

1. **Verify preconditions.** Run these **in parallel**:
   - `git rev-parse --is-inside-work-tree` to confirm this is a git repo.
   - `git rev-parse --show-toplevel` to get the repo root.
   - `git branch --show-current` to get the current branch.
   - Check that the current directory is not already a worktree: `git rev-parse --git-common-dir` should equal `git rev-parse --git-dir`.
2. **Parse task descriptions.** Split the argument on `|`. Trim whitespace. Each segment becomes a task.
3. **Create worktrees.** For each task:
   - Generate a branch name: `wt/<kebab-case-of-task>`, max 50 chars.
   - Choose the worktree path: `<repo-root>/.worktrees/<branch-name-without-prefix>`.
   - Create: `git worktree add -b <branch> <path>`.
   - Write a `.worktree-task.md` file in the worktree root with the task description.
   - Detect the package manager and run install if a lockfile exists (ask first).
4. **Present results.** Show a table with: worktree path, branch name, and task description. Suggest how to open each worktree in a separate terminal.

### `deliver` subcommand

1. **Verify context.** Confirm you are inside a worktree: `git rev-parse --git-common-dir` should differ from `git rev-parse --git-dir`.
2. **Gather state.** Run these **in parallel**:
   - `git status --porcelain` for uncommitted changes.
   - `git log --oneline main..HEAD` (or the default branch) for commits.
   - `cat .worktree-task.md` for the task description.
   - `git remote get-url origin` to detect the platform.
   - `git branch --show-current` for the branch name.
   - **Resolve account** per `rules/borrow-restore.md`: match the remote URL against authenticated `gh`/`glab` accounts, switch if needed, record the original to restore later.
3. **Stage and commit.** If there are uncommitted changes:
   - Run `git add -A` (worktrees are task-scoped, so this is safe).
   - Remove `.worktree-task.md` from staging: `git reset HEAD .worktree-task.md`.
   - Generate a conventional commit message from the diff analysis.
   - Show for approval, then commit.
4. **Push.** `git push -u origin <branch>`.
5. **Create PR.** Use the task description from `.worktree-task.md` as the basis for the PR body. Follow the same PR conventions as `/pr`: detect platform, use `gh pr create` or `glab mr create`, include What/How/Testing sections.
6. **Restore the original account** per `rules/borrow-restore.md`.
7. **Report.** Show the PR URL and suggest `/worktree cleanup` when the PR is merged.

### `check` subcommand

1. **List worktrees.** Run `git worktree list --porcelain` and parse the output.
2. **For each worktree**, gather **in parallel**:
   - Branch name from the worktree list.
   - `git -C <path> log --oneline main..HEAD | wc -l` for commit count.
   - `git -C <path> status --porcelain | wc -l` for uncommitted changes.
   - Read `.worktree-task.md` if it exists.
3. **Present as a table** with columns: path, branch, commits ahead, uncommitted changes, and task description.

### `cleanup` subcommand

1. **Parse flags.** Check for `--all`, `--branch <name>`, or `--dry-run`.
2. **List worktrees.** Run `git worktree list --porcelain` and filter to `wt/*` branches.
3. **Determine which to remove:**
   - Default (no flags): only worktrees whose branch is fully merged into the default branch. Check with `git branch --merged <default-branch>`.
   - `--all`: all `wt/*` worktrees regardless of merge status.
   - `--branch <name>`: only the worktree matching that branch.
4. **If `--dry-run`**: show what would be removed and stop.
5. **Ask for confirmation** unless `--dry-run`.
6. **Remove each worktree:**
   - `git worktree remove <path>` to remove the worktree.
   - `git branch -d <branch>` to delete the local branch (safe delete, merged only).
   - For `--all`, use `git branch -D <branch>` since unmerged branches are included.
   - `git push origin --delete <branch>` to delete the remote branch (ask first).
7. **Run `git worktree prune`** to clean up stale references.
8. **Report** what was removed.

## Rules

- Never create worktrees inside another worktree.
- Always use the `wt/` prefix for worktree branches to make cleanup safe.
- Never delete branches that don't start with `wt/`.
- Always write `.worktree-task.md` so the task context is preserved across sessions.
- Add `.worktree-task.md` to `.gitignore` so it never gets committed.
- When delivering, always remove `.worktree-task.md` from staging.
- Default branch detection: use `gh repo view --json defaultBranchRef` or fall back to `git remote show origin`.
- If `--all` is used for cleanup, warn that unmerged work will be lost and require double confirmation.
- Always restore the original account per `rules/borrow-restore.md`, even if earlier steps fail.

## Related skills

- `/pr` - Create PRs from any branch, not just worktrees.
- `/commit` - Commit changes with conventional format.
- `/checks` - Verify CI status after delivering.
