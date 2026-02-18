---
name: test
description: Detect the project's test runner and execute tests with coverage, linting, and security scanning.
---

Detect the project's test framework and package manager, then run tests with optional coverage, watch mode, or file targeting. Also supports linting, type checking, and security scanning as complementary verification steps.

## When to use

- After making code changes and before committing.
- When you need to verify that existing tests still pass.
- When you want to run tests for a specific file or pattern.
- When you need a coverage report.
- When you want to lint shell scripts, run Go linters, or scan for vulnerabilities.

## When NOT to use

- When the project has no test configuration or test files.

## Arguments

This skill accepts optional arguments after `/test`:

- No arguments: run the full test suite.
- A file path or pattern (e.g. `src/auth/login.test.ts`): run only matching tests.
- `--coverage`: run with coverage reporting enabled.
- `--watch`: run in watch mode for continuous feedback.
- `--lint`: run linters instead of tests.
- `--scan`: run security vulnerability scanning on the codebase.
- `--ci`: simulate CI locally using `act` (GitHub Actions).

## Steps

1. Detect the package manager by checking for lockfiles in the project root:
   - `bun.lock` or `bun.lockb`: use `bun run`.
   - `pnpm-lock.yaml`: use `pnpm run`.
   - `yarn.lock`: use `yarn`.
   - `package-lock.json`: use `npm run`.
   - `Cargo.toml`: use `cargo test`.
   - `go.mod`: use `go test`.
   - `pyproject.toml` with `uv.lock` or `[tool.uv]`: use `uv run pytest`.
   - `pyproject.toml` with `[tool.poetry]`: use `poetry run pytest`.
   - `pyproject.toml` or `requirements.txt`: use `pytest` (verify with `which pytest`).
   - `Makefile` with a `test` target: use `make test`.
   - `Justfile` with a `test` recipe: use `just test` (verify with `which just`).
   - If none found, ask the user how to run tests.
2. Detect the test runner and configuration:
   - **Node.js projects:** check `package.json` for a `test` script. Then look for:
     - `vitest.config.*` or `vitest` in devDependencies: vitest.
     - `jest.config.*` or `jest` in devDependencies: jest.
     - `mocha` in devDependencies or `.mocharc.*`: mocha.
   - **Rust:** `cargo test` (built-in).
   - **Go:** `go test ./...` (built-in). Also check for `golangci-lint` with `which golangci-lint` for linting.
   - **Python:** look for `pytest.ini`, `pyproject.toml` with `[tool.pytest]`, or `setup.cfg` with `[tool:pytest]`.
   - **Shell scripts:** if the project has `.sh` or `.zsh` files and no other test runner, check for `shellcheck` with `which shellcheck`.
   - If the test runner cannot be determined, read `package.json` scripts and ask the user.
3. Build the test command:
   - Start with the base command from step 1 (e.g. `pnpm run test`).
   - If a file path or pattern was provided:
     - vitest/jest: append the path directly (e.g. `pnpm run test src/auth`).
     - pytest: append the path (e.g. `pytest src/auth/`).
     - go: use the package path (e.g. `go test ./pkg/auth/...`).
     - cargo: use `cargo test <name>`.
   - If `--coverage` was requested:
     - vitest: add `--coverage`.
     - jest: add `--coverage`.
     - pytest: add `--cov` (verify `pytest-cov` is installed).
     - go: add `-cover` or `-coverprofile=coverage.out` for detailed output.
     - cargo: suggest `cargo-tarpaulin` if installed.
   - If `--watch` was requested:
     - vitest: watch mode is default, no flag needed.
     - jest: add `--watch`.
     - pytest: suggest `pytest-watch` if installed.
     - go/cargo: watch mode not built-in, suggest `entr` as alternative (verify with `which entr`).
4. For **`--lint`** mode:
   - **Node.js:** check `package.json` for `lint` script, run it.
   - **Go:** run `golangci-lint run` (verify with `which golangci-lint`).
   - **Shell:** run `shellcheck <files>` on `.sh` and `.zsh` files (verify with `which shellcheck`).
   - **Python:** run `ruff check .` or `flake8` based on what is configured.
   - **GitHub Actions:** run `actionlint` on `.github/workflows/*.yml` files (verify with `which actionlint`).
   - **Vim:** run `vint` on `.vim` files if relevant (verify with `which vint`).
5. For **`--scan`** mode:
   - Check for `trivy` with `which trivy`. If found, run `trivy fs .` to scan the project filesystem for vulnerabilities.
   - Check for `snyk` with `which snyk`. If found, run `snyk test` for dependency vulnerabilities.
   - Check for `gitleaks` with `which gitleaks`. If found, run `gitleaks detect --source .` to scan for leaked secrets.
   - Show results from whichever tools are available. If none are installed, say so and list what could be installed.
6. For **`--ci`** mode:
   - Verify `act` is installed with `which act`.
   - If found, run `act --list` to show available workflows.
   - Ask the user which workflow to run, or run the default push event with `act push --container-architecture linux/amd64`.
   - Note: this requires Docker to be running.
7. Run the test command and capture the output.
8. Parse the results:
   - Count passed, failed, and skipped tests.
   - If coverage was requested, extract the coverage summary (total percentage and per-file breakdown if available).
   - Identify any failing test names and their error messages.
9. Present the results:
   - If all tests pass: report the count and coverage if available.
   - If tests fail: show each failing test with its error message and file location.
   - If coverage is below a threshold noted in project config, mention it.

## Rules

- Always detect the package manager from the lockfile. Never assume npm.
- Always detect the test runner from project config. Never guess.
- Always check for `Justfile` and `Makefile` as potential test runners.
- Never install test dependencies without asking the user.
- Never modify test files. Only run them.
- If no test configuration exists, say so and stop. Do not create test config.
- If tests fail, show the failures clearly but do not automatically fix them.
- For `--scan`, only run tools that are already installed. Never install security tools without asking.

## Related skills

- `/commit` - After tests pass, commit the changes.
- `/checks` - After pushing, verify CI/CD tests also pass.
- `/deps` - Audit dependencies for vulnerabilities. The `deps scan` subcommand provides the same trivy/snyk/gitleaks scanning as `test --scan`.
