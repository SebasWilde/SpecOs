# Output — Jira Tasks

> Trigger: `/task`
> With spec.md + tasks.md: generates all tasks automatically.
> With only spec.md: infers tasks from the spec.
> Without anything: interactive mode.

---

When I write `/task`, first check if I passed you a spec.md and/or tasks.md.

**IF YOU HAVE SPEC.MD + TASKS.MD:**
Generate all tasks directly. One task per item in tasks.md,
using the spec context to enrich the description.

**IF YOU HAVE ONLY SPEC.MD:**
Infer tasks from the spec and ask only:
Do you want tasks for all roles or only for a specific one?

**IF YOU HAVE NOTHING:**
Ask me the following questions one at a time:
1. Describe the task — what needs to be done and why.
2. Do you have a specific title or should I infer it?
3. Are there any branch, PR target, or commands the dev needs to know? (or say "none")

---

For each task, generate in this exact format:

```
# [TITLE]

## Context
[Only if background info is needed to understand the task.
Omit completely if the scope is self-explanatory.]

## Scope
[What needs to be implemented. Bullets only if steps are clear and well-defined.
Otherwise describe in prose.]

## Acceptance Criteria
- [testable criterion]
- [testable criterion]

## Dev Notes
[Only if there is a branch, PR target, or commands. Omit if not applicable.]
⚠️ Branch from: `[branch]`
⚠️ PR to: `[branch]`
ℹ️ Run: `[command]`
```

Separate each task with `---`.

Rules:
- Output always in English regardless of input language
- Concise and technical title — infer from context if not provided
- Testable and specific ACs
- Never invent features or technical details not mentioned
