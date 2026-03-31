# SpecOS v2.0

> The operating system for your team with AI agents.
> Phase 1: Manual flow with prompts.

**Created by [Sebastian Wilde Alarcón Arenas](https://github.com/[tu-usuario])**
Licensed under [MIT](./LICENSE) · Free to use with attribution · [Credits](./CREDITS.md)

---

## What changed in v2.0

- `spec.md` now includes everything — `design.md` no longer exists as a separate file
- The tasks flow is collaborative between the lead and the AI
- Outputs are generated with team-configurable prompts
- No automation required to get started

---

## Contents

1. [What is SpecOS](#1-what-is-specos)
2. [Repo structure](#2-repo-structure)
3. [Core files](#3-core-files)
4. [Role guide](#4-role-guide)
5. [Prompts — how to use them](#5-prompts--how-to-use-them)
6. [Output configuration](#6-output-configuration)
7. [Initial setup step by step](#7-initial-setup-step-by-step)
8. [Future Improvements](#8-future-improvements)

---

## 1. What is SpecOS

SpecOS is not a tool — it's an engineering practice, like TDD. It sits on top of any methodology (Scrum, Kanban, Shape Up) and defines how the team works with AI agents.

### The 6 principles

| Principle | What it means |
|---|---|
| Single source of truth | The specs-repo is the only place where technical knowledge lives. Nothing is duplicated. |
| Spec first | No agent codes without an approved spec. Neither does any human. The spec is the Definition of Ready. |
| Generate > write | Confluence, Jira, and Notion are generated from the spec. They are never written manually. |
| Automatic close | The merge closes the task. The pipeline is the referee, not the human. |
| Agent-agnostic | AGENTS.md works with Claude, Cursor, Copilot, Gemini — any tool. |
| Accumulated context | Each feature enriches the repo. The next agent starts smarter. |

### The 3 moments of SpecOS

**Moment 1 — Create**
Lead + AI build `spec.md` and `tasks.md` in a collaborative session. The AI proposes, the lead validates section by section.

**Moment 2 — Implement**
Each member reads `spec.md` + their task. Uses their preferred AI. Marks `[x]` when done.

**Moment 3 — Distribute**
The `outputs/` prompts generate the doc for Confluence, tasks for Jira, test cases for Notion. Manual today, automatic in v2.0.

---

## 2. Repo structure

```
specs-repo/
├── README.md                      ← this file (the full playbook)
├── CHEATSHEET.md                  ← one-page quick reference
├── AGENTS.md                      ← global project context
├── constitution.md                ← non-negotiable rules
├── specos-outputs.yml             ← team output configuration
├── CLAUDE.md                      ← symlink to AGENTS.md (Claude Code)
├── .cursorrules                   ← symlink to AGENTS.md (Cursor)
├── SpecOS.spec.md                 ← the spec of SpecOS itself
├── SpecOS_MasterPrompt.md         ← master prompt for any AI
├── prompts/
│   ├── 00-repo-setup.md           ← creates the repo from scratch (interactive)
│   ├── 01-collaborative-session.md ← builds spec + tasks together
│   ├── 02-generate-spec.md        ← generates spec alone (quick)
│   ├── 03-generate-tasks.md       ← generates tasks from a ready spec
│   ├── outputs/
│   │   ├── output-confluence.md
│   │   ├── output-flows.md
│   │   ├── output-jira.md
│   │   └── output-test.md
│   └── meta/
│       └── how-to-create-output-prompt.md
├── specs/                         ← your project features go here
│   └── [feature-name]/
│       ├── spec.md
│       ├── tasks.md
│       └── CHANGELOG.md
└── examples/                      ← complete end-to-end examples
    └── feature-tags/
        ├── spec.md
        ├── tasks.md
        ├── CHANGELOG.md
        └── outputs/
            ├── confluence-page.md
            ├── confluence-flows.md
            ├── jira-tasks.md
            └── steps-to-test.md
```

---

## 3. Core files

### spec.md — all in one

`design.md` no longer exists as a separate file. Everything lives in `spec.md`.

```markdown
---
feature: feature-name-in-kebab-case
version: 1.0
status: draft | approved | in-development | complete
lead: name
date: YYYY-MM-DD
---

# Feature Title

## What it does and why it exists
[maximum 3 lines]

## User Journeys

### Journey 1 — [happy path]
1. [step]

### Journey 2 — [most likely error path]
1. [step]

## Acceptance Criteria
- [ ] [verifiable criterion — testable without interpretation]

## Out of Scope
- [at least 1 item]

## Technical Section

### API Contracts [if applicable]
### Data model [if applicable]
### Technical decisions

---
## Approval checklist (delete when approved)
- [ ] Has at least 1 error journey
- [ ] All ACs are verifiable (verb + subject + measurable condition)
- [ ] Has out of scope with at least 1 item
- [ ] API contracts defined if there are new endpoints
- [ ] Under 150 lines — if over, split into sub-features
```

> **Critical rule:** `"Token expires in exactly 24h"` ✓ — `"Should look good"` ✗

---

### tasks.md — built in collaborative session

```markdown
## Backend
- [ ] [concrete description testable in isolation]

## Frontend
- [ ] [concrete description testable in isolation]

## QA
- [ ] [concrete description testable in isolation]
```

> **Rule:** Maximum 15 tasks total. If you need more, split the feature.

---

### CHANGELOG.md

```markdown
# Changelog — [feature-name]

## YYYY-MM-DD v1.1
- [what changed]
- Reason: [why it changed]

## YYYY-MM-DD v1.0
- Initial spec approved
```

---

## 4. Role guide

### Lead

1. Open a session with your AI → paste `prompts/01-collaborative-session.md`
2. Describe the feature in natural language
3. Build spec.md section by section, validating with the AI
4. Continue in the same session with tasks.md
5. Push to the repo
6. When approved: use `outputs/` prompts to distribute
7. Update CHANGELOG.md if the spec changes during development

### Backend

1. Open a session with your preferred AI
2. Paste `spec.md` + your specific task from `tasks.md`
3. Implement in that context
4. Mark `[x]` in tasks.md → commit → open PR with `PROJ-XX #done`

### Frontend

1. Open a session with your preferred AI
2. Paste `spec.md` + your specific task
3. UI validations must match the spec's ACs exactly
4. Mark `[x]` → commit → PR

### QA

1. Read `spec.md` from day one — don't wait for the code
2. Paste `spec.md` + prompt `output-test.md` → generates test cases
3. Copy to Notion (or your team's tool)
4. If you find an uncovered edge case → tell the lead to update the spec
5. Mark `[x]` when tests are documented and executed

---

## 5. Prompts — how to use them

### Create the repo from scratch (one time only)

1. Open a session with your AI
2. Copy and paste `prompts/00-repo-setup.md`
3. Answer the questions about your project
4. The AI generates: `AGENTS.md`, `constitution.md`, `specos-outputs.yml` and setup commands
5. Run the commands and make the first commit

> **One time only:** `00-repo-setup.md` is used once per project. After that, the team uses the other prompts for daily work.

### Prompt reference

| Prompt | When to use |
|---|---|
| `00-repo-setup.md` | First time. Generates the full repo base. Interactive. |
| `01-collaborative-session.md` | Lead's main prompt. Builds spec + tasks together. |
| `02-generate-spec.md` | Simple features or when you already have clarity. Faster. |
| `03-generate-tasks.md` | When you have an approved spec and want tasks separately. |
| `outputs/output-confluence.md` | Confluence page. With spec: auto. Without spec: interactive. Trigger: `/document-module`. |
| `outputs/output-flows.md` | Mermaid diagrams of the journeys. Trigger: `/flow`. |
| `outputs/output-jira.md` | Jira tasks. With spec + tasks: generates all. Trigger: `/task`. |
| `outputs/output-test.md` | Steps to test for QA. Trigger: `/steps-to-test`. |
| `meta/how-to-create-output-prompt.md` | Create a new output prompt for any tool. |

---

## 6. Output configuration

### Example A — Confluence + Jira + Notion (manual mode)

```yaml
# specos-outputs.yml
version: "1.0"
mode: manual

outputs:
  - name: confluence-doc
    prompt: prompts/outputs/output-confluence.md
    input: spec.md
    trigger: manual
    destination: Confluence > your space

  - name: confluence-flows
    prompt: prompts/outputs/output-flows.md
    input: spec.md
    trigger: manual
    destination: Confluence > flows subpage

  - name: jira-tasks
    prompt: prompts/outputs/output-jira.md
    input: spec.md + tasks.md
    trigger: manual
    destination: Jira > your project

  - name: notion-test-cases
    prompt: prompts/outputs/output-test.md
    input: spec.md + tasks.md
    trigger: manual
    destination: Notion > QA database
```

### Example B — GitHub + Linear + Slack

```yaml
version: "1.0"
mode: manual

outputs:
  - name: github-issue
    prompt: prompts/outputs/output-github.md   # create with meta-prompt
    input: spec.md
    trigger: manual
    destination: GitHub Issues

  - name: linear-tasks
    prompt: prompts/outputs/output-linear.md   # create with meta-prompt
    input: spec.md + tasks.md
    trigger: manual
    destination: Linear

  - name: slack-briefing
    prompt: prompts/outputs/output-slack.md    # create with meta-prompt
    input: spec.md
    trigger: manual
    destination: Slack > #engineering
```

### How to adapt to another project

1. Identify your team's tools
2. For each new tool: paste `meta/how-to-create-output-prompt.md` in your AI
3. Answer the questions → the AI generates the prompt
4. Save it in `prompts/outputs/`
5. Add the entry to `specos-outputs.yml`

> **The pattern:** `spec.md` and `tasks.md` are always the same. What changes between teams are the `outputs/` prompts and `specos-outputs.yml`. The core system is the same for everyone.

---

## 7. Initial setup step by step

### Week 1 — Create the repo

```bash
# Clone
git clone git@github.com:[org]/specs-repo.git
cd specs-repo

# Create structure
mkdir -p specs prompts/outputs prompts/meta examples

# Create symlinks for agents
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md .cursorrules

# First commit
git add . && git commit -m 'init: SpecOS v1.0' && git push
```

Before the commit: use `prompts/00-repo-setup.md` to generate personalized `AGENTS.md` and `constitution.md` for your project.

### Week 2 — First feature

1. Choose a real feature from the next sprint
2. Open a session with your AI → paste `prompts/01-collaborative-session.md`
3. Build `spec.md` + `tasks.md` together
4. Save in `specs/[feature-name]/`
5. Create `CHANGELOG.md` with initial entry
6. Push → use output prompts to distribute

> **The goal:** By the end of week 2, the team should have the reflex of reading the spec before coding. That habit installed is the success of week 2.

---

## 8. Future Improvements (v2.0)

| Improvement | What it does |
|---|---|
| Output agent with MCP | Automatic outputs to Jira, Confluence, Notion on push |
| AI Spec Review | Checks ACs, ambiguities, and missing edge cases before approving |
| Domain templates | Pre-built specs: auth, API integration, migration, CRUD, notifications |
| Automatic retrospective | When all tasks close: actual vs estimated timing, lessons learned |
| Weekly health check | Specs without activity, tasks without PR, features in limbo |
| Automatic onboarding | Reads the repo and generates how this specific team works |
| Spec Diff | When the spec changes, flags which tasks are affected |
| PM/PO RAG | Answers project questions with real data from the repo |
| Analytics | Spec Quality Score, timing prediction, evolved DORA metrics |

---

*SpecOS v2.0 — the operating system for your team with AI agents*
