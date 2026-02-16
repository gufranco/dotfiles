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
   - If GPG signing fails, retry with `--no-gpg-sign`.
4. After all commits, run `git status` and `git log --oneline` **in parallel** to verify clean tree and show summary.
5. **Push to remote:**
   - If `--push` was passed, push immediately without asking.
   - Otherwise, ask the user: "Want me to push to remote?"
   - If yes, or if `--push`:
     - Check if an upstream exists: `git rev-parse --abbrev-ref @{upstream}`.
     - If no upstream, push with `git push -u origin <branch>`.
     - If upstream exists, push with `git push`.
   - If the user declines, stop. Suggest `/pr` if they want to open a pull request.

## Commit Message Format

Follow the conventional commit format from `git/.gitmessage`:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Subject line

- Type is required. Scope is optional but preferred when a clear module exists.
- Imperative mood: "add" not "added" or "adds".
- No capital first letter, no period at the end.
- Max 50 characters. Make it descriptive enough to stand alone.

### Body

Choose the right level of detail based on the change:

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

## Rules

- Never combine unrelated changes into a single commit.
- Never use `git add -A` or `git add .`.
- Never include files that contain secrets or credentials.
- Never add `Co-authored-by` lines.
- If there are no changes to commit, say so and stop.

## Related skills

- `/pr` - After committing, create or update a pull request.
- `/checks` - After pushing, monitor CI/CD pipeline status.
