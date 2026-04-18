# specos-start

You are the entry point for every SpecOS session. Your job is to read context, ask the minimum necessary questions, and route to the correct skill.

---

## Step 1 — Read session.md

Look for `session.md` or `.specos/session.md` in the current directory.

**If session.md exists:** read it silently. Do not ask any questions. Go to Step 3.

**If session.md does not exist:** go to Step 2.

---

## Step 2 — First-time flow

Read `specos-outputs.yml` to learn the team configuration and the roles of the current person.
Read `AGENTS.md` to understand the project structure.

If neither file exists, respond:
"SpecOS is not initialized in this repo. Run /specos-init first."
Stop here.

Based on the roles declared in `specos-outputs.yml` or `AGENTS.md`, ask one question:

**If role is lead only:**
"What feature do you want to specify?"

**If role is dev/backend/frontend only:**
"What is your task ID or description? (e.g. SP-42 or 'implement login endpoint')"

**If role is qa only:**
"Which spec or task do you want to work on?"

**If role includes multiple options (e.g. lead + backend):**
"What perspective do you take today?
1. Construction — define or refine a spec
2. Breaking — challenge what was built, design test cases
3. Both — start with construction, then switch to breaking"

**If role is builder (solo):**
"What do you want to do?
1. Specify a new feature
2. Implement a task
3. Test what I built"

Wait for the answer before continuing.

---

## Step 3 — Validate implementation repo paths

If the session requires writing code (dev or qa roles), check the implementation repo paths from `session.md` or `AGENTS.md`.

For each path that is not `null`:
- Check if the path is accessible from the current directory
- If not accessible: "I can't reach `[path]`. Please check the path in your session.md or AGENTS.md."
- Do not proceed until all required paths are valid.

If no implementation repos are configured (monorepo), skip this step.

---

## Step 4 — Check for specs

Look for any `spec.md` files inside `specs/`.

**If no specs exist and the role is dev or qa:**
"No specs available right now. Check with your Lead."
Stop here. Do not invent work.

**If no specs exist and the role is lead or builder:**
Continue — lead is about to create the first spec.

---

## Step 5 — Route to the correct skill

Based on the resolved role and perspective, hand off to the appropriate skill:

| Role / Perspective | Skill |
|---|---|
| lead — construction | specos-lead |
| lead — breaking | specos-qa |
| lead — both | specos-lead, then offer specos-qa |
| backend / frontend / dev | specos-dev |
| qa — breaking | specos-qa |
| builder — specify | specos-lead |
| builder — implement | specos-dev |
| builder — test | specos-qa |

Announce the handoff:
"Starting [skill name] for [feature or task]. Let's go."

Then load and follow the instructions of the target skill.

---

## Step 6 — Save session.md

Locate the **specs repo root**: the directory that contains both `specs/` and `specos-outputs.yml`. This is where `session.md` must always be saved, regardless of which directory the agent is currently running from.

- If you found `session.md` in Step 1, save back to that same location.
- If this is a first session, search upward from the current directory for a folder containing `specs/` and `specos-outputs.yml`. Use that as the root.
- Never save `session.md` inside an implementation repo (backend, frontend, e2e).

Write or update `session.md` at that root with the current state:

```markdown
# SpecOS session
updated: YYYY-MM-DD

roles: [role1, role2]
active_feature: feature-folder-name
task_id: TASK-XX
task_description: Short description of the current task
spec_path: specs/feature-name/spec.md
implementation_repos:
  backend: ../repo-back
  frontend: ../repo-front
  e2e: null
```

Use `null` for any field that does not apply. Do not commit this file — it is in `.gitignore`.
