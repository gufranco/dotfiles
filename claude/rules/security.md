# Security

## Secrets and Environment

**NEVER commit:** `.env`, `*.pem`, `*.key`, `credentials.json`, `id_rsa`

- Required env vars MUST be documented in `.env.example` with placeholder values
- Validate required env at startup. Fail fast with a clear message listing what is missing.

## Auth Checklist

- [ ] Passwords hashed (bcrypt/argon2)
- [ ] Rate limiting on auth
- [ ] Token expiration
- [ ] Permission check every request

## Audit Logging

Log sensitive actions with context:

- Login attempts (success/failure)
- Password changes
- Role changes
- Record deletions
- Permission changes

Format: `{ action, userId, targetId, timestamp, ip, userAgent }`
