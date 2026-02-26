# Caching

## When to Cache

Cache when: reads far outnumber writes, data tolerates staleness, and the origin is slow or expensive.

Do not cache when: data must be real-time, cache invalidation is harder than the performance gain, or the dataset fits in a single fast query.

## Strategies

| Strategy | How it works | When to use |
|----------|-------------|-------------|
| Cache-aside (lazy) | Read: check cache, miss, read DB, write cache. Write: update DB, invalidate cache | Default choice. Works for most read-heavy workloads |
| Write-through | Write: update cache + DB together. Read: always from cache | When reads must always reflect latest writes. Adds write latency |
| Write-behind (write-back) | Write: update cache, async flush to DB | High write throughput. Risk of data loss if cache crashes before flush |
| Read-through | Cache itself fetches from DB on miss | When the cache layer manages its own loading (CDN, Varnish) |

**Default rule**: start with cache-aside. Move to write-through only when you need read-your-writes consistency through the cache layer.

## Invalidation

| Method | When to use | Trade-off |
|--------|-------------|-----------|
| TTL expiration | Data tolerates bounded staleness | Simple, but stale reads until TTL expires |
| Explicit invalidation | On every write to the source | Consistent, but requires knowing all cache keys affected by a write |
| Event-driven invalidation | Source publishes change events, consumers invalidate | Decoupled, but adds an eventual consistency window |
| Versioned keys | Include a version in the cache key (`user:42:v3`) | Simple for immutable snapshots, useless for mutable data |

Never rely on "it will expire eventually" for data that users expect to see updated immediately after a write.

## Thundering Herd / Cache Stampede

When a popular cache key expires, hundreds of concurrent requests miss simultaneously and hit the origin.

**Prevention:**

- **Lock-based recomputation**: first request acquires a lock and recomputes, others wait or serve stale data
- **Stale-while-revalidate**: serve the expired value while one background request refreshes
- **Probabilistic early expiration**: each request has a small random chance of refreshing before TTL, spreading the load
- **TTL jitter**: never set the same TTL on all keys. Add `TTL + random(0, TTL * 0.1)` to prevent synchronized expiration

## Cache Warming

Cold caches after deploy or restart cause a load spike on the origin.

- Pre-load hot keys on startup from a known list or recent access log
- Use canary deploys: route a small percentage of traffic first so the cache fills gradually
- If pre-loading is not feasible, rate-limit cache-miss paths to protect the origin during warmup

## Sizing and Eviction

- Set a max memory limit. Never let the cache grow unbounded
- Default eviction: LRU. Use LFU when access patterns have a stable hot set
- Monitor hit rate. Below 80% means the cache is too small or the workload is not cache-friendly
- Store only what you need: serialized projections, not full ORM objects
