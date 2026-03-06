# Claude Code Configuration

Personal Claude Code setup with custom skills, engineering guidelines, and project-wide conventions. Everything lives in `~/.dotfiles/claude/` and is symlinked into `~/.claude/` by the dotfiles installer.

## Directory Structure

```
claude/
  settings.json          # Permissions, hooks, statusline, MCP, and global settings
  CLAUDE.md              # Core engineering rules (lean, ~150 lines)
  checklists/
    engineering.md       # 32-category shared checklist (used by /review and /assessment)
  rules/
    code-style.md        # Code conventions, data safety gate, comments, dependencies
    testing.md           # Test philosophy, mock policy, AAA pattern, fake data generators, scenario planning
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
    borrow-restore.md    # Borrow-and-restore pattern for global mutable CLI state
    infrastructure.md    # IaC, networking, container orchestration, CI/CD, cloud architecture
    pre-flight.md        # Pre-implementation confidence gate (duplicate check, architecture fit, interface verification)
    frontend.md          # Frontend design rules: typography, spacing, contrast, responsive, accessibility, Tailwind
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
      reviewer-prompt.md # 12 review-only categories + comment format with examples + reference to shared engineering checklist + code example compliance rule
    assessment/SKILL.md  # Architecture completeness audit (finds missing patterns, not bugs)
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
    readme/SKILL.md      # Marketing-grade README and GitHub About generation
    worktree/SKILL.md    # Git worktree management for parallel development
    retro/SKILL.md       # Session retrospective: captures patterns and preferences as durable config
    design-review/SKILL.md  # Visual design, UX, and accessibility audit for frontend code
    palette/SKILL.md     # Accessible OKLCH color palette generator with WCAG AA verification
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
- **Tone**: write like a coworker, not an assistant. Match conversation energy. Push back when something doesn't make sense. Explicit banned phrases list targeting common AI tells: filler openers, closers, hedges, transitions, and fluff adjectives. No passive aggression in any external output: never reference how many times something was discussed or reviewed, never imply the other person should have known better, focus on what remains not what was already said, assume good faith.
- **Writing style**: no em dashes, no parentheses in prose, no AI attribution in own output, no ASCII art or ASCII diagrams of any kind. All visual representations must use Mermaid syntax in fenced code blocks. Natural writing for all external output: vary structure, no parallel enumeration, no bold labels in prose, self-review before posting. GMT for all timestamps in reports and documentation. When writing instructions for others, provide maximally detailed console UI walkthroughs and CLI equivalents.
- **Confidence**: never act on assumptions. Read every file before modifying. No "I think" or "probably" about code facts. Red flags list for when to stop and verify. Investigate or ask one question at a time when blocked.
- **Anti-hallucination**: verify everything in the current session: file paths, import paths, function signatures, API shapes, CLI flags, versions, config, dependencies, env vars. Self-check every import and path reference before presenting code.
- **Shell alias safety**: prefix shell commands with `command` to bypass aliases (`du` -> `dust`, `ls` -> `eza`).
- **Scope control**: one task at a time, ask before expanding, max 3-5 files. Default to "all" when presenting improvement lists.
- **External tools**: verify installation before use, never use Homebrew on Linux, pnpm as default JS/TS package manager.
- **Mandatory verification**: run tests, lint, build before declaring done.
- **Context compaction**: preserve modified files, test results, and user decisions.
- **Debugging approach**: reproduce, isolate, root cause, fix+verify.
- **Session retrospective**: after significant multi-step work or sessions with corrections, run `/retro` to capture patterns and preferences as durable configuration.

**Rules directory covers:**

- **Code style** (`rules/code-style.md`): DRY, SOLID, KISS. Functions under 30 lines. No deep nesting (max 3 levels, guard clauses). Strong typing (no `any`, explicit types, strict mode, enums over string literal unions for domain values). TypeScript type construct guidelines: `interface` for object shapes, `type` for unions/intersections/mapped types, `enum` for domain value sets, `as const` objects for rich lookup tables. Immutability at every layer: pure functions, immutable objects/collections, state transitions that produce new state, append-only for audit data. Data safety gate: three mandatory questions (idempotent? atomic? duplicates?) before any mutation, referencing `resilience.md` and `database.md` for detailed patterns. Error classification gate: every catch must classify transient vs permanent, referencing `resilience.md` for the full table. Comments policy. Dependencies management. Zod as preferred validation library with semantic checks. DDD file naming (`name.type.ts`). Latest stable/LTS versions for languages and runtimes. Code examples rule: every snippet in any context (reviews, PRs, docs, chat) must follow all project rules. A fix suggestion that violates a rule is itself a defect.
- **Testing** (`rules/testing.md`): integration-first. Strict mock policy. AAA pattern. Fake data generators for all test data, seeded for determinism, static values are a blocking review issue. 80%+ coverage for new code. Deterministic tests: no time/random/network/shared-state dependencies, flaky test prevention with fix-or-delete policy. Test scenario planning with requirement traceability for non-trivial tasks.
- **Git workflow** (`rules/git-workflow.md`): conventional commits, branch naming, CI/CD monitoring, PR creation, conflict resolution, rollback strategy, ignored artifacts (dist/, build/, .next/, node_modules/ never committed).
- **Code review** (`rules/code-review.md`): author guidelines, natural review comments, branch freshness check (mandatory rebase and fresh evidence when behind), test evidence (CI pipeline results are sufficient, manual output only requested when tests are not automated), documentation checks, technical debt classification and tracking, ADR (Architecture Decision Records) format and usage, pre-completion checklist with fake data enforcement.
- **Security** (`rules/security.md`): secrets management, auth checklist with CSRF protection, access control (RBAC, IDOR prevention, default deny, least privilege), encryption (TLS in transit, platform-managed keys at rest, bcrypt/argon2 for passwords), data privacy (minimization, retention, right to erasure, consent, GDPR/LGPD compliance), supply chain security (lockfile integrity, typosquatting, dependency confusion, audit in CI), audit logging.
- **Database** (`rules/database.md`): schema rules, query optimization, isolation levels (READ COMMITTED through SERIALIZABLE with decision guide), transactions and atomic writes, conditional writes with optimistic locking, access pattern design with timezone alignment trap for time-range queries, NoSQL key design, safe migrations, connection management, locking strategy (prefer FOR UPDATE over advisory locks), production safety (never run destructive ops on prod without confirmation), naming conventions.
- **API design** (`rules/api-design.md`): REST conventions, status codes, error response format, pagination patterns, versioning with full deprecation lifecycle (announce, document, monitor, warn, remove), idempotency keys, rate limiting headers, bulk operations.
- **Observability** (`rules/observability.md`): structured JSON logging, log levels, sensitive data masking, correlation IDs, metrics naming, health check endpoints, distributed tracing, SLI/SLO/SLA with error budgets, alerting tied to SLO violations, incident response process, blameless postmortem template.
- **Resilience** (`rules/resilience.md`): error classification (transient vs permanent), retry strategies with exponential backoff and jitter, idempotency patterns at every layer (API, message handler, database, state machine), deduplication with durable stores, dead letter queue strategy with partial batch failure reporting, circuit breakers, timeout budgets, back pressure with load shedding priorities, bulkhead isolation per dependency, concurrency control with semaphores and worker pools.
- **Caching** (`rules/caching.md`): cache-aside, write-through, write-behind, and read-through strategies with default recommendations. Invalidation methods (TTL, explicit, event-driven, versioned keys). Thundering herd prevention (lock-based recomputation, stale-while-revalidate, probabilistic early expiration, TTL jitter). Cache warming strategies. Sizing and eviction policies.
- **Distributed systems** (`rules/distributed-systems.md`): monolith vs microservices decision guide (start monolith, extract only with concrete reason). Consistency models (strong, eventual, read-your-writes, causal) with default-to-weakest rule. Saga pattern with orchestration vs choreography decision guide and compensating action design. Outbox pattern with SQL example and delivery mechanisms (polling, CDC, log tailing). Distributed locking with fencing tokens. Event ordering and delivery guarantees (at-most-once, at-least-once, exactly-once). Schema evolution with backward/forward compatibility rules. Zero-downtime deployments (rolling, blue/green, canary, feature flags) with backward compatibility and graceful shutdown requirements.
- **Debugging** (`rules/debugging.md`): systematic four-phase debugging process, multi-component tracing, common traps to avoid. Expands on the debugging approach in CLAUDE.md with specific techniques for reproduction, isolation, root cause analysis, and fix verification.
- **Verification** (`rules/verification.md`): verification-before-completion enforcement. Gate function: identify what proves the claim, run it, read the output, verify it matches, only then claim done. Evidence requirements table for common claims. Covers partial completion reporting.
- **LLM docs** (`rules/llm-docs.md`): curated `llms.txt` and `llms-full.txt` references for common technologies. Fetch official docs before relying on training data.
- **Infrastructure** (`rules/infrastructure.md`): Infrastructure as Code (state management, drift detection, immutable infra, module design), networking and service discovery (DNS, load balancing algorithms, mTLS, VPC design, CDN), container orchestration (resource management, scaling strategies, availability patterns, deployment strategies, sidecar patterns), CI/CD pipeline design (stage ordering, artifact immutability, progressive delivery, pipeline security, DORA metrics), cloud architecture (multi-region strategies, blast radius containment, auto-scaling, traffic management, DDoS mitigation, data residency, cost allocation).
- **Borrow and restore** (`rules/borrow-restore.md`): two patterns for handling context-dependent CLI tools. Per-command context flags for tools that support them (Docker `--context`, `kubectl --context`, `aws --profile`): no global mutation, no restore needed, safe for parallel sessions. Borrow-and-restore for tools with no per-command option (`gh`, `glab`, `nvm`, Terraform): read current state, switch, work, restore. Detection order: env var, project config, convention, current state. Includes Docker/Colima section for per-command context resolution with profile running verification.
- **Pre-flight** (`rules/pre-flight.md`): pre-implementation confidence gate. Five checks before writing code: duplicate check (codebase, PRs, branches), architecture fit (patterns, abstractions, callers), interface verification (signatures, APIs, docs, schema), root cause confirmation (bug fixes only), and scope agreement. Complements verification.md: one guards the entrance, the other guards the exit.
- **Frontend design** (`rules/frontend.md`): visual design and UX rules applied automatically to all frontend work. Typography (16px min body, 45-75 char line length, text-balance/text-pretty, consistent heading scale). Spacing (consistent section padding, grid gaps, card padding using Tailwind scale). Color contrast (WCAG AA 4.5:1 for text, 3:1 for large text, OKLCH conversion snippet for verification, both light and dark mode). Responsive design (mobile-first breakpoints, grid transitions, 100dvh not 100vh, overflow-x: clip, 44x44px touch targets). Accessibility (semantic HTML, aria-labelledby on sections, aria-label on nav landmarks, focus management, prefers-reduced-motion). Component patterns (cards, buttons, forms, navigation). Images and icons (inline SVG under 48px, currentColor for theming). Animation (CSS-only, reduced-motion fallbacks, duration guidelines). Performance (self-hosted fonts, minimal client JS, no layout shift). Tailwind conventions (semantic tokens, responsive variant ordering, no @apply).

## Context Resolution

Skills that interact with context-dependent CLI tools resolve the correct context before running commands. Two strategies, defined in `rules/borrow-restore.md`:

### Per-command context (Docker, kubectl, aws)

When the tool supports a `--context` or `--profile` flag, pass it on every command. No global mutation, no restore step, safe for parallel sessions.

**Docker/Colima**: skills resolve the expected context from `DOCKER_CONTEXT` or `DOCKER_HOST` in `.env`/`.envrc`, then pass `--context <name>` on every `docker` invocation. When Colima is the runtime, each profile creates a context (`colima-<profile>`), and the wrong context sends commands to the wrong containers. The skill verifies the target profile is running before using it. Never uses `docker context use`.

**Skills with Docker context resolution:** `/docker`, `/db`, `/logs`.

### Borrow-and-restore (gh, glab)

When the tool has no per-command option, the skill reads the current state, switches, works, and restores. Always. Even on failure.

**Account resolution**: skills that interact with `gh` or `glab` match the repo's remote URL against all authenticated accounts. If the active account doesn't match, the skill switches with `gh auth switch --user <login>` and restores when done. All skills reference `rules/borrow-restore.md` for the procedure instead of restating it inline.

**Skills with account resolution:** `/commit` (pipeline monitoring), `/pr`, `/checks`, `/review`, `/release`, `/worktree` (deliver), `/readme` (GitHub About). `/morning` has full multi-account support with per-account enumeration across all queries.

## Skills Reference

### /commit

Analyzes uncommitted changes and creates semantic commits following conventional commit format.

**Arguments**: `--push` to push automatically after committing, `--pipeline` to push and monitor CI/CD checks with automatic fix-and-retry loop.

Runs `git status`, `git diff`, `git diff --cached`, and `git log` in parallel to gather context. Groups related changes into logical commits. Follows the commit format defined in `rules/git-workflow.md` and `git/.gitmessage`. Never uses `git add -A`, always stages specific files. After committing, asks whether to push to remote. Use `--push` to skip the question and push immediately. Use `--pipeline` to push and enter a closed-loop CI monitor: waits for checks, diagnoses failures with log fetching, searches for existing fixes, offers to apply fixes and re-push automatically. Max 3 fix-and-retry cycles. Each CI fix gets its own commit, never amends the user's original work.

---

### /pr

Creates or updates a pull request with structured descriptions.

**Arguments**: `--draft`, `--base <branch>`, `--reviewer <user>`, `--assignee <user>`, `--label <name>`, `--pipeline`, `update`, or a PR number.

Detects GitHub or GitLab from the remote URL. Fetches and rebases on the target branch before opening. Performs self-review of the diff for debug statements, secrets, and large files. Scales the description to PR size: subject-only for trivial changes, full "What/How/Testing" structure for larger ones. Warns on PRs over 400 lines and asks for confirmation over 1000 lines. Use `--pipeline` to monitor CI/CD checks after PR creation: waits for checks, diagnoses failures with parallel log fetching, searches for existing fixes, offers to apply fixes and re-push automatically. After CI passes, checks for review comments from bots and humans, verifies each suggestion against actual code, classifies as valid/out-of-scope/incorrect, and offers to fix valid ones in the same fix-and-retry loop. Max 3 fix-and-retry cycles. Updates the PR description's Testing section when non-trivial fixes are applied.

---

### /review

Reviews a pull request or local branch changes with rigorous, line-by-line analysis.

**Arguments**: no args for current branch PR, one or more PR numbers or URLs, `--local` to skip PR lookup, `--post` to auto-post without confirmation, `--backend` to review only backend and infrastructure files, `--frontend` to review only frontend files.

Works in two modes. PR mode fetches the diff and metadata from the remote. Local mode diffs committed changes against the base branch, useful before opening a PR. If no PR exists, automatically falls back to local mode. Supports batch reviews: pass multiple PR numbers or URLs to review them sequentially in one invocation. Scope filtering: `--backend` and `--frontend` flags classify diff files by directory structure, extensions, and monorepo workspace names. Backend scope includes infrastructure files. Shared packages and root config are included in both scopes. Ambiguous files are always included. Uses two checklists: 12 review-only categories in `reviewer-prompt.md` for correctness, algorithmic performance, frontend performance, testing with strict mock policy, code quality, naming, architecture patterns, backward compatibility, dependencies, PR quality, cross-file consistency, and cascading fix analysis, plus the 32-category shared engineering checklist in `checklists/engineering.md` for architecture, resilience, and infrastructure concerns. Context gathering reads every changed file in full, not just diff hunks, reads imported modules to understand side effects and error types, checks existing review comments from previous rounds, and verifies the PR description matches the actual diff. Deep analysis executes three explicit passes: (1) per-file analysis against all checklist categories including a strict mock policy check that blocks approval if tests mock internal infrastructure like databases, Redis, or queues instead of using real connections, (2) cross-file consistency check for design contradictions, import chain side effects, configuration completeness, contract alignment, error path consistency, and behavioral symmetry across files, (3) cascading fix analysis that predicts what each suggested fix could break and includes "When implementing this fix, also..." notes so the author handles issues and downstream effects in one iteration. Also checks CI status, PR size (warns above 400 lines, blocks above 1000), and includes an operational risk assessment covering blast radius, rollback complexity, and deployment dependencies. Every issue includes what's wrong, why it matters, and a code example showing the fix. Post-review behavior is authorship-aware: on your own PR or in local mode, offers to fix issues directly with a convergence loop (max 5 iterations) that re-verifies, re-reads, and re-audits modified files after each fix round. On someone else's PR, acts as a reviewer only and posts inline comments with REQUEST_CHANGES/APPROVE/COMMENT after approval. Use `--post` to skip the confirmation step and post immediately.

**Verdicts**: APPROVE, REQUEST_CHANGES, or COMMENT. Defaults to REQUEST_CHANGES when in doubt.

---

### /assessment

Architecture completeness audit for an implementation. Finds what's **missing**, not just what's wrong.

**Arguments**: no args for changed files on current branch, a file or directory path, `--scope <description>` to focus the assessment, `--focus <area>` to narrow to `security`, `resilience`, `api`, `data`, `ops`, `quality`, `tenancy`, `infra`, or `all` (default), `--comments` to add inline explanatory comments when fixing gaps.

Twelve-step process. (1) Scans the entire project for requirement documents and asks the user for email instructions, job postings, and company name. If a company is provided, researches their engineering blog, GitHub, tech talks, and Glassdoor interview reviews for evaluation criteria and tips. Requirements are treated as a floor, not a ceiling. (2-3) Gathers and reads the full implementation. (4) Verifies the project works: runs build, lint, typecheck, tests with coverage, runtime version check (upgrade to latest stable LTS, respect platform constraints like AWS Lambda), dependency audit, and output verification against requirements. Failures here are CRITICAL findings. (5) Hunts for planted defects: reads code with suspicion looking for logic bugs, data bugs, validation gaps, concurrency issues, security flaws, anti-patterns, config issues, mock abuse (tests mocking internal infrastructure instead of using real connections), structural violations, and test gaps. (6) Classifies the system by traits (write path, read path, external dependencies, async processing, multi-service, variable load, data storage, auth/user data, API exposure, production deployment, testable logic, multi-tenancy, system migration, infrastructure config, cloud services), detects languages with supersets (JS to TS, CSS to SCSS) and offers conversion, enforces strictest configuration on all tooling. (7) Audits against the 32-category engineering checklist plus README quality, git history quality, dependency health, and developer tooling (runtime version manager, editorconfig, formatter, linter, type checker, pre-commit hooks, commit linter, CI pipeline). After per-file audit, runs a cross-file consistency check for design contradictions, import chain side effects, configuration completeness, contract alignment, and behavioral symmetry. Categories span seven domains: data integrity, resilience, security and API, operations, quality, tenancy, and infrastructure. Each finding gets a status (PRESENT/PARTIAL/MISSING), severity (CRITICAL/HIGH/MEDIUM/LOW), and effort estimate (S/M/L/XL). (8) Presents structured output with gap analysis, summary table, and priority matrix. (9) Offers to fix in order: developer tooling setup, CI pipeline creation (GitHub Actions or GitLab CI with lint, typecheck, build, and test stages), project reorganization (DDD, SOLID, clean architecture, `name.type.extension` naming), then pattern fixes by severity. Before implementing each fix, runs cascading fix prediction to identify what the fix could break (signature changes, new dependencies, cross-file contradictions) and addresses downstream effects in the same fix to reduce convergence iterations. Transaction fixes always specify explicit lock types. Test data must use a faker library. Strict mock policy: tests must connect to real infrastructure (database, Redis, queues, caches) via docker-compose test dependencies with `beforeAll()` hooks for seeding. Mocking internal infrastructure is a CRITICAL finding. Use `--comments` to add inline code comments explaining the reasoning behind each fix. (10) **Convergence loop**: after all fixes, autonomously re-verifies (lint, typecheck, build, tests), re-reads modified files, re-audits against all applicable categories, user's CLAUDE.md rules, cross-file contradictions, new startup dependencies, and public interface changes, and fixes any new findings. Repeats until no new PARTIAL/MISSING findings exist or max 20 iterations. No user interaction during the loop. (11) Generates a technical README with Mermaid architecture diagram, design decisions as narrative paragraphs, API endpoint tables, coverage metrics, and tech stack. (12) Updates GitHub repository description and topics using borrow-and-restore for `gh` account handling.

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

Detects container status, migration tool, and package manager in parallel. Resolves Docker context from `.env`/`.envrc` and passes `--context` per command (never switches globally). Supports Prisma, Knex, Sequelize, TypeORM, Drizzle, Alembic, Goose, and Diesel. Drizzle uses `migrate` for migration-based workflows and `push` only in dev/prototyping when explicitly requested. Aware of standalone containers managed by shell functions like `postgres-start`, `mongo-init`, `redis-start`, following `/docker`'s container conventions. Checks container health before migration operations. Requires explicit approval for rollback and reset.

**Container defaults**: postgres on 127.0.0.1:5432 (postgres:postgres), mongo on :27017 (mongo:mongo), redis on :6379 (no auth), valkey on :7000, redict on :6379.

---

### /docker

Manages Docker containers, compose services, and the container runtime.

**Arguments**: no args for status, `build [service]`, `up [service]`, `down`, `restart [service]`, `logs [service]`, `shell <service|container>`.

Detects runtime, compose files, and running containers in parallel. Runtime-agnostic: works with Colima, Docker Desktop, or native daemon. Resolves Docker context from `DOCKER_CONTEXT` or `DOCKER_HOST` in `.env`/`.envrc` and passes `--context <name>` on every command, never switching the global context. Verifies the target Colima profile is running before using it. Suggests `colima-start` when Colima is installed but stopped. Distinguishes compose services from standalone containers. Asks approval before `down`.

---

### /env

Validates environment variables by comparing `.env` with `.env.example`.

**Arguments**: no args for validation, `diff`, `init`, or a path.

Reads `.env.example`, `.env`, and `.envrc` in parallel. Reports missing variables, empty values, and extras. Detects direnv configuration and checks if `.envrc` is allowed. Never displays actual secret values.

---

### /logs

Views and analyzes logs from Docker containers, log files, or process managers.

**Arguments**: no args for recent logs, service or container name, `--level <level>`, `--since <time>`, `--grep <pattern>`.

Detects Docker runtime and log sources in parallel. Resolves Docker context from `.env`/`.envrc` and passes `--context` per command (never switches globally). Supports Docker Compose services, standalone containers, pm2, and log files. Auto-detects JSON structured logs. Masks sensitive fields matching patterns like password, token, secret, authorization, credential, key, jwt, auth, apikey, access_token, refresh_token. Shows error count, frequency, and repeated patterns.

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

### /readme

Generates a visually striking, marketing-grade README and GitHub repository description that sells the project at first glance.

**Arguments**: no args for full generation, `--about-only` for just the GitHub description and topics, `--section <name>` to regenerate one section, `--diff` to update based on recent changes.

Deep-scans the project in parallel: package manifests, infrastructure configs, source tree, env files, git context, visual assets, and license. Classifies project type, stack, scale signals, differentiators, and personality. Generates a README designed to feel like a product landing page: centered hero section with logo and badges, bold metrics bar with concrete numbers, HTML feature grids for visual highlights, Mermaid architecture diagrams, comparison tables with checkmarks, prominent quick start, collapsible FAQ and project structure, and light/dark mode image support. Every claim is evidence-based: features, paths, and numbers are verified against the codebase. Also generates a GitHub About description (max 350 chars) and 8-15 topic tags. Presents everything for approval before writing.

---

### /worktree

Manages git worktrees for parallel development.

**Arguments**: `init <task1> | <task2>`, `deliver`, `check`, `cleanup`, `cleanup --all`, `cleanup --branch <name>`, `cleanup --dry-run`.

Enables working on multiple tasks simultaneously using git worktrees. `init` creates isolated worktrees from pipe-separated task descriptions, generating `wt/<kebab-task>` branches and `.worktree-task.md` files for context preservation. `deliver` commits, pushes, and creates a PR from inside a worktree using the task file as PR basis. `check` shows a status table of all worktrees with branch, commits ahead, and uncommitted changes. `cleanup` removes worktrees for merged branches, with `--all` for aggressive cleanup and `--dry-run` for preview. All worktree branches use the `wt/` prefix for safe identification.

### /design-review

Audits a page or component for visual design, UX, accessibility, responsive behavior, and color contrast.

**Arguments**: no args for changed frontend files on current branch, a file or directory path, `--focus <area>` to narrow to `contrast`, `responsive`, `accessibility`, `spacing`, `typography`, `animation`, or `all` (default), `--fix` to auto-fix findings.

Reads the color system from globals.css, resolves OKLCH values, and calculates actual contrast ratios for every foreground/background pair in both light and dark mode. Checks typography (16px min, line length, heading scale), spacing consistency across sections and grids, responsive behavior (grid transitions, touch targets, viewport units), accessibility (ARIA landmarks, labels, focus indicators, reduced-motion), animation (CSS-only, duration, reduced-motion fallback), and dark mode completeness. Each finding cites the specific rule from `rules/frontend.md`, includes severity (HIGH/MEDIUM/LOW), and provides an exact code fix. Uses the same report format as `/review` with summary counts and grouped findings.

---

### /palette

Generates an accessible OKLCH color palette with WCAG AA contrast verification, ready for Tailwind CSS v4 and shadcn/ui.

**Arguments**: a theme concept (e.g., "ocean blue", "forest green"), `--dark-only`, `--light-only`, `--minimal`, `--shadcn` (default).

Designs a coherent color system in OKLCH with all shadcn/ui tokens: primary, background, foreground, card, popover, secondary, muted, accent, destructive, border, input, ring, plus chart and sidebar tokens. Neutrals share the primary's hue angle at very low chroma for visual cohesion. Dark mode is designed independently, not inverted. Verifies all 10 foreground/background pairs that appear together in the UI against WCAG AA (4.5:1), iterating on L values until everything passes. Outputs complete CSS custom properties for both `:root` and `.dark`, a contrast verification table, and integration instructions.

---

### /retro

Analyzes the conversation for corrections, preferences, and recurring patterns, then proposes additions to the Claude configuration.

**Arguments**: no args for full analysis, `--dry-run` to show proposals without writing, `--memory-only` to skip rule proposals.

Scans the entire conversation extracting six categories: corrections the user made, preferences expressed, repeated mistakes, architectural decisions, tool/workflow preferences, and project-specific knowledge. Deduplicates against existing CLAUDE.md rules, rules files, and memory files. Classifies each finding by destination, defaulting to `~/.claude/` files for maximum reuse: `CLAUDE.md` for universal behavioral rules and preferences, `rules/*.md` for domain conventions, skill updates for operational changes, and memory files only for project-specific facts that don't apply elsewhere. Uses a classification test: "Would this rule improve behavior in a different project?" If yes, `~/.claude/`. If no, memory. Presents a summary table with proposed changes and exact text. Asks approval before writing. Updates README.md when any `~/.claude/` file changes. Runs proactively after significant sessions per the "Session Retrospective" rule in CLAUDE.md.

---

## Engineering Checklist

Both `/review` and `/assessment` share a single 32-category engineering checklist defined in `checklists/engineering.md`. Each skill applies it with a different lens: `/review` checks items against the diff for correctness, `/assessment` checks the full implementation for completeness.

### Review-only categories

`/review` also checks 12 categories that only make sense when reviewing a diff. These live in `skills/review/reviewer-prompt.md`:

1. **Correctness**: logic tracing, off-by-one, null handling, boolean logic, type coercion, regex, date/time, floating point, recursion termination.
2. **Algorithmic performance**: O(n^2) detection, data structure choices, unbounded memory, allocations in hot loops, sync I/O in async paths.
3. **Frontend performance**: unnecessary re-renders, list virtualization, bundle size, main thread blocking.
4. **Testing**: branch coverage at 80%+, AAA pattern, specific assertions, negative and boundary tests, contract tests at service boundaries, property-based tests for complex logic. Includes a **strict mock policy** that blocks approval if tests mock internal infrastructure (database, Redis, queues, caches, own services) instead of using real connections. Only external third-party APIs, time, and randomness may be mocked.
5. **Code quality**: function size, single responsibility, DRY, no dead code, composition over inheritance, isolated side effects.
6. **Naming**: descriptive variables, verb-based functions, boolean prefixes, no misleading names.
7. **Architecture patterns**: follows existing patterns, appropriate coupling, no circular dependencies, externalized config, decision reversibility (one-way/two-way doors), fan-out measurement.
8. **Backward compatibility**: public function signature changes update all callers, API response shape changes update consumers, database column renames follow safe migration pattern, message schema changes support in-flight messages, env var renames update deployment configs, feature removals have deprecation path.
9. **Dependencies**: justified, maintained, pinned, license-compatible, size-appropriate.
10. **Documentation and PR quality**: PR description explains what and why, breaking changes documented, README updated, env vars in .env.example.
11. **Cross-file consistency**: design contradictions between files, module-level import side effects, configuration completeness across environments, contract alignment between frontend and backend, error type flow across module boundaries, behavioral symmetry (acquire/release, enable/disable).
12. **Cascading fix analysis**: for every issue found, predict what the suggested fix could break: new dependencies, signature changes, cross-file coordination, environment-specific behavior, missing tests. Include "When implementing this fix, also..." notes.

### Shared engineering categories

The 32 categories in `checklists/engineering.md`, organized by domain:

**Data integrity:**

1. **Idempotency and deduplication**: every write safe to execute twice, guard per layer, durable dedup with TTL.
2. **Atomicity and transactions**: related writes atomic, conditional writes prevent lost updates, short transaction scope.
5. **Consistency model**: explicit choice (strong/eventual/read-your-writes/causal), weakest tolerable model used.
12. **Schema evolution**: backward/forward compatible, version field, no removed/renamed fields.
13. **Immutability**: pure functions, const default, new state per transition, append-only audit data.
14. **Query optimization**: no N+1, pagination, timezone-aware time ranges, NoSQL key distribution, connection pooling, EXPLAIN analysis, write amplification, read replica routing.
22. **Data modeling**: aggregate boundaries, entity vs value object, normalization level, relationship ownership, domain events, schema serves access patterns, bounded contexts, anti-corruption layers, ubiquitous language.

**Resilience:**

3. **Error classification and retry**: every catch classifies transient/permanent/ambiguous, retry with backoff+jitter, timeout budgets, partial failure handling, async error handling.
4. **Caching**: strategy explicit, invalidation chosen, TTL jitter, stampede prevention, warming, eviction.
6. **Back pressure and load management**: bounded queues, load shedding by priority, 10x traffic plan.
7. **Bulkhead isolation**: separate pool per dependency, critical/non-critical workload separation.
8. **Concurrency control**: bounded fan-out, worker pool sizing, per-unit timeout, TOCTOU prevention, deadlock avoidance.
9. **Saga and cross-service coordination**: compensating actions, outbox pattern, no dual writes.
10. **Event ordering and delivery**: delivery guarantee explicit, per-entity ordering, out-of-order handling.
11. **Distributed locking**: lease expiry, fencing tokens, stale write prevention.
18. **External dependency resilience**: explicit timeouts on all calls, circuit breakers, connection pooling per dependency, graceful degradation.
19. **Async processing resilience**: DLQ on every queue, partial batch failure reporting, reprocessing path, visibility timeout alignment.
21. **Graceful degradation**: per-dependency fallback UX, core flow independence, degraded state communication, blast radius analysis, timeout-based degradation, RTO/RPO targets, backup validation, cross-region failover, chaos engineering, game days.

**Security and API:**

16. **Security and access control**: injection prevention (SQL, XSS, command, path traversal, SSRF), auth with bcrypt/argon2, rate limiting, CSRF, default-deny authorization, IDOR prevention, encryption in transit/at rest, data privacy, audit logging, supply chain, IAM least privilege, secrets vault with rotation, network segmentation, zero trust, certificate management.
17. **API contract design**: REST conventions, correct status codes, consistent error format, pagination, versioning with deprecation lifecycle, rate limiting headers, idempotency keys, bulk operations.

**Operations:**

15. **Observability**: structured logging, correlation IDs, health checks (liveness + readiness), metrics, distributed tracing, SLIs/SLOs, alerts on SLO violations, runbooks per alert, distributed debugging path, on-call handoff docs, business metrics, A/B test instrumentation, incident severity classification, communication protocol, blameless postmortems.
20. **Deployment readiness**: backward compatibility during rollout, safe migrations, health probes, graceful shutdown, feature flags, rollback plan, canary promotion criteria, rollback tested, deployment frequency.
23. **Capacity planning**: storage growth rate, read/write ratio, bottleneck identification, horizontal scaling path, hot spot identification, data retention/archival, cost at 10x scale, auto-scaling validation, storage IOPS sizing.
25. **Cost awareness**: query cost, compute right-sizing, storage tiers, batch vs real-time, egress costs, cache ROI, unused resource cleanup, budget alerts.
27. **Migration strategy**: strangler fig or parallel run, feature parity validation, data migration plan, dark launching, cutover criteria, rollback path, old system decommission.

**Quality:**

24. **Testability**: dependency injection, pure function extraction, functional core/imperative shell, contract tests, load test coverage, feature flag testability, test data builders, injectable time/randomness.

**Tenancy:**

26. **Multi-tenancy**: tenant data isolation (row/schema/instance), query scoping, noisy neighbor prevention, per-tenant rate limits, tenant context propagation, tenant-aware caching, onboarding/offboarding automation.

**Infrastructure:**

28. **Infrastructure as Code**: all infra in code, idempotent provisioning, remote state with locking, drift detection, immutable infrastructure, environment parity, module versioning.
29. **Networking and service discovery**: service discovery mechanism, load balancing algorithm, DNS TTL, mTLS, network policies, VPC design, CDN, ingress/egress controls.
30. **Container orchestration**: resource requests/limits, HPA, pod disruption budgets, anti-affinity, rolling updates, health probes, graceful shutdown, resource quotas, sidecar patterns.
31. **CI/CD pipeline design**: feedback-ordered stages, artifact immutability, environment promotion, progressive delivery, pipeline security, DORA metrics, automated rollback.
32. **Cloud architecture**: multi-region strategy, blast radius containment, AZ independence, cell-based architecture, service quotas, auto-scaling, DDoS mitigation, data residency, cost allocation.
