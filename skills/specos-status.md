# specos-status

Display the current session state. Read-only — no files created or modified.

---

## Step 1 — Find session.md

Look for `session.md` or `.specos/session.md` in the current directory and parent directories.

**If session.md does not exist:**
Print:
```
No active session.
Run /specos-start to begin.
```
Stop here.

---

## Step 2 — Read and display session state

Read `session.md` silently and print a clean summary in this format:

```
SpecOS session — <active_feature or "no feature set">
updated: <updated value>

Roles:          <roles value>
Feature:        <active_feature or "—">
Task:           <task_id — task_description, or "—" if both are null>
Spec:           <spec_path or "—">
Implementation repos:
  backend:      <path or "not configured">
  frontend:     <path or "not configured">
  e2e:          <path or "not configured">
```

Rules:
- Replace `null` values with `—`
- If `task_id` is null but `task_description` is set, show only the description
- If both are set, show: `TASK-XX — description`
- Do not add commentary, suggestions, or extra content after the summary
- Print and stop
