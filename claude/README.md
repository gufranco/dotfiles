# Claude Code Configuration

Personal Claude Code setup with custom skills, engineering guidelines, and project-wide conventions. Everything lives in `~/.dotfiles/claude/` and is symlinked into `~/.claude/` by the dotfiles installer.

## Directory Structure

```
claude/
  settings.json          # Permissions, attribution, and global settings
  CLAUDE.md              # Core engineering rules (lean, ~135 lines)
  rules/
    code-style.md        # Code conventions, comments, dependencies, backward compat
    testing.md           # Test philosophy, mock policy, AAA pattern, scenario planning
    git-workflow.md      # Commit format, branches, CI monitoring, PRs, rollbacks
    code-review.md       # Author guidelines, review style, documentation checks
    security.md          # Secrets, auth checklist, audit logging
    database.md          # Schema rules, query optimization, migrations, naming
    llm-docs.md          # LLM-optimized documentation references for common tech
  skills/
    commit/SKILL.md      # Semantic commits from uncommitted changes
    pr/SKILL.md          # Pull request creation and updates
    review/SKILL.md      # Code review for PRs and local branches
      reviewer-prompt.md # 14-category review checklist
    checks/SKILL.md      # CI/CD pipeline monitoring and diagnosis
    release/SKILL.md     # Tagged releases with auto-generated changelogs
    test/SKILL.md        # Test runner detection and execution
    deps/SKILL.md        # Dependency auditing and vulnerability scanning
    db/SKILL.md          # Database migrations and container management
    docker/SKILL.md      # Container orchestration with Colima awareness
    env/SKILL.md         # Environment variable validation
    logs/SKILL.md        # Log viewing and analysis
    scaffold/SKILL.md    # Boilerplate generation from existing patterns
    terraform/SKILL.md   # Terraform/OpenTofu workflows with safety gates
```

## Settings

Defined in `settings.json`:

- **Output style**: `Explanatory`. Adds educational insight blocks before and after code, explaining implementation choices and codebase-specific patterns.
- **Language**: `english`. Always respond in English regardless of input language.
- **Effort level**: `high`. Maximum reasoning depth on every response. Override per-session with `/effortLevel medium` or `low` for faster, lighter interactions.
- **Attribution**: disabled. No "Co-authored-by" lines in commits or PRs.
- **Permissions**: broad pre-approved access covering file I/O (`Read`, `Write`, `Edit`), web access (`WebFetch`, `WebSearch`), skills, and ~100 bash commands across categories: version control, package managers, runtimes, build tools, containers, infrastructure, databases, dev tooling, shell utilities, search, networking, archives, data processing, process management, and macOS system commands. Only unusual or destructive operations require manual approval.

## CLAUDE.md Overview

The global `CLAUDE.md` is intentionally lean, containing only rules that change Claude's default behavior. Domain-specific conventions live in the `rules/` directory, which loads automatically with the same priority.

**Root file covers:**

- **Core checklist**: verify before acting, no secrets, fail fast, evidence required, safe defaults, single source of truth, explicit over implicit, reuse first.
- **Writing style**: no em dashes, no parentheses in prose, no AI attribution. Write like a human colleague.
- **Confidence**: 95%+ required before taking action. When uncertain, stop and ask. State trade-offs explicitly when multiple approaches exist. Ask one question at a time when blocked.
- **Anti-hallucination**: never invent paths, signatures, APIs, or versions.
- **Scope control**: one task at a time, ask before expanding, max 3-5 files.
- **Mandatory verification**: run tests, lint, build before declaring done.
- **Context compaction**: preserve modified files, test results, and user decisions.
- **Debugging approach**: reproduce, isolate, root cause, fix+verify.

**Rules directory covers:**

- **Code style** (`rules/code-style.md`): DRY, SOLID, KISS. Functions under 30 lines. Immutability. Comments policy. Dependencies management.
- **Testing** (`rules/testing.md`): integration-first. Strict mock policy. AAA pattern. 80%+ coverage for new code. Test scenario planning with requirement traceability for non-trivial tasks.
- **Git workflow** (`rules/git-workflow.md`): conventional commits, branch naming, CI/CD monitoring, PR creation, conflict resolution, rollback strategy.
- **Code review** (`rules/code-review.md`): author guidelines, natural review comments, test evidence, documentation checks, pre-completion checklist.
- **Security** (`rules/security.md`): secrets management, auth checklist, audit logging.
- **Database** (`rules/database.md`): schema rules, query optimization, safe migrations, naming conventions.
- **LLM docs** (`rules/llm-docs.md`): curated `llms.txt` and `llms-full.txt` references for common technologies. Fetch official docs before relying on training data.

## Skills Reference

### /commit

Analyzes uncommitted changes and creates semantic commits following conventional commit format.

**Arguments**: `--push` to push automatically after committing.

Runs `git status`, `git diff`, `git diff --cached`, and `git log` in parallel to gather context. Groups related changes into logical commits. Follows the format `<type>(<scope>): <subject>` with types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert. Never uses `git add -A`, always stages specific files. After committing, asks whether to push to remote. Use `--push` to skip the question and push immediately.

---

### /pr

Creates or updates a pull request with structured descriptions.

**Arguments**: `--draft`, `--base <branch>`, `--reviewer <user>`, `--assignee <user>`, `--label <name>`, `update`, or a PR number.

Detects GitHub or GitLab from the remote URL. Fetches and rebases on the target branch before opening. Performs self-review of the diff for debug statements, secrets, and large files. Scales the description to PR size: subject-only for trivial changes, full "What/How/Testing" structure for larger ones. Warns on PRs over 400 lines and asks for confirmation over 1000 lines.

---

### /review

Reviews a pull request or local branch changes with rigorous, line-by-line analysis.

**Arguments**: no args for current branch PR, a PR number, a URL, or `--local` to skip PR lookup.

Works in two modes. PR mode fetches the diff and metadata from the remote. Local mode diffs committed changes against the base branch, useful before opening a PR. If no PR exists, automatically falls back to local mode. Uses a 14-category checklist covering correctness, security, error handling, performance, concurrency, data integrity, API design, testing, code quality, naming, architecture, observability, dependencies, and documentation. Every issue includes what's wrong, why it matters, and a code example showing the fix. Post-review behavior is authorship-aware: on your own PR or in local mode, offers to fix issues directly. On someone else's PR, acts as a reviewer only and posts inline comments with REQUEST_CHANGES/APPROVE/COMMENT after approval.

**Verdicts**: APPROVE, REQUEST_CHANGES, or COMMENT. Defaults to REQUEST_CHANGES when in doubt.

---

### /checks

Monitors CI/CD pipeline status and diagnoses failures.

**Arguments**: no args for current branch, or a PR number.

Detects the platform from the remote URL. Waits for checks with a 10-minute timeout. When checks fail, fetches logs in parallel and formats failures with check name, direct URL, error message, and log excerpt. Searches for existing fixes in branches and PRs before suggesting corrections.

---

### /release

Creates a tagged release with an auto-generated changelog from conventional commits.

**Arguments**: no args for auto-detected version, a specific `<version>`, or `--dry-run`.

Gathers remote URL, latest tag, and working tree status in parallel. Groups commits by type into sections: Features, Bug fixes, Performance, Breaking changes. Runs tests, lint, and build if the project has them before proceeding. Requires explicit approval before creating the tag and release.

---

### /test

Detects the project's test runner and executes tests with coverage, linting, and security scanning.

**Arguments**: no args for full suite, file or pattern, `--coverage`, `--watch`, `--lint`, `--scan`, `--ci`.

Auto-detects the package manager from lockfiles and the test runner from config files. Supports vitest, jest, mocha, pytest, cargo test, and go test. Lint mode runs eslint, golangci-lint, shellcheck, ruff, flake8, actionlint, or vint as appropriate. Scan mode uses trivy, snyk, and gitleaks (same scanning as `/deps scan`). CI mode runs GitHub Actions locally with `act`.

---

### /deps

Audits dependencies for vulnerabilities and manages updates.

**Arguments**: no args for audit, `outdated`, `update [package]`, `scan`, or `image <name>`.

Detects the package manager automatically. Runs native audit commands, then deep scans with trivy, snyk, and gitleaks if installed (same scanning as `/test --scan`). Docker image analysis uses trivy and dive. Shows vulnerabilities grouped by severity. Always asks approval before updating.

---

### /db

Manages database migrations, containers, and data operations.

**Arguments**: no args for status, `migrate`, `rollback`, `create <name>`, `seed`, `reset`, `start`, `stop`, `terminal`.

Detects container status, migration tool, and package manager in parallel. Supports Prisma, Knex, Sequelize, TypeORM, Drizzle, Alembic, Goose, and Diesel. Aware of standalone containers managed by shell functions like `postgres-start`, `mongo-init`, `redis-start`. Checks container health before migration operations. Requires explicit approval for rollback and reset.

**Container defaults**: postgres on 127.0.0.1:5432 (postgres:postgres), mongo on :27017 (mongo:mongo), redis on :6379 (no auth), valkey on :7000.

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

Detects Docker runtime and log sources in parallel. Supports Docker Compose services, standalone containers, pm2, and log files. Auto-detects JSON structured logs. Masks sensitive fields. Shows error count, frequency, and repeated patterns.

---

### /scaffold

Generates boilerplate code by reading existing project patterns.

**Arguments**: `<type> <name>` where type is endpoint, service, component, module, model, controller, middleware, or hook.

Detects framework and finds existing examples in parallel. Reads 2-3 files of the same type to extract: naming convention, export style, import patterns, code structure, test file location. Generates the main file and test file matching project patterns exactly. Presents generated code for approval before writing.

---

### /terraform

Runs Terraform or OpenTofu workflows with safety checks and approval gates.

**Arguments**: no args for validate + plan, `init`, `fmt`, `validate`, `plan`, `apply`, `destroy`, or a directory path.

Detects terraform or tofu and the working directory in parallel. Checks direnv setup and Terraform-related environment variables. Always validates before planning, plans before applying. Saves plan files before apply. Requires explicit approval for apply and destroy. Displays the active workspace in all outputs.

## Review Checklist

The `/review` skill uses a 14-category checklist defined in `skills/review/reviewer-prompt.md`:

1. **Correctness**: logic tracing, off-by-one, null handling, boolean logic, type coercion, regex, date/time, floating point, recursion termination.
2. **Security**: injection (SQL, XSS, command, path traversal, SSRF, header, template), auth/authz, data exposure, cryptography.
3. **Error handling**: meaningful catches, context in errors, async error handling, partial failure rollback.
4. **Performance**: algorithmic complexity, N+1 queries, SELECT *, pagination, memory/IO, frontend re-renders.
5. **Concurrency**: shared mutable state, TOCTOU bugs, missing await, fire-and-forget, deadlock potential.
6. **Data integrity**: boundary validation, database constraints, safe migrations, UTC timestamps.
7. **API design**: REST conventions, response consistency, pagination, error format, idempotency.
8. **Testing**: branch coverage at 80%+, AAA pattern, specific assertions, no mocked internals, negative and boundary tests.
9. **Code quality**: function size, single responsibility, DRY, no dead code, composition over inheritance, immutability.
10. **Naming**: descriptive variables, verb-based functions, boolean prefixes, no misleading names.
11. **Architecture**: follows existing patterns, appropriate coupling, no circular dependencies, externalized config.
12. **Observability**: appropriate log levels, requestId in logs, no sensitive data logged, health checks.
13. **Dependencies**: justified, maintained, pinned, license-compatible, size-appropriate.
14. **Documentation**: PR description explains what and why, breaking changes documented, README updated, env vars in .env.example.
