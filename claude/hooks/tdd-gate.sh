#!/bin/bash
# tdd-gate.sh — Enforce TDD: tests must exist before production code.
#
# PreToolUse hook for Edit, MultiEdit, and Write.
# Blocks editing production code if no corresponding test file exists.
# Install per-project by adding to .claude/settings.json.
# NOTE: No set -euo pipefail — this hook must never block unintentionally.

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

case "$TOOL" in
  Edit|MultiEdit|Write) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

EXT="${FILE_PATH##*.}"

# Only check production code extensions
case "$EXT" in
  cs|py|ts|tsx|js|jsx|go|rs|rb|php|java|kt|swift|dart) ;;
  *) exit 0 ;;
esac

BASENAME=$(basename "$FILE_PATH")

# Skip test files themselves
case "$BASENAME" in
  *Test.${EXT}|*Tests.${EXT}|*_test.${EXT}|test_*.${EXT}) exit 0 ;;
  *.test.${EXT}|*.spec.${EXT}|*Spec.${EXT}|*Specs.${EXT}) exit 0 ;;
esac

# Skip config, migration, and infrastructure files
case "$BASENAME" in
  *Migration*|*migration*|*.dto.*|*DTO*) exit 0 ;;
  *.d.ts|*.config.ts|*.config.js|tsconfig*|package.json) exit 0 ;;
  Dockerfile|docker-compose*|*.tf|*.tfvars|*.yml|*.yaml) exit 0 ;;
  *.md|*.txt|*.json|*.xml|*.html|*.css|*.scss) exit 0 ;;
esac

# Skip non-production paths
case "$FILE_PATH" in
  */test/*|*/tests/*|*/__tests__/*) exit 0 ;;
  */spec/*|*/specs/*) exit 0 ;;
  */fixtures/*|*/mocks/*|*/stubs/*|*/fakes/*) exit 0 ;;
  */migrations/*|*/seeds/*|*/config/*|*/scripts/*) exit 0 ;;
esac

NAME_NO_EXT="${BASENAME%.*}"
FILE_DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# Search nearby test directories first
TESTS_FOUND=$(find "$FILE_DIR" "$FILE_DIR/../test" "$FILE_DIR/../tests" "$FILE_DIR/../__tests__" \
  -maxdepth 2 -type f \( \
  -name "${NAME_NO_EXT}Test.*" -o \
  -name "${NAME_NO_EXT}Tests.*" -o \
  -name "${NAME_NO_EXT}.test.*" -o \
  -name "${NAME_NO_EXT}.spec.*" -o \
  -name "${NAME_NO_EXT}_test.*" -o \
  -name "test_${NAME_NO_EXT}.*" \
  \) 2>/dev/null | head -1)

# Fallback: project-wide with depth limit
if [ -z "$TESTS_FOUND" ]; then
  TESTS_FOUND=$(find "$PROJECT_ROOT" -maxdepth 6 -type f \( \
    -name "${NAME_NO_EXT}Test.*" -o \
    -name "${NAME_NO_EXT}Tests.*" -o \
    -name "${NAME_NO_EXT}.test.*" -o \
    -name "${NAME_NO_EXT}.spec.*" -o \
    -name "${NAME_NO_EXT}_test.*" -o \
    -name "test_${NAME_NO_EXT}.*" \
    \) 2>/dev/null | head -1)
fi

if [ -z "$TESTS_FOUND" ]; then
  echo "TDD GATE: No tests found for '$BASENAME'. Write tests BEFORE implementing production code." >&2
  echo "  Create: ${NAME_NO_EXT}.test.${EXT} or ${NAME_NO_EXT}_test.${EXT}" >&2
  exit 2
fi

exit 0
