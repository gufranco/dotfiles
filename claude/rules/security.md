# Security

## Secrets and Environment

**NEVER commit:** `.env`, `*.pem`, `*.key`, `credentials.json`, `id_rsa`

- Required env vars MUST be documented in `.env.example` with placeholder values
- Validate required env at startup. Fail fast with a clear message listing what is missing.

## Auth Checklist

- [ ] Passwords hashed (bcrypt/argon2)
- [ ] Rate limiting on auth endpoints
- [ ] Token expiration configured
- [ ] Permission check on every request
- [ ] CSRF protection on state-changing endpoints (SameSite cookies, CSRF tokens, or origin validation)
- [ ] Principle of least privilege: every component, user, and service account has only the permissions it needs, nothing more

## Access Control

- Default deny. Explicitly grant permissions, never explicitly deny them
- Verify authorization per-resource, not just per-role. User A being an admin does not mean they can access User B's private data (IDOR prevention)
- Use role-based access control (RBAC) for most applications. Consider attribute-based (ABAC) when permissions depend on resource properties or context
- Authorization logic lives in one place, not scattered across controllers

## Encryption

| Layer | Requirement |
|-------|-------------|
| In transit | TLS 1.2+ on all external connections. No plaintext HTTP for APIs. Enforce HTTPS redirects |
| At rest | Encrypt sensitive data in databases and object storage. Use platform-managed keys (AWS KMS, GCP KMS) unless you have a specific reason to manage your own |
| Application | Hash passwords with bcrypt or argon2. Never use MD5 or SHA for password storage. Use constant-time comparison for secrets |

## Data Privacy

When handling personal data, design for compliance from the start:

- **Data minimization**: collect only what you need. Do not store data "just in case"
- **Retention policy**: define how long each type of personal data is kept. Automate deletion after the retention period
- **Right to erasure**: build a way to delete all of a user's personal data on request. Soft delete is not enough for privacy compliance; the data must be truly gone or anonymized
- **Consent**: if data use requires consent, record when and what was consented to. Make withdrawal easy
- **Audit trail**: log who accessed personal data, when, and why

These apply regardless of whether your users are covered by GDPR, LGPD, CCPA, or no regulation yet. Building it later is always harder than building it in.

## Audit Logging

Log sensitive actions with context:

- Login attempts (success/failure)
- Password changes
- Role changes
- Record deletions
- Permission changes
- Personal data access and exports

Format: `{ action, userId, targetId, timestamp, ip, userAgent }`

## Supply Chain Security

Your dependencies are your attack surface. A compromised or malicious package runs with the same permissions as your code.

- **Lock dependencies**: always commit lockfiles. Pin exact versions, not ranges
- **Verify integrity**: enable lockfile integrity checking (`npm ci`, not `npm install` in CI)
- **Review before adding**: check the package's maintainers, recent commits, download count, and known vulnerabilities before installing. A package with 12 downloads and one maintainer is a risk
- **Typosquatting**: double-check package names. `lodash` vs `1odash`, `colors` vs `colour`. One character can mean malicious code
- **Dependency confusion**: if you use private packages, configure scoped registries to prevent public registry substitution
- **Audit regularly**: run `npm audit`, `pip audit`, or equivalent in CI. Block builds on critical/high vulnerabilities
- **Minimize surface**: fewer dependencies = fewer attack vectors. Prefer native/stdlib when the alternative is a small package with deep transitive dependencies
- **Monitor advisories**: subscribe to security advisories for your critical dependencies. Do not wait for a scheduled audit to learn about a zero-day
