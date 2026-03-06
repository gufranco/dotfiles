#!/bin/bash
# scope-guard.sh — Detect files modified outside declared scope.
#
# Stop hook that compares git-modified files against the scope declared
# in the most recent .spec.md file's "Files to Create/Modify" section.
# Non-blocking: shows a warning, never fails.
# Install per-project by adding to .claude/settings.json.

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# Find the most recent .spec.md file
SPEC_FILE=$(find "$PROJECT_DIR" -name "*.spec.md" -mtime -14 -type f -print 2>/dev/null | head -1)
[ -z "$SPEC_FILE" ] && exit 0

# Extract declared files from "Files to Create/Modify" section
DECLARED=$(sed -n '/^##.*[Ff]iles.*[Cc]reate\|^##.*[Ff]iles.*[Mm]odify/,/^##/p' "$SPEC_FILE" 2>/dev/null \
  | grep -oE '`[^`]+`' \
  | tr -d '`' \
  | sort -u)

[ -z "$DECLARED" ] && exit 0

# Get files actually modified (staged + unstaged)
MODIFIED=$(git diff --name-only HEAD 2>/dev/null | sort -u)
[ -z "$MODIFIED" ] && exit 0

# Patterns to always exclude from scope warnings
EXCLUDED_PATTERN="(test|spec|__tests__|fixture|mock|stub|\.config\.|package-lock|yarn\.lock|pnpm-lock|\.md$|\.txt$)"

OUT_OF_SCOPE=""
while IFS= read -r file; do
  # Skip excluded patterns
  echo "$file" | grep -qE "$EXCLUDED_PATTERN" && continue

  # Check if file is in declared scope
  FOUND=0
  while IFS= read -r declared; do
    [ -z "$declared" ] && continue
    case "$file" in *"$declared"*) FOUND=1; break ;; esac
  done <<< "$DECLARED"

  [ "$FOUND" -eq 0 ] && OUT_OF_SCOPE="$OUT_OF_SCOPE\n  - $file"
done <<< "$MODIFIED"

if [ -n "$OUT_OF_SCOPE" ]; then
  echo ""
  echo "SCOPE GUARD: Files modified outside declared spec scope ($SPEC_FILE):"
  echo -e "$OUT_OF_SCOPE"
  echo ""
  echo "  This may indicate scope creep. Review before committing."
  echo ""
fi

exit 0
