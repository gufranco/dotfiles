---
name: morning
description: Start-of-day dashboard with open PRs, pending reviews, notifications, and standup prep.
---

Morning briefing that gives you a full picture of where things stand before you start coding. Covers your open PRs, reviews waiting for you, unread notifications, yesterday's activity, and local repo state. Queries all authenticated accounts on each platform, not just the active one. Can also review all pending PRs interactively after the briefing.

## When to use

- At the start of your workday.
- Before standup to quickly gather what you did and what's pending.
- After being away for a day or more to catch up.
- To batch-review all PRs assigned to you in one session.

## When NOT to use

- When you want to review a single specific PR. Use `/review <number>` instead.
- When you're not in a git repository and didn't pass `--all`.

## Arguments

This skill accepts optional arguments after `/morning`:

- No arguments: full briefing for the current repo.
- `--all`: include cross-repo data (notifications, all your open PRs across the org, reviews requested across the org). Without this flag, the scope is limited to the current repo.
- `--standup`: only show the standup section (yesterday's commits and today's pending items). Skip everything else.
- `--review`: skip the briefing entirely and jump straight to reviewing all pending PRs. Useful when you already ran `/morning` and just want to clear the review queue.

Flags can be combined: `/morning --all --review`.

## Steps

1. **Gather initial context.** Run these **in parallel**:
   - `git remote get-url origin` to detect the git platform and extract the owner/repo. If no remote exists, note it but continue (cross-repo mode can still work).
   - `git branch --show-current` to get the current branch.
   - `git status --porcelain` to check for uncommitted changes.
   - Parse flags: check if `--all`, `--standup`, or `--review` was passed.

2. **Enumerate all authenticated accounts.** Both `gh` and `glab` can have multiple accounts logged in simultaneously. Discover all of them and record which one is currently active so it can be restored at the end.
   - **GitHub:** run `gh auth status --json hosts`. Parse the JSON to extract every account across all hosts. Each entry has `host`, `login`, and `active`. Record the currently active account (the one with `active: true`). Verify `gh` is installed with `which gh` before this step.
   - **GitLab:** run `glab auth status`. Parse the output to identify all logged-in instances and users. Record the currently active one. Verify `glab` is installed with `which glab`. If not installed, skip GitLab entirely.
   - Build a list of accounts to query. Example structure:
     ```
     [
       { platform: "github", host: "github.com", login: "alice", active: true },
       { platform: "github", host: "github.com", login: "alice-work", active: false },
       { platform: "gitlab", host: "gitlab.com", login: "alice", active: true },
     ]
     ```

3. **If `--review` was passed, skip to step 12.** (Steps 4-5 will be executed as part of step 12 to gather the review queue.)

4. **If `--standup` was passed, skip to step 8.**

5. **Your open PRs.** For **each account** discovered in step 2, switch to that account, fetch PRs, then move to the next. Aggregate results from all accounts.
   - **Switching context:**
     - GitHub: `gh auth switch --user <login>` before querying.
     - GitLab: `glab auth login --hostname <host>` or the equivalent switch command.
   - **Current repo scope (default):**
     - Only query the account that matches the current repo's remote host and owner. Skip accounts that do not match.
     - GitHub: `gh pr list --author @me --state open --json number,title,url,createdAt,baseRefName,headRefName,reviewDecision,statusCheckRollup,isDraft,mergeable,updatedAt`.
     - GitLab: `glab mr list --author @me --state opened`.
   - **Cross-repo scope (`--all`):**
     - Query every account.
     - GitHub: `gh search prs --author @me --state open --limit 20 --json repository,number,title,url,createdAt,updatedAt`.
     - GitLab: `glab mr list --author @me --state opened` (repo-scoped, glab does not support cross-repo search).
   - For each PR, extract and display:
     - Account label (e.g. `gufranco` or `alice-work`) so the user knows which identity owns it.
     - PR number and title.
     - CI status: passing, failing, or pending.
     - Review status: approved, changes requested, awaiting review.
     - Merge status: mergeable, has conflicts, or unknown.
     - How long it has been open (e.g. "2 days", "1 week").
     - Whether it is a draft.
   - Sort: PRs with action needed first (failing CI, changes requested, conflicts), then approved/ready, then drafts.
   - Group by account if there are PRs from more than one account.

6. **Reviews waiting for you.** For **each account**, switch context and fetch PRs where that user is requested as a reviewer. Aggregate results. Store this list for use in step 12.
   - **Current repo scope (default):**
     - Only query the account that matches the current repo's remote.
     - GitHub: `gh pr list --search "review-requested:@me" --state open --json number,title,url,author,createdAt,additions,deletions,updatedAt,isDraft`.
     - GitLab: `glab mr list --reviewer @me --state opened`.
   - **Cross-repo scope (`--all`):**
     - Query every account.
     - GitHub: `gh search prs --review-requested @me --state open --limit 20 --json repository,number,title,url,author,createdAt,updatedAt`.
     - GitLab: `glab mr list --reviewer @me --state opened` (repo-scoped).
   - **Filter out draft PRs.** Drafts are not ready for review. Exclude them from the list and from the count.
   - For each non-draft PR, display:
     - Account label so the user knows which identity the review was requested from.
     - PR number, title, and author.
     - Size indicator: lines added/deleted.
     - How long it has been waiting for your review.
     - Repository name (only in `--all` mode).
   - Sort by size (smallest first). Smallest PRs are reviewed first to unblock teammates faster.
   - Group by account if there are reviews from more than one account.

7. **Unread notifications.** For **each account**, switch context and fetch notifications. Aggregate results.
   - GitHub: `gh api notifications --jq '.[] | {reason, subject: .subject.type, title: .subject.title, repo: .repository.full_name, updated: .updated_at, url: .subject.url}'`. Limit to 15 most recent per account.
     - Group by type: review requested, mention, CI failure, assignment, other.
     - For `--all` mode, show all repos. For default mode, filter to the current repo only.
   - GitLab: `glab api projects/:id/notification_settings` (limited support, show what's available).
   - If there are no unread notifications across all accounts, say so briefly.
   - When displaying, prefix each notification group with the account label if there are multiple accounts.

8. **Standup prep.** Run these **in parallel**:
   - **Yesterday's activity:** `git log --author="$(git config user.email)" --since="yesterday.midnight" --until="today.midnight" --oneline --all` to show your commits from yesterday across all branches. If today is Monday, use `--since="last friday.midnight"` to cover the weekend. Format as a bullet list grouped by branch.
     - If the user has multiple git email addresses configured across repos, this only captures the current repo's email. Note this limitation in the output if relevant.
   - **Today's pending work:**
     - Open PRs from step 5 that need attention (or re-fetch across all accounts if `--standup` skipped step 5):
       - PRs with changes requested.
       - PRs with failing CI.
       - PRs with merge conflicts.
     - Pending reviews from step 6 (or re-fetch across all accounts if `--standup` skipped step 6).
     - If on a feature branch with unpushed commits: `git log --oneline origin/<current-branch>..HEAD 2>/dev/null`. If the remote branch doesn't exist, show all commits on the branch vs the default branch.

9. **Local repo state.** Quick health check of the working directory:
   - Uncommitted changes: from step 1's `git status` output. Show a summary (X files modified, Y untracked).
   - Unpushed commits on the current branch: `git log --oneline @{upstream}..HEAD 2>/dev/null`. If no upstream, note the branch hasn't been pushed.
   - Stale local branches: `git branch --merged origin/HEAD 2>/dev/null` to find branches already merged into the default branch that could be cleaned up. Only mention this if there are 3 or more stale branches.

10. **Present the briefing.** Use this format:

    ```
    ## Good morning

    **Accounts:** <list of accounts queried, e.g. "gufranco, gfranco-onyxodds (github.com)">
    **Repo:** <owner/repo or "none (cross-repo mode)">
    **Branch:** <current branch or "N/A">
    **Date:** <today's date, weekday>

    ---

    ### Your open PRs

    #### <account label> (only if multiple accounts have PRs)

    <table or list with PR details from step 5>
    <or "No open PRs.">

    ---

    ### Reviews waiting for you

    #### <account label> (only if multiple accounts have reviews)

    <list with PR details from step 6>
    <or "No pending reviews.">

    ---

    ### Notifications

    #### <account label> (only if multiple accounts have notifications)

    <grouped notifications from step 7>
    <or "No unread notifications.">

    ---

    ### Standup

    **Yesterday:**
    <bullet list of commits grouped by branch>
    <or "No commits yesterday.">

    **Today:**
    <bullet list of pending items from all accounts>
    <or "Nothing pending, clean slate.">

    ---

    ### Local state

    <uncommitted changes, unpushed commits, stale branches>
    <or "Working directory clean, everything pushed.">
    ```

11. **Suggest next actions.** Based on what the briefing found, suggest 1-3 concrete actions. When the action involves a specific account that is not the currently active one, mention which account to switch to. Examples:
    - "You have 2 PRs with failing CI. Run `/checks` to diagnose."
    - "PR #42 has been approved and CI is green. Ready to merge."
    - "You have 5 merged branches locally. Consider cleaning up with `git branch -d ...`."
    - "You have uncommitted changes on `feature/auth`. Pick up where you left off or `/commit`."

    If there are pending reviews (non-draft PRs from step 6), always include this as a suggested action and ask:

    > You have N PRs waiting for your review. Want me to review them now?

    If the user says yes, proceed to step 12. If no, skip step 12.

12. **Interactive review loop.** Review each pending PR one by one. This step runs when:
    - The user said yes to the review prompt in step 11, OR
    - `--review` was passed (in which case, fetch the review queue first using step 6's logic if it wasn't already fetched).

    **12a. Build the review queue.** Take the list of non-draft PRs pending your review from step 6. If step 6 was skipped (because `--review` was passed directly), fetch the list now using the same logic as step 6. Sort by size, smallest first (fewest additions + deletions). Present the queue:

    ```
    ### Review queue (N PRs)

    1. #123 - Fix typo in README (alice) — +3/-2 — repo-name — account-label
    2. #456 - Add rate limiting (bob) — +120/-30 — repo-name — account-label
    3. #789 - Refactor auth module (carol) — +450/-200 — repo-name — account-label
    ```

    **12b. For each PR in the queue, sequentially:**

    1. Print a separator and header: `--- Reviewing #<number>: <title> (<N of M>) ---`
    2. Switch to the correct account for this PR: `gh auth switch --user <login>`.
    3. Verify the PR is still open:
       - GitHub: `gh pr view <number> --repo <owner/repo> --json state`.
       - If not open, skip it and say so.
    4. Fetch the diff and metadata. Run **in parallel**:
       - GitHub: `gh pr view <number> --repo <owner/repo> --json title,body,baseRefName,headRefName,files,commits,author` and `gh pr diff <number> --repo <owner/repo>`.
       - GitLab: `glab mr view <number>` and `glab mr diff <number>`.
    5. Read the PR description and commit messages to understand intent.
    6. If the changes touch files you're not familiar with, read surrounding code in those files to understand existing patterns.
    7. **Run the full review** using the checklist in `/review`'s `reviewer-prompt.md`. Go through every category: correctness, security, error handling, performance, concurrency, data integrity, API design, testing, code quality, naming, architecture, observability, dependencies, documentation. Do not skip sections.
    8. Check branch freshness: is the branch behind the base? If so, flag it.
    9. Present the review to the user following the same format as `/review`:
       - Summary of what the PR does.
       - Issues found with what's wrong, why it matters, and a code example showing the fix.
       - Verdict: APPROVE, REQUEST_CHANGES, or COMMENT.
    10. **Ask the user what to do.** Present three options:
        - **Post**: post the review as inline comments on the PR and move to the next.
        - **Skip**: do not post, move to the next PR.
        - **Stop**: do not post, stop reviewing entirely.
    11. If **Post**: post the review using the GitHub/GitLab API, same as `/review` does:
        - GitHub: `gh api repos/{owner}/{repo}/pulls/{number}/reviews` with JSON payload containing `event`, `body`, and `comments` array. Each comment has `path`, `line`, `side`, and `body`. Always post as individual inline comments. Use `REQUEST_CHANGES`, `APPROVE`, or `COMMENT` as the event.
        - GitLab: `glab mr note <number>` for comments.
        - After posting, confirm with a checkmark and the verdict.
    12. If **Skip**: say "Skipped" and move to the next PR.
    13. If **Stop**: say "Stopping review session" and exit the loop.

    **12c. After the loop finishes** (all PRs reviewed or user stopped), print a summary:

    ```
    ### Review session complete

    - #123: APPROVED (posted)
    - #456: REQUEST_CHANGES (posted)
    - #789: skipped
    - #101: not reviewed (stopped)
    ```

13. **Restore the original active account.** After everything is done, switch back to the account that was active at the start of step 2.
    - GitHub: `gh auth switch --user <original-login>`.
    - GitLab: switch back to the original active instance.
    - This step is **mandatory**. Even if earlier steps fail or the user stops the review loop, always restore the original account.

## Rules

- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always determine all authenticated users dynamically. Never hardcode usernames.
- Always restore the original active account after all operations. This is non-negotiable. Even if steps fail or the user stops mid-review, always restore.
- Always show which account owns each PR, review, or notification when multiple accounts are present. Use the login as a label.
- Always show times in relative format ("2 days ago", "3 hours ago"), not absolute timestamps.
- Always switch to the correct account before performing any review or posting any comment. Never post from the wrong account.
- Always filter out draft PRs from the review queue. Drafts are not ready for review.
- Always sort the review queue by size (smallest first). This is deliberate: small PRs are quick to review and unblock teammates faster.
- Always present each review to the user before posting. Never auto-post without explicit approval per PR.
- Always use the full `/review` checklist from `reviewer-prompt.md` for each PR. Do not do shallow reviews just because there are many PRs in the queue.
- Never modify any state beyond account switching (which is restored) and posting reviews (which requires explicit approval per PR). No commits, no pushes, no branch changes.
- Never display raw JSON. Always format output for readability.
- If `gh` is not installed, skip all GitHub queries and note it. If `glab` is not installed, skip all GitLab queries silently (it is optional).
- If not inside a git repository, skip local-repo steps (branch, status, stale branches, standup commits) but still run cross-repo queries if `--all` is passed.
- If API calls fail for one account (rate limits, auth issues, expired token), show what you can from other accounts and note which account failed. Do not stop the entire briefing because one account had an error.
- If posting a review fails, report the error, do not retry, and move to the next PR.
- Keep the briefing output concise. The goal is a quick scan, not a detailed report.
- Reviews should be thorough. Do not sacrifice review quality for speed.
- When in `--standup` mode, keep the output minimal: just yesterday's work and today's pending items. Do not offer to review PRs.
- For `--all` mode, always include the repository name in PR listings so it is clear which repo each item belongs to.
- When only one account exists, do not add account labels or subheadings. Keep the output clean.

## Related skills

- `/review` - Review a single specific PR with the same rigor. Use this when you want to review one PR outside of the morning routine.
- `/checks` - Diagnose failing CI/CD pipelines on specific PRs.
- `/pr` - Create or update PRs for branches with unpushed work.
- `/commit` - Commit uncommitted changes found during the local state check.
