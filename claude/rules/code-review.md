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

Every PR that changes behavior must include evidence of tests passing and coverage percentage. If missing, request it. Suggest recording the terminal session with asciinema and including the URL in the PR description.

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

## Pre-Completion Checklist

- [ ] Reuse checked (codebase, PRs, branches)
- [ ] Backward compatible
- [ ] Matches existing patterns
- [ ] Errors handled and logged
- [ ] Input validation (user endpoints)
- [ ] No sensitive data exposed
- [ ] Tests written and passing
- [ ] README updated (if API/setup/env changed)
