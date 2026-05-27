# specos-init

You are setting up SpecOS v3 for a new project. Your job is to ask exactly 6 questions, then generate the required files. Do not generate any file before all 6 answers are collected.

---

## Protocol

Ask the questions one at a time. Wait for the user's answer before asking the next one.

**Question 1 — Project name**
"What is the name of this project?"

**Question 2 — Stack**
"What is your tech stack? (languages, frameworks, databases — be as brief or detailed as you like)"

**Question 3 — Team composition**
"What is your team setup? Choose one:
1. Solo builder — you design, build, and test alone
2. Small team — lead + 1-2 devs, QA is shared or agent
3. Full team — lead, backend, frontend, QA as separate roles
4. Custom — I'll describe my own setup"

**Question 4 — Roles for this person**
"What roles do you hold on this project? You can select multiple:
- lead (writes and approves specs)
- backend (implements API and business logic)
- frontend (implements UI)
- qa (designs and runs tests)
- builder (designs + builds + tests — solo role)"

**Question 5 — Project structure**
"How is your code organized?
1. Monorepo — specs and code live in the same repo
2. Separate repos — this is the specs repo, code lives elsewhere"

**Question 6 — Language**
"What language should specs and outputs be written in? (e.g. English, Spanish, Portuguese — or type the ISO code: en, es, pt)"

*(Store for specos-standards.yml. Default: en if not answered.)*

**Question 7 — Implementation repo paths** *(ask only if answer to Q5 was "separate repos")*
"What are the paths to your implementation repos relative to this folder?
Provide one per role that applies. Example:
- backend: ../repo-backend
- frontend: ../repo-frontend
- e2e: ../repo-e2e
Leave a role as `null` if it does not apply."

*(If answer to Q5 was "monorepo", skip Q7 and use `null` for all implementation repo paths.)*

---

## File generation

After all answers are collected, generate the following files in order. Announce each file as you create it.

### 1. AGENTS.md

Generate a project-specific `AGENTS.md` using the answers. Include:
- Project name and one-line description (inferred from stack if not provided)
- Tech stack summary
- Team roles and who holds them
- SpecOS structure: `specs/`, `local-workspace.yml` (gitignored), `session.md` (gitignored)
- Implementation repo paths if separate repos
- Rule: no agent writes code without a spec in the repo
- Rule: only Lead modifies `spec.md`
- Rule: `local-workspace.yml` and `session.md` are never committed

### 2. constitution.md

Generate `constitution.md` with exactly these 8 rules:

1. Construction perspective always exists — someone defines and approves the spec before any code is written.
2. Breaking perspective always exists — it cannot be the same logic that built the feature.
3. No agent writes code without a spec committed to the repo.
4. Only the Lead role modifies `spec.md`.
5. Maximum 15 tasks per feature — split into a new feature if more are needed.
6. All outputs are written in English by default.
7. A spec change affecting more than 50% of the content is a new feature, not an update.
8. Every spec change requires a `CHANGELOG.md` entry: date, what changed, and why.

### 3. specos-outputs.yml

Generate `specos-outputs.yml` using the team composition answers:

```yaml
version: "1.0"
language: en

team:
  lead: human         # human | agent
  qa: human           # human | agent | both

ids:
  task_prefix: SP
  testcase_prefix: TC

integrations:
  jira:
    enabled: false
    mcp: null
  confluence:
    enabled: false
    mcp: null
  notion:
    enabled: false
  linear:
    enabled: false
  github_issues:
    enabled: false
  slack:
    enabled: false

outputs:
  tasks:
    destination: manual
  testcases:
    destination: manual
  confluence_doc:
    destination: manual
```

Set `team.qa: agent` if the user selected solo builder or indicated QA is handled by the agent. Otherwise `human`.

### 4. specos-standards.yml

Generate `specos-standards.yml` using the language answer from Question 6:

```yaml
# specos-standards.yml
# Project-level standards for SpecOS v3.
# Committed to the repo. Edit as your project evolves.
#
# `language` is the only reserved key. Everything else is free-form.
# Define any section your project needs. Organize by role within each section.
# Skills read the entire file and apply all entries for the relevant role.

language:
  specs: [language code from Q6]   # ISO 639-1 — for spec.md, tasks.md, testcases.md
  outputs: [language code from Q6] # for Jira/Confluence/etc. generated outputs

# --- Add your project standards below ---
# Each section can have: frontend, backend, qa, shared
# Examples: acceptance_criteria, code_style, api_conventions, accessibility, security
```

### 5. .gitignore entry

If a `.gitignore` already exists, append to it. If not, create it. Add:

```
# SpecOS local files — never committed
local-workspace.yml
.specos/session.md
session.md
```

### 6. specs/ directory

Create the `specs/` directory if it does not exist. Do not create any files inside it.

### 7. README.md

Generate `README.md` at the repo root using the answers collected in questions 1–6. Write in English. The README must cover:

**Structure:**

```markdown
# [Project Name] — Specs

One-line description of what the product does and who it's for.

---

## What's in this repo

This repository contains the product specs, task breakdowns, and QA test cases for [Project Name].
It uses **SpecOS v3** — a structured workflow for AI-assisted software development.

| Folder / File | Purpose |
|---|---|
| `specs/` | One folder per feature. Each contains spec.md, tasks.md, testcases.md, CHANGELOG.md |
| `AGENTS.md` | Project context — read automatically by AI agents |
| `constitution.md` | The 8 rules every agent and team member follows |
| `specos-outputs.yml` | Team configuration and integration settings |
| `local-workspace.yml` | Local identity: your name, roles, repo paths — gitignored |
| `session.md` | Active session state — gitignored, never committed |

---

## How to work on this project

### 1. Start every session

Run `/specos-start` in your AI agent. It reads your session state and routes you to the right skill automatically.

### 2. Define or update a spec (Lead role)

Run `/specos-lead`. The agent will guide you through writing or refining a `spec.md` for a feature.

### 3. Implement a task (Dev role)

Run `/specos-dev`. Provide your task ID (e.g. `SP-04`). The agent reads the spec, loads your implementation repo, and helps you build.

### 4. Write or run test cases (QA role)

Run `/specos-qa`. The agent generates test cases from the spec or helps you execute them.

### 5. Distribute outputs

Run `/specos-distribute` to push specs, tasks, or test cases to your configured tools (Jira, Confluence, Notion, etc.).

---

## Tech stack

[Summarize the stack from question 2: languages, frameworks, databases, infra.]

---

## Team

| Role | Responsibility |
|---|---|
| Lead | Writes and approves specs |
| Backend | Implements API and business logic |
| Frontend | Implements UI and validations |
| QA | Designs and executes test cases |

[Fill in names from the answers to questions 3–4.]

---

## Rules

All contributors (human and AI) follow the rules in `constitution.md`. The key ones:

- No code is written without a `spec.md` committed to this repo.
- Only the Lead role modifies `spec.md`.
- Every spec change requires a `CHANGELOG.md` entry.

---

## Getting started

```bash
# First time setup (already done if you're reading this)
bash install.sh

# First session on this machine — will ask your name, role, and repo paths
/specos-start
```
```

Fill in all `[placeholders]` using the answers collected during init. Do not leave any placeholder unfilled.

---

## Confirmation message

After all files are generated, print:

```
SpecOS v3 initialized.

Files created:
  AGENTS.md
  constitution.md
  specos-outputs.yml
  specos-standards.yml
  README.md
  .gitignore (updated)
  specs/

Next step: run /specos-start to begin your first session.
```
