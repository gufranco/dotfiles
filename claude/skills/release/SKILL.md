---
name: release
description: Create a tagged release with an auto-generated changelog from conventional commits.
---

Create a tagged release with a changelog generated from conventional commits since the last tag. Supports both GitHub and GitLab.

## When to use

- After merging all planned changes to the main branch and ready to release.
- When you want to preview a release with `--dry-run` before creating it.

## When NOT to use

- When there are no new commits since the last tag.
- When the working tree has uncommitted changes. Use `/commit` first.
- When CI/CD checks are failing. Use `/checks` to diagnose first.

## Arguments

This skill accepts optional arguments after `/release`:

- No arguments: auto-detect the next version based on commit types.
- A version (e.g. `1.2.0`): use that exact version.
- `--dry-run`: show what would be released without creating anything.

## Steps

1. **Gather initial context.** Run these **in parallel**:
   - `git remote get-url origin` to detect the git platform.
   - `git describe --tags --abbrev=0` to find the latest tag (if no tags, use root commit).
   - `git status --porcelain` to check for uncommitted changes.
   - Determine the CLI tool from the remote URL: `github.com` means `gh`, `gitlab` means `glab`. Verify with `which <tool>`.
   - If the working tree is dirty, stop and warn the user.
2. Gather all commits since the last tag:
   - Run `git log --oneline <last-tag>..HEAD` (or `git log --oneline` if no tags).
   - If there are no new commits, say so and stop.
3. Determine the next version:
   - If the user provided a version, use that.
   - Otherwise, parse the last tag as semver and bump based on commit types:
     - Any `BREAKING CHANGE` or `!` in type: bump major.
     - Any `feat`: bump minor.
     - Only `fix`, `perf`, `refactor`, `chore`, `docs`, `style`, `test`, `build`, `ci`: bump patch.
   - If the last tag is not semver, ask the user for the version.
4. Generate the changelog by grouping commits by type:

   ```
   ## What's new

   ### Features
   - <subject> (<short-hash>)

   ### Bug fixes
   - <subject> (<short-hash>)

   ### Performance
   - <subject> (<short-hash>)

   ### Other changes
   - <subject> (<short-hash>)

   ### Breaking changes
   - <description>
   ```

   Rules for the changelog:
   - Only include sections that have commits.
   - Use the commit subject as the description.
   - Include the short hash for reference.
   - List breaking changes in their own section with details from the commit body/footer.

5. If `--dry-run` was passed, show the version and changelog and stop.
6. **If the project has tests, lint, or build commands,** run them to verify everything passes before releasing. If they fail, stop and tell the user.
7. Present the version and changelog to the user for approval before creating anything.
8. After user approval:
   - Create an annotated tag: `git tag -a v<version> -m "v<version>"`.
   - Push the tag: `git push origin v<version>`.
   - Create the release:
     - GitHub: `gh release create v<version> --title "v<version>" --notes-file <tmpfile>`.
     - GitLab: `glab release create v<version> --notes-file <tmpfile>`.
   - Clean up the temp file after the command completes, whether it succeeded or failed.
9. Show the release URL when done.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always present the changelog to the user before creating the tag or release.
- Never create a tag or release without explicit user approval.
- Never release if there are no new commits since the last tag.
- Never release if the working tree is dirty. Run `git status` and warn if there are uncommitted changes.
- Always write release notes to a temp file to avoid shell escaping issues. Clean up the temp file on both success and failure.
- If the required CLI tool (`gh` or `glab`) is not installed, stop and tell the user.

## Related skills

- `/commit` - Ensure all changes are committed before releasing.
- `/checks` - Verify CI/CD passes before creating a release.
- `/pr` - Merge outstanding PRs before releasing.
