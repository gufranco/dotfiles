---
name: review
description: Review a pull request or local branch changes following the code review conventions from CLAUDE.md.
---

Review a pull request, merge request, or local branch changes with an extremely rigorous, detail-oriented analysis. Every line of the diff is scrutinized for correctness, security, performance, maintainability, and adherence to best practices. This review leaves nothing to chance.

Use two checklists as structured guides:

1. `reviewer-prompt.md` in this directory for review-only categories (correctness, performance, testing, code quality, naming, dependencies, PR quality).
2. `../../checklists/engineering.md` for the 32 shared architecture, resilience, and infrastructure categories (also used by `/assessment`).

Go through every applicable category. Do not skip sections because the changes "look simple."

## When to use

- Before merging a PR/MR to catch issues early.
- When asked to review someone else's PR/MR.
- Before opening a PR, to catch issues early and save review cycles.
- When stuck on your own code and want a fresh perspective.

## When NOT to use

- For trivial changes like typo fixes that don't need formal review.
- When there are no changes to review (no PR and no local commits ahead of base).

## Arguments

This skill accepts optional arguments after `/review`:

- No arguments: review the PR/MR for the current branch. If no PR/MR exists, automatically fall back to local mode.
- One or more PR/MR numbers (e.g. `123` or `123 456 789`): review those specific PRs/MRs sequentially.
- One or more URLs: review the PRs/MRs at those URLs sequentially.
- `--local`: skip PR lookup entirely and review the local branch diff against the base branch. Useful before opening a PR.
- `--post`: automatically post the review as inline comments without asking for confirmation. Only applies to someone else's PR. Has no effect in local mode or on your own PR.
- `--backend`: review only backend and infrastructure files. Excludes frontend files from the diff. See "Scope Filtering" for classification rules.
- `--frontend`: review only frontend files. Excludes backend and infrastructure files from the diff. See "Scope Filtering" for classification rules.
- If neither `--backend` nor `--frontend` is passed, review all files (default behavior).

## Scope Filtering

When `--backend` or `--frontend` is passed, classify each file in the diff and exclude files outside the requested scope. Files that don't clearly belong to either scope are included in both.

### Classification rules

Detect the project structure from the diff file paths. Use these signals to classify:

**Frontend signals:**
- Directories: paths containing `frontend/`, `web/`, `client/`, `src/app/` (Next.js/React app router), `src/pages/`, `src/components/`, `src/hooks/`, `src/styles/`, `public/`
- Extensions: `.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`, `.less`, `.sass`
- Config files: `next.config.*`, `vite.config.*`, `webpack.config.*`, `tailwind.config.*`, `postcss.config.*`, `tsconfig.json` inside a frontend directory

**Backend signals:**
- Directories: paths containing `backend/`, `server/`, `api/`, `services/`, `workers/`, `jobs/`, `lambdas/`, `functions/`
- Extensions: `.go`, `.py`, `.rb`, `.rs`, `.java`, `.kt` (these are always backend)
- Config files: `Dockerfile`, `docker-compose.*`, `serverless.*`

**Infrastructure signals (included with `--backend`):**
- Directories: paths containing `infra/`, `infrastructure/`, `terraform/`, `cdk/`, `pulumi/`, `deploy/`, `k8s/`, `helm/`
- Extensions: `.tf`, `.tfvars`, `.hcl`
- Files: `*.yaml`/`*.yml` in infra-related directories

**Shared (included in both scopes):**
- Shared packages: paths containing `packages/`, `libs/`, `shared/`, `common/`
- Root config: `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `tsconfig.base.json`, `.eslintrc.*`, `.prettierrc.*`, `.gitignore`, `.env.example`
- Database: `prisma/`, `migrations/`, `seeds/` (included in both because schema changes affect frontend types)

### Monorepo detection

In monorepos, use the top-level directory name as the primary signal. If a file is at `apps/web/src/...`, it's frontend. If at `apps/api/src/...`, it's backend. The workspace name is more reliable than the file extension.

### Ambiguous files

If a file cannot be classified with confidence, include it. Reviewing an extra file is cheaper than missing a bug.

### Reporting

When scope filtering is active, report at the start of the review: how many files are in scope, how many were excluded, and from which directories. This makes the filtering transparent.

## Steps

1. **Gather initial context.** Run these **in parallel**:
   - `git remote get-url origin` to detect the git platform.
   - `git branch --show-current` to get the current branch.
   - Determine the CLI tool from the remote URL: `github.com` means `gh`, `gitlab` means `glab`. Verify with `which <tool>`.
   - **Resolve account** per `rules/borrow-restore.md`: match the remote URL against authenticated `gh`/`glab` accounts, switch if needed, record the original to restore later.
   - Parse flags: check if `--post`, `--local`, `--backend`, or `--frontend` was passed. Collect all remaining arguments as PR identifiers.
   - **If multiple PRs were given**, process each one sequentially through steps 2-10 below. Complete the full review cycle for one PR before starting the next. Between PRs, print a separator line so the user can tell where one review ends and the next begins.
2. **Determine the review mode (PR or local):**
   - If `--local` was passed, go directly to **local mode** (step 3B).
   - If a PR/MR number or URL was provided, look up that specific PR/MR:
     - GitHub: `gh pr view <number> --json number,url,title,body,state,baseRefName,headRefName`.
     - GitLab: `glab mr view <number>`.
     - **Check the state immediately.** If not `OPEN` (e.g. `MERGED` or `CLOSED`), tell the user the current state and stop.
   - If no arguments were provided, check if a PR/MR exists for the current branch:
     - GitHub: `gh pr view --json number,url,title,body,state,baseRefName,headRefName`.
     - GitLab: `glab mr view`.
     - If a PR/MR exists and is `OPEN`, continue in **PR mode** (step 3A).
     - If the PR/MR exists but is not `OPEN`, tell the user the state and stop.
     - **If no PR/MR exists, automatically fall back to local mode** (step 3B). Tell the user: "No PR found for this branch, reviewing local changes."
3. **Get the diff and context.** This step differs by mode:

   **3A. PR mode.** Run these **in parallel**:
   - Metadata and authorship:
     - GitHub: `gh pr view <number> --json title,body,baseRefName,headRefName,files,commits,author` and `gh api user --jq '.login'`.
     - GitLab: `glab mr view <number>` and `glab auth status` to get the current user.
     - Compare the PR author with the current authenticated user. Store a flag: `isOwnPR = true` if they match.
   - Diff:
     - GitHub: `gh pr diff <number>`.
     - GitLab: `glab mr diff <number>`.

   **3B. Local mode.** Run these **in parallel**:
   - Detect the base branch:
     - GitHub: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`.
     - GitLab: `glab repo view --output json` and extract the default branch.
     - Fallback: `git remote show origin` for "HEAD branch", then `main`/`master`.
   - `git fetch origin` to ensure the remote is up to date.
   - Then run **in parallel**:
     - `git log --oneline origin/<base>..HEAD` to get commits. If there are no commits, say so and stop.
     - `git diff origin/<base>...HEAD --stat` for the stat summary.
     - `git diff origin/<base>...HEAD` for the full diff.
   - If the branch also has uncommitted changes (`git status --porcelain`), warn the user that only committed changes are being reviewed.

4. **Apply scope filter.** If `--backend` or `--frontend` was passed:
   - Parse the file list from the diff stat summary.
   - Classify each file using the rules in "Scope Filtering" above.
   - Exclude files outside the requested scope from the diff.
   - Report the scope: "Reviewing N backend files (M frontend files excluded)" or vice versa. List the excluded directories briefly.
   - If all files are excluded by the filter, tell the user and stop: "No <scope> files found in this diff."
   - If neither flag was passed, skip this step entirely.
5. **Understand the context before judging the code:**
   - In PR mode: read the PR description and commit messages for intent.
   - In local mode: read the commit messages for intent. There is no PR description yet.
   - **Read every changed file in full**, not just the diff hunks. The diff shows what changed, but the full file shows whether the change fits the surrounding code, whether existing patterns were followed, and whether the change breaks something the diff doesn't show. This is non-negotiable: do not review a diff in isolation.
   - When a new import is added, **read the imported module** to understand its behavior, side effects, error types, and configuration requirements. An import is not just a line of code; it's a dependency with consequences.
   - **Check existing reviews** (PR mode only). If the PR already has review comments from previous rounds, read them. Verify that previously raised issues were actually addressed in subsequent commits, not just acknowledged. If a prior reviewer asked for a change and it wasn't made, flag it. Do not rediscover and re-raise the same issue without acknowledging the history.
   - **Verify PR description matches the diff** (PR mode only). Compare what the PR description claims to do against what the diff actually does. Flag undocumented changes: code in the diff that the description doesn't mention. Flag missing changes: things the description promises but the diff doesn't deliver. Flag scope creep: unrelated changes bundled into the PR without explanation.
6. **Deep analysis: three explicit passes.** Do not treat this as a single scan. Execute three distinct passes, each with a different lens. Findings from earlier passes inform later ones. Do not stop after finding a few issues: exhaustive coverage across all passes is the goal.

   **Pass 1: Per-file analysis.** For each in-scope file, go through every category in `reviewer-prompt.md` and every applicable category in `../../checklists/engineering.md`:
   - **Correctness:** Does the logic actually do what it claims? Trace through the code mentally with concrete inputs, especially edge cases. Look for off-by-one errors, null/undefined access, wrong operator precedence, incorrect boolean logic, missing return statements, unreachable code.
   - **Security:** Apply the full OWASP top 10 lens. Check for injection, broken auth, sensitive data exposure, XXE, broken access control, misconfig, XSS, insecure deserialization, known vulnerable components, insufficient logging. Check for secrets, tokens, or credentials in the diff.
   - **Error handling:** Are all error paths covered? Are errors caught with context, or silently swallowed? Are error messages helpful for debugging? Is the error propagation strategy consistent? Could a thrown exception crash a request handler?
   - **Performance:** Look for O(n^2) loops hidden as nested iterations, unnecessary allocations inside loops, missing database indexes on new queries, N+1 query patterns, unbounded list fetches, missing pagination, synchronous I/O blocking the event loop, unnecessary re-renders.
   - **Concurrency and race conditions:** Shared mutable state, missing locks, time-of-check-to-time-of-use (TOCTOU) bugs, unhandled promise rejections, missing `await`, fire-and-forget async calls that should be awaited.
   - **Data integrity:** Missing validation at system boundaries, missing database constraints, missing uniqueness checks, potential for duplicate processing, missing idempotency on mutations.
   - **Naming and readability:** Are variables, functions, and files named with precision? Could someone unfamiliar with the codebase understand this code? Are abstractions at the right level? Is the code self-documenting or does it need comments that are missing?
   - **Design:** Single responsibility respected? Coupling between modules appropriate? Dependencies flowing in the right direction? Composition over inheritance? Is this the simplest solution that works, or is it over/under-engineered?
   - **Testing:** Are the changes covered by meaningful tests? Do tests verify real behavior or just mock behavior? Are edge cases and error paths tested? Is the test structure clean (AAA pattern)? Are assertions specific enough to catch regressions?
   - **Mock policy (STRICT, blocking):** Tests must connect to real infrastructure: database, Redis, queues, caches. These dependencies belong in docker-compose for the test environment, with `beforeAll()` hooks to seed data. Only external third-party APIs, time, and randomness may be mocked. Mocking your own database, services, or modules is a blocking issue: the test may pass while the actual integration is broken, which is worse than no test. If any test mocks something that should be real, flag it as a blocking issue with a code example showing the real-connection approach.
   - **Consistency:** Does the code follow the existing patterns in the codebase? Is the style consistent with surrounding code? Are similar problems solved the same way?

   **Pass 2: Cross-file consistency.** After reviewing each file individually, review the diff as a whole. Look for contradictions and implicit assumptions that only become visible when files interact:
   - **Design contradictions:** Does one file assume graceful degradation while another enforces a hard dependency? Does one file treat a field as optional while another treats it as required? Does one file validate input while another trusts it blindly?
   - **Import chain side effects:** When a new module is imported, trace the full import chain. Does it trigger module-level side effects like connections, env validation, or scheduled tasks that change startup behavior? Would a missing env var crash the entire process at import time?
   - **Configuration completeness:** When a new env var, dependency, or infrastructure requirement is introduced, verify all environments can satisfy it: local dev, CI, staging, production. Check `.env.example`, Docker configs, CI pipelines, and IaC templates.
   - **Contract alignment:** Does the frontend send data in the exact format the backend expects? Do header names, field names, parameter positions, and types match? Is the API client updated to match the API changes?
   - **Error path consistency:** If module A classifies or throws errors in a specific way, does module B handle those error types correctly? Do error responses from the backend match what the frontend catches and displays?
   - **Behavioral symmetry:** If an operation has setup, does it have teardown? If a resource is acquired, is it released on all paths? If a feature is enabled, can it be disabled?

   **Pass 3: Cascading fix analysis.** For every issue found in passes 1 and 2, think one step ahead. If the author implements the suggested fix exactly as described, what new problems could that introduce?
   - Would the fix add a new dependency, env var, or startup requirement?
   - Would the fix change a function signature, breaking callers not in this diff?
   - Would the fix require coordinated changes in files not touched by this PR?
   - Would the fix change error behavior that other code relies on?
   - Would the fix behave differently across environments (dev vs staging vs production)?
   - Would the fix introduce a new test requirement that isn't mentioned?

   When the answer to any of these is yes, include a "When implementing this fix, also..." note in the review comment. This front-loads what would otherwise become a second review round. The goal is that the author can address every issue and its downstream effects in a single iteration.
7. **Run local verification.** Detect test, lint, and build commands using the same lockfile and config detection as `/test`. Run them and report the results.
8. **Check branch freshness, CI status, test evidence, and PR size.** Do these **in parallel**:
   - Verify the branch is up to date with the base branch. If behind, this is a blocking issue.
   - In PR mode: check CI status. GitHub: `gh pr checks <number>`. If any required check has failed, this is a blocking issue. If checks are still running, note it.
   - In PR mode: check test evidence per the "Test Evidence" section below.
   - In local mode: skip CI and test evidence checks. Running tests locally in step 7 serves as the evidence.
   - **PR size check.** Count the total lines added and deleted in the diff. If the diff exceeds 400 lines, note that the PR is large and suggest splitting if the changes span unrelated concerns. If the diff exceeds 1000 lines, flag it as a blocking issue unless the PR is a single cohesive feature that cannot be meaningfully split.
9. **Present the full review to the user.** Format as described below.
   - In local mode: clearly label the review as "Local Review" so the user knows this was not posted anywhere.
   - If scope filtering was applied, include the scope in the header: "Local Review (backend only)" or "PR Review (frontend only)".
10. **Ask the user what to do next.** After presenting the review, the behavior depends on whether this is your own PR, someone else's PR, or a local review:

    **Own PR (`isOwnPR = true`) or local mode:**
    - If issues were found, ask the user: "Want me to fix these issues?" If yes, apply the fixes directly, then enter the convergence loop.
    - **Convergence loop (max 5 iterations).** Fixes can introduce new issues, break existing tests, or create cross-file contradictions. After applying fixes, verify convergence:
      1. **Re-verify.** Run lint, typecheck, build, and tests. If any gate fails, fix the failure before continuing.
      2. **Re-read.** Read every file that was modified during the fix pass.
      3. **Re-audit.** Run all three review passes (per-file, cross-file consistency, cascading fix analysis) on the modified files. Check specifically:
         - Did any fix violate project conventions from CLAUDE.md or the rules directory?
         - Did any fix introduce a cross-file contradiction?
         - Did any fix change a public interface without updating all callers?
         - Did any fix introduce a new dependency or configuration requirement without updating env files, CI, or documentation?
         - Are all new code paths covered by tests?
      4. **If new issues are found:** fix them and repeat from step 1.
      5. **If no new issues:** convergence achieved. Proceed.
    - After convergence, suggest `/commit` to commit.
    - In local mode: do NOT post anything. If the review is clean, suggest `/pr` to open the PR.
    - In PR mode on your own PR: after fixing and converging, push the changes.

    **Someone else's PR (`isOwnPR = false`):**
    - Do NOT offer to fix the code directly. You are a reviewer, not a co-author.
    - If `--post` was passed: post the review as inline comments immediately after presenting it, without asking for confirmation.
    - If `--post` was NOT passed: ask the user if they want to post the review as inline comments. If yes, post after explicit approval.
    - When posting:
      - GitHub: use `gh api repos/{owner}/{repo}/pulls/{number}/reviews` with a JSON payload containing `event`, `body`, and `comments` array. Each comment has `path`, `line`, `side`, and `body`. Always post individual comments on the exact lines, never a single big comment. Use `REQUEST_CHANGES` as the event when there are issues, `APPROVE` when clean, or `COMMENT` for minor suggestions only.
      - GitLab: use `glab mr note <number>` for comments.
    - Each comment should include the issue, why it matters, and a code example showing the fix, so the author knows exactly what to do.

## Review Standards

This review operates at the highest standard. The bar for approval is:

- Zero bugs, zero security issues, zero data integrity risks.
- Every error path handled explicitly with context.
- Every public input validated.
- Every new behavior covered by meaningful tests.
- Performance characteristics understood and acceptable.
- Code is clear enough that a new team member could maintain it.

If something is "probably fine," that's not good enough. If you have to squint to understand what a function does, that's a problem. If a test only checks the happy path, that's incomplete.

Be demanding, but always be helpful. The goal is to make the code excellent, not to block the developer. Every issue you raise must come with a clear explanation of why it matters and a concrete code example showing how to fix it.

## Comment Format

Follow the comment format, code example standards, and examples defined in `reviewer-prompt.md`. Every comment must include what's wrong, why it matters, and a code example showing the fix.

## Review Summary

The overall review body should be a direct, honest assessment. Start with what the PR gets right, then list what needs attention. Be specific: name the files and the issues.

**Operational risk assessment.** For non-trivial changes, include a brief risk section at the end of the review body. Cover:
- **Blast radius:** what breaks if this change has a bug? One endpoint, one user flow, all users, the entire service?
- **Rollback:** can this be reverted cleanly, or does it include a database migration, new infrastructure, or data format change that makes rollback complex?
- **Deployment dependencies:** does this change require anything beyond a code deploy? New env vars, infrastructure provisioning, feature flags, coordinated deploys with other services?

Skip this section for trivial changes like typos, config tweaks, or small refactors where the risk is self-evident.

Choose the verdict based on what you found:
- **APPROVE**: Zero issues found. Tests pass, coverage is adequate, code is clean. This is a high bar.
- **REQUEST_CHANGES**: Any bugs, security issues, missing error handling, missing tests, or stale branch. Most reviews will land here.
- **COMMENT**: Minor suggestions only, nothing that would cause problems in production.

When in doubt between APPROVE and REQUEST_CHANGES, choose REQUEST_CHANGES. It's always better to ask for one more look than to let a problem through.

## Test Evidence

Follow the test evidence policy in `rules/code-review.md`. CI pipeline passing counts as sufficient evidence. Only request manual output when tests are not automated.

If tests exist but coverage is below 80% for the changed code, flag it. If the PR adds new behavior with zero tests, that alone is enough for REQUEST_CHANGES.

## Branch Freshness

Check if the branch is up to date with the base branch. If it is behind, ask the author to rebase and re-run the tests with fresh evidence. If the rebase causes conflicts, ask the author to resolve them and provide test evidence again after resolution. Stale branches should not be approved.

## Rules

- Always execute all three review passes (per-file, cross-file consistency, cascading fix analysis). Do not skip passes because the diff looks simple or because enough issues were already found. The most expensive bugs hide in cross-file interactions and downstream fix effects.
- Every comment that suggests a fix must include a cascading analysis: what could the fix itself break? If the fix could introduce a new problem, include a "When implementing this fix, also..." note. The goal is zero second-round surprises.
- Always detect the git platform from the remote URL. Never assume GitHub or GitLab.
- Always read surrounding code to understand context before reviewing changes. Never review a diff in isolation.
- Always present the full review to the user before posting any comments.
- Always post comments as individual inline comments on the exact lines where the change is needed. Never post a single big comment with everything.
- Always include a code example in every comment that points out an issue. The developer should see exactly what the fix looks like.
- Never post comments without explicit user approval, unless `--post` was passed.
- Never approve a PR that has failing tests or lint errors.
- Never approve without test evidence (see "Test Evidence" section).
- Never approve a stale branch (see "Branch Freshness" section).
- Never approve a PR where new behavior is not covered by tests.
- Never let something slide because "it's a small PR" or "it's just a refactor." Small changes can introduce big bugs.
- Every comment must sound like a real person wrote it. No prefix labels, no formulaic language, no template-driven phrasing.
- If the required CLI tool (`gh` or `glab`) is not installed and a PR number/URL was given, stop and tell the user. In local mode, the CLI tool is only needed for base branch detection and is not strictly required.
- If no PR/MR exists and no local commits are ahead of the base branch, say so and stop.
- Never review a PR/MR that is not open. Check the state before doing any work. If merged or closed, tell the user and stop immediately.
- In local mode, never post comments anywhere. Present the review to the user only.
- In local mode, if the review is clean, suggest the user run `/pr` to open the PR.
- Always restore the original account per `rules/borrow-restore.md`, even if earlier steps fail.

## Related skills

- `/pr` - Create or update the PR/MR being reviewed.
- `/checks` - Verify CI/CD pipeline status before approving.
- `/commit` - Commit fixes after addressing review feedback.
