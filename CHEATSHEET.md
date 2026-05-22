# SpecOS v3 — Cheat Sheet

> One page. Everything you need for daily work.

---

## The 2 perspectives

```
CONSTRUCTION   Lead defines spec → Dev implements
BREAKING       QA (human or agent) challenges, tests, flags gaps
```

Both always required. Never the same logic.

---

## Session startup

```
/specos-start
```

Agent reads `session.md`. If it exists: resumes. If not: asks based on your role.

---

## Skill reference

| Skill | Who | What |
|---|---|---|
| `/specos-init` | Lead | First-time setup — 7 questions, generates AGENTS.md + constitution.md + specos-outputs.yml + specos-standards.yml |
| `/specos-start` | Everyone | Begins any session, routes by role and session state |
| `/specos-lead` | Lead | Builds spec + tasks collaboratively, assigns SP-XX IDs, collects real IDs |
| `/specos-dev` | Dev | Loads only the relevant spec, writes to implementation repo |
| `/specos-qa` | QA | Generates testcases.md collaboratively, assigns TC-XX IDs |
| `/specos-distribute` | Lead / QA | Generates outputs per specos-outputs.yml + standards |
| `/specos-split` | Lead | Splits a large spec into sub-specs under a group folder |
| `/specos-group` | Lead | Groups related existing specs under a shared parent folder |

---

## Perspective flows

**Lead — new feature:**
```
/specos-start → construction perspective
→ spec.md section by section → Lead validates each
→ tasks.md collaboratively → Lead adjusts
→ SP-XX IDs assigned → real IDs collected → tasks.md updated
```

**Dev — implement task:**
```
/specos-start → provide task ID or description
→ agent loads spec.md → implement in context
```

**QA — generate test cases:**
```
/specos-start → provide feature or task ID
→ agent loads spec.md → testcases.md collaboratively
→ QA edits freely → /specos-distribute
```

**Solo builder (agent takes breaking perspective):**
```
/specos-start → construction → finish feature
→ agent proposes: "Want me to take the breaking perspective?"
→ agent generates testcases.md, flags edge cases
```

**Person with multiple roles:**
```
/specos-start → roles: [lead, backend]
→ "Which perspective today? Construction / Breaking / Both"
→ same session, both perspectives, no restart
```

---

## Files per feature

| File | Who writes | What |
|---|---|---|
| `spec.md` | Lead + agent (collaborative) | Journeys, ACs, technical — everything |
| `tasks.md` | Lead + agent (collaborative) | Tasks by role, no checkboxes, max 15 |
| `testcases.md` | QA + agent (collaborative) | Test cases with TC-XX IDs, free-form fields |
| `CHANGELOG.md` | Lead | Spec changes with date and reason |

---

## tasks.md format

```markdown
## Backend
- [SP-01] Description

## Frontend
- [SP-02] Description

## QA
- [SP-03] Description
```

No checkboxes. State lives in the team's task software.

---

## testcases.md format

```markdown
## TC-01 — Title
task: SP-03
steps:
  1. Step one
  2. Step two
expected: Expected result
```

Additional fields are optional and free-form — agent never rejects them.

---

## session.md schema

```markdown
# SpecOS session
updated: YYYY-MM-DD

roles: [lead, backend]
active_feature: feature-folder-name
task_id: SP-01
task_description: Short description
spec_path: specs/feature-name/spec.md
implementation_repos:
  backend: ../repo_back
  frontend: null
  e2e: null
```

Always in `.gitignore`. Never committed.

---

## Grouped specs

Use when a feature is too large or when specs share a domain.

```
specs/
└── payments/              ← group folder
    ├── spec.md            ← summary + list of sub-specs only (type: group)
    ├── checkout/
    │   ├── spec.md
    │   └── tasks.md
    └── refunds/
        ├── spec.md
        └── tasks.md
```

| When | Skill |
|---|---|
| Spec is too large, split into parts | `/specos-split` |
| Multiple specs share a domain | `/specos-group` |

`active_feature` in session.md: `payments/checkout`

---

## specos-standards.yml

Committed config. Edit as the project evolves.

```yaml
# Only `language` is reserved. Add any section your project needs.
language:
  specs: en
  outputs: en

acceptance_criteria:   # → injected into task ACs in /specos-distribute
  backend:
    - "All error responses must include an error code and a message"
  shared:
    - "..."

code_style:            # → injected as ## Standards in task output, enforced by /specos-dev
  backend:
    - "..."
  shared:
    - "No hardcoded environment-specific values — use environment variables"

# Other sections teams add: api_conventions, accessibility, security, naming_conventions
```

Skills read the entire file. No fixed schema beyond `language`. Each section's entries are applied to the matching role and `shared`.

---

## Golden rules

- **No code without a spec** — repo presence = approved
- **No status fields** — task software is the source of truth
- **Max 15 tasks** — if more, split the feature
- **Spec change >50% of content** — create a new feature
- **Every spec change** — add CHANGELOG.md entry

---

## Verifiable AC checklist

```
✓  "Token expires in exactly 24h"
✗  "Should look good"
✓  "Maximum 5 tags — 6th attempt is rejected with error message"
✗  "Tags work correctly"
```

---

*SpecOS v3*
