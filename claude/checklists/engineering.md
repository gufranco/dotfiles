# Engineering Checklist

Shared checklist used by both `/review` and `/assessment`. Each skill applies it differently:

- `/review` checks these items against the **diff**: is what's written correct?
- `/assessment` checks these items against the **full implementation**: is the pattern present, partial, or missing?

Only apply categories relevant to the system type. A CLI tool doesn't need caching. A single-service app doesn't need saga.

## 1. Idempotency and Deduplication

- [ ] Every write operation (API, event handler, database) safe to execute twice with the same input?
- [ ] Guard mechanism identified per layer?
  - API: `Idempotency-Key` header with cached response
  - Event handler: dedup by message ID before processing
  - Database: upsert, `ON CONFLICT DO NOTHING`, or conditional expression
  - State machine: check current state before transitioning
- [ ] Natural deduplication key identified (request ID, event ID, user+action+date)?
- [ ] Dedup state stored durably (database, not in-memory)? Survives restarts?
- [ ] Dedup window (TTL) exceeds maximum retry/redelivery time?
- [ ] POST endpoints that create resources support `Idempotency-Key` header?

Reference: `rules/code-style.md` (Data Safety), `rules/resilience.md` (Idempotency, Deduplication)

## 2. Atomicity and Transactions

- [ ] Related writes wrapped in a single transaction?
- [ ] Conditional writes used to prevent lost updates (optimistic locking, version field)?
- [ ] Transaction scope kept short (validation and I/O before, not inside)?
- [ ] Explicit rollback on failure, not relying on implicit cleanup?
- [ ] NoSQL: `TransactWriteItems` or conditional expressions for multi-item atomicity?
- [ ] Conditional write failures classified: conflict (retry with fresh read) vs duplicate (skip)?
- [ ] Multi-step workflows handle partial failure with rollback or compensating actions?

Reference: `rules/database.md` (Transactions and Atomic Writes, Conditional Writes)

## 3. Error Classification and Retry

- [ ] Every `catch` classifies the error as transient or permanent?
- [ ] Transient errors (timeout, 429, 503, connection reset): logged as warn, retried with exponential backoff + jitter?
- [ ] Permanent errors (400, 404, validation, auth): logged as error, failed immediately, never retried?
- [ ] Ambiguous errors (500, unknown): retried up to 3 times, then treated as permanent?
- [ ] Classification propagated upstream so callers can make informed decisions?
- [ ] No bare catch blocks that log and rethrow without classification?
- [ ] Retry parameters explicit: base delay (100-500ms), multiplier (2x), jitter (0-50%), max retries (3 sync, 5 async)?
- [ ] Max delay cap set (never exceeds 30s between retries)?
- [ ] Total retry time fits within the caller's timeout budget?
- [ ] Caught errors include context: what operation failed, with what input, and why?
- [ ] Async errors handled? No unhandled promise rejections? No missing `await`?
- [ ] Error propagation consistent? Not mixing thrown exceptions with returned error codes in the same layer?
- [ ] HTTP status codes correct for each error type (400, 401, 403, 404, 409, 422, 500)?
- [ ] Partial failure: if step 3 of 5 fails, are steps 1-2 rolled back or is the state consistent?
- [ ] Batch processing: individual item failures reported without aborting the batch?
- [ ] Errors in cleanup code (finally blocks, defer) handled separately?

Reference: `rules/code-style.md` (Error Classification), `rules/resilience.md` (Error Classification, Retry Strategy)

## 4. Caching

- [ ] Reads from slow or expensive sources: caching considered?
- [ ] Cache strategy chosen explicitly (cache-aside, write-through, read-through)?
- [ ] Invalidation strategy explicit (TTL, event-driven, explicit on write)?
- [ ] TTL set with jitter to prevent synchronized expiration?
- [ ] Popular keys protected from thundering herd (lock-based recomputation, stale-while-revalidate)?
- [ ] Cache warming strategy for cold starts after deploy?
- [ ] Max memory limit set? Eviction policy chosen (LRU, LFU)?
- [ ] Hit rate monitored?

Reference: `rules/caching.md`

## 5. Consistency Model

- [ ] Consistency model chosen explicitly (strong, eventual, read-your-writes, causal)?
- [ ] Weakest tolerable model used (strong only for finance, auth, inventory)?
- [ ] Read-your-writes implemented where users mutate and immediately read their own data?
- [ ] Implementation of read-your-writes explicit (read from primary after write, version token, or optimistic UI update)?
- [ ] Eventual consistency communicated to consumers (not silently stale)?

Reference: `rules/distributed-systems.md` (Consistency Models)

## 6. Back Pressure and Load Management

- [ ] Every in-memory queue and channel has a max size?
- [ ] Behavior defined when queue is full (reject, drop oldest, block)?
- [ ] Load shedding strategy: requests classified by priority (critical > important > deferrable)?
- [ ] Overload responses use 503 with `Retry-After` header?
- [ ] Rate limiting on public endpoints?
- [ ] Plan for 10x traffic explicitly considered?

Reference: `rules/resilience.md` (Back Pressure)

## 7. Bulkhead Isolation

- [ ] Separate connection pool per external dependency?
- [ ] One slow dependency cannot exhaust the shared pool?
- [ ] Critical and non-critical workloads isolated (separate processes, queues, or deployments)?
- [ ] Per-tenant or per-priority queue isolation where applicable?

Reference: `rules/resilience.md` (Bulkhead)

## 8. Concurrency Control

- [ ] Fan-out operations bounded by semaphore or worker pool?
- [ ] No unbounded `Promise.all` over large arrays?
- [ ] Worker pool size configured, not left at defaults?
- [ ] Timeout set on each unit of work (stuck worker does not permanently reduce capacity)?
- [ ] Queue depth, active workers, and rejection count instrumented?
- [ ] Shared mutable state protected by locks, mutexes, or atomic operations?
- [ ] No TOCTOU (time-of-check-to-time-of-use) bugs? Check-then-act patterns use database constraints or CAS?
- [ ] Async operations awaited where the result matters? No fire-and-forget without error handler?
- [ ] No deadlock potential from acquiring multiple locks?

Reference: `rules/resilience.md` (Concurrency Control)

## 9. Saga and Cross-Service Coordination

- [ ] Multi-service transactions use saga pattern (not distributed transactions/2PC)?
- [ ] Each saga step has an explicit compensating action?
- [ ] Compensating actions are idempotent?
- [ ] Saga state persisted durably (can resume after crash)?
- [ ] Saga timeout defined, compensation triggered if exceeded?
- [ ] Database write + event publish uses outbox pattern (single transaction)?
- [ ] Outbox delivery mechanism chosen (polling, CDC, log tailing)?
- [ ] No dual writes (DB + message broker in separate operations)?

Reference: `rules/distributed-systems.md` (Saga Pattern, Outbox Pattern)

## 10. Event Ordering and Delivery Guarantees

- [ ] Delivery guarantee chosen explicitly (at-most-once, at-least-once, exactly-once)?
- [ ] At-least-once delivery paired with idempotent consumers?
- [ ] Ordering scope chosen (per-entity, global, causal, none)?
- [ ] Partition key set for per-entity ordering (Kafka partition key, SQS FIFO group ID)?
- [ ] Out-of-order events handled (version check, last-write-wins, or buffer and reorder)?
- [ ] Consumers handle message redelivery without duplicate side effects?

Reference: `rules/distributed-systems.md` (Event Ordering and Delivery Guarantees)

## 11. Distributed Locking

- [ ] Coordination required between instances (scheduled jobs, leader election, exclusive access)?
- [ ] Lock implementation chosen (Redis, database advisory, ZooKeeper/etcd)?
- [ ] Lease expiry set so crashed holders release locks?
- [ ] Fencing tokens used to prevent stale writes after lease expiry?
- [ ] Every write includes the fencing token, storage rejects stale tokens?

Reference: `rules/distributed-systems.md` (Distributed Locking)

## 12. Schema Evolution

- [ ] Events and messages include a `schemaVersion` field?
- [ ] All schema changes backward and forward compatible?
- [ ] No removed or renamed fields without migration plan?
- [ ] No changed field types (new field with new type added instead)?
- [ ] Consumers handle at least current and previous schema version?

Reference: `rules/distributed-systems.md` (Schema Evolution)

## 13. Immutability

- [ ] Functions do not mutate their arguments? Copy-in, copy-out?
- [ ] `const` by default, `let` only when reassignment needed?
- [ ] State transitions produce new state, never mutate previous?
- [ ] Derived values computed from state via selectors, not cached as mutable fields?
- [ ] Audit-sensitive data append-only (versioned rows, not in-place updates)?
- [ ] Events stored as immutable facts in event-driven systems?

Reference: `rules/code-style.md` (Immutability and Explicit Side Effects)

## 14. Query Optimization

- [ ] No `SELECT *`, only needed columns fetched?
- [ ] No N+1 queries? Eager loading or joins used?
- [ ] Pagination on all list endpoints (default + max page size)?
- [ ] Indexes on WHERE, JOIN, ORDER BY columns?
- [ ] Filtering at database level, not in application code?
- [ ] Aggregation at database level, not fetching rows and aggregating in app?
- [ ] Time-range queries: timezone-aware? Not assuming UTC alignment for daily buckets?
- [ ] Time-range boundaries computed at query time from user's local timezone?
- [ ] NoSQL key design distributes writes evenly? No hot partitions?
- [ ] Connection pooling configured? No connection leak (opening without closing)?

Reference: `rules/database.md` (Query Optimization, Time-Range Queries)

## 15. Observability

- [ ] Structured JSON logging with required fields (level, message, timestamp, requestId, service)?
- [ ] Log levels correct (error for failures, warn for handled-but-unexpected, info for business events)?
- [ ] Correlation ID (requestId) propagated across all service calls via `X-Request-Id` header?
- [ ] No sensitive data logged (passwords, tokens, PII)? Redaction patterns applied?
- [ ] No logging inside tight loops?
- [ ] Health check endpoints present: liveness (process alive, no deps) + readiness (all deps reachable with latency)?
- [ ] Metrics for request rate, error rate, latency (p50/p95/p99), saturation?
- [ ] Metric labels low-cardinality (never user IDs, request IDs, timestamps)?
- [ ] Distributed tracing: W3C Trace Context headers, spans for inbound/outbound calls, DB queries, and queue ops?
- [ ] Alerts on symptoms, not causes? Tied to SLO violations? Runbook links on every alert?
- [ ] SLIs defined (availability, latency, error rate)? SLOs set based on measured data, not guesses?
- [ ] Error budget tracked? Reliability prioritized over features when budget is spent?

Reference: `rules/observability.md`

## 16. Security and Access Control

### Injection and input handling
- [ ] SQL injection: all queries parameterized or using ORM? No string concatenation in queries?
- [ ] XSS: all user input escaped before rendering? Framework auto-escaping not bypassed?
- [ ] Command injection: no user input passed to `exec`, `spawn`, or shell commands without sanitization?
- [ ] Path traversal: no user input used in file paths without validation? `../` sequences blocked?
- [ ] SSRF: no user-controlled URLs fetched without allowlist validation?
- [ ] Header injection: no user input in HTTP headers without sanitization?
- [ ] Template injection: no user input in template strings evaluated server-side?
- [ ] Input sanitization at all system boundaries (user input, external APIs)?

### Authentication and authorization
- [ ] Passwords hashed with bcrypt or argon2, never MD5 or SHA?
- [ ] Rate limiting on auth endpoints (login, register, password reset)?
- [ ] Token expiration configured? Refresh token rotation?
- [ ] Tokens validated for expiration, signature, and audience?
- [ ] Session management: tokens rotated after auth state changes? Proper invalidation on logout?
- [ ] CSRF protection on state-changing endpoints (SameSite cookies, CSRF tokens, or origin validation)?
- [ ] Access control: default deny? Permissions explicitly granted, never explicitly denied?
- [ ] Per-resource authorization checked, not just per-role (IDOR prevention)?
- [ ] Authorization logic centralized, not scattered across controllers?

### Data protection
- [ ] Encryption in transit: TLS 1.2+ on all external connections?
- [ ] Encryption at rest for sensitive data (platform-managed keys)?
- [ ] Constant-time comparison for secrets (no timing side-channel)?
- [ ] No secrets, API keys, tokens, or credentials in code, comments, or config files?
- [ ] No sensitive data in logs, error messages, or stack traces?
- [ ] No PII leaked through API responses beyond what the caller needs?
- [ ] Error messages generic in production, no internal paths or query details?
- [ ] CORS configured correctly? Not using `*` with credentials?

### Cryptography
- [ ] No custom crypto implementations? Using well-known libraries?
- [ ] No weak algorithms (MD5, SHA1 for security purposes, DES)?
- [ ] Random values generated with cryptographically secure source?

### Data privacy
- [ ] Data minimization: only collecting what's needed?
- [ ] Retention policy defined per data type? Automated deletion after retention period?
- [ ] Right to erasure: path to delete all of a user's personal data on request?
- [ ] Audit logging for sensitive actions (login, password change, role change, record deletion, PII access)?

### Supply chain
- [ ] Dependencies locked with exact versions? Lockfile committed? Audit in CI?

Reference: `rules/security.md`

## 17. API Contract Design

- [ ] Resources are plural nouns, actions use HTTP methods, max 2 levels of nesting?
- [ ] Status codes correct: 201 for creates with Location header, 204 for no-content, 409 for conflicts, 422 for validation?
- [ ] Error response shape consistent: machine-readable code, human message, requestId, optional field details?
- [ ] No stack traces or internal paths exposed in production error responses?
- [ ] Request/response shapes consistent with existing endpoints?
- [ ] Pagination on all list endpoints? Strategy chosen (cursor-based default, offset-based for random access)?
- [ ] Default and maximum page size set?
- [ ] Filtering and sorting on list endpoints?
- [ ] Versioning strategy: URL path (`/v1/...`), at most two major versions active?
- [ ] Deprecation lifecycle: `Deprecation` and `Sunset` headers, monitoring, documented migration path?
- [ ] Rate limiting headers on every response (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`)?
- [ ] `Retry-After` header on 429 responses?
- [ ] POST endpoints that create resources support `Idempotency-Key` header?
- [ ] Bulk operations return per-item results with individual status codes?
- [ ] ISO 8601 dates, UTC timestamps, `Content-Type` header set?
- [ ] Collections wrapped in `data` field? Consistent response envelope?
- [ ] Response includes only necessary data? No over-fetching?

Reference: `rules/api-design.md`

## 18. External Dependency Resilience

- [ ] Explicit timeout on every external call (connect + read for HTTP, statement for DB, visibility for queues)?
- [ ] No reliance on framework defaults (often 30-60s, too generous)?
- [ ] Circuit breakers for services that may be degraded (closed, open, half-open)?
- [ ] Circuit breaker trips on sustained failure, not a single error?
- [ ] Connection pooling: separate pool per external dependency?
- [ ] Pool size based on expected concurrency, not defaults or guesses?
- [ ] Idle timeout configured to reclaim unused connections?
- [ ] For serverless: connection proxy (RDS Proxy, PgBouncer) to prevent exhaustion from cold starts?
- [ ] Graceful degradation: fallback behavior defined when a dependency is unavailable?
- [ ] Health check readiness endpoint reflects dependency status?

Reference: `rules/resilience.md` (Circuit Breakers, Timeouts), `rules/database.md` (Connection Management)

## 19. Async Processing Resilience

- [ ] Dead letter queue configured on every queue and event source mapping?
- [ ] `maxReceiveCount` set based on retry policy (typically 3-5)?
- [ ] Partial batch failures reported: return individual failure IDs so successful messages are not redelivered?
- [ ] DLQ depth monitored with alerts? Messages in DLQ mean data is not being processed.
- [ ] Reprocessing path built: DLQ messages can be replayed after root cause fix?
- [ ] Consumer processes each item independently? One failure does not abort the batch?
- [ ] Per-item success/failure tracked and reported?
- [ ] State consistent after partial failure (compensating actions or rollback)?
- [ ] Background jobs have execution timeout with cleanup?
- [ ] Message visibility timeout aligned with expected processing time?

Reference: `rules/resilience.md` (Dead Letter Queues, Partial Failure, Timeouts)

## 20. Deployment Readiness

- [ ] Backward compatibility: old and new versions coexist during rollout (rolling update, blue/green, canary)?
- [ ] Database migrations run before deployment? Old code works with new schema?
- [ ] Safe migration patterns used: nullable columns first, no renames or type changes in one step?
- [ ] Liveness probe: returns 200 if process is running, no dependency checks?
- [ ] Readiness probe: returns 200 only when all critical dependencies are reachable?
- [ ] Graceful shutdown: stop accepting new requests, finish in-flight within timeout, then exit?
- [ ] Feature flags for user-facing behavior changes that need gradual rollout?
- [ ] Rollback plan: can revert deployment without data loss or manual intervention?
- [ ] No hardcoded config: all environment-specific values from env vars or config service?

Reference: `rules/distributed-systems.md` (Zero-Downtime Deployments), `rules/database.md` (Safe Migrations)
