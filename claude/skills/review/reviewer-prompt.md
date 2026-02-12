# Code Reviewer Prompt

Use this as a structured checklist when reviewing a PR/MR diff. Go through each category and note any findings.

## Review Checklist

### Code Quality

- [ ] Clean separation of concerns?
- [ ] Proper error handling? No swallowed errors?
- [ ] Type safety maintained?
- [ ] DRY principle followed? No unnecessary duplication?
- [ ] Edge cases handled?
- [ ] No magic numbers or hardcoded values?
- [ ] Functions small and focused?

### Architecture

- [ ] Sound design decisions for this codebase?
- [ ] Follows existing patterns and conventions?
- [ ] No unnecessary coupling between modules?
- [ ] Performance implications considered?
- [ ] Scalability concerns addressed?

### Security

- [ ] No secrets, tokens, or credentials in code?
- [ ] Input validation at system boundaries?
- [ ] SQL injection, XSS, IDOR prevention?
- [ ] Auth and permissions checked where needed?
- [ ] No sensitive data in logs or error messages?

### Testing

- [ ] New code covered by tests?
- [ ] Tests verify real behavior, not mock behavior?
- [ ] Edge cases and error paths tested?
- [ ] Existing tests still pass?
- [ ] No test-only methods added to production code?

### Requirements

- [ ] All stated requirements met?
- [ ] Implementation matches the PR description?
- [ ] No scope creep beyond what was asked?
- [ ] Breaking changes documented?

### Production Readiness

- [ ] Backward compatible with existing callers?
- [ ] Migration strategy if schema changes?
- [ ] No obvious bugs or race conditions?
- [ ] Error messages helpful for debugging?
- [ ] Logging appropriate, not excessive?

## Severity Guide

| Severity | When to use | Blocking? |
|----------|-------------|-----------|
| `issue:` | Bugs, security holes, data loss risks, broken functionality | Yes |
| `question:` | Unclear intent, missing context, ambiguous behavior | Yes |
| `suggestion:` | Better approach, cleaner pattern, optional improvement | No |
| `nit:` | Style, naming, formatting, minor readability | No |
| `praise:` | Well-designed code, good patterns, clean solutions | No |

## Output Template

For each finding, use:

```
<severity>: <file>:<line> - <concise description>
<why it matters, 1-2 sentences>
```
