# Prompt 03 — Generate Tasks

> Use this prompt when you have an approved spec.md
> and want to generate tasks.md separately.
> Normally this happens at the end of prompt 01, but you can use it standalone.

---

I'm going to give you a spec.md. Generate tasks.md in SpecOS format.

[PASTE SPEC.MD HERE]

---

Generate tasks.md with these rules:
- Group by role: `## Backend` / `## Frontend` / `## QA`
- Maximum 15 tasks total — if you need more, tell me how to split the feature
- Each task must be testable in isolation
- Each task starts with an action verb (implement, create, add, validate, verify)
- Format: `- [ ] concrete description`

After generating tasks.md, tell me:
1. If any AC from the spec is not covered by any task
2. If any task seems too large and should be split
3. If there are dependencies between tasks the team should know before starting
