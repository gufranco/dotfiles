# API Design

## REST Conventions

- Resources are nouns, plural: `/users`, `/orders`, `/invoices`
- Actions on resources use HTTP methods: GET reads, POST creates, PUT replaces, PATCH updates, DELETE removes
- Nested resources for ownership: `/users/:id/orders`
- Max two levels of nesting. Beyond that, promote to a top-level resource with a filter
- Use kebab-case for URLs: `/order-items`, not `/orderItems`
- Use camelCase for JSON fields: `createdAt`, not `created_at`

## Status Codes

| Code | When to use |
|------|-------------|
| 200 | Success with body |
| 201 | Resource created. Include `Location` header |
| 204 | Success with no body (DELETE, PUT with no return) |
| 400 | Invalid input, malformed request |
| 401 | Missing or invalid authentication |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state violation) |
| 422 | Validation error (valid JSON, invalid business rules) |
| 429 | Rate limit exceeded. Include `Retry-After` header |
| 500 | Unexpected server error |

## Error Response Format

Every error returns a consistent shape:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "requestId": "req_abc123",
    "details": [
      { "field": "email", "message": "must be a valid email address" }
    ]
  }
}
```

- `code`: machine-readable, UPPER_SNAKE_CASE
- `message`: safe for end users in production, no internal paths or stack traces
- `requestId`: correlate with server logs
- `details`: optional, for field-level validation errors

## Pagination

All list endpoints must be paginated. Use cursor-based by default, offset-based only when random page access is required.

**Cursor-based:**
```
GET /users?cursor=eyJpZCI6MTAwfQ&limit=20
```

Response includes:
```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTIwfQ",
    "hasMore": true
  }
}
```

**Offset-based (when needed):**
```
GET /users?page=2&pageSize=20
```

- Default page size: 20
- Maximum page size: 100
- Always return total count for offset-based

## Filtering and Sorting

- Filter with query params: `GET /users?status=active&role=admin`
- Sort with a `sort` param: `GET /users?sort=-createdAt,name` (prefix `-` for descending)
- Document all supported filter and sort fields

## Versioning

- Use URL path versioning: `/v1/users`
- Major version only. Minor changes are backward compatible
- Support at most two major versions simultaneously

### Deprecation Lifecycle

Deprecation is a process, not an event. Follow this sequence:

1. **Announce**: add `Deprecation: true` and `Sunset: <date>` response headers. Include a `Link` header pointing to the replacement. Set the sunset date at least 6 months out for external APIs
2. **Document**: update API docs, changelog, and migration guide. Explain what to use instead and how to migrate
3. **Monitor**: track usage of the deprecated endpoint. Do not remove it while it still receives meaningful traffic
4. **Warn**: return a `Warning` header or a `deprecated` field in the response body to make it visible to consumers who don't check headers
5. **Remove**: only after traffic drops to near-zero or the sunset date passes. Return 410 Gone, not 404, so consumers know it was intentional

## Idempotency

- GET, PUT, DELETE are naturally idempotent
- POST endpoints that create resources must support an `Idempotency-Key` header
- Store the key server-side with the response for the TTL window (default: 24h)
- Return the cached response on duplicate requests, do not re-execute

## Rate Limiting

Include these headers on every response:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1620000000
Retry-After: 30
```

- `Reset` is a Unix timestamp
- `Retry-After` only on 429 responses, in seconds

## Request and Response Conventions

- Accept and return `application/json` by default
- Always set `Content-Type` header
- Use ISO 8601 for dates: `2024-01-15T10:30:00Z`
- Use UTC for all timestamps
- Wrap collections in a `data` field: `{ "data": [...] }`
- Single resources at the top level: `{ "id": 1, "name": "..." }`
- Include `requestId` in every response for traceability

## HATEOAS (when applicable)

For APIs with complex state transitions, include links:

```json
{
  "id": 1,
  "status": "pending",
  "links": {
    "approve": { "method": "POST", "href": "/orders/1/approve" },
    "cancel": { "method": "POST", "href": "/orders/1/cancel" }
  }
}
```

Only include links for actions available in the current state.

## Bulk Operations

- Use a dedicated endpoint: `POST /users/bulk`
- Accept an array of operations
- Return per-item results with individual status codes
- Never let one failure abort the entire batch
