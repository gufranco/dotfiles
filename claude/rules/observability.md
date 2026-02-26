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

## Alerting Conventions

- Alert on symptoms, not causes. "Error rate > 1%" not "CPU > 80%"
- Every alert must have a runbook link
- Use severity levels: `critical` (pages immediately), `warning` (notify channel), `info` (dashboard only)
- Include in alert: what is happening, which service, since when, link to dashboard
