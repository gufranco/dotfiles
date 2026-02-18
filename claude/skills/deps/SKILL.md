---
name: deps
description: Audit dependencies for vulnerabilities, check for outdated packages, and manage updates with deep scanning.
---

Audit project dependencies for known vulnerabilities, list outdated packages, and help manage updates safely. Detects the package manager automatically and supports deep scanning with trivy, snyk, and gitleaks when available.

## When to use

- On a regular basis to check for security vulnerabilities.
- Before a release to ensure dependencies are up to date.
- When investigating a security advisory.
- When you want to update a specific package or all packages.
- When you want a deep security scan beyond just dependency audits.

## When NOT to use

- When the project has no dependency manifest (no `package.json`, `Cargo.toml`, etc.).
- When you want to add a new dependency. Use the package manager directly.

## Arguments

This skill accepts optional arguments after `/deps`:

- No arguments: run a security audit.
- `outdated`: list packages with newer versions available.
- `update [package]`: show what would be updated and ask for approval before updating.
- `scan`: deep security scan using trivy, snyk, and gitleaks.
- `image <name>`: analyze a Docker image for vulnerabilities and layer efficiency.

## Steps

1. Detect the package manager by checking for lockfiles in the current directory:
   - `bun.lock` or `bun.lockb`: use `bun`.
   - `pnpm-lock.yaml`: use `pnpm`.
   - `yarn.lock`: use `yarn`.
   - `package-lock.json`: use `npm`.
   - `Cargo.toml`: use `cargo`.
   - `go.mod`: use `go`.
   - `pyproject.toml` with `uv.lock` or `[tool.uv]`: use `uv`.
   - `pyproject.toml` with `[tool.poetry]`: use `poetry`.
   - `requirements.txt`: use `pip`.
   - If none found, ask the user which package manager to use.
2. Verify the package manager CLI is installed with `which <tool>`. If not installed, stop and tell the user.
3. For **audit** mode (default):
   - npm: run `npm audit`.
   - pnpm: run `pnpm audit`.
   - yarn: run `yarn audit`.
   - bun: verify `bun audit` exists by running it. If not supported, fall back to `npm audit` only if npm is also available. If neither works, tell the user that bun does not yet support native auditing.
   - cargo: run `cargo audit` (verify with `which cargo-audit`, suggest installing if missing).
   - go: run `govulncheck ./...` (verify with `which govulncheck`, suggest installing if missing).
   - uv: run `uv pip audit` or fall back to `pip-audit`.
   - poetry: run `poetry check` or `pip-audit`.
   - pip: run `pip-audit` (verify with `which pip-audit`, suggest installing if missing).
   - Parse the output and present a summary:
     ```
     Vulnerabilities found: <count>
     Critical: <count>  High: <count>  Moderate: <count>  Low: <count>

     <package>@<version> - <severity> - <description>
     Fix available: <fixed-version>
     ```
4. For **outdated** mode:
   - npm: run `npm outdated`.
   - pnpm: run `pnpm outdated`.
   - yarn: run `yarn outdated`.
   - bun: run `bun outdated`.
   - cargo: run `cargo outdated` (verify with `which cargo-outdated`).
   - go: run `go list -m -u all`.
   - uv: run `uv pip list --outdated`.
   - pip: run `pip list --outdated`.
   - Present results showing current version, wanted version, and latest version.
5. For **update** mode:
   - If a specific package was named:
     - Show the current and target version.
     - Ask the user for approval.
     - Run the update command (e.g. `npm install <package>@latest`, `pnpm update <package>`).
   - If no specific package:
     - Run the outdated check first to show what would change.
     - Ask the user for approval.
     - npm: `npm update`.
     - pnpm: `pnpm update`.
     - yarn: `yarn upgrade`.
     - bun: `bun update`.
     - cargo: `cargo update`.
     - go: `go get -u ./...`.
     - uv: `uv pip compile --upgrade` then `uv pip sync`.
   - After updating, run the audit again to verify no new vulnerabilities.
6. For **scan** mode (deep security):
   - First, check which tools are available by running `which trivy`, `which snyk`, and `which gitleaks` **in parallel**.
   - Then run **all available scanners in parallel**:
     - **trivy:** `trivy fs .` to scan for vulnerabilities in dependencies, config files, and secrets. Summarize by severity.
     - **snyk:** `snyk test` for dependency scanning, `snyk code test` for static analysis.
     - **gitleaks:** `gitleaks detect --source .` to scan for hardcoded secrets. Report findings with file and line references.
   - Show results from whichever tools are available. If none are installed, list what could be installed and their purpose.
7. For **image** mode (Docker image analysis):
   - Verify Docker is available and the daemon is reachable.
   - **trivy** (verify with `which trivy`): run `trivy image <name>` to scan for OS and library vulnerabilities.
   - **dive** (verify with `which dive`): run `dive <name>` for layer-by-layer analysis and wasted space detection.
   - If neither tool is installed, suggest them.
8. Show a summary of what was done.

## Rules

- Always detect the package manager from the lockfile. Never assume npm.
- Always verify audit, scan, and outdated tools are installed before running them.
- Never update packages without showing what will change and getting user approval.
- Never remove the lockfile or `node_modules` to "fix" issues.
- Never run `npm audit fix --force` or equivalent without explicit user approval. It can introduce breaking changes.
- Never install scanning tools without asking. Only use what is already available.
- If no vulnerabilities are found, say so clearly.

## Related skills

- `/test` - Run tests after updating dependencies to verify nothing broke. The `--scan` flag provides the same trivy/snyk/gitleaks scanning as `deps scan`.
- `/commit` - Commit lockfile changes after updates.
- `/docker` - Docker images can be scanned for vulnerabilities too.
