# Database

## Schema Rules

- Always: `created_at`, `updated_at`
- Soft delete: `deleted_at` (nullable)
- Dates in UTC

## Query Optimization

- No `SELECT *`: specify columns
- No N+1: use include/eager loading
- Pagination for lists
- Indexes for WHERE, JOIN, ORDER BY

## Safe Migrations

| Operation | Approach |
|-----------|----------|
| Add column | Nullable first, backfill, constraint |
| Remove column | Stop reading, deploy, remove |
| Rename column | Add new, copy, migrate code, remove old |
| Add index | CONCURRENTLY |

## Naming

- Tables: `plural_snake_case`
- Columns: `singular_snake_case`
- FK: `<table>_id`
