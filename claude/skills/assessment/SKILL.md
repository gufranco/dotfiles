---
name: assessment
description: Architecture completeness audit for an implementation. Finds missing patterns, not just bugs.
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
- `--focus <area>`: narrow the assessment to a specific concern: `security`, `resilience`, `api`, `data`, `ops`, `quality`, `tenancy`, or `all` (default).
- `--comments`: when fixing gaps, add inline comments explaining the reasoning behind each change. Useful for interview take-homes where reviewers need to understand your decision-making process.

## Steps

1. **Gather the implementation.** Run these **in parallel**:
   - `git branch --show-current` to get the current branch.
   - Detect the base branch (same logic as `/review`).
   - `git fetch origin` to ensure remote is up to date.
   - If a path argument was given, use that. Otherwise, get the list of changed files: `git diff origin/<base>...HEAD --name-only`.
   - If `--scope` was provided, record the description for context.

2. **Read the full implementation.** Read every changed file in full, not just the diff. The goal is to understand the complete solution, not just what changed. Also read key surrounding files: imports, configs, schemas, middleware, route definitions, environment files.

3. **Classify the implementation.** Determine what type of system this is. Each trait maps to a set of applicable categories:

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

   If `--focus` was provided, only check categories in that area:
   - `security`: 16, 17 (auth/input parts)
   - `resilience`: 3, 6, 7, 8, 18, 19, 21
   - `api`: 1, 17
   - `data`: 2, 4, 5, 13, 14, 22
   - `ops`: 15, 19, 20, 23, 25, 27
   - `quality`: 24
   - `tenancy`: 26

4. **Audit against each applicable category.** For every category that applies based on step 3, evaluate the implementation. Use the full checklist from `checklists/engineering.md`. For each finding, assign:

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

5. **Present the assessment.** Format the output as described below.

6. **Offer to fix.** After presenting the assessment, ask: "Want me to implement the missing patterns?" If yes, work through them by priority: all CRITICAL first, then HIGH, then MEDIUM. Within the same severity, prefer lower effort. Each fix gets its own commit.

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

## Assessment Checklist Categories

The full checklist lives in `checklists/engineering.md` (shared with `/review`). Categories:

1. **Idempotency and deduplication** — Can every write operation run twice safely?
2. **Atomicity and transactions** — Are related writes atomic? Conditional writes prevent lost updates?
3. **Error classification and retry** — Transient vs permanent? Retry only transient? Timeout budgets?
4. **Caching** — Strategy chosen? Invalidation explicit? Stampede prevention?
5. **Consistency model** — Strong, eventual, or read-your-writes? Chosen deliberately?
6. **Back pressure and load management** — Bounded queues? Load shedding plan?
7. **Bulkhead isolation** — Failure domains isolated? Separate pools per dependency?
8. **Concurrency control** — Fan-out bounded? Worker pools sized?
9. **Saga and cross-service coordination** — Compensating actions? Outbox pattern?
10. **Event ordering and delivery** — Delivery guarantees explicit? Ordering scope chosen?
11. **Distributed locking** — Lease expiry? Fencing tokens?
12. **Schema evolution** — Backward/forward compatible? Version field present?
13. **Immutability** — Functions pure? State transitions produce new state? Audit data append-only?
14. **Query optimization** — No N+1? Pagination? Timezone-aware time ranges? EXPLAIN analysis?
15. **Observability** — Structured logging? Correlation IDs? Health checks? SLOs? Runbooks?
16. **Security and access control** — Auth, authorization, encryption, data privacy, supply chain?
17. **API contract design** — REST conventions, error format, pagination, versioning, rate limiting?
18. **External dependency resilience** — Timeouts, circuit breakers, connection pooling, graceful degradation?
19. **Async processing resilience** — DLQ, partial failure reporting, reprocessing path?
20. **Deployment readiness** — Backward compat, health probes, graceful shutdown, safe migrations? Canary criteria?
21. **Graceful degradation** — Per-dependency fallback UX? Core flows independent? Degraded state communicated?
22. **Data modeling** — Aggregate boundaries? Entity vs value object? Schema serves access patterns?
23. **Capacity planning** — Growth rate estimated? Bottleneck identified? Horizontal scaling path?
24. **Testability** — Dependencies injected? Pure functions extracted? Contract tests? Functional core, imperative shell?
25. **Cost awareness** — Query cost understood? Compute right-sized? Storage tiered? Egress minimized?
26. **Multi-tenancy** — Tenant data isolation? Noisy neighbor prevention? Per-tenant limits?
27. **Migration strategy** — Strangler fig or parallel run? Feature parity validated? Rollback path?

## Output Format

```
# Architecture Assessment

## Scope
[What was assessed: files, feature description, branch]
[Focus area if --focus was used]

## Classification
[System traits detected and which of the 27 categories apply]

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

- Read the full implementation, not just diffs. Missing patterns live in what was NOT written.
- Only assess categories that apply to the system type. Do not flag missing caching on a CLI tool or missing saga on a single-service app.
- Every "MISSING" finding must include a concrete code example showing how to add it.
- Every "PARTIAL" finding must explain exactly what's there and what's not.
- Every non-PRESENT finding must have a severity and effort estimate.
- Be direct about gaps. The goal is to catch what a senior engineer or interviewer would catch. Sugarcoating defeats the purpose.
- Rank by severity first: CRITICAL before HIGH before MEDIUM before LOW. Within the same severity, lower effort first.
- If everything is covered, say so. Do not invent problems.
- Reference the relevant rules file for each category so the user can read the full guidance: `rules/security.md`, `rules/api-design.md`, `rules/resilience.md`, `rules/database.md`, `rules/caching.md`, `rules/distributed-systems.md`, `rules/observability.md`, `rules/code-style.md`.
- After the assessment, always offer to implement the missing patterns, prioritized by severity then effort.
- Security findings are always at least HIGH severity. A missing auth check or exposed secret is CRITICAL.
- Do not flag deployment readiness for code that is explicitly a prototype, proof-of-concept, or interview take-home unless `--focus ops` was specified.
- When `--comments` is active, every comment must pass this test: would a senior engineer reading this code for the first time learn something from the comment that the code alone does not convey? If not, delete the comment.
- `--comments` only affects the fix step. The assessment output itself is unchanged.

## Related skills

- `/review` — Diff-based code review for correctness. Catches bugs in what's written.
- `/test` — Run tests to verify the implementation works.
- `/commit` — Commit fixes after addressing assessment gaps.
