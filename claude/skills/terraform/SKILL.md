---
name: terraform
description: Run Terraform or OpenTofu workflows with safety checks, plan review, and approval gates.
---

Run Terraform or OpenTofu commands with built-in safety checks. Always validates before planning, always plans before applying, and always requires explicit approval for state-changing operations. Works with direnv for per-directory variable management.

## When to use

- When initializing, planning, or applying Terraform/OpenTofu infrastructure changes.
- When you want to format or validate configuration files.
- When reviewing what changes an apply would make.

## When NOT to use

- When the project has no `.tf` files.
- For production applies. Those should go through CI/CD pipelines.

## Arguments

This skill accepts optional arguments after `/terraform`:

- No arguments: run `validate` then `plan`.
- `init`: initialize the working directory.
- `fmt`: format all `.tf` files.
- `validate`: validate configuration.
- `plan`: validate then plan (same as no args).
- `apply`: validate, plan, show changes, and apply after approval.
- `destroy`: plan destroy, show what would be removed, and destroy after approval.
- A directory path (e.g. `infra/staging`): use that as the working directory.

## Steps

1. **Detect the IaC tool and find the working directory.** Run these **in parallel**:
   - `which terraform` and `which tofu` to find which tool is available. Prefer `terraform`, fall back to `tofu`. If neither is found, stop.
   - If a path argument was provided, use that as the working directory. Otherwise, look for `.tf` files in the current directory, then one level down. If none found, ask the user.
2. **Check the environment setup:**
   - If the working directory has a `.envrc` file, check if direnv is active with `direnv status`.
   - If direnv is available but the `.envrc` is not allowed, suggest `direnv allow`. Terraform often depends on env vars for backend config, provider credentials, and `TF_VAR_*` variables.
   - Show which Terraform-related environment variables are set (e.g. `TF_VAR_*`, `AWS_*`, `ARM_*`, `GOOGLE_*`) without showing their values.
3. Check if the directory is initialized:
   - Look for a `.terraform` directory or `.terraform.lock.hcl` file.
   - If not initialized and the command is not `init`, run `<tool> init` first. If init fails, stop and show the error.
4. For **fmt** mode:
   - Run `<tool> fmt -recursive -diff` to show what would change.
   - If there are changes, run `<tool> fmt -recursive` to apply them.
   - Report which files were formatted.
5. For **validate** mode:
   - Run `<tool> validate`.
   - If validation fails, show the errors with file and line references.
   - If validation passes, report success.
6. For **plan** mode (also the default):
   - Run `<tool> validate` first. If it fails, stop and show errors.
   - Run `<tool> plan -out=tfplan` to save the plan.
   - Parse and summarize the plan output:
     ```
     Workspace: <workspace>
     Plan: <add> to add, <change> to change, <destroy> to destroy.

     Resources:
     + <resource.name>  (create)
     ~ <resource.name>  (update)
     - <resource.name>  (destroy)
     ```
   - If there are no changes, say so and stop.
7. For **apply** mode:
   - Run validate and plan as described above.
   - Show the plan summary to the user.
   - Ask for explicit approval before applying.
   - After approval, run `<tool> apply tfplan`.
   - Show the apply output and report success or failure.
   - If apply fails, show the error. Do not retry automatically.
8. For **destroy** mode:
   - Run `<tool> plan -destroy -out=tfplan`.
   - Show all resources that would be destroyed.
   - Ask for explicit approval. Warn that this is destructive and irreversible.
   - After approval, run `<tool> apply tfplan`.
   - Report what was destroyed.
9. Show the current workspace info:
    - Run `<tool> workspace show` to display the active workspace.
    - Include this in the output so the user always knows which workspace they are operating on.

## Rules

- Always detect whether to use `terraform` or `tofu`. Never assume either.
- Always validate before planning. Always plan before applying.
- Always show the plan and require explicit user approval before apply or destroy.
- Always display the current workspace so the user knows the target environment.
- Always check for direnv and `.envrc` when entering a Terraform directory. Missing env vars are a common cause of init and plan failures.
- Never run apply without a saved plan file (`-out=tfplan`). This prevents drift between plan and apply.
- Never auto-approve applies. The `-auto-approve` flag must never be used.
- Never run destroy without explicit user approval and a clear warning.
- Never display secret values from environment variables. Show variable names only.
- If init fails (e.g. missing backend config), stop and show the error. Do not retry with different flags.
- If the working directory has no `.tf` files, say so and stop.
- Clean up `tfplan` files after successful apply.

## Related skills

- `/commit` - Commit Terraform configuration changes.
- `/pr` - Create a PR for infrastructure changes to be reviewed.
- `/env` - Terraform backends and providers often need environment variables managed by direnv.
