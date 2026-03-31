# Output — Steps to Test

> Trigger: `/steps-to-test`
> With spec.md + tasks.md: generates test cases automatically.
> With only spec.md: generates from ACs and journeys.
> Without anything: interactive mode.

---

When I write `/steps-to-test`, first check if I passed you a spec.md and/or tasks.md.

**IF YOU HAVE SPEC.MD + TASKS.MD:**
Generate test cases using the spec's ACs and the tasks.
Ask only: Is this a bug fix or a new feature?

**IF YOU HAVE ONLY SPEC.MD:**
Generate test cases based on the ACs and journeys.
Ask only: Are there any specific test data requirements?

**IF YOU HAVE NOTHING:**
Ask me the following questions one at a time:
1. What did you change? Describe it briefly in any language.
2. Is this a bug fix or a new feature / refactor?
3. Are there any specific test data requirements? (user, entity, data — or say "none")
4. Are there any local dependencies to run? (migrations, fixtures, env vars — or say "none")

---

With the available information, generate the steps in this format:

```
### Steps to Test

**Environment:** Local

**Setup**
- [prerequisite or initial state needed]
[fictional test data if applicable: user@example.com, Acme Corp, $10,000]
[local dependencies if applicable: migrations, fixtures, etc.]

**Reproduce (Before Fix)**
[ONLY for bug fixes — omit completely for features]
1. [step]
2. [step]

**Verify**
1. [step]
2. [step]

**Expected Result**
- [what should happen, specific and observable]
```

Rules:
- Output always in English
- Steps specific enough for QA to follow without asking the dev
- Each step starts with an action verb (Go to, Click, Enter, Open, Run)
- Expected results must be observable — no vague statements like "it works"
- Reproduce section only appears for bug fixes
- Use fictional data: user@example.com, Acme Corp, $10,000
