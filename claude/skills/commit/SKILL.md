---
name: commit
description: Analyze all uncommitted changes and create semantic commits following conventional commit format.
disable-model-invocation: true
---

Analyze all uncommitted changes in the repository and create semantic commits following the commit format defined in CLAUDE.md.

## Steps

1. Run `git status` to identify all modified, added, and deleted files.
2. Run `git diff` to understand the actual changes in each file.
3. Run `git diff --cached` to check for already staged changes.
4. Run `git log --oneline -5` to understand the existing commit style.
5. Group related changes into logical units. Each group becomes one commit. Consider:
   - Changes to the same feature or module belong together.
   - Unrelated changes to different areas must be separate commits.
   - Renames, moves, and formatting changes are separate from logic changes.
   - Test changes go with the code they test, not in a separate commit.
6. For each group, in dependency order:
   - Stage only the relevant files using `git add <file1> <file2> ...`. Never use `git add -A` or `git add .`.
   - Commit following the conventional commit format from CLAUDE.md.
   - If GPG signing fails, retry with `--no-gpg-sign`.
7. Run `git status` after all commits to verify a clean working tree.
8. Show a summary of all commits created using `git log --oneline`.

## Rules

- Never combine unrelated changes into a single commit.
- Never use `git add -A` or `git add .`.
- Never include files that contain secrets or credentials.
- If there are no changes to commit, say so and stop.
- Do not push to remote. Only create local commits.
