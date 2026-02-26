# Claude Code Configuration

Personal Claude Code setup with custom skills, engineering guidelines, and project-wide conventions. Everything lives in `~/.dotfiles/claude/` and is symlinked into `~/.claude/` by the dotfiles installer.

## Directory Structure

```
claude/
  settings.json          # Permissions, hooks, statusline, MCP, and global settings
  CLAUDE.md              # Core engineering rules (lean, ~150 lines)
  rules/
    code-style.md        # Code conventions, data safety gate, comments, dependencies
    testing.md           # Test philosophy, mock policy, AAA pattern, scenario planning
    git-workflow.md      # Commit format, branches, CI monitoring, PRs, rollbacks
    code-review.md       # Author guidelines, review style, documentation checks
    security.md          # Secrets, auth checklist, audit logging
    database.md          # Schema rules, query optimization, migrations, naming
    api-design.md        # REST conventions, error format, pagination, versioning
    observability.md     # Structured logging, metrics, tracing, health checks
    resilience.md        # Error classification, retries, idempotency, deduplication, DLQs, back pressure, bulkhead, concurrency control
    caching.md           # Cache strategies, invalidation, thundering herd, warming, sizing
    distributed-systems.md # Consistency models, saga, outbox, distributed locking, event ordering, schema evolution
    debugging.md         # Systematic debugging process, multi-component tracing
    verification.md      # Verification-before-completion enforcement
    llm-docs.md          # LLM-optimized documentation references for common tech
  hooks/
    dangerous-command-blocker.py  # Blocks catastrophic bash commands (3 severity levels)
    secret-scanner.py             # Scans staged files for 40+ secret patterns
    conventional-commits.sh       # Validates commit message format
    smart-formatter.sh            # Auto-formats files after edit by language
  scripts/
    context-monitor.py   # Statusline: context usage, git branch, cost
  skills/
    commit/SKILL.md      # Semantic commits from uncommitted changes
    pr/SKILL.md          # Pull request creation and updates
    review/SKILL.md      # Code review for PRs and local branches
      reviewer-prompt.md # 15-category review checklist with expanded architecture checks
    assessment/SKILL.md  # Architecture completeness audit (finds missing patterns, not bugs)
      assessment-checklist.md # 15-category architecture assessment checklist
    checks/SKILL.md      # CI/CD pipeline monitoring and diagnosis
    release/SKILL.md     # Tagged releases with auto-generated changelogs
    test/SKILL.md        # Test runner detection and execution
    deps/SKILL.md        # Dependency auditing and vulnerability scanning
    db/SKILL.md          # Database migrations and container management
    docker/SKILL.md      # Container orchestration with Colima awareness
    env/SKILL.md         # Environment variable validation
    logs/SKILL.md        # Log viewing and analysis
    morning/SKILL.md     # Start-of-day dashboard and standup prep
    scaffold/SKILL.md    # Boilerplate generation from existing patterns
    terraform/SKILL.md   # Terraform/OpenTofu workflows with safety gates
    perf/SKILL.md        # Load testing and HTTP endpoint benchmarks
    worktree/SKILL.md    # Git worktree management for parallel development
```

## Settings

Defined in `settings.json`:

- **Output style**: `Explanatory`. Adds educational insight blocks before and after code, explaining implementation choices and codebase-specific patterns.
- **Language**: `english`. Always respond in English regardless of input language.
- **Effort level**: `high`. Maximum reasoning depth on every response. Override per-session with `/effortLevel medium` or `low` for faster, lighter interactions.
- **Attribution**: disabled. No "Co-authored-by" lines in commits or PRs.
- **Permissions**: broad pre-approved access covering file I/O (`Read`, `Write`, `Edit`), web access (`WebFetch`, `WebSearch`), skills, and ~100 bash commands. Explicit deny rules for `.env`, `.env.local`, `.env.production`, `secrets/`, and `config/credentials.json`.
- **Hooks**: four hooks enforcing rules at runtime (see Hooks section below).
- **Statusline**: context monitor showing context usage percentage, git branch, and session cost.
- **MCP servers**: Context7 for pulling version-specific library documentation into prompts.

## Hooks

Hooks enforce rules at runtime by intercepting tool calls. Defined in `settings.json`, scripts live in `hooks/`.

### PreToolUse Hooks (Bash)

**Dangerous command blocker** (`hooks/dangerous-command-blocker.py`): three severity levels.
- Level 1 BLOCK: catastrophic commands (`rm -rf /`, `dd` to disk, `mkfs`, fork bombs, `chmod 777 /`, piping remote scripts to shell).
- Level 2 BLOCK: critical path protection (deleting `.git/`, `.env`, `.claude/`, `git push --force`, `git reset --hard`, `git clean -f`, `git checkout .`).
- Level 3 WARN: suspicious patterns (`rm` with wildcards, `find -delete`, `xargs rm`, writing to `/etc/`, `killall`).

**Secret scanner** (`hooks/secret-scanner.py`): intercepts `git commit` commands and scans all staged files for 40+ secret patterns including AWS, Anthropic, OpenAI, Google, Stripe, GitHub, GitLab, Slack, Discord, Telegram, Vercel, Supabase, Hugging Face, npm, PyPI, private keys, JWTs, database URLs, and generic password/secret assignments. Skips lockfiles, binary files, and `.env.example`. Blocks the commit with a report listing each finding.

**Conventional commits** (`hooks/conventional-commits.sh`): validates that `git commit` messages match the conventional commit format (`type(scope): subject`). Allows all standard types: feat, fix, docs, style, refactor, perf, test, chore, ci, build, revert. Enforces max 72-char subject line. Skips amend, merge, and squash commits.

### PostToolUse Hooks (Edit/Write)

**Smart formatter** (`hooks/smart-formatter.sh`): runs the appropriate formatter after any Edit or Write operation based on file extension. JS/TS/JSON/CSS/HTML/YAML use prettier, Python uses black or ruff, Go uses gofmt, Rust uses rustfmt, Ruby uses rubocop, shell uses shfmt. Silently skips if the formatter is not installed.

### Stop Hook

**Desktop notification**: sends a macOS notification via `osascript` when Claude finishes responding. Allows switching to another window without polling.

## MCP Servers

**Context7** (`@upstash/context7-mcp`): pulls up-to-date, version-specific library documentation directly into prompts. Complements the `rules/llm-docs.md` curated references by automating doc lookups for any library, not just those in the reference table.

## CLAUDE.md Overview

The global `CLAUDE.md` is intentionally lean, containing only rules that change Claude's default behavior. Domain-specific conventions live in the `rules/` directory, which loads automatically with the same priority.

**Root file covers:**

- **Core checklist**: verify before acting, no secrets, fail fast, evidence required, safe defaults, single source of truth, explicit over implicit, reuse first, performance first.
- **Tone**: write like a coworker, not an assistant. Match conversation energy. Push back when something doesn't make sense. Explicit banned phrases list targeting common AI tells: filler openers, closers, hedges, transitions, and fluff adjectives.
- **Writing style**: no em dashes, no parentheses in prose, no AI attribution in own output. Natural writing for all external output: vary structure, no parallel enumeration, no bold labels in prose, self-review before posting.
- **Confidence**: never act on assumptions. Read every file before modifying. No "I think" or "probably" about code facts. Red flags list for when to stop and verify. Investigate or ask one question at a time when blocked.
- **Anti-hallucination**: verify everything in the current session: file paths, import paths, function signatures, API shapes, CLI flags, versions, config, dependencies, env vars. Self-check every import and path reference before presenting code.
- **Scope control**: one task at a time, ask before expanding, max 3-5 files.
- **Mandatory verification**: run tests, lint, build before declaring done.
- **Context compaction**: preserve modified files, test results, and user decisions.
- **Debugging approach**: reproduce, isolate, root cause, fix+verify.

**Rules directory covers:**

- **Code style** (`rules/code-style.md`): DRY, SOLID, KISS. Functions under 30 lines. No deep nesting (max 3 levels, guard clauses). Strong typing (no `any`, explicit types, strict mode). Immutability at every layer: pure functions, immutable objects/collections, state transitions that produce new state, append-only for audit data. Data safety gate: three mandatory questions (idempotent? atomic? duplicates?) before any mutation. Error classification gate: every catch must classify transient vs permanent. Comments policy. Dependencies management.
- **Testing** (`rules/testing.md`): integration-first. Strict mock policy. AAA pattern. 80%+ coverage for new code. Deterministic tests: no time/random/network/shared-state dependencies, flaky test prevention with fix-or-delete policy. Test scenario planning with requirement traceability for non-trivial tasks.
- **Git workflow** (`rules/git-workflow.md`): conventional commits, branch naming, CI/CD monitoring, PR creation, conflict resolution, rollback strategy.
- **Code review** (`rules/code-review.md`): author guidelines, natural review comments, test evidence, documentation checks, technical debt classification and tracking, ADR (Architecture Decision Records) format and usage, pre-completion checklist.
- **Security** (`rules/security.md`): secrets management, auth checklist with CSRF protection, access control (RBAC, IDOR prevention, default deny, least privilege), encryption (TLS in transit, platform-managed keys at rest, bcrypt/argon2 for passwords), data privacy (minimization, retention, right to erasure, consent, GDPR/LGPD compliance), supply chain security (lockfile integrity, typosquatting, dependency confusion, audit in CI), audit logging.
- **Database** (`rules/database.md`): schema rules, query optimization, isolation levels (READ COMMITTED through SERIALIZABLE with decision guide), transactions and atomic writes, conditional writes with optimistic locking, access pattern design with timezone alignment trap for time-range queries, NoSQL key design, safe migrations, connection management, naming conventions.
- **API design** (`rules/api-design.md`): REST conventions, status codes, error response format, pagination patterns, versioning with full deprecation lifecycle (announce, document, monitor, warn, remove), idempotency keys, rate limiting headers, bulk operations.
- **Observability** (`rules/observability.md`): structured JSON logging, log levels, sensitive data masking, correlation IDs, metrics naming, health check endpoints, distributed tracing, SLI/SLO/SLA with error budgets, alerting tied to SLO violations, incident response process, blameless postmortem template.
- **Resilience** (`rules/resilience.md`): error classification (transient vs permanent), retry strategies with exponential backoff and jitter, idempotency patterns at every layer (API, message handler, database, state machine), deduplication with durable stores, dead letter queue strategy with partial batch failure reporting, circuit breakers, timeout budgets, back pressure with load shedding priorities, bulkhead isolation per dependency, concurrency control with semaphores and worker pools.
- **Caching** (`rules/caching.md`): cache-aside, write-through, write-behind, and read-through strategies with default recommendations. Invalidation methods (TTL, explicit, event-driven, versioned keys). Thundering herd prevention (lock-based recomputation, stale-while-revalidate, probabilistic early expiration, TTL jitter). Cache warming strategies. Sizing and eviction policies.
- **Distributed systems** (`rules/distributed-systems.md`): monolith vs microservices decision guide (start monolith, extract only with concrete reason). Consistency models (strong, eventual, read-your-writes, causal) with default-to-weakest rule. Saga pattern with orchestration vs choreography decision guide and compensating action design. Outbox pattern with SQL example and delivery mechanisms (polling, CDC, log tailing). Distributed locking with fencing tokens. Event ordering and delivery guarantees (at-most-once, at-least-once, exactly-once). Schema evolution with backward/forward compatibility rules. Zero-downtime deployments (rolling, blue/green, canary, feature flags) with backward compatibility and graceful shutdown requirements.
- **Debugging** (`rules/debugging.md`): systematic four-phase debugging process, multi-component tracing, common traps to avoid. Expands on the debugging approach in CLAUDE.md with specific techniques for reproduction, isolation, root cause analysis, and fix verification.
- **Verification** (`rules/verification.md`): verification-before-completion enforcement. Gate function: identify what proves the claim, run it, read the output, verify it matches, only then claim done. Evidence requirements table for common claims. Covers partial completion reporting.
- **LLM docs** (`rules/llm-docs.md`): curated `llms.txt` and `llms-full.txt` references for common technologies. Fetch official docs before relying on training data.

## Skills Reference

### /commit

Analyzes uncommitted changes and creates semantic commits following conventional commit format.

**Arguments**: `--push` to push automatically after committing.

Runs `git status`, `git diff`, `git diff --cached`, and `git log` in parallel to gather context. Groups related changes into logical commits. Follows the commit format defined in `rules/git-workflow.md` and `git/.gitmessage`. Never uses `git add -A`, always stages specific files. After committing, asks whether to push to remote. Use `--push` to skip the question and push immediately.

---

### /pr

Creates or updates a pull request with structured descriptions.

**Arguments**: `--draft`, `--base <branch>`, `--reviewer <user>`, `--assignee <user>`, `--label <name>`, `update`, or a PR number.

Detects GitHub or GitLab from the remote URL. Fetches and rebases on the target branch before opening. Performs self-review of the diff for debug statements, secrets, and large files. Scales the description to PR size: subject-only for trivial changes, full "What/How/Testing" structure for larger ones. Warns on PRs over 400 lines and asks for confirmation over 1000 lines.

---

### /review

Reviews a pull request or local branch changes with rigorous, line-by-line analysis.

**Arguments**: no args for current branch PR, one or more PR numbers or URLs, `--local` to skip PR lookup, `--post` to auto-post without confirmation.

Works in two modes. PR mode fetches the diff and metadata from the remote. Local mode diffs committed changes against the base branch, useful before opening a PR. If no PR exists, automatically falls back to local mode. Supports batch reviews: pass multiple PR numbers or URLs to review them sequentially in one invocation. Uses a 15-category checklist covering correctness, security, error handling, performance (including caching, time-range timezone alignment), concurrency (including bounded concurrency, distributed locking with fencing), data integrity (including schema evolution, append-only audit data), API design, testing, code quality (including immutability enforcement), naming, architecture (including consistency models, read-your-writes, outbox pattern), observability, dependencies, documentation, and resilience/fault tolerance (including saga/compensation, back pressure with load shedding, bulkhead isolation). Every issue includes what's wrong, why it matters, and a code example showing the fix. Post-review behavior is authorship-aware: on your own PR or in local mode, offers to fix issues directly. On someone else's PR, acts as a reviewer only and posts inline comments with REQUEST_CHANGES/APPROVE/COMMENT after approval. Use `--post` to skip the confirmation step and post immediately.

**Verdicts**: APPROVE, REQUEST_CHANGES, or COMMENT. Defaults to REQUEST_CHANGES when in doubt.

---

### /assessment

Architecture completeness audit for an implementation. Finds what's **missing**, not just what's wrong.

**Arguments**: no args for changed files on current branch, a file or directory path, `--scope <description>` to focus the assessment.

Unlike `/review` which checks diffs for correctness, `/assessment` reads the full implementation and identifies missing architectural patterns. Classifies the system type first (write path, read path, external dependencies, async processing, multi-service, variable load, data storage), then audits only the applicable categories. Uses a 15-category checklist: idempotency/deduplication, atomicity/transactions, error classification, caching, consistency models, back pressure/load management, bulkhead isolation, concurrency control, saga/outbox, event ordering/delivery guarantees, distributed locking, schema evolution, immutability, query optimization, and observability. Output is a structured gap analysis with PRESENT/MISSING/PARTIAL status per category, concrete code examples for every gap, and a ranked top-3 impact list. After the assessment, offers to implement the missing patterns.

---

### /checks

Monitors CI/CD pipeline status and diagnoses failures.

**Arguments**: no args for current branch, or a PR number.

Detects the platform from the remote URL. Waits for checks with a 10-minute timeout using a `timeout 600` wrapper since `gh` has no native timeout flag. When checks fail, fetches logs in parallel and formats failures with check name, direct URL, error message, and log excerpt. Searches for existing fixes in branches and PRs before suggesting corrections.

---

### /release

Creates a tagged release with an auto-generated changelog from conventional commits.

**Arguments**: no args for auto-detected version, a specific `<version>`, or `--dry-run`.

Gathers remote URL, latest tag, and working tree status in parallel. Groups commits by type into sections: Features, Bug fixes, Performance, Breaking changes. Determines version bump from commit types: `feat` bumps minor, `fix`/`perf`/`refactor` bump patch, non-artifact types like `chore`/`docs`/`style`/`test`/`build`/`ci` skip the bump. Runs tests, lint, and build using the same detection as `/test` before proceeding. Requires explicit approval before creating the tag and release.

---

### /test

Detects the project's test runner and executes tests with coverage, linting, and security scanning.

**Arguments**: no args for full suite, file or pattern, `--coverage`, `--watch`, `--lint`, `--scan`, `--ci`.

Auto-detects the package manager from lockfiles and the test runner from config files. Supports vitest, jest, mocha, pytest, cargo test, and go test. Lint mode runs eslint, golangci-lint, shellcheck, ruff, flake8, actionlint, or vint as appropriate. Scan mode uses trivy, snyk, and gitleaks (same scanning as `/deps scan`). CI mode runs GitHub Actions locally with `act`.

---

### /deps

Audits dependencies for vulnerabilities and manages updates.

**Arguments**: no args for audit, `outdated`, `update [package]`, `scan`, or `image <name>`.

Detects the package manager automatically using the same lockfile detection order as `/test`. Runs native audit commands, then deep scans with trivy, snyk, and gitleaks if installed (same scanning as `/test --scan`). Docker image analysis uses trivy and dive. Shows vulnerabilities grouped by severity. Always asks approval before updating.

---

### /db

Manages database migrations, containers, and data operations.

**Arguments**: no args for status, `migrate`, `rollback`, `create <name>`, `seed`, `reset`, `start`, `stop`, `terminal`.

Detects container status, migration tool, and package manager in parallel. Supports Prisma, Knex, Sequelize, TypeORM, Drizzle, Alembic, Goose, and Diesel. Drizzle uses `migrate` for migration-based workflows and `push` only in dev/prototyping when explicitly requested. Aware of standalone containers managed by shell functions like `postgres-start`, `mongo-init`, `redis-start`, following `/docker`'s container conventions. Checks container health before migration operations. Requires explicit approval for rollback and reset.

**Container defaults**: postgres on 127.0.0.1:5432 (postgres:postgres), mongo on :27017 (mongo:mongo), redis on :6379 (no auth), valkey on :7000, redict on :6379.

---

### /docker

Manages Docker containers, compose services, and the container runtime.

**Arguments**: no args for status, `build [service]`, `up [service]`, `down`, `restart [service]`, `logs [service]`, `shell <service|container>`.

Detects runtime, compose files, and running containers in parallel. Runtime-agnostic: works with Colima, Docker Desktop, or native daemon. Suggests `colima-start` when Colima is installed but stopped. Distinguishes compose services from standalone containers. Asks approval before `down`.

---

### /env

Validates environment variables by comparing `.env` with `.env.example`.

**Arguments**: no args for validation, `diff`, `init`, or a path.

Reads `.env.example`, `.env`, and `.envrc` in parallel. Reports missing variables, empty values, and extras. Detects direnv configuration and checks if `.envrc` is allowed. Never displays actual secret values.

---

### /logs

Views and analyzes logs from Docker containers, log files, or process managers.

**Arguments**: no args for recent logs, service or container name, `--level <level>`, `--since <time>`, `--grep <pattern>`.

Detects Docker runtime and log sources in parallel. Supports Docker Compose services, standalone containers, pm2, and log files. Auto-detects JSON structured logs. Masks sensitive fields matching patterns like password, token, secret, authorization, credential, key, jwt, auth, apikey, access_token, refresh_token. Shows error count, frequency, and repeated patterns.

---

### /morning

Start-of-day dashboard with open PRs, pending reviews, notifications, and standup prep.

**Arguments**: no args for full briefing in the current repo, `--all` for cross-repo data, `--standup` for just yesterday's commits and today's pending items, `--review` to skip the briefing and jump straight to reviewing pending PRs.

Enumerates all authenticated accounts on GitHub and GitLab with fallback parsing for older `gh` versions, queries each one, and aggregates the results. Fetches your open PRs with CI, review, and merge status. Fetches PRs where you are requested as a reviewer, sorted by size (smallest first) to unblock teammates faster, with drafts filtered out. Pulls unread notifications grouped by type. Builds a standup summary from yesterday's commits grouped by branch, with Monday-aware weekend coverage. Checks local state for uncommitted changes, unpushed commits, and stale merged branches. After the briefing, if there are pending reviews, offers to review them all interactively: for each PR, runs the full `/review` checklist, presents the analysis, and asks whether to Post, Skip, or Stop. Account switching is handled automatically per PR and the original account is always restored.

---

### /scaffold

Generates boilerplate code by reading existing project patterns.

**Arguments**: `<type> <name>` where type is endpoint, service, component, module, model, controller, middleware, or hook.

Detects framework and finds existing examples in parallel. Reads 2-3 files of the same type to extract: naming convention, export style, import patterns, code structure, test file location. Generates the main file and test file matching project patterns exactly. Presents generated code for approval before writing.

---

### /terraform

Runs Terraform or OpenTofu workflows with safety checks and approval gates.

**Arguments**: no args for validate + plan, `init`, `fmt`, `validate`, `plan`, `apply`, `destroy`, or a directory path.

Detects terraform or tofu and the working directory in parallel, using `.terraform-version` or `.opentofu-version` files to determine preference when both are installed. Checks direnv setup and Terraform-related environment variables. Always validates before planning, plans before applying. Saves plan files before apply and cleans them up after. Requires explicit approval for apply and destroy. Displays the active workspace in all outputs.

---

### /perf

Runs load tests and benchmarks against HTTP endpoints.

**Arguments**: a URL (required), `-n <requests>`, `-c <concurrency>`, `-d <duration>`, `--method <METHOD>`, `--body <json>`, `--header <key:value>`, `--compare`, `--script <path>`.

Auto-detects installed load testing tools in order of preference: k6, wrk, hey, ab. Validates the target is reachable before starting. For k6, generates a temporary script or uses a custom one via `--script`. Parses results into a standard table: total requests, failures, requests/sec, latency avg/p50/p95/p99, and transfer rate. Flags tail latency above 1s and error rates above 1%. Compare mode runs the test twice with a pause between for changes, then shows a side-by-side diff with percentage deltas. Refuses to hit production URLs without explicit confirmation. Defaults to 1000 requests at 10 concurrency.

---

### /worktree

Manages git worktrees for parallel development.

**Arguments**: `init <task1> | <task2>`, `deliver`, `check`, `cleanup`, `cleanup --all`, `cleanup --branch <name>`, `cleanup --dry-run`.

Enables working on multiple tasks simultaneously using git worktrees. `init` creates isolated worktrees from pipe-separated task descriptions, generating `wt/<kebab-task>` branches and `.worktree-task.md` files for context preservation. `deliver` commits, pushes, and creates a PR from inside a worktree using the task file as PR basis. `check` shows a status table of all worktrees with branch, commits ahead, and uncommitted changes. `cleanup` removes worktrees for merged branches, with `--all` for aggressive cleanup and `--dry-run` for preview. All worktree branches use the `wt/` prefix for safe identification.

## Review Checklist

The `/review` skill uses a 15-category checklist defined in `skills/review/reviewer-prompt.md`:

1. **Correctness**: logic tracing, off-by-one, null handling, boolean logic, type coercion, regex, date/time, floating point, recursion termination.
2. **Security**: injection (SQL, XSS, command, path traversal, SSRF, header, template), auth/authz, data exposure, cryptography.
3. **Error handling**: meaningful catches, context in errors, error classification (transient vs permanent), retry with backoff, async error handling, partial failure and batch failure reporting.
4. **Performance**: algorithmic complexity, N+1 queries, SELECT *, pagination, conditional writes, time-range query design with timezone alignment, NoSQL key distribution, memory/IO, caching strategies and invalidation, thundering herd prevention, frontend re-renders.
5. **Concurrency**: shared mutable state, TOCTOU bugs, missing await, fire-and-forget, deadlock potential, bounded concurrency (semaphore/worker pool), distributed locking with fencing tokens, event ordering and delivery guarantees.
6. **Data integrity**: boundary validation, database constraints, safe migrations, UTC timestamps, append-only for audit data, schema evolution (backward/forward compatibility).
7. **API design**: REST conventions, response consistency, pagination, error format, idempotency.
8. **Testing**: branch coverage at 80%+, AAA pattern, specific assertions, no mocked internals, negative and boundary tests.
9. **Code quality**: function size, single responsibility, DRY, no dead code, composition over inheritance, immutability (pure functions, new state per transition, derived values via selectors).
10. **Naming**: descriptive variables, verb-based functions, boolean prefixes, no misleading names.
11. **Architecture**: follows existing patterns, appropriate coupling, no circular dependencies, externalized config, consistency model chosen explicitly, read-your-writes for user mutations, outbox pattern for cross-service event publishing.
12. **Observability**: appropriate log levels, correlation identifier (requestId, traceId, or similar) in logs, no sensitive data logged, health checks.
13. **Dependencies**: justified, maintained, pinned, license-compatible, size-appropriate.
14. **Documentation**: PR description explains what and why, breaking changes documented, README updated, env vars in .env.example.
15. **Resilience**: idempotent handlers with durable deduplication, conditional/atomic writes, DLQ with partial batch failure reporting, explicit timeouts on all external calls, circuit breakers for degraded services, saga with compensating actions and outbox, back pressure with load shedding by priority, bulkhead isolation per dependency.

## Assessment Checklist

The `/assessment` skill uses a 15-category architecture completeness checklist defined in `skills/assessment/assessment-checklist.md`:

1. **Idempotency and deduplication**: every write safe to execute twice, guard per layer, durable dedup with TTL.
2. **Atomicity and transactions**: related writes atomic, conditional writes prevent lost updates, short transaction scope.
3. **Error classification**: every catch classifies transient/permanent/ambiguous, retry only transient with backoff+jitter.
4. **Caching**: strategy explicit, invalidation chosen, TTL jitter, stampede prevention, warming, eviction.
5. **Consistency model**: explicit choice (strong/eventual/read-your-writes/causal), weakest tolerable model used.
6. **Back pressure and load management**: bounded queues, load shedding by priority, 10x traffic plan.
7. **Bulkhead isolation**: separate pool per dependency, critical/non-critical workload separation.
8. **Concurrency control**: bounded fan-out, worker pool sizing, per-unit timeout.
9. **Saga and cross-service coordination**: compensating actions, outbox pattern, no dual writes.
10. **Event ordering and delivery**: delivery guarantee explicit, per-entity ordering, out-of-order handling.
11. **Distributed locking**: lease expiry, fencing tokens, stale write prevention.
12. **Schema evolution**: backward/forward compatible, version field, no removed/renamed fields.
13. **Immutability**: pure functions, const default, new state per transition, append-only audit data.
14. **Query optimization**: no N+1, pagination, timezone-aware time ranges, database-level filtering.
15. **Observability**: structured logging, correlation IDs, health checks, metrics, alerts on symptoms.
