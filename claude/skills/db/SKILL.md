---
name: db
description: Manage database migrations, standalone containers, and data operations with ORM and shell function awareness.
---

Manage database migrations using the project's ORM or migration tool. Check migration status, run or rollback migrations, create new migration files, and seed data. Aware of standalone database containers managed via shell functions.

## When to use

- When setting up a project and need to run initial migrations.
- When you created new migration files and need to apply them.
- When you need to check which migrations have been applied.
- When you need to rollback a bad migration or reset the database.
- When you need to start or check the status of a database container.

## When NOT to use

- When the project does not use a database or migration tool.
- For production database operations. Those should go through CI/CD or runbooks.

## Arguments

This skill accepts optional arguments after `/db`:

- No arguments: show migration status and database container status.
- `migrate`: run all pending migrations.
- `rollback`: rollback the last migration batch.
- `create <name>` (e.g. `create add-users-table`): create a new migration file.
- `seed`: run database seeders.
- `reset`: rollback all migrations and re-run them. Destructive.
- `start`: start the database container if not running.
- `stop`: stop the database container.
- `terminal`: open a database shell (psql, mongosh, redis-cli, etc.).

## Steps

1. **Detect database setup, migration tool, and package manager.** Run these **in parallel**:
   - Check for standalone database containers: `docker ps -a --format "{{.Names}}"` and look for `mongo`, `postgres`, `redis`, `valkey`, `redict`. If Docker is not reachable, check `which colima` and suggest `colima-start` if stopped.
   - Detect the migration tool by checking project files and dependencies:
     - `prisma/schema.prisma` or `prisma` in deps: **Prisma**.
     - `knexfile.*` or `knex` in deps: **Knex**.
     - `sequelize` in deps and `.sequelizerc` or `config/config.json`: **Sequelize**.
     - `typeorm` in deps or `ormconfig.*` or `data-source.*`: **TypeORM**.
     - `drizzle.config.*` or `drizzle-kit` in deps: **Drizzle**.
     - `alembic.ini` or `alembic/` directory: **Alembic** (Python).
     - `goose` in go deps or `db/migrations/` with `.sql` files: **Goose**.
     - `diesel.toml` or `diesel` in Cargo.toml: **Diesel** (Rust).
     - If none found and the user asked for migration operations, ask which tool they use.
   - Detect the package manager (for Node.js tools) using lockfile detection.
2. Verify the tool is available:
   - For Prisma: check `npx prisma --version` or equivalent with the detected package manager.
   - For CLI tools (goose, alembic, diesel): verify with `which <tool>`.
   - If not available, stop and tell the user.
3. For **status** mode (default):
   - First, show database container status if applicable:
     - Check `docker ps -a --filter "name=<db>" --format "{{.Names}}\t{{.Status}}"` for the relevant database.
     - If the container is not running, mention it and suggest the user's shell function (e.g. `postgres-start`).
   - Then show migration status:
     - Prisma: run `<pm> prisma migrate status`.
     - Knex: run `<pm> knex migrate:status`.
     - Sequelize: run `<pm> sequelize-cli db:migrate:status`.
     - TypeORM: run `<pm> typeorm migration:show`.
     - Drizzle: run `<pm> drizzle-kit status`.
     - Alembic: run `alembic current` and `alembic history`.
     - Goose: run `goose status`.
     - Diesel: run `diesel migration list`.
   - Show which migrations are applied and which are pending.
4. For **start** mode:
   - Determine which database the project uses from the ORM config or `DATABASE_URL` env var.
   - Suggest the appropriate shell function:
     - PostgreSQL: `postgres-start` (or `postgres-init` if the container doesn't exist yet).
     - MongoDB: `mongo-start` (or `mongo-init`).
     - Redis: `redis-start` (or `redis-init`).
     - Valkey: `valkey-start` (or `valkey-init`).
   - If the container exists but is stopped, suggest `<service>-start`.
   - If the container doesn't exist at all, suggest `<service>-init` which creates it with proper volumes, ports, and health checks.
5. For **stop** mode:
   - Suggest the appropriate shell function (e.g. `postgres-stop`).
6. For **terminal** mode:
   - Suggest the user's shell function (e.g. `postgres-terminal`, `mongo-terminal`).
   - Alternatively, for direct database client access:
     - PostgreSQL: `docker exec -it postgres psql -U postgres`.
     - MongoDB: `docker exec -it mongo mongosh -u mongo -p mongo`.
     - Redis: `docker exec -it redis redis-cli`.
7. For **migrate** mode:
   - Check if the database container is running. If not, suggest starting it first.
   - Show pending migrations first (run status).
   - If no pending migrations, say so and stop.
   - Prisma: run `<pm> prisma migrate deploy`.
   - Knex: run `<pm> knex migrate:latest`.
   - Sequelize: run `<pm> sequelize-cli db:migrate`.
   - TypeORM: run `<pm> typeorm migration:run`.
   - Drizzle: run `<pm> drizzle-kit push` or `drizzle-kit migrate`.
   - Alembic: run `alembic upgrade head`.
   - Goose: run `goose up`.
   - Diesel: run `diesel migration run`.
   - Show the result and run status again to confirm.
8. For **rollback** mode:
    - Show the current status first.
    - Warn the user that rollback will undo the last migration batch and may cause data loss.
    - Ask for explicit approval.
    - Prisma: Prisma does not support rollback directly. Show `prisma migrate resolve` instructions.
    - Knex: run `<pm> knex migrate:rollback`.
    - Sequelize: run `<pm> sequelize-cli db:migrate:undo`.
    - TypeORM: run `<pm> typeorm migration:revert`.
    - Alembic: run `alembic downgrade -1`.
    - Goose: run `goose down`.
    - Diesel: run `diesel migration revert`.
    - Show the result and run status again.
9. For **create** mode:
    - A migration name is required. If not provided, ask the user.
    - Prisma: run `<pm> prisma migrate dev --name <name> --create-only`.
    - Knex: run `<pm> knex migrate:make <name>`.
    - Sequelize: run `<pm> sequelize-cli migration:generate --name <name>`.
    - TypeORM: run `<pm> typeorm migration:create <name>`.
    - Drizzle: create a new file in the migrations directory following existing naming patterns.
    - Alembic: run `alembic revision -m "<name>"`.
    - Goose: run `goose create <name> sql`.
    - Diesel: run `diesel migration generate <name>`.
    - Show the created file path.
10. For **seed** mode:
    - Prisma: run `<pm> prisma db seed`.
    - Knex: run `<pm> knex seed:run`.
    - Sequelize: run `<pm> sequelize-cli db:seed:all`.
    - TypeORM: look for a seed script in `package.json`.
    - Alembic: look for a seed script or suggest creating one.
    - If no seed command exists, say so and stop.
11. For **reset** mode:
    - Warn the user that this will drop all data and re-run all migrations.
    - Ask for explicit approval.
    - Prisma: run `<pm> prisma migrate reset`.
    - Knex: run `<pm> knex migrate:rollback --all` then `<pm> knex migrate:latest`.
    - Sequelize: run `<pm> sequelize-cli db:migrate:undo:all` then `<pm> sequelize-cli db:migrate`.
    - TypeORM: run `<pm> typeorm schema:drop` then `<pm> typeorm migration:run`.
    - Alembic: run `alembic downgrade base` then `alembic upgrade head`.
    - Goose: run `goose reset` then `goose up`.
    - Diesel: run `diesel migration redo`.
    - Run status after to confirm clean state.

## Standalone container details

The user manages database containers via shell functions defined in `~/.dotfiles/zsh/infrastructure`. These containers use:

- **Volumes:** named Docker volumes for data persistence and bind mounts to `~/Docker/<Service>/` for file exchange.
- **Ports:** bound to 127.0.0.1 only (postgres: 5432, mongo: 27017, redis: 6379, valkey: 7000).
- **Health checks:** built-in health check commands (pg_isready, mongosh ping, redis-cli ping).
- **Credentials:** postgres:postgres for PostgreSQL, mongo:mongo for MongoDB. Redis has no auth.

When suggesting shell functions, prefer them over raw docker commands because they handle all the configuration consistently.

## Rules

- Always detect the migration tool from project config and dependencies. Never assume.
- Always check if the database container is running before migration operations.
- If the database container is not running, suggest the user's shell function to start it. Do not run `docker start` directly.
- Always show migration status before running migrate, rollback, or reset.
- Always require explicit user approval for rollback and reset. These can cause data loss.
- Never run migrations against a production database. If `DATABASE_URL` or similar points to production, warn the user.
- Never modify existing migration files. Only create new ones.
- If the migration tool is not installed, stop and tell the user how to install it.
- If `create` is used without a name, ask the user for one. Do not generate names.

## Related skills

- `/test` - Run tests after migrations to verify schema changes work correctly.
- `/commit` - Commit new migration files.
- `/env` - Database connection strings are usually in environment variables.
- `/docker` - Manage the container runtime and database containers.
