---
name: retro
description: Analyze the conversation for corrections, preferences, and recurring patterns, then propose additions to the Claude configuration.
---

Analyze the current conversation to extract directives, corrections, preferences, and recurring mistakes, then propose concrete additions to the Claude Code configuration so the same issues do not happen again.

## When to use

- At the end of a significant multi-step session.
- After a session where the user corrected your behavior more than once.
- When the user explicitly asks you to analyze what went wrong or what to remember.
- **Proactively**: after completing significant work, run this analysis automatically (see the "Session Retrospective" rule in CLAUDE.md).

## When NOT to use

- After trivial one-shot tasks with no corrections or preferences expressed.
- When the conversation was purely informational with no implementation work.

## Arguments

This skill accepts optional arguments after `/retro`:

- No arguments: analyze the full conversation.
- `--dry-run`: show proposals without offering to write them.
- `--memory-only`: only update memory files, skip rule/CLAUDE.md proposals.

## Steps

### 1. Scan the conversation

Read through the entire conversation and extract:

| Category | What to look for | Example |
|----------|-----------------|---------|
| **Corrections** | User told you to stop doing X or start doing Y | "Don't add comments to code you didn't write" |
| **Preferences** | User expressed how they want things done | "I prefer single-color bars, not stacked" |
| **Repeated mistakes** | Same type of error appeared more than once | Forgetting platform compatibility three times |
| **Architectural decisions** | Decisions about the project that should persist | "Dashboard should be compact, max 56x28" |
| **Tool/workflow preferences** | How the user wants to interact with you | "Always run tests before declaring done" |
| **Project-specific knowledge** | Facts about the codebase learned during the session | "macOS stat needs /usr/bin/stat to bypass GNU" |

### 2. Deduplicate against existing configuration

For each finding, check if it already exists in:

1. `~/.claude/CLAUDE.md`
2. `~/.claude/rules/*.md`
3. Project-level `CLAUDE.md` files
4. Memory files in `~/.claude/projects/*/memory/`

Skip anything already covered. Flag items that partially overlap and could be strengthened.

### 3. Classify each finding

Assign each unique finding to a destination. **Default to `~/.claude/` files, not memory.** Memory is the exception for facts that only apply to one project. If a preference, convention, or behavioral rule could apply across projects, it belongs in `CLAUDE.md` or a rules file.

| Destination | When | Example |
|-------------|------|---------|
| **`~/.claude/CLAUDE.md`** | Universal behavioral change, writing style, communication preference, workflow rule | "Use GMT in reports", "Always provide UI walkthroughs for instructions" |
| **`~/.claude/rules/*.md`** (new or existing) | Domain-specific convention that needs detail or belongs with related rules | New testing convention, new code style rule, new API design pattern |
| **Skill update** | Change to how a skill operates | "/commit should also check for X" |
| **Memory file** | Project-specific fact that only applies to one codebase: infra details, team members, architecture decisions | "Aurora cluster ID is database", "ECS cluster name is webservices" |
| **No action** | One-time context, not a pattern | "Fix the typo on line 42" |

**Classification test:** "Would this rule improve my behavior in a different project?" If yes, it goes in `~/.claude/`. If it only makes sense in the context of this specific codebase, it goes in memory.

### 4. Present findings

Show a summary table:

```
## Session Retrospective

### Findings

| # | Finding | Source | Destination | Status |
|---|---------|--------|-------------|--------|
| 1 | <description> | <where in conversation> | <file to update> | New / Strengthen |
| 2 | ... | ... | ... | ... |

### Proposed Changes

#### 1. <destination file>
<what to add or change, with the exact text>

#### 2. <destination file>
<what to add or change, with the exact text>
```

### 5. Apply changes

After presenting the proposals:

- Ask the user which changes to apply. Offer "All", "Pick individually", or "None".
- For each approved change, write or edit the target file.
- If any change touches a file inside `~/.claude/`, update `~/.claude/README.md` to reflect it.
- Show a final summary of what was written and where.

### 6. Verify

- Read each modified file to confirm the changes are present and correctly placed.
- If a rules file was updated, verify it does not contradict existing rules in other files.

## Rules

- Never write a rule that contradicts an existing one. If there is a conflict, present both and ask the user to choose.
- Never add duplicate content. If the finding already exists, skip it or propose strengthening the existing text.
- Keep proposals concise. Match the style of the target file. A memory entry is 1-2 lines. A CLAUDE.md rule is a bullet point. A rules file section has a heading and a few bullets or a table.
- Do not invent findings. Every proposal must trace back to something the user said or a mistake that actually happened in the conversation.
- If `--dry-run` was passed, present findings and proposals but do not offer to write them.
- If `--memory-only` was passed, only propose memory file updates, skip CLAUDE.md and rules.
- When running proactively at end of session, keep it brief. Skip the full table for sessions with zero or one finding. A simple "No recurring patterns to capture from this session" is enough.

## Related skills

- `/assessment` - Architecture audit for implementations.
- `/review` - Code review for PRs and branches.
- `/commit` - May trigger retro when `--pipeline` reveals recurring CI issues.
