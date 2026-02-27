# Borrow and Restore

## The Pattern

When a tool maintains global mutable state and you need to temporarily change it, follow this sequence:

1. **Read** the current state. Record it.
2. **Switch** to the required state.
3. **Work.** Do whatever you need to do.
4. **Restore** the original state. Always. Even if step 3 fails.

This is the CLI equivalent of a `try/finally` block. The restore step is not optional.

## When to Apply

Apply this pattern whenever you use a tool that has a single global "active context" that persists across commands. Changing it affects every subsequent command in the terminal, not just yours.

## Tools That Need This

| Tool | Global state | Read current | Switch | Restore |
|:-----|:-------------|:-------------|:-------|:--------|
| `gh` | Active GitHub account | `gh auth status` | `gh auth switch --user <login>` | Same switch back |
| `glab` | Active GitLab instance | `glab auth status` | Switch to target instance | Same switch back |
| Docker | Active context (daemon socket) | `docker context show` | `docker context use <name>` | Same use back |
| `kubectl` | Active cluster context | `kubectl config current-context` | `kubectl config use-context <name>` | Same use back |
| Terraform | Active workspace | `terraform workspace show` | `terraform workspace select <name>` | Same select back |
| `aws` | Active profile | `echo $AWS_PROFILE` | `export AWS_PROFILE=<name>` | Restore the original env var |
| `nvm` | Active Node.js version | `nvm current` | `nvm use <version>` | Same use back |

Not all of these will be relevant in every project. Only apply the pattern when the tool is actually used and multiple contexts exist.

## How to Detect the Correct Context

You need a way to determine which context the current project expects. In order of preference:

1. **Environment variable.** The project's `.env` or `.envrc` may set the expected context (e.g., `DOCKER_CONTEXT=colima-myproject`, `AWS_PROFILE=company-prod`, `KUBECONFIG=...`). Check these first.
2. **Project config file.** Some tools have project-level config: `.terraform/environment` for workspaces, `.nvmrc` for Node version, `.ruby-version` for Ruby.
3. **Convention.** If the project repo name or directory name matches a known context pattern, use it. This is the weakest signal, only use it as a last resort.
4. **Current state.** If none of the above exist, assume the current context is correct. Do not guess.

## Rules

- **Always restore.** The restore step runs on success and on failure. No exceptions.
- **Never restore to a state you didn't read.** Always record the original state before switching. Restoring to a hardcoded or assumed default is wrong.
- **Restore exactly once.** At the end of the operation, not in the middle, not multiple times.
- **Announce the switch.** When switching context, tell the user what you switched from and to. Silent switches are confusing.
- **Skip if unnecessary.** If the current context already matches the required one, do not switch and do not restore. No-op is always safe.
- **Do not switch if you cannot determine the target.** If there's no signal (env var, config file, convention) telling you which context to use, work with whatever is currently active. Guessing is worse than asking.

## Colima and Docker Contexts

Colima creates a Docker context for each profile. The naming convention is:

- Default profile: context name is `colima`
- Named profile: context name is `colima-<profile>`

When Colima is the runtime and multiple profiles exist, the Docker context determines which Colima VM receives the commands. Wrong context means commands hit the wrong set of containers.

Detection order for the expected Docker context:

1. `DOCKER_CONTEXT` env var in `.env` or `.envrc`.
2. `DOCKER_HOST` env var pointing to a specific Colima socket (e.g., `unix:///Users/<user>/.colima/<profile>/docker.sock`).
3. If neither exists, use the current `docker context show` value as-is.

Before switching Docker context, verify the target Colima profile is running with `colima list`. If the profile is stopped, suggest starting it with `colima start --profile <name>` or the user's custom function. Do not switch to a context whose backend is not running.

If Colima is not installed or the runtime is Docker Desktop or native, this section does not apply. Only handle Colima contexts when Colima is the detected runtime.
