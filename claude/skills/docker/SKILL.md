---
name: docker
description: Manage Docker containers, compose services, and the container runtime with Colima-aware orchestration.
---

Manage Docker containers, compose services, and the underlying container runtime. Handles both compose-based projects and standalone containers. Runtime-agnostic: works with Colima, Docker Desktop, or a native Docker daemon.

## When to use

- When starting, stopping, or restarting Docker services for development.
- When the Docker daemon is not reachable and you need to start the runtime.
- When you need to view container logs or debug a service.
- When you need to rebuild images after changing a Dockerfile or dependencies.
- When you need a shell inside a running container.
- When managing standalone database containers alongside compose projects.

## When NOT to use

- When Docker is not installed or the project does not use Docker.
- For production deployments. This skill is for local development only.

## Arguments

This skill accepts optional arguments after `/docker`:

- No arguments: show the status of all containers, compose services, and runtime info.
- `build [service]`: build images. Optionally target a single service.
- `up [service]`: start services in detached mode. Optionally target a single service.
- `down`: stop and remove compose containers.
- `restart [service]`: restart services. Optionally target a single service.
- `logs [service]`: show recent logs. Optionally target a single service or standalone container.
- `shell <service|container>`: open an interactive shell in a running container.
- `status`: show runtime, container, and compose status.

## Steps

1. **Verify Docker and check daemon.** Run `which docker` and `docker info` (suppress output):
   - If `docker` is not found, stop and tell the user.
   - If the daemon is NOT reachable, detect the container runtime and try to start it:
     - **Colima:** run `which colima`. If found, check `colima status`. If stopped, suggest `colima-start` (the user's custom function). Do not run `colima start` directly.
     - **Docker Desktop:** check if `/Applications/Docker.app` exists. If so, suggest opening it.
     - **Native daemon (Linux):** suggest `sudo systemctl start docker` or `sudo service docker start`.
   - If the daemon cannot be started, stop and tell the user.
2. **Detect runtime, compose, and containers.** Once the daemon is reachable, run these **in parallel**:
   - `docker context show` to detect the active runtime (colima, desktop-linux, default). If colima, also run `colima status` for VM info.
   - Look for compose files (`compose.yml`, `compose.yaml`, `docker-compose.yml`, `docker-compose.yaml`) and detect the compose command (`docker compose version` or `which docker-compose`).
   - `docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"` to list all containers including standalone ones.
   - If no compose file is found and the user requested a compose operation (up, down, build), say so and stop.
3. For **status** mode (default):
   - Show the runtime info (context, VM status if Colima).
   - If compose is available: run `<compose> ps` to show compose service status.
   - Run `docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"` to show all containers.
   - Mention `lazydocker` as available for an interactive TUI if the user wants a visual overview (check with `which lazydocker`).
4. For **build** mode:
   - If a service was specified: run `<compose> build <service>`.
   - Otherwise: run `<compose> build`.
   - Show build output and report success or failure.
   - Mention `dive <image>` for layer analysis if the user wants to inspect the image (check with `which dive`).
5. For **up** mode:
   - If a service was specified: run `<compose> up -d <service>`.
   - Otherwise: run `<compose> up -d`.
   - After starting, run `<compose> ps` to confirm services are running.
   - If any service is unhealthy or exited, show its logs with `<compose> logs --tail=30 <service>`.
6. For **down** mode:
   - Show currently running compose services first.
   - Ask the user for approval. This stops and removes containers, networks, and anonymous volumes.
   - Run `<compose> down`.
   - Confirm containers are stopped.
7. For **restart** mode:
   - If a service was specified: run `<compose> restart <service>`.
   - If the target is a standalone container: run `docker restart <container>`.
   - Otherwise: run `<compose> restart`.
   - After restarting, verify the service/container is healthy.
8. For **logs** mode:
   - If the target is a compose service: run `<compose> logs --tail=100 <service>`.
   - If the target is a standalone container: run `docker logs --tail=100 <container>`.
   - If no target: run `<compose> logs --tail=100` for compose, or list containers and ask which one.
   - If the user needs to follow logs, mention `docker compose logs -f <service>` or `docker logs -f <container>`.
9. For **shell** mode:
    - A service or container name is required. If not provided, list running containers and ask which one.
    - If compose: find the container ID with `<compose> ps -q <service>`.
    - If standalone: use the container name directly.
    - If the container is not running, say so and stop.
    - Try bash first: run `docker exec -it <container> bash`.
    - If bash is not available (exit code 126 or 127), fall back to `docker exec -it <container> sh`.

## Standalone container conventions

The user has shell functions for managing standalone database and utility containers. These follow the pattern `<service>-<action>`:

- `<service>-init`: Create and start a new container with volumes, ports, and health checks.
- `<service>-start`: Start an existing stopped container.
- `<service>-stop`: Stop a running container.
- `<service>-purge`: Stop, remove the container, and delete its data directory.
- `<service>-terminal`: Exec into the container with a shell.

Known services: `mongo`, `postgres`, `redis`, `valkey`, `redict`, `ubuntu`.

When the user asks to manage one of these services, prefer suggesting the shell functions instead of raw docker commands, since the functions handle volume mounts, health checks, and data directories consistently.

## Rules

- Always check if the Docker daemon is reachable before running container commands.
- If the daemon is not reachable and Colima is detected, suggest the user's `colima-start` function. Do not run `colima start` directly.
- Always detect the compose file and command. Never assume `docker-compose` or `docker compose`.
- Always distinguish between compose services and standalone containers.
- Always ask for user approval before running `down`. It destroys containers and anonymous volumes.
- Never run `docker system prune`, `docker volume prune`, or similar destructive cleanup commands. The user has `docker-purge` and `colima-purge` for that.
- Never build or start containers in production mode unless the user explicitly asks.
- If no compose file exists, work with standalone containers (ps, logs, exec, restart).
- Never expose or forward ports that are not already defined in the compose file or the container's init function.

## Related skills

- `/logs` - For more advanced log analysis and filtering.
- `/env` - Compose services often depend on environment variables.
- `/db` - Database containers can be managed via shell functions.
