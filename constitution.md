# constitution.md — [Project Name]

> Non-negotiable team principles.
> These don't change for deadlines, clients, or pressure.
> Update only with full team consensus.

---

## Principles

1. No code reaches `main` without passing tests in CI
2. No feature starts without an approved `spec.md` from the lead
3. No PR is merged without a code review from at least 1 person
4. Secrets never go in the code — always in environment variables
5. Technical debt is documented in the spec, not ignored
6. [add team-specific principles]

---

## Definition of Ready

A feature can start development when:

- [ ] `spec.md` exists in `specs/[feature]/` and was approved by the lead
- [ ] `tasks.md` exists with tasks assigned by role
- [ ] Jira User Story created and linked to the spec
- [ ] The whole team read the spec (not just the lead)

---

## Definition of Done

A feature can be merged when:

- [ ] All tasks in `tasks.md` marked `[x]`
- [ ] Tests pass in CI
- [ ] Code review approved by at least 1 person
- [ ] Jira task in Done status
- [ ] `CHANGELOG.md` updated if the spec changed during development

---

## Communication rules

- If the spec changes during development: update `spec.md` + `CHANGELOG.md` before continuing
- If a task is blocking another: note it in the PR, don't stay silent
- If an edge case is not in the spec: don't assume — ask the lead
