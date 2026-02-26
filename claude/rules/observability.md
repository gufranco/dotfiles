# Observability

## Structured Logging

Always log as JSON. One event per line.

Required fields on every log entry:

```json
{
  "level": "info",
  "message": "order created",
  "timestamp": "2024-01-15T10:30:00.123Z",
  "requestId": "req_abc123",
  "service": "order-service"
}
```

Optional context fields:

```json
{
  "userId": "usr_456",
  "orderId": "ord_789",
  "durationMs": 42,
  "error": { "code": "DB_TIMEOUT", "message": "connection timed out after 5000ms" }
}
```

## Log Levels

| Level | When to use |
|-------|-------------|
| `error` | Operation failed, requires attention. Include error code, message, and stack |
| `warn` | Handled but unexpected. Degraded state, fallback used, retry triggered |
| `info` | Business events: request received, order created, payment processed |
| `debug` | Developer details: query params, cache hit/miss, function entry/exit |

- Default to `info` in production, `debug` in development
- Configure via `LOG_LEVEL` env var
- Never log at `debug` level in hot paths in production

## Sensitive Data

Never log:

- Passwords, tokens, API keys, secrets
- Full credit card numbers, SSNs, or government IDs
- Request/response bodies containing PII without masking

Mask patterns: `password`, `token`, `secret`, `authorization`, `credential`, `key`, `jwt`, `apikey`, `access_token`, `refresh_token`

When logging request bodies, redact sensitive fields:
```json
{ "email": "user@example.com", "password": "[REDACTED]" }
```

## Correlation IDs

- Generate a unique `requestId` at the API gateway or first service
- Propagate via `X-Request-Id` header across all service calls
- Include `requestId` in every log entry, error response, and metric tag
- For async workflows, also propagate a `correlationId` that links the entire chain

## Metrics

### Naming Convention

Use dot-separated lowercase: `service.module.metric_name`

```
http.request.duration_ms
http.request.count
db.query.duration_ms
db.pool.active_connections
cache.hit_count
cache.miss_count
queue.message.published
queue.message.consumed
queue.message.failed
```

### Required Metrics

Every service must expose:

- **Request rate**: requests per second by endpoint and status code
- **Error rate**: 4xx and 5xx counts by endpoint
- **Latency**: p50, p95, p99 by endpoint
- **Saturation**: connection pool usage, queue depth, memory usage

### Labels and Tags

- Keep cardinality low. Never use user IDs, request IDs, or timestamps as labels
- Standard labels: `service`, `environment`, `method`, `path`, `status_code`
- Use bucketed values for high-cardinality dimensions

## Health Checks

Every service must expose:

### Liveness: `GET /health/live`

Returns 200 if the process is running. No dependency checks.

```json
{ "status": "ok" }
```

### Readiness: `GET /health/ready`

Returns 200 only when all dependencies are reachable.

```json
{
  "status": "ok",
  "checks": {
    "database": { "status": "ok", "latencyMs": 3 },
    "redis": { "status": "ok", "latencyMs": 1 },
    "external-api": { "status": "degraded", "latencyMs": 1200 }
  }
}
```

- Return 503 if any critical dependency is down
- Include latency for each dependency
- Use `ok`, `degraded`, `down` as status values

## Distributed Tracing

- Use W3C Trace Context headers: `traceparent`, `tracestate`
- Create a span for every inbound request, outbound HTTP call, database query, and queue publish/consume
- Span names should be descriptive: `POST /users`, `db.users.findById`, `queue.orders.publish`
- Add relevant attributes to spans: `http.method`, `http.status_code`, `db.statement`, `db.system`

## SLIs, SLOs, and SLAs

Define reliability targets before building monitoring. Without them, alerts are arbitrary and incident response has no priority framework.

| Term | What it is | Who defines it | Example |
|------|-----------|----------------|---------|
| SLI (Service Level Indicator) | A measurable signal of service health | Engineering | Request latency p99, error rate, availability percentage |
| SLO (Service Level Objective) | A target value for an SLI | Engineering + Product | p99 latency < 200ms, availability > 99.9% per rolling 30 days |
| SLA (Service Level Agreement) | A contractual promise to customers with consequences | Business | 99.95% uptime or credits issued |

**Rules:**

- Define SLIs first. Common: availability, latency (p50, p95, p99), error rate, throughput
- SLOs must be based on SLIs, not gut feeling. Measure first, then set targets
- SLOs should be slightly stricter than SLAs. If the SLA is 99.95%, the SLO might be 99.97%
- **Error budget** = 100% minus SLO. A 99.9% SLO means 0.1% error budget, roughly 43 minutes of downtime per month. When the budget is spent, prioritize reliability over features

## Alerting Conventions

- Alert on symptoms, not causes. "Error rate > 1%" not "CPU > 80%"
- Tie alerts to SLO violations: "error budget burn rate exceeds 10x" is more actionable than a static threshold
- Every alert must have a runbook link
- Use severity levels: `critical` (pages immediately), `warning` (notify channel), `info` (dashboard only)
- Include in alert: what is happening, which service, since when, link to dashboard
- Review alert signal-to-noise ratio monthly. If an alert fires without requiring action, tune or remove it

## Incident Response

When production breaks:

1. **Detect**: SLO breach triggers alert. Monitoring catches it before users do
2. **Triage**: classify severity based on SLO impact. How much error budget is being burned?
3. **Mitigate**: restore service first. Rollback, feature flag, redirect traffic. Root cause analysis comes later
4. **Communicate**: update status page and stakeholders. Set expectations for resolution
5. **Resolve**: fix the underlying issue after service is restored
6. **Postmortem**: blameless review within 48 hours. Document what happened, timeline, root cause, what went well, what didn't, and action items with owners

### Postmortem Template

- **Summary**: one paragraph of what happened
- **Impact**: duration, affected users, error budget consumed
- **Timeline**: timestamped sequence of events from detection to resolution
- **Root cause**: the actual cause, not the trigger
- **Contributing factors**: what made detection or recovery slower
- **Action items**: concrete tasks with owners and due dates. Not "be more careful"
