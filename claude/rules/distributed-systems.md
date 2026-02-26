# Distributed Systems

## Monolith vs Microservices

This is an architecture decision, not a religious one. Choose based on the constraints.

| Factor | Monolith | Microservices |
|--------|----------|---------------|
| Team size | Small team (< 10 devs). One team can own the whole codebase | Multiple teams need independent deploy cycles |
| Domain complexity | Well-understood domain, shared data model | Distinct bounded contexts with different data ownership |
| Data consistency | Transactions across entities are easy | Every cross-service operation needs saga, outbox, or eventual consistency |
| Deployment | One artifact, simple | Many artifacts, requires mature CI/CD, orchestration, observability |
| Latency | In-process calls are free | Network calls add latency and failure modes |
| Debugging | Stack trace shows the full picture | Distributed tracing required just to understand a request |

**Default rule**: start with a modular monolith. Extract services only when you have a concrete reason: independent scaling, different deployment cadence, different team ownership, or a fundamentally different technology need. "It might need to scale" is not a reason.

When you do extract a service:
- The boundary must align with a domain boundary, not a technical layer
- The service must own its data. No shared databases
- Every cross-service call is a potential failure. Apply timeouts, retries, circuit breakers from the start
- You are trading code complexity for operational complexity. Be sure the trade is worth it

## Consistency Models

Every read in a distributed system returns data with some staleness guarantee. Know which one you are choosing:

| Model | Guarantee | Cost | When to use |
|-------|-----------|------|-------------|
| Strong | Read always sees the latest write | Higher latency, lower availability | Financial transactions, inventory counts, auth state |
| Eventual | Read will eventually see the latest write, may be stale now | Lower latency, higher availability | Feeds, analytics, search indexes, recommendations |
| Read-your-writes | A client always sees its own writes, may not see others' | Medium | User profile updates, form submissions, settings |
| Causal | If A caused B, everyone sees A before B | Medium | Comment threads, collaborative editing |

**Default rule**: choose the weakest model your use case tolerates. Strong consistency everywhere kills scalability.

### Read-Your-Writes in Practice

After a user writes data, they must see it on the next read:

| Pattern | How | Trade-off |
|---------|-----|-----------|
| Read from primary after write | Route reads to the write node for N seconds after a mutation | Simple, increases primary load |
| Version token | Write returns a version. Client sends it on next read. If the replica is behind, redirect to primary | Precise, requires client cooperation |
| Client-side optimistic update | Update the UI immediately, reconcile when the server confirms | Best UX, needs conflict handling on failure |

Avoid session stickiness for read-your-writes. It is fragile and breaks on rebalancing.

## Saga Pattern

When a business transaction spans multiple services and a distributed transaction (2PC) is not feasible.

### Orchestration vs Choreography

| Approach | How it works | When to use |
|----------|-------------|-------------|
| Orchestration | A central coordinator tells each service what to do and handles failures | Complex flows with many steps, need visibility into overall state |
| Choreography | Each service listens for events and reacts independently | Simple flows with 2-3 steps, services are truly independent |

**Default rule**: use orchestration when the flow has more than 3 steps or when you need to reason about the saga's state as a whole. Choreography becomes impossible to debug at scale.

### Compensating Actions

Every saga step that produces a side effect must have a compensating action that undoes it:

| Step | Compensation |
|------|-------------|
| Create order | Cancel order |
| Reserve inventory | Release inventory |
| Charge payment | Refund payment |
| Send notification | Send correction (cannot always undo) |

- Compensating actions must be idempotent. A compensation may itself be retried.
- For actions that cannot be undone, like emails or shipments, use a confirmation step: tentative action first, confirm or cancel after the saga completes.

### Implementation

- Persist saga state: each step's outcome must be durable so the saga can resume after a crash
- Set a timeout for the entire saga. If not completed within the window, trigger compensation
- Log every step transition for debugging and auditing

## Outbox Pattern

Solves the dual-write problem: how to update a database AND publish an event reliably, without 2PC.

### The Problem

```
// BROKEN: if the app crashes between these two lines, the event is lost
await db.save(order);
await eventBus.publish("order.created", order);  // may never execute
```

### The Solution

1. Write the business data AND the event to the **same database** in a **single transaction**
2. A separate process reads the outbox table and publishes events to the broker
3. Mark events as published after successful delivery

```sql
BEGIN;
  INSERT INTO orders (id, ...) VALUES (...);
  INSERT INTO outbox (id, event_type, payload, created_at, published_at)
    VALUES (gen_id(), 'order.created', '{"orderId": ...}', now(), NULL);
COMMIT;
```

### Delivery Mechanisms

| Mechanism | How | Trade-off |
|-----------|-----|-----------|
| Polling publisher | Background job queries outbox for unpublished rows on an interval | Simple, slight delay, DB load at scale |
| CDC (Change Data Capture) | Database log (WAL/binlog) streams changes to the event bus | Lower latency, no polling load, more infrastructure |
| Transaction log tailing | Read the database's write-ahead log directly | Lowest latency, tightest coupling to DB internals |

**Default rule**: start with polling publisher. Move to CDC when polling frequency or DB load becomes a problem.

## Distributed Locking

When multiple instances must coordinate: scheduled jobs, leader election, exclusive resource access.

### Requirements for a Correct Lock

1. **Mutual exclusion**: only one holder at a time
2. **Deadlock freedom**: locks must expire even if the holder crashes
3. **Fencing**: a slow holder that outlives its lease must not corrupt state after a new holder takes over

### Patterns

| Pattern | Implementation | When to use |
|---------|---------------|-------------|
| Redis lock | `SET key value NX PX ttl` + fencing token | Short-lived locks, seconds to minutes, across application instances |
| Database advisory lock | `pg_advisory_lock(id)` or `GET_LOCK(name, timeout)` | Already have a database, don't want Redis dependency |
| ZooKeeper / etcd lease | Ephemeral node or lease-based key | Leader election, long-lived coordination |

### Fencing Tokens

A lock without fencing is unsafe. The holder may pause due to GC, swap, or network issues, outlive the lease, and write stale data while a new holder is already active.

1. Each lock acquisition returns a monotonically increasing token
2. Every write operation includes the token
3. The storage layer rejects writes with a token older than the latest it has seen

Without fencing, a lock only gives "best effort" mutual exclusion.

## Event Ordering and Delivery Guarantees

### Delivery Levels

| Level | Guarantee | How | When to use |
|-------|-----------|-----|-------------|
| At-most-once | May be lost, never duplicated | Fire and forget, no ack | Metrics, logs, non-critical analytics |
| At-least-once | Delivered one or more times | Ack after processing, redeliver on timeout | Default. Requires idempotent consumers |
| Exactly-once | Processed exactly one time | At-least-once delivery + idempotent/deduplicated processing | Financial, inventory. Achieved at application level, not transport |

**Exactly-once is not a transport guarantee.** It is at-least-once delivery combined with application-level deduplication. See `rules/resilience.md` for dedup patterns.

### Ordering Scope

| Scope | How to achieve | Cost |
|-------|---------------|------|
| Per-entity | Partition by entity ID (Kafka partition key, SQS FIFO group ID) | Limited parallelism per entity |
| Global | Single partition or single FIFO group | No parallelism, throughput bottleneck |
| Causal | Vector clock or sequence number, consumer buffers and reorders | Complex, extra storage |
| None needed | Standard queues with parallel consumers | Maximum throughput |

**Default rule**: per-entity ordering covers most use cases. Global ordering kills throughput. If you think you need it, reconsider the design.

### Handling Out-of-Order Events

- **Version check**: each event carries a version. Consumer rejects events older than current state
- **Last-write-wins**: use the event's timestamp to resolve conflicts. Only works with synchronized clocks (NTP)
- **Buffer and reorder**: hold events in a short window, sort before processing. Adds latency equal to the buffer

## Schema Evolution

Events and messages outlive the code that created them. Consumers and producers deploy independently.

### Compatibility Rules

| Type | Rule | Example |
|------|------|---------|
| Backward compatible | New schema reads old data | Adding an optional field |
| Forward compatible | Old schema reads new data | Old consumer ignores unknown fields |
| Full compatible | Both directions | Adding optional fields, never removing or renaming |

**Default rule**: all changes must be both backward and forward compatible.

- **Add** optional fields freely
- **Never remove** a field in one step. Stop reading it in all consumers first, then remove in a later version
- **Never rename** a field. Add the new name, dual-write both, migrate all readers, drop the old name
- **Never change** a field's type. Add a new field with the new type instead

### Versioning

- Include a `schemaVersion` field in every event and message
- Consumers must handle at least the current and previous version
- When a breaking change is unavoidable, publish on a new topic and migrate consumers

## Zero-Downtime Deployments

Every deployment to production should be invisible to users. No maintenance windows, no "please try again later."

### Strategies

| Strategy | How it works | When to use |
|----------|-------------|-------------|
| Rolling update | Replace instances one at a time. Old and new versions run simultaneously during the rollout | Default for stateless services. Requires backward-compatible changes |
| Blue/green | Run two identical environments. Switch traffic from blue (old) to green (new) atomically | When you need instant rollback. Higher infrastructure cost |
| Canary | Route a small percentage of traffic (1-5%) to the new version. Monitor, then gradually increase | When you want to validate in production before full rollout |
| Feature flags | Deploy code to all instances but gate new behavior behind a flag. Enable gradually | When the risk is in the feature logic, not the deployment itself |

**Default rule**: rolling update for most services. Add canary when the change is high-risk. Use feature flags for user-facing behavior changes.

### Requirements for Zero-Downtime

- **Backward-compatible changes**: old and new versions will run simultaneously during any deployment. Database schema, API contracts, and message formats must work for both
- **Health checks**: the orchestrator must know when an instance is ready to receive traffic. No traffic until readiness probe passes
- **Graceful shutdown**: on termination, stop accepting new requests, finish in-flight requests within a timeout, then exit
- **Database migrations**: run before the deployment, not during. The old code must work with the new schema. See `rules/database.md` for safe migration patterns
