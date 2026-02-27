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
- [ ] Query plans reviewed with EXPLAIN for new or changed queries? No full table scans on large tables?
- [ ] Write amplification understood? Indexes add write cost proportional to their count.
- [ ] Read replicas used for read-heavy queries that tolerate slight staleness?

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
- [ ] Every alert has a runbook with: what it means, how to diagnose, how to mitigate, and who to escalate to?
- [ ] Distributed debugging path documented? Given a requestId, can an engineer trace the full request across services?
- [ ] On-call handoff includes: known fragile areas, recent incidents, pending deployments, and alert context?
- [ ] Business metrics instrumented? Conversion rates, feature adoption, funnel drop-off tracked alongside technical metrics.
- [ ] A/B test observability? Experiment assignment logged, metrics split by variant, statistical significance tracked.
- [ ] Incident severity classification defined? SEV1-SEV4 with response time expectations and escalation paths.
- [ ] Communication protocol during incidents? Status page updates, stakeholder notifications, war room coordination.
- [ ] Blameless postmortem conducted within 48h of SEV1/SEV2? Timeline, root cause, contributing factors, action items with owners.

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

### Infrastructure security
- [ ] IAM follows least privilege? Service accounts scoped per service, no shared credentials across services.
- [ ] Secrets managed through a vault (HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager)? Rotated automatically on schedule.
- [ ] Network segmentation enforced? Services only reachable from expected sources. No flat network where everything can talk to everything.
- [ ] Zero trust applied? No implicit trust based on network location. Every request authenticated and authorized regardless of origin.
- [ ] Certificate management automated? TLS certificates rotated before expiry. No manual cert renewal in production.

Reference: `rules/security.md`, `rules/infrastructure.md` (Networking and Service Discovery)

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
- [ ] Canary promotion criteria defined? Metrics checked before widening rollout (error rate, latency, business KPIs)?
- [ ] Rollback tested, not just planned? The rollback path has been exercised at least once?
- [ ] Deployment frequency sustainable? Can the team ship this change independently without coordinating with other teams?

Reference: `rules/distributed-systems.md` (Zero-Downtime Deployments), `rules/database.md` (Safe Migrations)

## 21. Graceful Degradation

- [ ] Each external dependency has a defined fallback UX when unavailable?
- [ ] Core user flows work without non-critical dependencies (recommendations, analytics, notifications)?
- [ ] Fallback responses identified per dependency: cached data, default values, or reduced functionality?
- [ ] Degraded state communicated to the user? No silent failures that look like empty data.
- [ ] Degraded paths tested? Chaos testing or dependency kill switches exercised?
- [ ] Blast radius analyzed? A single dependency failure does not cascade to unrelated features.
- [ ] Timeout-based degradation: if a dependency is slow but not down, the system switches to fallback before the user notices?
- [ ] RTO (Recovery Time Objective) and RPO (Recovery Point Objective) defined per service? How fast must it recover, and how much data loss is tolerable?
- [ ] Backup strategy validated? Backups tested with actual restore, not just "backups run nightly."
- [ ] Cross-region failover plan exists for critical services? Traffic can shift to a secondary region if the primary is unavailable.
- [ ] Chaos engineering practiced? Failure injection tested in non-production or controlled production environments.
- [ ] Game days scheduled? Team exercises simulating outages to validate runbooks, monitoring, and incident response.

Reference: `rules/resilience.md` (Circuit Breakers, Timeouts)

## 22. Data Modeling

- [ ] Aggregate boundaries defined? Each aggregate is the unit of consistency and transactional integrity.
- [ ] Entity vs value object distinction clear? Entities have identity, value objects are compared by attributes.
- [ ] Normalization level chosen deliberately? 3NF for write-heavy, denormalized for read-heavy, with documented trade-offs.
- [ ] Relationship ownership explicit? One side owns the FK, the other side queries through it.
- [ ] Domain events identified? State transitions that other parts of the system need to react to.
- [ ] Natural keys vs surrogate keys: chosen per table with justification? Natural keys where stable, surrogate where not.
- [ ] Schema designed for access patterns, not just data structure? Indexes, partitions, and key design serve the queries.
- [ ] Enums and status fields use explicit string values, not magic integers? Readable in raw queries and logs.
- [ ] Bounded contexts identified? Each context has its own model of shared concepts, no single "God object" used everywhere.
- [ ] Anti-corruption layer at context boundaries? Translation between external models and internal domain models happens at the edge, not throughout the codebase.
- [ ] Ubiquitous language consistent? The same term means the same thing in code, database, API, and conversation. No synonyms for the same concept.

Reference: `rules/database.md` (Access Pattern Design, Schema Rules)

## 23. Capacity Planning

- [ ] Storage growth rate estimated? Data volume projected for 1 year, 3 years.
- [ ] Read/write ratio understood? Informs caching strategy, replica topology, and index design.
- [ ] Bottleneck identified? CPU-bound, memory-bound, I/O-bound, or network-bound under expected load.
- [ ] Horizontal scaling path exists? No single-instance assumptions baked into the design (local file storage, in-memory state, sticky sessions).
- [ ] Hot spots identified? Uneven distribution of load across partitions, shards, or instances.
- [ ] Data retention and archival strategy defined? Old data moved to cold storage or deleted on schedule.
- [ ] Connection and thread pool limits sized for expected concurrency, with headroom for spikes?
- [ ] Cost of the current design at 10x scale estimated? No surprise bills from unbounded resources.
- [ ] Auto-scaling validated under load? Scale-up and scale-down behavior tested, not just configured.
- [ ] Storage IOPS and throughput sized for peak? Not just capacity but performance under concurrent access.

Reference: `rules/database.md` (Connection Management, NoSQL Key Design), `rules/resilience.md` (Back Pressure), `rules/infrastructure.md` (Cloud Architecture)

## 24. Testability

- [ ] Dependencies injected, not instantiated inline? Every external dependency replaceable in tests without mocking frameworks.
- [ ] Pure functions extracted from I/O? Business logic testable without databases, networks, or file systems.
- [ ] Functional core, imperative shell? Core domain logic is pure and tested exhaustively, I/O is thin and tested via integration.
- [ ] Contract tests at service boundaries? Consumer-driven contracts verify that provider changes do not break consumers.
- [ ] Load test coverage for critical paths? Performance regressions caught before production, not after.
- [ ] Feature flags testable? Both sides of every flag exercised in tests.
- [ ] Test data builders or factories used? No brittle test setup with hardcoded object literals duplicated across tests.
- [ ] Time and randomness injectable? Tests do not depend on the current clock or random output.

Reference: `rules/testing.md` (Philosophy, Mock Policy), `rules/code-style.md` (Immutability and Explicit Side Effects)

## 25. Cost Awareness

- [ ] Query cost understood? Expensive queries identified and optimized or cached.
- [ ] Compute right-sized? Instance types, Lambda memory, and container resources match actual usage, not guesses.
- [ ] Storage tiers used appropriately? Hot data on fast storage, cold data on archive (S3 IA, Glacier, equivalent).
- [ ] Batch vs real-time chosen deliberately? Real-time processing only when the use case requires it.
- [ ] Egress costs considered? Cross-region and cross-AZ traffic minimized. CDN for static assets.
- [ ] Cache ROI positive? The cost of the cache infrastructure is less than the cost of hitting the origin.
- [ ] Unused resources cleaned up? No orphaned volumes, snapshots, or idle load balancers accumulating charges.
- [ ] Cost alerts configured? Budget thresholds with notifications before spending spirals.

Reference: `rules/caching.md` (When to Cache), `rules/database.md` (Query Optimization)

## 26. Multi-Tenancy

- [ ] Tenant data isolation enforced? Row-level (shared DB, tenant_id column), schema-level (tenant per schema), or instance-level (tenant per DB)?
- [ ] Every query scoped to the tenant? No accidental cross-tenant data leakage through missing WHERE clauses or cache key collisions?
- [ ] Noisy neighbor prevention? One tenant's heavy usage cannot degrade performance for others (per-tenant rate limits, queue isolation, connection limits).
- [ ] Per-tenant resource limits defined? Storage quotas, API rate limits, concurrent connection caps.
- [ ] Tenant context propagated across service boundaries? Every downstream call carries the tenant identifier.
- [ ] Tenant-aware caching? Cache keys include tenant ID. Invalidation scoped to the affected tenant.
- [ ] Tenant onboarding and offboarding automated? Provisioning and deprovisioning do not require manual steps or code changes.
- [ ] Tenant-specific configuration supported? Feature flags, plan limits, and custom settings per tenant without code deploys.

Reference: `rules/security.md` (Access Control), `rules/database.md` (Access Pattern Design)

## 27. Migration Strategy

- [ ] Migration approach chosen? Strangler fig (gradual replacement), parallel run (old + new simultaneously), or big bang (with rollback plan)?
- [ ] Feature parity validated? Automated comparison between old and new system outputs for the same inputs.
- [ ] Data migration plan defined? Backfill strategy, data transformation, validation checksums, rollback path for data.
- [ ] Dark launching used for high-risk migrations? New path runs in shadow mode, results compared but not served to users.
- [ ] Cutover criteria explicit? What metrics must hold for the migration to be considered complete?
- [ ] Rollback during migration possible? Can traffic be routed back to the old system at any point without data loss?
- [ ] Migration progress observable? Percentage of traffic or data migrated, error rates on old vs new, latency comparison.
- [ ] Old system decommission planned? Timeline for shutting down the previous implementation after migration completes.

Reference: `rules/distributed-systems.md` (Zero-Downtime Deployments), `rules/database.md` (Safe Migrations)

## 28. Infrastructure as Code

- [ ] All infrastructure defined in code (Terraform, Pulumi, CloudFormation)? No manually provisioned resources?
- [ ] Provisioning idempotent? Running the same code twice produces the same infrastructure with no orphaned resources.
- [ ] State managed remotely with locking? No local state files for shared infrastructure.
- [ ] State isolation: separate state per environment and per service? One blast radius per state file.
- [ ] Immutable infrastructure: dependencies baked into images, instances replaced not patched?
- [ ] Environment parity: dev, staging, production from the same templates with environment-specific variables?
- [ ] Drift detection automated? Scheduled `plan` runs alert on manual changes to infrastructure.
- [ ] Modules versioned and pinned? No unintentional module updates during apply.
- [ ] Secrets not stored in IaC state or templates? Sensitive values from a vault or secrets manager.
- [ ] Plan reviewed before apply? No blind applies in production.

Reference: `rules/infrastructure.md` (Infrastructure as Code)

## 29. Networking and Service Discovery

- [ ] Service discovery mechanism chosen? DNS-based, client-side, server-side LB, or service mesh?
- [ ] Load balancing algorithm appropriate? Round-robin for stateless, least-connections for variable duration, consistent hashing for stateful.
- [ ] DNS TTL configured for failover requirements? Low enough for fast failover, not so low it hammers DNS.
- [ ] mTLS between services? Service-to-service traffic encrypted, not relying on network trust.
- [ ] Network policies / security groups follow least privilege? Default deny, explicit allow only for required traffic.
- [ ] VPC / subnet design isolates tiers? Public, private, and data subnets. Databases never in public subnets.
- [ ] CDN configured for static assets and cacheable responses? Cache invalidation strategy defined.
- [ ] Ingress and egress controls defined? Known set of external endpoints. Unexpected egress investigated.

Reference: `rules/infrastructure.md` (Networking and Service Discovery)

## 30. Container Orchestration

- [ ] Resource requests and limits set on every container? Requests based on actual usage, limits with headroom for peaks.
- [ ] Horizontal pod autoscaling configured? Metric (CPU, custom) chosen, min/max replicas set, cooldown tuned.
- [ ] Pod disruption budgets defined? Minimum available during voluntary disruptions (node drain, upgrade).
- [ ] Anti-affinity spreads replicas across nodes and availability zones? No single-point-of-failure co-location.
- [ ] Rolling update strategy tuned? maxUnavailable and maxSurge set for zero-downtime deploys.
- [ ] Health probes configured correctly? Liveness (restart on hang), readiness (remove from LB on unready), startup (slow-starting apps).
- [ ] Graceful shutdown: preStop hook, terminationGracePeriodSeconds long enough to drain connections?
- [ ] Resource quotas and limit ranges per namespace? One team cannot consume the entire cluster.
- [ ] Sidecar pattern used for cross-cutting concerns (mesh proxy, log collector, secrets injector)?

Reference: `rules/infrastructure.md` (Container Orchestration)

## 31. CI/CD Pipeline Design

- [ ] Pipeline stages ordered by feedback speed? Lint and static analysis first, deploy last.
- [ ] Artifact built once and promoted through environments? No rebuilding for production.
- [ ] Artifacts tagged with git SHA? No `latest` as a deployment strategy.
- [ ] Artifacts signed and verified before deployment?
- [ ] Environment promotion strategy explicit? Push-based, GitOps, or manual promotion?
- [ ] Progressive delivery configured? Canary with auto-promote/rollback based on metrics, feature flags, or dark launching.
- [ ] Pipeline security: secrets injected at runtime, not in repo or build logs? Least-privilege credentials per stage.
- [ ] DORA metrics tracked? Deployment frequency, lead time, change failure rate, MTTR.
- [ ] Rollback automated or one-click? Not a multi-step manual process.

Reference: `rules/infrastructure.md` (CI/CD Pipeline Design)

## 32. Cloud Architecture

- [ ] Multi-region strategy chosen? Single, active-passive, or active-active? Trade-offs (cost, complexity, RTO) understood.
- [ ] Blast radius contained at infrastructure level? Account/project isolation per environment and workload class.
- [ ] AZ-independent? Losing one availability zone does not degrade service. Resources spread across 2+ AZs.
- [ ] Cell-based architecture where appropriate? Independent cells by geography, customer segment, or shard.
- [ ] Service quotas known and monitored? Hitting a cloud provider limit in production is an outage.
- [ ] Auto-scaling validated? Scale-up and scale-down tested under load. Predictive scaling for known patterns.
- [ ] DDoS mitigation: WAF, rate limiting at edge, cloud-native shield on public load balancers?
- [ ] Data residency requirements met? Storage and processing regions comply with regulations (GDPR, LGPD).
- [ ] Cost allocation tags on all resources? Environment, team, service, cost center.
- [ ] Reserved capacity or savings plans for stable workloads? Spot/preemptible for fault-tolerant jobs.

Reference: `rules/infrastructure.md` (Cloud Architecture)
