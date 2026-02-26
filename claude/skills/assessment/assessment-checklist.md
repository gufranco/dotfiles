# Architecture Assessment Checklist

Use this checklist to audit an implementation for completeness. Only apply categories relevant to the system type. For each item, determine: PRESENT (implemented), PARTIAL (partially implemented), or MISSING (not addressed).

## 1. Idempotency and Deduplication

- [ ] Every write operation (API, event handler, database) safe to execute twice with the same input?
- [ ] Guard mechanism identified per layer?
  - API: `Idempotency-Key` header with cached response
  - Event handler: dedup by message ID before processing
  - Database: upsert, `ON CONFLICT DO NOTHING`, or conditional expression
  - State machine: check current state before transitioning
- [ ] Natural deduplication key identified (request ID, event ID, user+action+date)?
- [ ] Dedup state stored durably (database, not in-memory)?
- [ ] Dedup window (TTL) exceeds maximum retry/redelivery time?

Reference: `rules/code-style.md` (Data Safety), `rules/resilience.md` (Idempotency, Deduplication)

## 2. Atomicity and Transactions

- [ ] Related writes wrapped in a single transaction?
- [ ] Conditional writes used to prevent lost updates (optimistic locking, version field)?
- [ ] Transaction scope kept short (validation and I/O before, not inside)?
- [ ] Explicit rollback on failure, not relying on implicit cleanup?
- [ ] NoSQL: `TransactWriteItems` or conditional expressions for multi-item atomicity?
- [ ] Conditional write failures classified: conflict (retry with fresh read) vs duplicate (skip)?

Reference: `rules/database.md` (Transactions and Atomic Writes, Conditional Writes)

## 3. Error Classification

- [ ] Every `catch` classifies the error as transient or permanent?
- [ ] Transient errors (timeout, 429, 503, connection reset): logged as warn, retried with exponential backoff + jitter?
- [ ] Permanent errors (400, 404, validation, auth): logged as error, failed immediately, never retried?
- [ ] Ambiguous errors (500, unknown): retried up to 3 times, then treated as permanent?
- [ ] Classification propagated upstream so callers can make informed decisions?
- [ ] No bare catch blocks that log and rethrow without classification?

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

Reference: `rules/database.md` (Query Optimization, Time-Range Queries)

## 15. Observability

- [ ] Structured JSON logging with required fields (level, message, timestamp, requestId, service)?
- [ ] Log levels correct (error for failures, warn for handled-but-unexpected, info for business events)?
- [ ] Correlation ID (requestId) propagated across all service calls?
- [ ] No sensitive data logged (passwords, tokens, PII)?
- [ ] Health check endpoints present (liveness + readiness)?
- [ ] Metrics for request rate, error rate, latency (p50/p95/p99), saturation?
- [ ] Alerts on symptoms, not causes? Runbook links on every alert?

Reference: `rules/observability.md`
