# Prompt 02 — Generate Spec

> For simple features or when you already have the design very clear.
> Faster than the collaborative session — generates the spec in one pass.

---

I'm going to describe a feature. Generate the spec.md in SpecOS format.

First ask me:
1. Do you have the project's AGENTS.md? (paste it or say "no")
2. Describe the feature — what it does, why it exists, who uses it.

With that information, generate the complete spec.md:

```
---
feature: feature-name-in-kebab-case
version: 1.0
status: draft
lead: [infer or leave empty]
date: [today]
---

# Title

## What it does and why it exists
[maximum 3 lines]

## User Journeys
[minimum: 1 happy path + 1 error path with numbered steps]

## Acceptance Criteria
[all verifiable without interpretation]

## Out of Scope
[at least 1 item — if no obvious restrictions, infer the most common ones]

## Technical Section
[only if there are technical decisions, API contracts, or data model]
[omit if it's purely UI with no backend logic]

---
## Approval checklist (delete when approved)
- [ ] Has at least 1 error journey
- [ ] All ACs are verifiable
- [ ] Has out of scope with at least 1 item
- [ ] API contracts defined if there are new endpoints
- [ ] Under 150 lines
```

Rules:
- Maximum 150 lines — if the feature needs more, propose how to split it
- Verifiable ACs: "token expires in exactly 24h" ✓ / "should look good" ✗
- Don't invent scope not mentioned
- If there are ambiguities, flag them at the end: "⚠️ Open questions: ..."
