# SpecOS — Cheat Sheet

> One page. Everything you need for daily work.

---

## The flow in 3 moments

```
1. CREATE        Lead + AI → spec.md + tasks.md (collaborative session)
2. IMPLEMENT     Dev reads spec.md + their task → codes → marks [x] → PR
3. DISTRIBUTE    Lead uses outputs/ prompts → copies to Confluence/Jira/Notion
```

---

## Session startup commands

**Lead — new feature:**
```
Paste: prompts/01-collaborative-session.md
Then: describe the feature in natural language
```

**Backend / Frontend / QA — implement:**
```
Paste: spec.md of the feature
Paste: your specific task from tasks.md
Work in that context
```

**Lead — generate outputs:**
```
/document-module → output-confluence.md + spec.md
/flow            → output-flows.md + spec.md
/task            → output-jira.md + spec.md + tasks.md
/steps-to-test   → output-test.md + spec.md + tasks.md
```

---

## Files per feature

| File | Who writes it | What it contains |
|---|---|---|
| `spec.md` | Lead + AI (collaborative) | Journeys, ACs, technical — everything |
| `tasks.md` | Lead + AI (collaborative) | Tasks by role, max 15 |
| `CHANGELOG.md` | Lead | Spec changes with date and reason |

---

## spec.md header

```markdown
---
feature: feature-name-in-kebab-case
version: 1.0
status: draft
lead: name
date: YYYY-MM-DD
---
```

Statuses: `draft` → `approved` → `in-development` → `complete`

---

## Approval checklist

- [ ] Has at least 1 error journey
- [ ] All ACs are verifiable (not descriptive)
- [ ] Has out of scope with at least 1 item
- [ ] API contracts defined if there are new endpoints
- [ ] Under 150 lines — if over, split the feature

---

## PR format

```
feat: task description

PROJ-XX #done
Spec: specs/[feature]/spec.md (task [role] #N)
```

---

## Golden rule

**Verifiable AC:** "Token expires in exactly 24h" ✓
**Descriptive AC:** "Should look good" ✗

**Feature too large:** over 150 lines or over 15 tasks → split feature

**Agent without context:** always paste spec.md before asking for code

---

## Available prompts

```
prompts/
├── 00-repo-setup.md              ← first time, creates the full repo
├── 01-collaborative-session.md   ← new feature, lead's main prompt
├── 02-generate-spec.md           ← simple feature, quick generation
├── 03-generate-tasks.md          ← tasks from already approved spec
├── outputs/
│   ├── output-confluence.md      ← /document-module
│   ├── output-flows.md           ← /flow
│   ├── output-jira.md            ← /task
│   └── output-test.md            ← /steps-to-test
└── meta/
    └── how-to-create-output-prompt.md  ← create prompt for new tool
```

---

*SpecOS v2.0*
