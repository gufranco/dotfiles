#!/usr/bin/env bash
# Validate that git commit messages follow conventional commit format.
#
# Intercepts Bash tool calls that run git commit. Extracts the commit
# message and validates it against the conventional commit pattern.
#
# Receives Bash tool input as JSON on stdin.
# Exit 0 = allow, exit 2 = block.

set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('input', {}).get('command', ''))
except:
    pass
" 2>/dev/null)

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
    exit 0
fi

# Skip amend, merge, and squash commits (they reuse existing messages)
if echo "$COMMAND" | grep -qE '\-\-amend|\-\-no-edit|\-\-squash'; then
    exit 0
fi

# Extract message from -m flag (handles both 'single' and "double" quotes)
MESSAGE=$(echo "$COMMAND" | python3 -c "
import re, sys
cmd = sys.stdin.read()
# Match heredoc format: cat <<'EOF' or cat <<EOF
heredoc = re.search(r\"cat <<'?EOF'?\\n(.+?)\\nEOF\", cmd, re.DOTALL)
if heredoc:
    print(heredoc.group(1).strip())
    sys.exit(0)
# Match -m with quotes
m_flag = re.search(r'-m\s+[\"'\\''](.+?)[\"'\\'']', cmd)
if m_flag:
    print(m_flag.group(1).strip())
    sys.exit(0)
# Match -m with \$() substitution
m_sub = re.search(r'-m\s+\"\\\$\\(cat <<', cmd)
if m_sub:
    # Heredoc inside -m, extract the content
    content = re.search(r\"cat <<'?EOF'?\\n(.+?)\\n\\s*EOF\", cmd, re.DOTALL)
    if content:
        print(content.group(1).strip())
        sys.exit(0)
" 2>/dev/null)

# If we couldn't extract a message, allow (might be interactive or --allow-empty-message)
if [ -z "$MESSAGE" ]; then
    exit 0
fi

# Get the first line (subject)
SUBJECT=$(echo "$MESSAGE" | head -1)

# Validate conventional commit format
PATTERN='^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\(.+\))?(!)?: .+'
if ! echo "$SUBJECT" | grep -qE "$PATTERN"; then
    echo "BLOCKED: Commit message does not follow conventional commit format."
    echo ""
    echo "  Got: $SUBJECT"
    echo ""
    echo "  Expected: <type>(<scope>): <subject>"
    echo "  Types: feat, fix, docs, style, refactor, perf, test, chore, ci, build, revert"
    echo "  Example: feat(auth): add SSO login with Google provider"
    exit 2
fi

# Validate subject length (max 50 chars for subject line)
SUBJECT_LENGTH=${#SUBJECT}
if [ "$SUBJECT_LENGTH" -gt 72 ]; then
    echo "BLOCKED: Commit subject line is $SUBJECT_LENGTH characters (max 72)."
    echo ""
    echo "  Got: $SUBJECT"
    echo ""
    echo "  Keep the subject concise. Use the body for details."
    exit 2
fi

exit 0
