---
name: checks
description: Monitor CI/CD checks for the current branch and diagnose failures.
---

Monitor CI/CD pipeline checks for the current branch and help diagnose any failures. Supports both GitHub and GitLab.

## When to use

- After pushing commits or creating a PR/MR.
- When CI/CD pipeline is running and you want to wait for results.
- When a pipeline fails and you need to diagnose the failure.

## When NOT to use

- When there is no remote branch or PR/MR and no recent pipelines.
- When you want to fix failures automatically. This skill only diagnoses.

## Arguments

This skill accepts optional arguments after `/checks`:

- No arguments: check the current branch.
- A PR/MR number (e.g. `123`): check that specific PR/MR instead of the current branch.

## Steps

1. **Gather initial context.** Run these **in parallel** (skip branch check if a PR/MR number was provided):
   - `git remote get-url origin` to detect the git platform.
   - `git branch --show-current` to get the current branch name.
   - Determine the CLI tool from the remote URL: `github.com` means `gh`, `gitlab` means `glab`. Verify with `which <tool>`.
2. Check if a PR/MR exists:
   - If a number was provided, use that directly.
   - Otherwise, check the current branch:
     - GitHub: run `gh pr view --json number,url,statusCheckRollup`.
     - GitLab: run `glab mr view`.
   - If no PR/MR exists, fall back to checking branch pipelines directly:
     - GitHub: run `gh run list --branch <branch> --limit 5`.
     - GitLab: run `glab ci list --branch <branch>`.
     - If no pipelines exist either, say so and stop.
4. Check the status of all pipeline checks:
   - **With PR/MR:**
     - GitHub: run `gh pr checks`.
     - GitLab: run `glab ci status`.
   - **Without PR/MR (branch pipelines only):**
     - GitHub: run `gh run list --branch <branch> --limit 1` to find the latest run, then `gh run view <id>`.
     - GitLab: run `glab ci status`.
5. If all checks pass, report success and stop.
6. If checks are still running, wait with a timeout:
   - GitHub: run `gh pr checks --watch` (or `gh run watch <id>` for branch pipelines) with a 10-minute timeout.
   - GitLab: run `glab ci status --wait` with a 10-minute timeout.
   - If the timeout is reached, report that checks are still running and show the URL for the user to monitor manually.
7. If any checks failed:
   - **GitHub:**
     - Identify the failed check names from the output.
     - Run `gh run list --branch <branch> --limit 5` to find the run IDs.
     - Fetch logs for **all failed runs in parallel** using `gh run view <id> --log-failed` for each.
   - **GitLab:**
     - Run `glab ci view` to see the pipeline overview.
     - Identify failed jobs and fetch logs **in parallel** using `glab ci trace <job-id>` for each.
   - Before suggesting a fix, search for an existing fix:
     - Check recent commits on the branch: `git log --oneline -5`.
     - Check open PRs/MRs that might address it:
       - GitHub: `gh pr list --search "<failed check name>"`.
       - GitLab: `glab mr list --search "<failed check name>"`.
     - If an existing fix is found, report it and stop.
8. Present the diagnosis using this format for each failure:

   ```
   ### <check name>
   **URL:** <direct link to the failed check>
   **Error:**
   <relevant error message, file/line if available>

   **Log excerpt:**
   <the most relevant 10-20 lines from the failure log>
   ```

9. After diagnosing, suggest next steps but do not automatically fix anything.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always search for existing fixes before suggesting corrections.
- Always include the direct URL to each failed check in the output.
- Always use a timeout when waiting for checks. Never wait indefinitely.
- Never mark a task as complete if checks are still running or failing.
- Do not automatically fix failures. Present the diagnosis and let the user decide.
- If the required CLI tool (`gh` or `glab`) is not installed, stop and tell the user.

## Related skills

- `/pr` - Create or update a PR/MR before checking pipelines.
- `/review` - Review the PR/MR code after checks pass.
- `/commit` - Fix issues locally and commit before pushing again.
