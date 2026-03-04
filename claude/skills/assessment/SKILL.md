---
name: assessment
description: Architecture completeness audit for an implementation. Finds missing patterns, planted defects, and opportunities to stand out.
---

Perform an architecture completeness audit on an implementation. Unlike `/review` which checks diffs for correctness, this skill reads the full implementation and identifies **what's missing**: architectural patterns, resilience strategies, security measures, API contracts, and design decisions that should be present but aren't.

Designed for self-assessment before submitting work, whether in an interview, a take-home, or before declaring a feature complete.

## When to use

- After implementing a feature and before saying "I'm done."
- Interview self-check: catch missing architectural patterns before the interviewer does.
- Design validation: verify a solution covers all the patterns it should.
- Pre-production readiness: verify deployment, security, and operational patterns.
- Learning: understand which architecture concepts apply to a given problem.

## When NOT to use

- For reviewing a diff or PR. Use `/review` instead.
- For trivial changes that don't involve architecture decisions.

## Arguments

This skill accepts optional arguments after `/assessment`:

- No arguments: assess all changed files on the current branch compared to the base branch.
- A file or directory path: assess those specific files.
- `--scope <description>`: provide a description of what was implemented so the assessment can focus on relevant patterns.
- `--focus <area>`: narrow the assessment to a specific concern: `security`, `resilience`, `api`, `data`, `ops`, `quality`, `tenancy`, `infra`, or `all` (default).
- `--comments`: when fixing gaps, add inline comments explaining the reasoning behind each change. Useful for interview take-homes where reviewers need to understand your decision-making process.

## Steps

1. **Understand the requirements.** Before assessing the implementation, understand what was asked.
   - Scan the **entire project** for requirement and context documents, not just the root or `docs/`. Search all directories for files named README, INSTRUCTIONS, BRIEF, ASSIGNMENT, REQUIREMENTS, CHALLENGE, TASK, PROMPT, PROBLEM, SPEC, DESIGN, ARCHITECTURE, ADR, or similar, in any format: `.md`, `.txt`, `.pdf`, `.docx`, `.html`. Also check for hidden files like `.assignment`, `.brief`, or dotfiles that might contain instructions.
   - Read every document found. Extract: the problem statement, explicit requirements, evaluation criteria, constraints, time limits, and bonus/stretch goals if mentioned.
   - Ask the user: **"Do you have additional instructions from email, a job posting, or other external sources that I should consider? If this is for a specific company, what is the company name?"** Wait for a response before proceeding. If the user provides text, screenshots, or URLs, incorporate that as additional requirements context.
   - **Company research.** If a company name is provided, search for their engineering blog, tech blog, GitHub organization, open source projects, tech talks, and **Glassdoor interview reviews**. Glassdoor is especially valuable: candidates often share the exact take-home problem, evaluation criteria, interview questions, and what the company looks for. Search for `"<company name>" interview software engineer site:glassdoor.com` and similar queries. Also understand what technologies they use, what patterns they value, and what their engineering culture looks like. A company that blogs about event sourcing will notice if you didn't use it. A company with strict TypeScript repos will judge a loosely-typed submission. Use this context to prioritize which patterns matter most for the assessment.
   - Record all requirements, but treat them as a **floor, not a ceiling**. The explicit requirements define the minimum. The assessment should go well beyond them, identifying patterns and improvements that would make the implementation stand out. In interview contexts, what separates a passing submission from an impressive one is the engineering depth that was not explicitly asked for.

2. **Gather the implementation.** Run these **in parallel**:
   - `git branch --show-current` to get the current branch.
   - Detect the base branch (same logic as `/review`).
   - `git fetch origin` to ensure remote is up to date.
   - If a path argument was given, use that. Otherwise, get the list of changed files: `git diff origin/<base>...HEAD --name-only`.
   - If `--scope` was provided, record the description for context.

3. **Read the full implementation.** Read every changed file in full, not just the diff. The goal is to understand the complete solution, not just what changed. Also read key surrounding files: imports, configs, schemas, middleware, route definitions, environment files.

4. **Verify the project works.** Before analyzing architecture, confirm the project actually builds and passes its own tests. A project that doesn't compile is worse than any missing pattern. Run these **in parallel** where possible:

   - **Build**: detect the build system and run it (`pnpm build`, `npm run build`, `make`, `go build`, `cargo build`, etc.). Record success or failure with output.
   - **Lint**: run the project's linter (`pnpm lint`, `eslint`, `golangci-lint`, `ruff`, etc.). Record warnings and errors.
   - **Typecheck**: if applicable, run the type checker (`pnpm typecheck`, `tsc --noEmit`, `mypy`, etc.). Record any type errors.
   - **Tests**: run the test suite with coverage (`pnpm test -- --coverage`, `pytest --cov`, `go test -cover`, etc.). Record pass/fail count and coverage percentage.
   - **Runtime and language version**: check the language and runtime version the project uses. **Always upgrade to the latest stable LTS version.** If the project runs on a managed platform with version constraints (AWS Lambda, Google Cloud Functions, Azure Functions, Vercel, Heroku, etc.), use the latest stable version available on that platform. Check the platform's documentation to confirm which versions are supported. Update **all** version references: config files, CI pipelines, Dockerfiles, IaC templates (`Runtime` in SAM/CloudFormation/Terraform), and README. Verify the project builds and passes tests after the upgrade.

     **Runtime version pinning is mandatory.** The project must use a version manager config file so every developer and CI environment uses the same version. Add the appropriate file if missing:

     | Ecosystem | Version manager | Config file |
     |:----------|:----------------|:------------|
     | Node.js | nvm, fnm, volta, asdf | `.nvmrc` or `.node-version` |
     | Python | pyenv, asdf | `.python-version` |
     | Ruby | rbenv, rvm, asdf | `.ruby-version` |
     | Go | goenv, asdf | `go.mod` `go` directive |
     | Rust | rustup | `rust-toolchain.toml` |
     | Java | sdkman, asdf | `.sdkmanrc` or `.java-version` |
     | Multi-language | asdf, mise | `.tool-versions` |

     Also set `engines` in `package.json` (Node.js), `requires-python` in `pyproject.toml` (Python), or the equivalent for other ecosystems. This enforces the version constraint in the package manager, not just the version manager.

     An outdated runtime is a MEDIUM finding. A runtime past end-of-life is HIGH. Missing version manager config is MEDIUM.
   - **Dependency audit and update**: run the package manager's audit command (`pnpm audit`, `npm audit`, `pip audit`, `cargo audit`, etc.). Record any known vulnerabilities by severity. Then check for outdated dependencies (`pnpm outdated`, `npm outdated`, `pip list --outdated`, etc.). **Assume dependency versions may be intentionally outdated, vulnerable, or incompatible with the current platform** (e.g., packages that fail on Apple Silicon, deprecated Node.js versions, libraries with known CVEs). Always update all dependencies to their latest stable versions. Run `pnpm update --latest` (or equivalent) and verify the project still builds and passes tests after the update. If a specific update breaks something, pin that dependency at the last working version and document why.
   - **Output verification**: if the requirements include example inputs, expected outputs, or acceptance criteria, actually run the code with those inputs and verify the results match. Reading the code and believing it works is not proof.

   Any failures in this step are findings. A failing build or test is CRITICAL. Lint errors are MEDIUM. Dependency vulnerabilities are HIGH if exploitable, MEDIUM otherwise. Outdated dependencies are MEDIUM. Low test coverage (below 80%) is MEDIUM.

   Record all results for inclusion in the assessment output.

5. **Hunt for planted defects.** Some projects, especially interview take-homes and coding challenges, contain **intentional bugs, anti-patterns, or subtle correctness issues** designed to test whether the candidate can spot and fix them. Read the code with suspicion. For each file, look for: logic bugs, data bugs, validation gaps, concurrency bugs, security flaws, anti-patterns, configuration issues, dependency traps, test gaps, mock abuse, and structural violations. The specific criteria for each category are defined in `reviewer-prompt.md` sections 1-9 and `../../checklists/engineering.md`. Use those checklists as the hunting guide, but read with the assumption that defects may be intentional. Pay special attention to tests that mock internal infrastructure like databases, Redis, or queues instead of using real connections: this is a common defect that makes tests pass while the actual code is broken.

   If any defect is found, classify it with the same severity/effort scale used for missing patterns. Planted bugs that affect correctness or security are always CRITICAL.

6. **Classify the implementation.** Determine what type of system this is, informed by both the code and the requirements gathered in step 1. Each trait maps to a set of applicable categories:

   | Trait | Signal | Categories to check |
   |:------|:-------|:-------------------|
   | Has a write path | API endpoints, event handlers, DB writes | 1, 2, 17, 22 |
   | Has a read path | Queries, API responses, dashboards | 4, 14, 17 |
   | Has external deps | HTTP calls, third-party APIs, DB connections | 3, 7, 18, 21, 25 |
   | Has async processing | Queues, events, background jobs | 1, 10, 19 |
   | Spans multiple services | Service-to-service calls, event bus | 5, 9, 11, 12, 24 |
   | Handles variable load | Public API, webhook receiver, batch processor | 6, 8, 23 |
   | Stores data | Database reads/writes, file storage | 2, 13, 14, 22, 23 |
   | Has auth/user data | Login, signup, roles, PII | 16 |
   | Exposes an API | REST/GraphQL endpoints | 17 |
   | Runs in production | Deployed service, not a script or CLI | 15, 18, 20, 21, 25 |
   | Has testable logic | Business rules, domain logic, state machines | 24 |
   | Serves multiple tenants | SaaS, shared infrastructure, per-customer data | 26 |
   | Replaces existing system | Migration, rewrite, platform change | 27 |
   | Has infrastructure config | Terraform, CloudFormation, Pulumi, Dockerfiles, K8s manifests | 28, 30, 31 |
   | Uses cloud services | AWS/GCP/Azure resources, managed services | 28, 29, 32 |

   If `--focus` was provided, only check categories in that area:
   - `security`: 16, 17 (auth/input parts)
   - `resilience`: 3, 6, 7, 8, 18, 19, 21
   - `api`: 1, 17
   - `data`: 2, 4, 5, 13, 14, 22
   - `ops`: 15, 19, 20, 23, 25, 27
   - `quality`: 24
   - `tenancy`: 26
   - `infra`: 28, 29, 30, 31, 32

   **Superset detection.** If the codebase uses a language that has a widely adopted superset offering stronger type safety or tooling, ask the user whether they want to convert. This is especially valuable in interview contexts where using the superset demonstrates engineering rigor.

   | Language | Superset | Key benefit |
   |:---------|:---------|:------------|
   | JavaScript | TypeScript | Static typing, compile-time error detection, better IDE support |
   | CSS | SCSS/Sass | Variables, nesting, mixins, modularity |
   | JSON config | JSON Schema or Zod validation | Runtime validation, self-documenting contracts |

   Ask: **"The project uses [language]. Would you like me to convert it to [superset]? This adds type safety and is generally viewed favorably in assessments."** Only ask once per language detected. If the user declines, proceed without converting. If the user accepts, add the conversion as a task in the fix step, before other fixes. Do not ask about superset conversion when the requirements explicitly specify the base language.

   **Strictest configuration possible.** When converting to a superset or when any tool, linter, compiler, or framework supports strictness levels, always configure the **maximum strictness**. TypeScript gets `strict: true` with all additional strict flags enabled (`noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, etc.). ESLint gets the strictest recommended config. tsconfig gets `noEmit`, `isolatedModules`, `verbatimModuleSyntax`. This applies to everything: compilers, linters, formatters, test runners, security scanners, CI checks. If there is a stricter option, enable it. No exceptions.

   **Package compatibility with superset.** When converting to a superset, review every dependency for type support. For each package, follow this decision tree:

   1. **Package ships types natively** (has its own type declarations bundled). No action needed. Most modern packages do this.
   2. **Community type definitions exist** (separate package maintained by the community). Install them as dev dependencies. Examples by ecosystem:
      - JS/TS: `@types/express`, `@types/node`, `@types/jest`, etc. from DefinitelyTyped.
      - Python: `types-requests`, `django-stubs`, `types-PyYAML`, `boto3-stubs`, etc.
      - Ruby/Sorbet: RBI files from `tapioca` gem or community sources.
   3. **A typed alternative exists** that replaces the original package entirely with better superset support. Prefer the alternative. Examples:
      - `request` → `got` or `node-fetch` (typed, maintained, lighter)
      - `moment` → `date-fns` or `dayjs` (typed, tree-shakeable, immutable)
      - `underscore` → `lodash-es` (typed, tree-shakeable) or native methods
      - `callback-based APIs` → their promise-based or async equivalents
   4. **No types exist and no alternative exists**. Write a minimal type declaration file (`.d.ts`, stub file, etc.) for the parts of the API actually used. Never leave untyped imports.

   This logic is language-agnostic. The principle is: every dependency must have full type support in the target superset. If it doesn't, either find types, find an alternative that has types, or write the types yourself.

7. **Audit against each applicable category.** For every category that applies based on step 6, evaluate the implementation against both the engineering checklist (`../../checklists/engineering.md`) and the requirements gathered in step 1. Include any defects found in step 5 and verification failures from step 4 as findings under the most relevant category.

   After auditing each file individually, perform a **cross-file consistency check**:
   - **Design contradictions:** Does one module assume graceful degradation while another enforces a hard dependency? Does one file treat a field as optional while another treats it as required?
   - **Import chain side effects:** Trace import chains for module-level side effects like connections, env validation, or scheduled tasks. Would a missing env var crash the entire process at import time even though the feature claims graceful degradation?
   - **Configuration completeness:** Every new env var, dependency, or infrastructure requirement must be satisfiable in all environments: local dev, CI, staging, production. Check `.env.example`, Docker configs, CI pipelines, and IaC templates.
   - **Contract alignment:** Do types, field names, and data formats align across module boundaries? Does the API match what the consumer sends? Do error types thrown in one layer match what the caller catches?
   - **Behavioral symmetry:** If a resource is acquired, is it released on all code paths? If a feature is enabled, can it be disabled? If data is written, can it be read back consistently?

   In addition to the 32 engineering categories, also assess:

   - **README and presentation quality.** The README is the first thing a reviewer reads. Check: does it explain what the project does, how to set it up, how to run it, and how to test it? Are architecture decisions documented? Is there a clear project structure section? For interview submissions, a well-structured README with setup instructions, architecture explanation, and trade-off discussion can be the difference between an interview and a rejection. A missing or minimal README is a HIGH finding.

   - **Git history quality.** For interview submissions, commit history signals engineering discipline. Check: are commits logical and atomic (one concern per commit)? Do messages follow conventional commit format? Is there a meaningful progression (infrastructure first, then core logic, then tests, then polish)? A single "initial commit" with everything is a MEDIUM finding. Messy or meaningless commit messages are LOW.

   - **Dependency health and package selection.** Apply `reviewer-prompt.md` section 8 for the baseline checks (justified, maintained, pinned, licensed, typed, better alternatives). Beyond that, also check assessment-specific concerns:
     - Is the runtime version the latest stable LTS, pinned with a version manager config file and `engines` (or equivalent) in the package manifest?
     - Are there platform-specific issues (native modules failing on Apple Silicon, deprecated packages with no ARM64 support)?
     - **Better alternatives signals**: no commits in 12+ months, open security issues, archived repository, missing type support when alternatives have it, large bundle size when a lighter option exists. Flag and include the replacement in the fix step.
     - **Type support completeness**: if using a typed language or superset, verify every dependency has type support (see step 6). Untyped dependencies in a typed codebase are a finding.

     Unjustified or heavy dependencies are LOW. Deprecated packages with maintained alternatives are MEDIUM. Known vulnerabilities are HIGH. Outdated runtime versions are MEDIUM.

   - **Developer tooling and enforcement.** The project must have automated code quality enforcement. Check for and add if missing:

     | Tool type | Purpose | Examples by ecosystem |
     |:----------|:--------|:---------------------|
     | Runtime version manager | Pin runtime version for all developers and CI | `.nvmrc` / `.node-version` (Node.js), `.python-version` (Python), `.ruby-version` (Ruby), `rust-toolchain.toml` (Rust), `.tool-versions` (multi-language) |
     | EditorConfig | Consistent formatting across editors | `.editorconfig` with language-appropriate indent style/size, charset, end of line, trailing whitespace, final newline |
     | Formatter | Deterministic code formatting | JS/TS: Prettier. Python: Black, Ruff format. Go: gofmt. Rust: rustfmt. Ruby: RuboCop. Java: google-java-format. Elixir: mix format |
     | Linter | Static analysis, code quality | JS/TS: ESLint (strictest config). Python: Ruff, Flake8, Pylint. Go: golangci-lint. Rust: Clippy. Ruby: RuboCop. Java: Checkstyle, SpotBugs |
     | Type checker | Static type verification | TS: tsc. Python: mypy, pyright. Ruby: Sorbet. Elixir: Dialyzer |
     | Pre-commit hooks | Enforce quality before commit | JS/TS: husky + lint-staged. Python: pre-commit framework. Go/Rust/Ruby: lefthook or pre-commit |
     | Commit linter | Enforce conventional commits | commitlint, commitizen |
     | CI pipeline | Automated quality gate on every push and PR | GitHub Actions, GitLab CI, CircleCI, Jenkins |

     All tools must be configured at their **strictest** settings. Missing `.editorconfig` is MEDIUM. Missing formatter or linter is HIGH. Missing pre-commit hooks is MEDIUM. Missing CI pipeline is HIGH.

   For each finding, assign:

   **Status**: PRESENT, PARTIAL, or MISSING.

   **Severity** (for PARTIAL and MISSING only):
   - **CRITICAL**: data loss, security vulnerability, or correctness failure in production. Fix before shipping.
   - **HIGH**: resilience gap that causes outages under real-world conditions. Fix soon.
   - **MEDIUM**: performance, maintainability, or operational gap. Schedule for next iteration.
   - **LOW**: best practice not followed, but no immediate risk. Backlog.

   **Effort** (for PARTIAL and MISSING only):
   - **S**: hours. A focused change in 1-2 files.
   - **M**: a day. Touches 3-5 files, may need tests.
   - **L**: days. Cross-cutting change, new infrastructure, or significant refactor.
   - **XL**: week+. New system component, major architectural shift.

8. **Present the assessment.** Format the output as described below.

9. **Offer to fix.** After presenting the assessment, ask: "Want me to implement the missing patterns?" If yes, work through them by priority: all CRITICAL first, then HIGH, then MEDIUM. Within the same severity, prefer lower effort. Each fix gets its own commit.

   **Cascading fix prediction.** Before implementing each fix, analyze what it could break:
   - Would the fix change a function signature, breaking existing callers?
   - Would the fix introduce a new dependency or startup requirement?
   - Would the fix change error behavior that other code relies on?
   - Would the fix require coordinated changes in files not part of the current finding?
   - Would the fix behave differently across environments (dev vs production)?

   If any answer is yes, address the downstream effects in the same fix. Do not create fixes that introduce new problems for the convergence loop to catch. Front-loading this analysis reduces the number of convergence iterations.

   **First, set up developer tooling** if missing: `.editorconfig`, formatter (Prettier, Black, gofmt, etc.), linter (ESLint, Ruff, golangci-lint, etc.), type checker, pre-commit hooks (husky + lint-staged, pre-commit framework, lefthook), and commit linter (commitlint). All at strictest settings. This is a single commit.

   **Then, create a CI pipeline** if the project does not already have one. The pipeline must run on every push and pull request to the default branch. Detect the git platform from the remote URL and create the appropriate config file:

   | Platform | Config file | Location |
   |:---------|:-----------|:---------|
   | GitHub | `.github/workflows/ci.yml` | GitHub Actions |
   | GitLab | `.gitlab-ci.yml` | GitLab CI |

   The pipeline must execute every quality gate the project has, in order of feedback speed:

   1. **Install dependencies**: use the lockfile-based install command (`npm ci`, `pnpm install --frozen-lockfile`, `pip install -r requirements.txt`, etc.). Never use `npm install` in CI as it can modify the lockfile.
   2. **Lint**: run the project's linter (`npm run lint`, `pnpm lint`, `ruff check`, `golangci-lint run`, etc.).
   3. **Type check**: if applicable, run the type checker (`npm run typecheck`, `tsc --noEmit`, `mypy .`, etc.).
   4. **Build**: compile the project (`npm run build`, `pnpm build`, `go build`, `cargo build`, etc.).
   5. **Test with coverage**: run the full test suite with coverage reporting (`npm test -- --coverage`, `pytest --cov`, `go test -cover`, etc.).

   Pin the runtime version in the pipeline to match the project's version manager config (`.nvmrc`, `.python-version`, etc.). Use caching for dependencies to speed up runs. Set `fail-fast: true` so the pipeline stops at the first failure.

   For GitHub Actions, use the latest stable action versions: `actions/checkout@v4`, `actions/setup-node@v4` (or equivalent for other runtimes), `actions/cache@v4`. Use matrix strategy only when the project needs to support multiple runtime versions.

   This is a single commit: `ci: add GitHub Actions pipeline for lint, typecheck, build, and test`.

   **Then, reorganize the project** applying all relevant software engineering patterns: DDD (bounded contexts, aggregates, domain events), SOLID, DRY, KISS, YAGNI, clean architecture (domain core without framework imports, infrastructure adapters at boundaries), composition over inheritance, CQS, repository pattern, and functional core/imperative shell. Rename files to `name.type.extension` (e.g., `user.service.ts`, `order.repository.ts`). Group by domain, not by technical layer. This reorganization is a single commit before the pattern fixes.

   **Test data must use a faker library, not hardcoded literals.** Every test that generates input data, whether for names, emails, amounts, dates, or IDs, must use a faker library for the language ecosystem (`@faker-js/faker` for JS/TS, `Faker` for Python, `faker` for Ruby, etc.). Install the library as a dev dependency if not already present. Hardcoded test data like `"John"`, `"test@example.com"`, or `42` makes tests brittle and hides assumptions about valid input ranges. Faker generates realistic, randomized values that exercise more code paths and make tests more expressive. The exception is when a specific value is part of the test assertion, like verifying a known seed data record exists.

   Faker values that need to be deterministic across runs, like IDs referencing seed data, should remain as literals. Use faker for values where the specific value does not matter: deposit amounts, invalid input strings, non-existent IDs, future dates, random names. This is a MEDIUM finding if tests use hardcoded data where faker would be appropriate.

   **Mock policy (STRICT).** Tests must connect to real infrastructure. If the code talks to a database, the test connects to a real database. If it uses Redis, the test uses a real Redis instance. Same for queues, caches, and any other data store. Add test dependencies to docker-compose with a `beforeAll()` hook to seed required data. Only external third-party APIs outside your control, time, and randomness may be mocked. Mocking your own database, services, or modules is a CRITICAL finding: the test may pass while the actual integration is broken, which is worse than no test at all. When fixing mock violations, replace the mock with a real connection, add the dependency to docker-compose if missing, and use `beforeAll()` / `afterAll()` for setup and teardown.

   **For any fix involving transactions**, follow `../../checklists/engineering.md` category 2: explicit lock type, explicit isolation level, conditional expressions for NoSQL.

   **If `--comments` was passed**, add an inline comment above each significant code change explaining:
   - **What** pattern is being applied and **why** it matters here.
   - **What would go wrong** without this pattern, using a concrete scenario.

   Comment guidelines:
   - Write comments as short, direct explanations. One to three lines per comment. No essays.
   - Use the language's comment syntax. No doc-comment format unless it is a public API.
   - Only comment on non-obvious decisions. Do not comment self-explanatory code like variable declarations or standard error handling.
   - Focus on the "why", not the "what". The code shows what; the comment shows the reasoning.
   - Sound like a human engineer, not a generated template. Vary phrasing. No labels like "Pattern:" or "Reason:".

   Example:

   ```typescript
   // Dedup by orderId so a network retry from the payment gateway
   // doesn't charge the customer twice.
   const existing = await db.payment.findUnique({ where: { orderId } });
   if (existing) return existing;
   ```

   ```typescript
   // Circuit breaker: if the recommendation service is down, return an
   // empty list instead of failing the entire product page.
   const recommendations = await withFallback(
     () => recommendationClient.getFor(productId),
     () => [],
   );
   ```

10. **Convergence loop.** Fixes can introduce new findings, reveal masked issues, or break existing quality gates. After completing all fixes in step 9, loop until the codebase is clean. **This loop runs autonomously with no user interaction.**

    **For each iteration (max 20 iterations):**

    1. **Re-verify.** Run all quality gates in parallel: lint, typecheck, build, tests. If any gate fails, fix the failure before continuing. A fix that breaks the build is worse than no fix.
    2. **Re-read.** Read every file that was modified in the previous fix pass, plus any new files created.
    3. **Re-audit.** Evaluate the modified files against all applicable categories from step 6. Also check:
       - Did any fix violate a rule from `~/.claude/CLAUDE.md` or `~/.dotfiles/claude/rules/`? (AAA comments, code style, naming, immutability, etc.)
       - Did any fix introduce a new dependency, pattern, or code path that itself needs assessment?
       - Did any fix create a cross-file contradiction? (one module now assumes behavior that another module does not support)
       - Did any fix introduce a new startup dependency or configuration requirement without updating all relevant config files (.env.example, Docker, CI)?
       - Did any fix change a public interface without updating all callers and consumers?
       - Did any fix leave dead code behind? Check for unused imports, orphaned functions, unreferenced variables, and stale exports after extractions or refactors.
       - Are all new tests following project conventions? (faker for test data, AAA structure, no mocks for DB)
       - Did the README, CI config, or other generated artifacts become stale due to the fixes?
    4. **Classify new findings.** If there are new PARTIAL or MISSING findings, or new defects introduced by the fixes, collect them.
    5. **If no new findings:** break the loop. Convergence achieved.
    6. **If new findings exist:** fix them using the same priority order (CRITICAL → HIGH → MEDIUM, lower effort first). Each fix gets its own commit. Then go to step 10.1.

    **Termination:** If after 20 iterations there are still new findings, stop the loop, list the remaining findings, and inform the user. Twenty iterations is enough for any reasonable convergence. Infinite loops indicate a structural problem that needs human judgment.

    **What to look for in each re-audit pass:**
    - Quality gate regressions: did a fix break lint, types, or tests?
    - Convention violations in the new code: comment style, naming conventions, file structure, export patterns
    - Stale references: README sections that reference old file names, test counts, or coverage numbers that changed
    - Missing tests for new code paths added during fixes
    - Dependencies added during fixes that need audit, type checking, or justification

11. **Generate the README.** After convergence, generate a technical README that documents what was built and why. See the README structure below.

12. **Update GitHub repository metadata.** After committing the README, update the repository's description and topics on GitHub so the repo page communicates the same quality as the code.

    **Description format**: one sentence describing what the project is and its key technologies, followed by a second sentence listing comma-separated architectural highlights and a quantified test claim. Keep it under 350 characters.

    Example: `"Production-grade contractor payment API on Express.js, Sequelize, and SQLite. Clean architecture with dependency inversion, SERIALIZABLE transactions with LOCK.UPDATE, two-sided Zod validation, typed repository pattern, and 48 zero-mock integration tests at 98.85% coverage"`

    **Topics**: add 10-12 specific technology topics as lowercase kebab-case tags. Include the primary language, runtime version, framework, database, ORM, validation library, test framework, and 3-5 distinguishing architectural or domain terms. Do not use generic tags like "backend" or "api".

    Example topics: `typescript`, `expressjs`, `sequelize`, `sqlite`, `zod`, `clean-architecture`, `node22`, `jest`, `helmet`, `dependency-injection`, `repository-pattern`, `contractor-payments`

    **Commands**:
    ```bash
    gh repo edit <owner>/<repo> --description "<description>"
    gh repo edit <owner>/<repo> --add-topic <topic1> --add-topic <topic2> ...
    ```

    **Account handling**: follow the borrow-and-restore pattern from `rules/borrow-restore.md`. Check `gh auth status`, switch to the account that owns the repo if needed, update metadata, verify with `gh repo view`, and restore the original account.

    Commit the README as a separate commit: `docs: add technical README with architecture and design decisions`. The GitHub metadata update does not require a commit since it only changes the repository settings.

    The README structure for step 11 follows. An interviewer or reviewer reading it should understand the architecture, the reasoning behind every decision, and how to run the project, all before opening a single source file.

    **Data gathering.** Scan the project in parallel: package manifest, infrastructure configs, source tree structure, environment files, git context, test output with coverage, and any existing README. Read the actual codebase to extract concrete details: number of tests, coverage percentage, number of endpoints, isolation levels used, patterns applied, and technologies with their exact versions from the lockfile or config.

    **Assessment README structure.** Use the structure below. The tone is technical and explanatory. Every section uses tables and concrete examples. Design decisions are written as narrative paragraphs, not structured labels. Architecture uses Mermaid diagrams with subgraphs for layers.

    ```
    # {Company} {Role}: Technical Assessment

    A production-grade [type of system] for [domain], built with [key technologies].
    Submitted as a take-home assessment for the **{Role}** position at **{Company}**.

    If the company name or role is unknown, use a neutral title:
    # [Project Name]: Technical Assessment

    ## What This Assessment Covers

    This is not a minimal [type]. It is a fully operational system with
    production-level engineering across every layer:

    | Area | What was built |
    |------|---------------|
    | **[Area name]** | [Concrete description of what was implemented, referencing specific patterns, tools, or techniques. Not vague claims like "clean code" but specifics like "Three-layer design with dependency inversion. Domain has zero framework imports."] |
    | **[Area name]** | [Another concrete description] |

    Include 8-12 rows covering: architecture, transaction safety, input validation,
    type safety, ORM/data access, repository pattern, error handling, security,
    query optimization, testing (with count and coverage), and developer tooling.
    Only include rows for things actually implemented. Never invent features.

    ## Architecture

    Mermaid diagram showing system layers, components, and dependency direction.
    Use subgraphs for architectural layers and arrows for dependency flow.

    The diagram must show:
    - Each architectural layer as a labeled subgraph
    - Key components within each layer (entities, use cases, repositories, models, routes)
    - Dependency direction with labeled arrows
    - External actors (HTTP client, database) at the boundaries
    - Max 15-20 nodes to keep it readable

    Example Mermaid diagram (wrap in a mermaid code fence):

        graph TB
          subgraph Domain["Domain Layer"]
            Entities["Entities: EntityA, EntityB, EntityC"]
            Repos["Repository Interfaces: IRepoA, IRepoB, IUnitOfWork"]
            Errors["Domain Errors: NotFoundError, ForbiddenError"]
          end
          subgraph Application["Application Layer"]
            UseCases["Use Cases: UseCaseA, UseCaseB, UseCaseC"]
          end
          subgraph Infrastructure["Infrastructure Layer"]
            Routes["Routes and Middleware"]
            RepoImpl["Repository Implementations"]
            Models["ORM Models"]
          end
          Client["HTTP Client"] --> Routes
          UseCases -->|depends on| Repos
          Routes -->|depends on| UseCases
          RepoImpl -->|implements| Repos
          Models --> DB[(Database)]

    After the diagram, add a paragraph explaining the dependency direction
    and how the composition root wires everything together.

    ## Project Structure

    Directory tree showing the actual project layout with inline descriptions
    for each directory. Explain the file naming convention used.

    src/
      domain/
        entities/           [Description of what lives here]
        errors/             [Description]
        repositories/       [Description]
      application/
        use-cases/          [Description]
      infrastructure/
        database/
          models/           [Description]
          repositories/     [Description]
      middleware/           [Description]
      routes/              [Description]
        schemas/           [Description]
      container.ts         [Description of composition root]
      app.ts               [Description]
      server.ts            [Description]

    After the tree, add a paragraph explaining the naming convention:
    "Files use a `name.type.ts` naming convention: `profile.model.ts`,
    `get-contract-by-id.use-case.ts`. The suffix tells you what a file
    contains before you open it."

    ## API Endpoints

    All endpoints require [auth mechanism description].

    Group endpoints by resource. For each resource group:

    ### [Resource Name]

    | Method | Endpoint | Description |
    |--------|----------|-------------|
    | GET | `/resource/:id` | [What it does, including security behavior] |
    | POST | `/resource` | [What it does] |

    **Response format:**

    ```json
    {
      "field": "value",
      "nested": { "field": "value" }
    }
    ```

    For endpoints with error conditions, add an error table:

    | Error condition | Status | Error code |
    |----------------|--------|------------|
    | [Condition] | 404 | `NOT_FOUND` |
    | [Condition] | 403 | `FORBIDDEN` |

    Include a final section documenting the error response format:

    ### Error response format

    All errors return a consistent shape:

    ```json
    {
      "error": {
        "code": "ERROR_CODE",
        "message": "Human-readable description",
        "details": [
          { "field": "fieldName", "message": "Specific error" }
        ]
      }
    }
    ```

    Explain the `code`, `message`, and `details` fields.

    ## Design Decisions

    For each significant decision (at least 5), write a narrative subsection.
    Do NOT use structured labels like "Choice/Why/Trade-off". Write natural
    paragraphs that explain what was done, why, and the trade-off, all woven
    into the prose. Each subsection has a descriptive title.

    ### [Descriptive decision title]

    [One or more paragraphs explaining the decision naturally. Start with what
    was done, flow into why this approach over alternatives, and end with the
    trade-off. Reference specific code patterns, file names, or techniques.
    The reader should understand the engineering reasoning without seeing the code.]

    Cover decisions like: architecture pattern, transaction strategy, validation
    approach, type safety configuration, ORM setup, error handling design,
    query optimization strategy, testing approach. Only document decisions that
    were actually made in the code.

    ## Testing

    [Number] integration tests using [framework] against [database setup].
    [Testing philosophy: e.g., "No mocks for the database layer: tests exercise
    the full request path from HTTP to database and back."]

    ```bash
    npm test              # run all tests
    npm run test:coverage # run with coverage report
    ```

    | Metric | Coverage |
    |--------|----------|
    | Statements | XX% |
    | Functions | XX% |
    | Lines | XX% |

    Tests cover:

    - **Happy paths**: [specific examples]
    - **Authorization**: [specific examples]
    - **Business rules**: [specific examples]
    - **Edge cases**: [specific examples]

    ## Prerequisites

    | Tool | Version | Required for | Install |
    |------|---------|-------------|---------|
    | [Tool] | [Version] | [Purpose] | [Link or command] |

    ## Getting Started

    ```bash
    [install command]
    [seed/setup command]
    [start command]
    ```

    ## Scripts

    | Command | Description |
    |---------|-------------|
    | `npm start` | [Description] |
    | `npm test` | [Description] |
    | `npm run lint` | [Description] |

    ## Developer Tooling

    | Tool | Purpose | Configuration |
    |------|---------|---------------|
    | [Tool] | [What it does] | [Config file] |

    ## Tech Stack

    | Category | Technology |
    |----------|-----------|
    | Runtime | [Name version] |
    | Framework | [Name version with key detail] |
    | ORM | [Name version with key detail] |
    | Database | [Name with usage detail] |
    | Validation | [Name version with key detail] |
    | Testing | [Name version, test count, coverage] |
    | Code quality | [Tools with key configs] |
    ```

    **README generation rules:**
    - Every claim must be grounded in the actual codebase. Never invent features. Read the code to verify before writing.
    - The "Design Decisions" section is the most important. This is where the engineer's thinking shows. Write each decision as a natural narrative paragraph, not as a structured template with labels. The reader should feel like a senior engineer is explaining their reasoning over coffee, not filling out a form.
    - The "What This Assessment Covers" table is the second most important. Each row must reference a specific, concrete implementation detail. "Clean architecture" is too vague. "Three-layer design with dependency inversion. Domain has zero framework imports. Use cases depend on repository interfaces, never on Sequelize or Express" is concrete.
    - Architecture diagrams use Mermaid with subgraphs for layers and labeled arrows for dependency direction. Max 15-20 nodes to keep diagrams readable. GitHub, GitLab, and most markdown renderers support Mermaid natively.
    - API documentation includes endpoint tables, JSON request/response examples with realistic data, and error condition tables with status codes and machine-readable error codes.
    - Skip sections that don't apply. A project without an API skips API Endpoints. A project without CI skips CI/CD.
    - Quantify everything: number of tests, coverage percentage, number of endpoints, specific TypeScript flags enabled, specific ESLint rules configured.
    - Include exact version numbers in the Tech Stack table, pulled from the lockfile or config files.
    - The title must include the company name and role if known. Format: `# {Company} {Role}: Technical Assessment`. If unknown, use `# [Project Name]: Technical Assessment`.
    - Commit the README as a separate commit: `docs: add technical README with architecture and design decisions`.

## Assessment Checklist Categories

The full 32-category checklist lives in `../../checklists/engineering.md` (shared with `/review`). Read it directly for the complete criteria. The trait table in step 6 maps system traits to category numbers.

## Output Format

```
# Architecture Assessment

## Scope
[What was assessed: files, feature description, branch]
[Focus area if --focus was used]

### Requirements
[Summary of requirements found in project documents and provided by the user]
[Explicit requirements, evaluation criteria, constraints, and stretch goals]
[If no requirements documents were found and the user had no additional context, state "No requirement documents found. Assessment based on engineering best practices only."]

## Company Context
[If a company name was provided: engineering blog insights, Glassdoor interview tips, tech stack, and what they value]
[If no company provided, omit this section]

## Verification Results

| Check | Result | Details |
|-------|--------|---------|
| Build | PASS / FAIL | [Command run and output summary] |
| Lint | PASS / FAIL / N warnings | [Errors or warnings found] |
| Typecheck | PASS / FAIL / N/A | [Type errors found] |
| Tests | X passed, Y failed, Z% coverage | [Failing test names if any] |
| Dependency audit | X vulnerabilities (N critical, N high) | [Notable findings] |
| Output verification | PASS / FAIL / N/A | [Expected vs actual results] |

## Classification
[System traits detected and which of the 32 categories apply]

## Defects Found
[List any bugs, anti-patterns, or correctness issues found in the existing code]
[For each: file, line, what's wrong, why it matters, severity, and fix]
[If no defects found, state "No defects found in the existing implementation."]

## Findings

### [Category Name] — [PRESENT | PARTIAL | MISSING] [severity if not PRESENT]

**Status**: [One-line summary of what's there and what's not]

**What's missing** (if applicable):
- [Specific gap with actionable fix]
- [Specific gap with actionable fix]

**Example fix** (if applicable):
[Code example showing how to add the missing pattern]

**Effort**: [S | M | L | XL] — [brief justification]

[Repeat for each applicable category]

## Presentation Quality

### README — [PRESENT | PARTIAL | MISSING] [severity if not PRESENT]
[Does it explain what the project does, how to set up, run, and test?]
[Architecture decisions documented? Trade-offs discussed?]

### Git History — [PRESENT | PARTIAL | MISSING] [severity if not PRESENT]
[Are commits logical, atomic, and well-messaged?]
[Is there a meaningful progression?]

### Dependencies — [PRESENT | PARTIAL | MISSING] [severity if not PRESENT]
[Are dependencies justified, pinned, audited?]
[Any unused or unjustified heavy packages?]

## Summary

| # | Category | Status | Severity | Effort |
|---|----------|--------|----------|--------|
| 1 | ... | PRESENT / PARTIAL / MISSING | — / CRITICAL / HIGH / MEDIUM / LOW | — / S / M / L / XL |

**Coverage**: X of Y applicable categories fully covered.
**Critical gaps**: N findings require immediate attention.

## Priority Matrix

### Fix now (CRITICAL)
1. [Gap, why it's critical, estimated effort]

### Fix soon (HIGH)
1. [Gap, why it matters, estimated effort]

### Schedule (MEDIUM)
1. [Gap, trade-off, estimated effort]

### Backlog (LOW)
1. [Gap, note]
```

## Rules

Steps 1-12 above define **what** to do. These rules define **constraints** on how to do it. Do not duplicate step content here.

- Read the full implementation, not just diffs. Missing patterns live in what was NOT written.
- Only assess categories that apply to the system type. Do not flag missing caching on a CLI tool or missing saga on a single-service app.
- Every "MISSING" finding must include a concrete code example showing how to add it.
- Every "PARTIAL" finding must explain exactly what's there and what's not.
- Every non-PRESENT finding must have a severity and effort estimate.
- Be direct about gaps. The goal is to catch what a senior engineer or interviewer would catch. Sugarcoating defeats the purpose.
- Rank by severity first: CRITICAL before HIGH before MEDIUM before LOW. Within the same severity, lower effort first.
- If everything is covered, say so. Do not invent problems.
- Security findings are always at least HIGH severity. A missing auth check or exposed secret is CRITICAL.
- Reference the relevant rules file for each category: `rules/security.md`, `rules/api-design.md`, `rules/resilience.md`, `rules/database.md`, `rules/caching.md`, `rules/distributed-systems.md`, `rules/observability.md`, `rules/code-style.md`.
- Do not flag deployment readiness for code that is explicitly a prototype, proof-of-concept, or interview take-home unless `--focus ops` was specified.
- When `--comments` is active, every comment must pass this test: would a senior engineer reading this code for the first time learn something from the comment that the code alone does not convey? If not, delete the comment. `--comments` only affects the fix step, not the assessment output.
- The detailed criteria for input/output validation, query performance, transaction locks, and structural quality live in `../../checklists/engineering.md`. Do not duplicate them here.
- Every API must validate both sides of the boundary: inputs (request body, query params, path params, headers) AND outputs (response body) with a schema library. Missing output validation is a finding. See `../../checklists/engineering.md` category 16.

## Related skills

- `/review` — Diff-based code review for correctness. Catches bugs in what's written.
- `/test` — Run tests to verify the implementation works.
- `/commit` — Commit fixes after addressing assessment gaps.
- `/readme` — Marketing-grade README. The assessment README reuses Phase 1 scanning but uses a technical structure instead.
