# SpecOS — Master Prompt v2.0

> Paste this file at the start of any session with any AI.
> At the bottom, in ## TASK, write what you need.
> Works with Claude, ChatGPT, Gemini, Cursor, or any agent.

---

## What is SpecOS

SpecOS is an AI-First methodology for product teams. It defines how humans and agents collaborate using a single source of truth: the specs-repo.

**The 6 principles:**
1. The specs-repo is the only technical source of truth
2. No agent codes without an approved spec
3. Confluence, Jira, Notion are generated from the spec — never written manually
4. The merge closes the task — the pipeline is the referee
5. AGENTS.md works with any agent (tool-agnostic)
6. Each feature enriches the repo — context accumulates

---

## spec.md format

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
1. [numbered step]
### Journey 2 — [error path]
1. [numbered step]

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
- [ ] All ACs are verifiable
- [ ] Has out of scope with at least 1 item
- [ ] API contracts defined if there are new endpoints
- [ ] Under 150 lines
```

---

## tasks.md format

```markdown
## Backend
- [ ] [concrete description testable in isolation]

## Frontend
- [ ] [concrete description testable in isolation]

## QA
- [ ] [concrete description testable in isolation]
```

Rule: maximum 15 tasks total. If you need more, split the feature.

---

## The 3 flow moments

**Create:** Lead + AI → `spec.md` + `tasks.md` (collaborative session, section by section)
**Implement:** Dev reads spec + their task → codes → marks `[x]` → PR with `PROJ-XX #done`
**Distribute:** Output prompts → Confluence / Jira / Notion (manual in v1.0)

---

## Output language

All generated files and outputs are always in English regardless of the language used during the session. You can converse, ask questions, and respond in any language — but every generated file (spec.md, tasks.md, CHANGELOG.md, AGENTS.md, constitution.md, and all output prompts) must be written in English.

---

## Rules for generating SpecOS content

1. `spec.md` — numbered journeys, verifiable ACs, integrated technical section, max 150 lines
2. `tasks.md` — max 15 tasks, testable in isolation, grouped by role
3. `CHANGELOG.md` — each change has date, description, and reason
4. `AGENTS.md` — stack, conventions, explicit prohibitions
5. `constitution.md` — Definition of Ready, Definition of Done, principles
6. If the feature needs more than 15 tasks → propose how to split it
7. If the spec exceeds 150 lines → flag which parts are sub-features
8. In collaborative session mode: build section by section, wait for lead validation

---

## TASK

> Replace this section with what you need.

**Examples:**

```
Let's build the spec.md for the [name] feature in collaborative session mode.
Start by asking me: "What feature are we building today?"
```

```
Read this spec.md and generate tasks.md for a team of
1 Django backend dev, 1 React frontend dev, 1 QA:
[PASTE SPEC.MD HERE]
```

```
Generate AGENTS.md for a project with this stack:
Backend: Django + PostgreSQL + Celery
Frontend: React + TypeScript
Tools: Jira + Confluence + Notion
```

```
/document-module
[PASTE SPEC.MD HERE]
```

```
Review this spec.md and tell me:
1. Which ACs are not verifiable
2. Which edge cases are missing
3. Whether the feature is too large for a single sprint
[PASTE SPEC.MD HERE]
```

---

*SpecOS v2.0 — the operating system for your team with AI agents*
