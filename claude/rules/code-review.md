# Code Review

## As Author

- Self-review the entire diff line by line
- Run all tests locally
- Keep PRs small (< 400 lines ideally, max 1000)
- One logical change per PR
- Include before/after screenshots for UI changes

## Review Comments

Write review comments the way a human colleague would. No prefix labels, no structured templates. Just say what you mean directly.

If something needs to be fixed, say it. If you have a question, ask it. If something looks good, say so briefly. Each comment should be its own thought, written naturally, not items from a generated checklist.

## Test Evidence (MANDATORY)

Every PR that changes behavior must have evidence of tests passing. Check CI first: if the PR has a pipeline that runs tests and they pass, that is sufficient evidence. Only request manual test output with coverage percentage when the project has no CI pipeline, when the pipeline does not run tests, or when the pipeline has not executed yet. Do not ask authors to paste terminal output for something CI already verifies.

## Branch Freshness (MANDATORY)

Before approving any PR, check if the branch is behind the base branch. If it is:

- Request a rebase onto the latest base branch
- Request fresh test evidence after the rebase
- If there are merge conflicts, request resolution and new evidence

A PR with passing tests on stale code proves nothing about the merged result.

## Documentation (README) - MANDATORY

Every task completion MUST include a README check. If the change affects how someone uses or sets up the project, update the README:

- New environment variables
- New API endpoints
- Authentication changes
- New commands or scripts
- Changed setup steps
- New dependencies with setup
- Architecture changes
- New features

## Technical Debt

Not all tech debt is bad. Intentional debt taken with a plan to repay is a valid engineering trade-off. Untracked debt that accumulates silently is the problem.

**When reviewing or completing work:**

- If you introduce a shortcut or known limitation, document it with a `TODO(debt):` comment explaining what the ideal solution is and why it wasn't done now
- If you encounter existing debt while working, note it but do not fix it in the same PR. File it separately
- Classify debt by impact: **blocks future work** (fix soon), **slows development** (schedule), **cosmetic** (backlog)

### Architecture Decision Records (ADR)

For non-trivial architecture decisions, record the decision so future engineers understand WHY, not just WHAT.

Format:

```
# ADR-NNN: <Title>

**Status**: proposed | accepted | deprecated | superseded by ADR-NNN
**Date**: YYYY-MM-DD

## Context
What is the problem or situation that requires a decision?

## Decision
What was decided and why this option over the alternatives?

## Consequences
What are the trade-offs? What becomes easier? What becomes harder?
```

Store ADRs in a `docs/adr/` directory in the repository. Number them sequentially. Never delete a superseded ADR, mark it as superseded and link to the replacement.

## Pre-Completion Checklist

- [ ] Reuse checked (codebase, PRs, branches)
- [ ] Backward compatible
- [ ] Matches existing patterns
- [ ] Errors classified (transient vs permanent) and handled accordingly
- [ ] **Idempotent**: every write operation safe to execute twice with the same input. If not naturally idempotent, what guard prevents duplicate effects?
- [ ] **Deduplicated**: identified the natural dedup key. Durable check-before-process in place. In-memory-only dedup is not acceptable
- [ ] **Atomic**: related writes wrapped in a transaction or conditional expression. No partial writes left to corrupt state
- [ ] Async processors have DLQ, partial batch failure reporting, dedup by message ID, and monitoring
- [ ] Input validation (user endpoints)
- [ ] No sensitive data exposed
- [ ] Tests written and passing
- [ ] **Test data uses fake data generator.** No hardcoded static values in test setup. Generator is seeded for determinism
- [ ] README updated (if API/setup/env changed)
