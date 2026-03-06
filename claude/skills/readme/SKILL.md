---
name: readme
description: Generate a marketing-grade README and GitHub repo description by analyzing the project's actual codebase, infrastructure, and architecture.
---

Generate a visually striking, technically deep README.md and GitHub repository description that sells the project at first glance. The output should feel like a product landing page built entirely in Markdown: eye-catching hero section, visual feature grids, architecture diagrams, concrete metrics, and a quick start that's impossible to miss. Every claim must be grounded in the actual codebase. Never invent features.

## When to use

- When starting a new project that needs a professional README.
- When a project has outgrown its initial README and needs a rewrite.
- When preparing a project for public release or portfolio showcase.
- When the README is stale and no longer reflects the codebase.
- When you want the project to stand out on GitHub.

## When NOT to use

- For minor README tweaks like fixing a typo or adding one section.
- When the project has no code yet, just a plan.

## Arguments

This skill accepts optional arguments after `/readme`:

- No arguments: generate a full README and repo description by scanning the entire project.
- `--about-only`: generate only the GitHub repo description and topics, skip README.
- `--section <name>`: regenerate a specific section (e.g., `--section quick-start`).
- `--diff`: update the existing README based on what changed since it was last written.

## Steps

### Phase 1: Deep Scan

Read the project thoroughly. Run these **in parallel**:

1. **Project identity**: read `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Makefile`, or equivalent to get the project name, version, description, dependencies, and scripts.
2. **Infrastructure and config**: read Terraform files, Docker files, CI/CD configs, `docker-compose.yml`, and deployment configs to understand the infrastructure.
3. **Source code structure**: map the directory tree (`ls -R` or glob) to understand the project layout, modules, and organization.
4. **Existing README**: read the current `README.md` if it exists, to understand what the user already had and what to improve.
5. **Environment and setup**: read `.env.example`, setup scripts, and Makefile targets to document prerequisites and setup steps.
6. **Git context**: run `git remote -v` and `git log --oneline -10` to get the repo URL, recent activity, and contributor count.
7. **Visual assets**: check for logo files (`logo.png`, `logo.svg`, `banner.png`, `.github/assets/`, `docs/images/`) and existing screenshots or demos.
8. **License and metadata**: read `LICENSE`, `.github/FUNDING.yml`, badges in existing README.

### Phase 2: Architecture and Identity Analysis

From the scan results, build a project profile:

- **Type**: library, CLI tool, web app, API service, infrastructure, monorepo, dotfiles, or combination.
- **Stack**: languages, frameworks, databases, cloud services, CI/CD tools.
- **Scale signals**: multi-region, microservices, event-driven, serverless, multi-tenant, monorepo with N packages, etc.
- **Differentiators**: what makes this project stand out? Look for unique combinations, unusual scale, well-solved hard problems, or opinionated design choices.
- **Personality**: infer the project's tone from existing docs, comments, and commit messages. Technical and serious? Fun and playful? Opinionated and sharp? Match it.
- **Metrics inventory**: count concrete numbers: modules, services, endpoints, tests, config files, CLI commands, supported platforms, dependencies, lines of code by language. These become the quantified summary.

### Phase 3: Generate README

Write the README following the structure and visual guide below. Every section must be grounded in what was found in Phase 1. If a section doesn't apply, skip it. The goal is a README that makes someone stop scrolling and star the repo.

### Phase 4: Generate GitHub About

Generate a concise repo description (max 350 characters) and a list of topic tags. See the "GitHub About" section below.

### Phase 5: Present and Apply

1. Show the full README to the user for review.
2. Show the GitHub About description and topics.
3. Ask if they want changes before writing.
4. **Resolve account** per `rules/borrow-restore.md` before applying GitHub About. Match the remote URL against authenticated accounts, switch if needed.
5. After approval:
   - Write the README.md file.
   - Apply the GitHub About using `gh repo edit --description "<desc>"` and `gh repo edit --add-topic <topic>` commands.
   - Restore the original account per `rules/borrow-restore.md`.

## README Structure

Use this structure as a guide. Skip sections that don't apply. Reorder if it makes more sense for the project.

### 1. Hero Section

The first thing anyone sees. It must create instant visual identity and communicate what the project does in under 5 seconds.

```html
<div align="center">

<!-- Logo: use the project's actual logo if found in Phase 1 -->
<!-- If no logo exists, skip this. Never use a placeholder -->
<img src="path/to/logo.svg" alt="Project Name" width="200">

<br>
<br>

<!-- Tagline: one line, confident, specific -->
<strong>What it does, concretely, in one sentence.</strong>

<br>
<br>

<!-- Badge bar: only verifiable facts -->
<!-- Group by: build status | version/release | tech stack | license -->
[![CI](badge-url)](link)
[![Version](badge-url)](link)
[![License](badge-url)](link)

</div>
```

After the centered hero, add a **metrics bar**: a single line or short paragraph with concrete numbers that make the scope tangible. Use bold for the numbers.

Example:
```markdown
**12** modules · **30+** AWS services · **6** regions · **200+** tests · deploys in **~30 min**
```

For CLI tools or libraries, quantify differently:
```markdown
**45** commands · **3** platforms · **zero** dependencies · **<5ms** startup
```

### 2. Highlights Grid

A visual feature showcase that reads like a product landing page. Use an HTML table to create a 2-column or 3-column grid. Each cell has a short title and a one-line description.

```html
<table>
<tr>
<td width="50%" valign="top">

### Title A
One-line description of what this feature does and why it matters.

</td>
<td width="50%" valign="top">

### Title B
One-line description of what this feature does and why it matters.

</td>
</tr>
<tr>
<td width="50%" valign="top">

### Title C
One-line description of what this feature does and why it matters.

</td>
<td width="50%" valign="top">

### Title D
One-line description of what this feature does and why it matters.

</td>
</tr>
</table>
```

**Rules for the grid:**
- 4 to 8 cells. Pick the most impressive or differentiating features.
- Each title is 2-4 words. No fluff.
- Each description is one sentence. Specific, not generic. "Deploys to 6 AWS regions with one command" not "Easy deployment".
- Order by impact: most impressive first.

### 3. The Problem and The Solution

Two short sections that frame the project as a story. Why does this exist? What pain does it kill?

**The Problem**: 2-3 sentences max. Describe the pain point that motivated the project. Be specific and relatable.

**The Solution**: how does this project solve it? If alternatives exist, include a comparison table. Be fair to alternatives but highlight genuine advantages with checkmarks.

```markdown
| Capability | This Project | Alternative A | Alternative B |
|:-----------|:------------:|:-------------:|:-------------:|
| Feature 1  | ✅           | ✅            | ❌            |
| Feature 2  | ✅           | ❌            | ✅            |
| Feature 3  | ✅           | ❌            | ❌            |
```

### 4. Architecture

Mermaid diagrams for projects with enough complexity to warrant them. Use the diagram type that best fits:

- **Flowchart** (`graph LR` or `graph TD`): system architecture, data flow between components.
- **Sequence diagram**: request/response flows, multi-service interactions.
- **C4 Context**: high-level system boundaries for larger projects.

```markdown
```mermaid
graph LR
    A[Client] --> B[API Gateway]
    B --> C[Service A]
    B --> D[Service B]
    C --> E[(Database)]
    D --> F[(Cache)]
`` `
```

**Diagram rules:**
- Max 15-20 nodes per diagram. Split into multiple if needed.
- Use descriptive labels, not single letters.
- Include the data flow direction.
- For multi-layer architectures, use `subgraph` to group related components.
- Skip this section entirely for simple projects (CLIs, small libraries).

### 5. What's Included

Categorized feature list. Group by domain, not by file. Use tables with two columns: feature and description.

```markdown
### Category Name

| Feature | Description |
|:--------|:------------|
| Feature A | What it does, concretely |
| Feature B | What it does, concretely |
```

Categories come from the project's actual domains: Infrastructure, Security, Data Layer, Monitoring, CLI Commands, Components, etc.

### 6. Demo / Screenshots

If the project has visual output (web app, CLI with TUI, desktop app), this section is mandatory. If no screenshots or demos exist yet, add the section with a placeholder structure and a comment telling the user to add them.

**For CLI tools**, show terminal output in a code block or reference an asciinema recording:

```markdown
[![asciicast](https://asciinema.org/a/XXXXX.svg)](https://asciinema.org/a/XXXXX)
```

**For web apps**, use a screenshot with a subtle border:

```html
<div align="center">
<img src="docs/images/screenshot.png" alt="App screenshot" width="700">
</div>
```

**For GitHub light/dark mode support** (when the project has both variants):

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/screenshot-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="docs/images/screenshot-light.png">
  <img alt="App screenshot" src="docs/images/screenshot-light.png" width="700">
</picture>
```

### 7. Quick Start

The most important section after the hero. It must be prominent, copy-pasteable, and verifiable. A reader should go from zero to running in under 60 seconds.

```markdown
## Quick Start

### Prerequisites

| Tool | Version | Install |
|:-----|:--------|:--------|
| Node.js | >= 20 | [nodejs.org](https://nodejs.org) |
| Docker | >= 24 | [docker.com](https://docker.com) |

### Setup

```bash
git clone https://github.com/user/repo.git
cd repo
npm install
cp .env.example .env
npm run dev
```

### Verify

```bash
curl http://localhost:3000/health
# {"status":"ok"}
```
```

**Rules:**
- Prerequisites in a table, not a bullet list.
- Setup commands numbered only if order matters, otherwise a single code block.
- Always end with a verification step that proves it works.
- Include the expected output of the verification command.

### 8. Project Structure

Directory tree with one-line descriptions. For large projects, wrap in a collapsible section.

```html
<details>
<summary><strong>Project structure</strong></summary>

`` `
src/
  api/          # REST endpoints and middleware
  services/     # Business logic
  models/       # Database models and schemas
  utils/        # Shared utilities
tests/          # Test suites
infra/          # Terraform modules
`` `

</details>
```

For smaller projects (< 10 directories), show the tree directly without collapsing.

### 9. Development Commands

Tables grouped by category. Only include if the project has a Makefile, scripts, or task runner.

```markdown
### Development

| Command | Description |
|:--------|:------------|
| `npm run dev` | Start development server with hot reload |
| `npm run test` | Run test suite with coverage |
| `npm run lint` | Lint and format check |

### Infrastructure

| Command | Description |
|:--------|:------------|
| `make deploy` | Deploy to staging |
| `make tf-plan` | Preview infrastructure changes |
```

### 10. Configuration / Environment Variables

Tables with variable name, description, required/optional, and default value.

```markdown
| Variable | Description | Required | Default |
|:---------|:------------|:--------:|:--------|
| `DATABASE_URL` | PostgreSQL connection string | Yes | — |
| `PORT` | Server port | No | `3000` |
| `LOG_LEVEL` | Logging verbosity | No | `info` |
```

### 11. API Reference

For projects with APIs, include endpoint tables. For large APIs, link to external docs and show only the most important endpoints.

```markdown
| Method | Endpoint | Description |
|:-------|:---------|:------------|
| `GET` | `/api/users` | List all users (paginated) |
| `POST` | `/api/users` | Create a new user |
| `GET` | `/api/users/:id` | Get user by ID |
```

### 12. FAQ

4-6 questions a newcomer would ask. Use collapsible sections to keep the page clean.

```html
<details>
<summary><strong>How do I configure X?</strong></summary>
<br>

Direct, useful answer with a code example if applicable.

</details>

<details>
<summary><strong>Why did you choose Y over Z?</strong></summary>
<br>

Honest, technical answer explaining the trade-off.

</details>
```

### 13. License

Short and simple. One line with the license name and a link to the full text.

```markdown
## License

[MIT](LICENSE)
```

## Style Guide

### Voice and Tone

- **Confident and direct.** No hedging ("might", "should", "could potentially"). State what the project does.
- **Technical but magnetic.** Assume the reader is a developer. Respect their intelligence but make them excited.
- **Show, don't tell.** Instead of "easy to set up", show a 3-line setup. Instead of "fast", show a benchmark. Instead of "flexible", show 3 different config examples.
- **Opinionated is good.** If the project made deliberate choices, state them proudly. "We use X because Y" is more compelling than "supports X and Y".

### Visual Hierarchy

The README should be scannable in 10 seconds. A developer scrolling fast should understand what the project does without reading a single paragraph.

1. **Hero with logo/tagline** catches the eye.
2. **Metrics bar** establishes credibility and scale.
3. **Highlights grid** communicates top features visually.
4. **Architecture diagram** shows the system at a glance.
5. **Quick Start** lets them try it immediately.
6. **Everything else** is reference material below the fold.

### Formatting Rules

- **Centered hero section** using `<div align="center">`. This is the only centered section.
- **HTML tables for feature grids** when you need multi-column layouts that Markdown tables can't achieve.
- **Markdown tables for data** (commands, env vars, endpoints, prerequisites).
- **Mermaid diagrams** for architecture. Keep them readable, max 20 nodes.
- **Collapsible sections** (`<details>`) for verbose content: project structure, FAQ, extended config.
- **Code blocks** for every command. Always include the language identifier.
- **Horizontal rules** (`---`) to separate the hero from the content. Use sparingly elsewhere.
- **Bold numbers** in the metrics bar to make them pop.
- **Consistent alignment**: use `:--------` for left-align, `:--------:` for center-align in tables. Align columns purposefully: names left, statuses center, descriptions left.

### Badges

Only for verifiable, meaningful facts. Grouped and ordered consistently.

**Order**: build status, version/release, language, license, optional extras.

**Allowed**: CI status, latest release, language version, license type, downloads/installs, code coverage, platform support.

**Banned**: vanity badges ("awesome", "made with love"), badges for technologies not central to the project, broken or outdated badges.

Use shields.io with a consistent style parameter across all badges (e.g., `?style=flat-square` or `?style=for-the-badge` for bolder READMEs).

### Quantification

Make the project's scope tangible with specific numbers. These are the most persuasive thing in a README because they can't be faked.

- Number of modules, services, components, or packages.
- Number of cloud services, regions, or resources managed.
- Lines of Terraform, tests, or endpoints.
- Concrete metrics: "deploys in ~30 min", "0.5-128 ACU scaling range", "6 regions".
- Performance: "cold start < 100ms", "handles 10k req/s", "< 5MB binary".
- Reliability: "99.9% uptime SLO", "zero-downtime deploys", "100% test coverage".

**Never estimate. Count from the source.**

### What NOT to Include

- **No "Contributing" section** unless the user asks for it.
- **No "Acknowledgments" section** unless the user asks for it.
- **No version history or changelog** in the README. Link to releases instead.
- **No "Built with" section** that just lists logos. The badges and stack description cover this.
- **No placeholder text.** If information is unknown, skip the section entirely.
- **No AI attribution.** Never add "Generated by AI" or similar markers.
- **No marketing fluff words.** "Revolutionary", "game-changing", "next-generation", "cutting-edge", "blazing fast" are all banned. Let the numbers and features speak.

## GitHub About

### Description

- Max 350 characters.
- Format: `[What it is] + [key differentiator] + [quantified scope]`.
- No emojis. No trailing period.
- Example: `Production-grade multi-region AWS infrastructure as code. 9 Terraform modules, 30+ AWS services, 6 regions, one terraform apply`

### Topics

- 8-15 topic tags.
- Include: primary language, framework, cloud provider, key technologies, project type.
- Use lowercase, hyphenated: `terraform`, `aws`, `multi-region`, `ecs-fargate`, `aurora-serverless`.
- No generic tags like `code`, `project`, `awesome`.

## Rules

- **Evidence-based only.** Every feature, service, or capability mentioned must exist in the codebase. Read the actual files.
- **No invented features.** If you didn't find it in the code, don't write about it.
- **Verify commands.** Every setup command in Quick Start must work. Check that referenced scripts and Makefile targets exist.
- **Check paths.** Every file path in the directory tree must exist. Use glob or ls to verify.
- **Quantify accurately.** Count modules, services, and endpoints from the source. Don't estimate.
- **Match project scale.** A small CLI tool gets a focused README with fewer sections. A multi-region infra project gets the full treatment. Never pad a small project with unnecessary sections.
- **Preserve user customizations.** If the user already has sections they wrote (like a specific "About" or custom badges), keep them unless asked to replace.
- **Visual assets must exist.** Never reference an image, logo, or screenshot that doesn't exist in the repo. If no visual assets exist, skip those elements and note it as a follow-up.
- **Test the visual output.** After generating, mentally render the Markdown. Check that HTML tables, Mermaid diagrams, and collapsible sections are properly closed and will render on GitHub.

## Related skills

- `/commit` - Commit the README changes.
- `/pr` - Create a PR with the README update.
- `/assessment` - Audit the implementation for completeness before documenting it.
