# Flow: /specos-init

> **When to run:** Once per project, by the Lead.
> **What it does:** Asks 6 questions and generates AGENTS.md, constitution.md, specos-outputs.yml, .gitignore entry, and specs/.

---

## Full conversational transcript

The following shows the complete back-and-forth between the user (Lead) and the agent when running `/specos-init` for the first time.

---

> **User**
> ```
> /specos-init
> ```

> **Agent**
>
> Welcome to SpecOS v3. I'll set up this project by asking you 6 questions — one at a time.
>
> **Question 1 of 6**
> What is the name of this project?

---

> **User**
>
> TaskManager Pro

---

> **Agent**
>
> **Question 2 of 6**
> What is your tech stack?
> Include languages, frameworks, and databases. For example: "Django + React + PostgreSQL" or "Node/Express + Next.js + MySQL".

---

> **User**
>
> Django / DRF for the backend, React + TypeScript for the frontend, PostgreSQL

---

> **Agent**
>
> **Question 3 of 6**
> What is your team composition?
>
> 1. **Solo builder** — you design, build, and test alone
> 2. **Small team** — lead + 1-2 devs, QA is shared or handled by the agent
> 3. **Full team** — lead, backend, frontend, and QA are separate people
> 4. **Custom** — describe your own setup

---

> **User**
>
> 2 — small team, QA will be handled by the agent

---

> **Agent**
>
> **Question 4 of 6**
> What are your roles on this project?
>
> Select all that apply: `lead`, `backend`, `frontend`, `qa`, `builder`
>
> (You can hold multiple roles. For example: "lead, backend" or "lead, frontend, qa".)

---

> **User**
>
> lead, backend

---

> **Agent**
>
> **Question 5 of 6**
> What is the structure of this project?
>
> 1. **Monorepo** — specs and all code live in the same repository
> 2. **Separate repos** — this is the specs repo; code lives in separate implementation repos

---

> **User**
>
> 1 — monorepo

---

> **Agent**
>
> **Question 6 of 6** — skipped.
>
> *(Repo paths are only needed for separate-repo setups. Since this is a monorepo, all paths will be set to `.`)*
>
> ---
>
> All questions answered. Generating project files...

---

> **Agent** — files generated
>
> ✓ **AGENTS.md** — project context for all agents
> ✓ **constitution.md** — the 8 non-negotiable rules for this project
> ✓ **specos-outputs.yml** — team configuration and integration settings
> ✓ **.gitignore** — updated with `session.md` entry
> ✓ **specs/** — directory created, ready for your first feature
>
> ---
>
> **SpecOS v3 initialized.**
>
> Commit these files to your repo — they are your project's source of truth.
> `session.md` is already in .gitignore and will never be committed.
>
> **Next step:** run `/specos-start` to begin your first session.

---

## What was generated

### AGENTS.md (excerpt)
```markdown
# AGENTS.md — TaskManager Pro

## Project context
TaskManager Pro is a task management application...

## Tech stack
- Backend: Django / DRF, Python
- Database: PostgreSQL
- Frontend: React + TypeScript

## Team and roles
| Role     | Person | Responsibility              |
|----------|--------|-----------------------------|
| Lead     | —      | Writes specs, approves PRs  |
| Backend  | —      | API and business logic      |
| QA       | agent  | Test cases (breaking perspective) |
```

### specos-outputs.yml (excerpt)
```yaml
version: "1.0"
language: en

team:
  lead: human
  qa: agent

ids:
  task_prefix: SP
  testcase_prefix: TC

integrations:
  jira:
    enabled: false
  linear: false
  github_issues: false

outputs:
  tasks:
    destination: manual
  testcases:
    destination: manual
```

---

## Notes

- Question 6 (implementation repo paths) is only asked when you choose **separate repos** in question 5.
- The `qa: agent` setting in `specos-outputs.yml` means the agent automatically takes the breaking perspective when running `/specos-qa`. A human QA can still override this.
- You can edit any generated file after init. Run `/specos-init` again only to fully reset (it will overwrite existing files).
