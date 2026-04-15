# specos-init

You are setting up SpecOS v3 for a new project. Your job is to ask exactly 6 questions, then generate the required files. Do not generate any file before all 6 answers are collected.

---

## Protocol

Ask the questions one at a time. Wait for the user's answer before asking the next one.

**Question 1 — Project name**
"What is the name of this project?"

**Question 2 — Stack**
"What is your tech stack? (languages, frameworks, databases — be as brief or detailed as you like)"

**Question 3 — Team composition**
"What is your team setup? Choose one:
1. Solo builder — you design, build, and test alone
2. Small team — lead + 1-2 devs, QA is shared or agent
3. Full team — lead, backend, frontend, QA as separate roles
4. Custom — I'll describe my own setup"

**Question 4 — Roles for this person**
"What roles do you hold on this project? You can select multiple:
- lead (writes and approves specs)
- backend (implements API and business logic)
- frontend (implements UI)
- qa (designs and runs tests)
- builder (designs + builds + tests — solo role)"

**Question 5 — Project structure**
"How is your code organized?
1. Monorepo — specs and code live in the same repo
2. Separate repos — this is the specs repo, code lives elsewhere"

**Question 6 — Implementation repo paths** *(ask only if answer to Q5 was "separate repos")*
"What are the paths to your implementation repos relative to this folder?
Provide one per role that applies. Example:
- backend: ../repo-backend
- frontend: ../repo-frontend
- e2e: ../repo-e2e
Leave a role as `null` if it does not apply."

*(If answer to Q5 was "monorepo", skip Q6 and use `null` for all implementation repo paths.)*

---

## File generation

After all answers are collected, generate the following files in order. Announce each file as you create it.

### 1. AGENTS.md

Generate a project-specific `AGENTS.md` using the answers. Include:
- Project name and one-line description (inferred from stack if not provided)
- Tech stack summary
- Team roles and who holds them
- SpecOS structure: `specs/`, `skills/`, `session.md` (gitignored)
- Implementation repo paths if separate repos
- Rule: no agent writes code without a spec in the repo
- Rule: only Lead modifies `spec.md`
- Rule: `session.md` is never committed

### 2. constitution.md

Generate `constitution.md` with exactly these 8 rules:

1. Construction perspective always exists — someone defines and approves the spec before any code is written.
2. Breaking perspective always exists — it cannot be the same logic that built the feature.
3. No agent writes code without a spec committed to the repo.
4. Only the Lead role modifies `spec.md`.
5. Maximum 15 tasks per feature — split into a new feature if more are needed.
6. All outputs are written in English by default.
7. A spec change affecting more than 50% of the content is a new feature, not an update.
8. Every spec change requires a `CHANGELOG.md` entry: date, what changed, and why.

### 3. specos-outputs.yml

Generate `specos-outputs.yml` using the team composition answers:

```yaml
version: "1.0"
language: en

team:
  lead: human         # human | agent
  qa: human           # human | agent | both

ids:
  task_prefix: SP
  testcase_prefix: TC

integrations:
  jira:
    enabled: false
    mcp: null
  confluence:
    enabled: false
    mcp: null
  notion:
    enabled: false
  linear:
    enabled: false
  github_issues:
    enabled: false
  slack:
    enabled: false

outputs:
  tasks:
    destination: manual
  testcases:
    destination: manual
  confluence_doc:
    destination: manual
```

Set `team.qa: agent` if the user selected solo builder or indicated QA is handled by the agent. Otherwise `human`.

### 4. .gitignore entry

If a `.gitignore` already exists, append to it. If not, create it. Add:

```
# SpecOS session state — local only, never committed
.specos/session.md
session.md
```

### 5. specs/ directory

Create the `specs/` directory if it does not exist. Do not create any files inside it.

---

## Confirmation message

After all files are generated, print:

```
SpecOS v3 initialized.

Files created:
  AGENTS.md
  constitution.md
  specos-outputs.yml
  .gitignore (updated)
  specs/

Next step: run /specos-start to begin your first session.
```
