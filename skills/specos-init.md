# specos-init

You are setting up SpecOS v3 for a new project. Your job is to ask up to 7 questions, then generate the required files. Do not generate any file before all answers are collected.

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

*(Store for specos-project.yml. Default: en if not answered.)*

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
- Rule: no agent writes code without an approved spec in the repo
- Rule: changes to `spec.md` require Lead approval; an agent may write them only after that approval
- Rule: `local-workspace.yml` and `session.md` are never committed
- Optional files: `design.md` (the how, per feature) and `00-architecture.md` (context shared by a group)

### 2. constitution.md

Generate `constitution.md` with exactly these 8 rules:

1. Construction perspective always exists — someone defines and approves the spec before any code is written.
2. Breaking perspective always exists — it cannot be the same logic that built the feature. The Lead's testcase sketches are seeds; the independent perspective is the QA invocation with spec-only context.
3. No agent writes code without an approved spec in the repo. Committing it may follow implementation, but is mandatory before handing work to another person or agent.
4. Changes to `spec.md` require Lead approval; an agent may write them only after that approval.
5. A capped number of tasks per feature — the cap is `settings.lead.max_tasks` in `specos-project.yml`, 15 by default. Split into a new feature if more are needed.
6. All outputs are written in English by default.
7. A spec change affecting more than 50% of the content is a new feature, not an update.
8. Every spec change requires a `CHANGELOG.md` entry: what / why / impact, at most 3 lines.

### 3. specos-project.yml

Generate `specos-project.yml` — the single committed config file. Use the team composition answers and the language answer from Question 6.

```yaml
# specos-project.yml
# Everything configurable about this project. Committed to the repo.
# Machine-specific paths and identity live in local-workspace.yml, never here.
#
# Written in English whatever language.specs says.
#
# Three blocks: team / ids / integrations / outputs (who does what, where
# output goes), settings (closed schema, skills obey), rules (free-form,
# skills interpret).

version: "2"

language:
  specs: [language code from Q6]   # ISO 639-1 — for spec.md, tasks.md, testcases.md
  outputs: [language code from Q6] # for Jira/Confluence/etc. generated outputs

# --- Team and destinations -------------------------------------------------

team:
  lead: human         # human | agent
  qa: human           # human | agent | both

ids:
  task_prefix: SP     # optional hint for the shape of task keys
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

# --- Settings --------------------------------------------------------------
# Closed schema: only these keys are valid, only these values are accepted.
# Every key optional — an absent key uses the default shown.
# Uncomment and change only what you want to pin. Run /specos-config to edit.
#
#   lead:
#     max_tasks: 15                 # integer >= 1
#     max_journeys: none            # integer >= 1 | none
#     require_error_journey: false  # true | false
#     review: draft                 # draft | sections
#     suggest_scenarios: true       # true | false
#   qa:
#     cases_per_ac: standard        # minimal | standard | exhaustive | integer
#     include_negative_cases: true  # true | false
#     batch_by: journey             # journey | ac | all
#   distribute:
#     diagrams: ask                 # none | combined | per_journey | ask
#     branch_info: ask              # ask | none
#     task_title_max_words: 8       # integer >= 1
#     task_detail: standard         # standard | link | full
#   dev:
#     require_tests: false          # true | false
#
# `ask` is a real choice: it keeps a question being asked every run.

# --- Rules -----------------------------------------------------------------
# Free-form. Any section name, organized by role: frontend, backend, qa, shared.
# Use rules for what a value cannot express (tone, naming, review expectations).
#
#   rules:
#     writing_style:
#       shared:
#         - "Direct tone, no filler. Never 'should work correctly'"
#     code_style:
#       backend:
#         - "Validate every request body with Zod"
```

Set `team.qa: agent` if the user selected solo builder or indicated QA is handled by the agent. Otherwise `human`.

Write `settings:` and `rules:` as commented examples only — never as active keys. A fresh project runs entirely on documented defaults, and `/specos-config` writes the first real entry when the Lead sets one.

### 4. .gitignore entry

If a `.gitignore` already exists, append to it. If not, create it. Add:

```
# SpecOS local files — never committed
local-workspace.yml
.specos/
session.md
```

`.specos/` covers both `session.md` and the `memory.md` fallback used by agents that have no memory system of their own. Add the same entry to each implementation repo's `.gitignore` when the project uses separate repos.

### 5. specs/ directory

Create the `specs/` directory if it does not exist. Do not create any files inside it.

### 6. README.md

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
| `specs/` | One folder per feature: spec.md (ACs with stable ids), tasks.md, testcases.md, CHANGELOG.md |
| `AGENTS.md` | Project context — read automatically by AI agents |
| `constitution.md` | The 8 rules every agent and team member follows |
| `specos-project.yml` | Everything configurable: language, team, IDs, integrations, destinations, settings, rules |
| `local-workspace.yml` | Local identity: your name, roles, repo paths, memory links — gitignored |
| `session.md` | Active session state — gitignored, never committed |

---

## How to work on this project

### 1. Start every session

Run `/specos-start` in your AI agent. It reads your session state and routes you to the right skill automatically.

### 2. Define or update a spec (Lead role)

Run `/specos-lead`. Explain the feature freely; the agent writes one draft and asks only what it cannot decide. The same skill changes an existing spec.

### 3. Implement a task (Dev role)

Run `/specos-dev`. Provide your task key (e.g. `FK-42`). The agent reads the spec, loads your implementation repo, and helps you build.

### 4. Write or run test cases (QA role)

Run `/specos-qa`. The agent expands the Lead's testcase sketches into test cases and checks every AC is covered.

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

- No code is written without an approved `spec.md` in this repo.
- Changes to `spec.md` require Lead approval.
- Every spec change requires a `CHANGELOG.md` entry.

---

## Getting started

Run `/specos-start` — the first session on this machine asks your name, role, and repo paths.
```

Fill in every `[placeholder]` from the answers.

---

## Confirmation message

After all files are generated, print:

```
SpecOS v3 initialized.

Files created:
  AGENTS.md
  constitution.md
  specos-project.yml
  README.md
  .gitignore (updated)
  specs/

Next step: run /specos-start to begin your first session.
```
