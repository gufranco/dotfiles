---
name: scaffold
description: Generate boilerplate code by reading existing project patterns and conventions.
---

Generate new files by reading the existing codebase to detect patterns, naming conventions, file structure, and imports. Never uses external generators or templates. Everything is derived from the project itself.

## When to use

- When creating a new API endpoint, service, component, module, or model.
- When you want new code to match the style and patterns already in the project.

## When NOT to use

- When the project has no existing code to derive patterns from.
- When you want to use an external scaffolding tool (e.g. `nest generate`, `rails generate`).

## Arguments

This skill requires arguments after `/scaffold`:

- `<type> <name>` where type is one of the patterns found in the project.
- Common types: `endpoint`, `service`, `component`, `module`, `model`, `controller`, `middleware`, `hook`.
- The name should be descriptive (e.g. `scaffold endpoint create-user`, `scaffold component user-profile`).

## Steps

1. Parse the arguments:
   - Extract the type and name from the arguments.
   - If no arguments were provided, list the available types detected from the project and ask the user.
   - If only a type was provided without a name, ask the user for the name.
2. **Detect framework and find examples.** Do both **in parallel**:
   - Read `package.json`, `go.mod`, `Cargo.toml`, or `pyproject.toml` to identify the framework.
   - Map the directory structure to understand where different file types live.
   - Search for existing examples of the requested type (see locations below).
3. Existing example locations for each type:
   - For `endpoint` or `controller`: look in `src/routes/`, `src/controllers/`, `src/api/`, `app/api/`, or similar.
   - For `service`: look in `src/services/`, `src/lib/`, `src/domain/`, or similar.
   - For `component`: look in `src/components/`, `app/components/`, or similar.
   - For `module`: look in `src/modules/`, `src/features/`, or similar.
   - For `model`: look in `src/models/`, `src/entities/`, `prisma/`, or similar.
   - For `middleware`: look in `src/middleware/`, `src/middlewares/`, or similar.
   - For `hook`: look in `src/hooks/`, or similar.
   - If no existing examples found for the type, ask the user where the file should go.
4. Analyze the existing examples (read 2-3 files of the same type):
   - File naming convention: kebab-case, camelCase, PascalCase, snake_case.
   - Export style: default export, named export, module.exports.
   - Import patterns: what shared utilities, types, or base classes are used.
   - Code structure: class-based or functional, decorators, middleware patterns.
   - Test file location: co-located (`*.test.ts` next to source) or separate `__tests__/` directory.
   - TypeScript or JavaScript, and which TS patterns (interfaces, types, enums).
5. Generate the new files:
   - Create the main file following the exact patterns found in step 4.
   - Create the test file in the same location pattern as existing tests.
   - Use the provided name, converting case to match the project convention.
   - Include the same imports, base classes, decorators, and utility usage as existing files.
   - Add placeholder implementations with `TODO` comments where business logic goes.
6. Present all generated files to the user for review before writing:
   - Show each file's path and full content.
   - Ask for approval before creating any files.
7. After approval, write the files.
8. If the project uses barrel exports (index.ts/index.js files that re-export), update the relevant barrel file to include the new export.

## Rules

- Always read existing code to derive patterns. Never use hardcoded templates.
- Always present generated code to the user for approval before writing files.
- Always match the exact naming convention, export style, and import patterns of existing code.
- Never generate code without finding at least one existing example to base it on.
- Never install dependencies. If the scaffold needs a dependency that doesn't exist, mention it.
- Never generate code that duplicates existing functionality. Check first.
- If no existing examples of the requested type exist, ask the user for guidance instead of guessing.
- Keep generated code minimal. Provide the skeleton with TODOs, not a full implementation.

## Related skills

- `/test` - Run tests after scaffolding to verify the new files integrate correctly.
- `/commit` - Commit the scaffolded files.
