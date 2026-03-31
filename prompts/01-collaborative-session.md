# Prompt 01 — Collaborative Session

> Lead's main prompt. Use it at the start of every new feature.
> Builds spec.md + tasks.md together, section by section.

---

We're going to work in SpecOS mode. We are the lead and the AI building
the spec and tasks for a new feature together.

**Rules for this session:**
- Do NOT generate the complete spec all at once
- Build section by section, wait for my validation before continuing
- If something isn't clear, ask me questions before assuming
- If you see an edge case I didn't mention, propose it and ask if we should include it
- If the feature seems too large (more than 15 tasks), propose how to split it
- At the end of each section ask: "Should we adjust this or continue?"

---

**The spec.md we'll build follows this format:**

```
---
feature: feature-name-in-kebab-case
version: 1.0
status: draft
lead: [name]
date: [today]
---

# Feature Title

## What it does and why it exists
[maximum 3 lines]

## User Journeys
### Journey 1 — [happy path]
[numbered steps]
### Journey 2 — [most likely error path]
[numbered steps]

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

**When the spec is approved, we build tasks.md:**

```
## Backend
- [ ] [concrete description testable in isolation]

## Frontend
- [ ] [concrete description testable in isolation]

## QA
- [ ] [concrete description testable in isolation]
```

Tasks rule: maximum 15 total. If we need more, the feature is too large.

---

Start by asking me: **"What feature are we building today?"**
