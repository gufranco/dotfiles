---
name: assessment
description: Architecture completeness audit for an implementation. Finds missing patterns, not just bugs.
---

Perform an architecture completeness audit on an implementation. Unlike `/review` which checks diffs for correctness, this skill reads the full implementation and identifies **what's missing**: architectural patterns, resilience strategies, and design decisions that should be present but aren't.

Designed for self-assessment before submitting work, whether in an interview, a take-home, or before declaring a feature complete.

## When to use

- After implementing a feature and before saying "I'm done."
- Interview self-check: catch missing architectural patterns before the interviewer does.
- Design validation: verify a solution covers all the patterns it should.
- Learning: understand which architecture concepts apply to a given problem.

## When NOT to use

- For reviewing a diff or PR. Use `/review` instead.
- For trivial changes that don't involve architecture decisions.

## Arguments

This skill accepts optional arguments after `/assessment`:

- No arguments: assess all changed files on the current branch compared to the base branch.
- A file or directory path: assess those specific files.
- `--scope <description>`: provide a description of what was implemented so the assessment can focus on relevant patterns.

## Steps

1. **Gather the implementation.** Run these **in parallel**:
   - `git branch --show-current` to get the current branch.
   - Detect the base branch (same logic as `/review`).
   - `git fetch origin` to ensure remote is up to date.
   - If a path argument was given, use that. Otherwise, get the list of changed files: `git diff origin/<base>...HEAD --name-only`.
   - If `--scope` was provided, record the description for context.

2. **Read the full implementation.** Read every changed file in full, not just the diff. The goal is to understand the complete solution, not just what changed. Also read key surrounding files (imports, configs, schemas) to understand context.

3. **Classify the implementation.** Determine what type of system this is, as not every pattern applies to every system:
   - **Has a write path?** (API endpoints, event handlers, database writes) → Check: idempotency, deduplication, atomicity, conditional writes, transactions.
   - **Has a read path?** (queries, API responses, dashboards) → Check: caching, query optimization, pagination, timezone handling.
   - **Has external dependencies?** (HTTP calls, third-party APIs, databases) → Check: timeouts, circuit breakers, bulkhead, connection pooling, error classification.
   - **Has async processing?** (queues, events, background jobs) → Check: DLQ, partial batch failure, deduplication, event ordering, delivery guarantees.
   - **Spans multiple services?** → Check: saga/compensation, outbox pattern, distributed locking, consistency model, schema evolution.
   - **Handles variable load?** (public API, webhook receiver, batch processor) → Check: back pressure, load shedding, rate limiting, bounded concurrency.
   - **Stores data?** → Check: immutability, append-only for audit, soft delete, UTC timestamps, safe migrations.

4. **Audit against each applicable category.** For every category that applies based on step 3, evaluate the implementation. Use the full checklist from `assessment-checklist.md` in this directory.

5. **Present the assessment.** Format the output as described below.

6. **Offer to fix.** After presenting the assessment, ask: "Want me to implement the missing patterns?" If yes, work through them one at a time, starting with the highest-impact gaps.

## Assessment Checklist Categories

The full checklist lives in `assessment-checklist.md`. Categories:

1. **Idempotency and deduplication** — Can every write operation run twice safely?
2. **Atomicity and transactions** — Are related writes atomic? Conditional writes prevent lost updates?
3. **Error classification** — Transient vs permanent? Retry only transient?
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
14. **Query optimization** — No N+1? Pagination? Timezone-aware time ranges?
15. **Observability** — Structured logging? Correlation IDs? Health checks?

## Output Format

```
# Architecture Assessment

## Scope
[What was assessed: files, feature description, branch]

## Classification
[What type of system this is and which categories apply]

## Findings

### [Category Name] — [PRESENT | MISSING | PARTIAL]

**Status**: [One-line summary of what's there and what's not]

**What's missing** (if applicable):
- [Specific gap with actionable fix]
- [Specific gap with actionable fix]

**Example fix** (if applicable):
[Code example showing how to add the missing pattern]

[Repeat for each applicable category]

## Summary

| Category | Status |
|----------|--------|
| ... | PRESENT / MISSING / PARTIAL |

**Coverage**: X of Y applicable categories fully covered.

## Top 3 Gaps (by impact)
1. [Most impactful missing pattern and why it matters]
2. [Second most impactful]
3. [Third most impactful]
```

## Rules

- Read the full implementation, not just diffs. Missing patterns live in what was NOT written.
- Only assess categories that apply to the system type. Do not flag missing caching on a CLI tool or missing saga on a single-service app.
- Every "MISSING" finding must include a concrete code example showing how to add it.
- Every "PARTIAL" finding must explain exactly what's there and what's not.
- Be direct about gaps. The goal is to catch what an interviewer would catch. Sugarcoating defeats the purpose.
- Rank the summary by impact: data loss and correctness issues first, then resilience, then optimization.
- If everything is covered, say so. Do not invent problems.
- Reference the relevant rules file for each category so the user can read the full guidance: `rules/resilience.md`, `rules/database.md`, `rules/caching.md`, `rules/distributed-systems.md`, `rules/code-style.md`.
- After the assessment, always offer to implement the missing patterns.

## Related skills

- `/review` — Diff-based code review for correctness. Catches bugs in what's written.
- `/test` — Run tests to verify the implementation works.
- `/commit` — Commit fixes after addressing assessment gaps.
