# specos-status

Display the current session state. Read-only — no files created or modified.

---

## Step 1 — Find session files

Look for `local-workspace.yml`, `session.md`, and `specos-project.yml` in the current directory and parent directories.

**If neither file exists:**
Print:
```
No active session.
Run /specos-start to begin.
```
Stop here.

---

## Step 2 — Read and display session state

Read both files silently (use whichever exist) and print a clean summary in this format:

```
SpecOS session — <active_feature or "no feature set">
updated: <updated value or "—">

User:           <user from local-workspace.yml or "—">
Roles:          <roles from local-workspace.yml or "—">
Feature:        <active_feature or "—">
Task:           <task_id — task_description, or "—" if both are null>
Spec:           <spec_path or "—">
Implementation repos:
  backend:      <path from local-workspace.yml or "not configured">
  frontend:     <path from local-workspace.yml or "not configured">
  e2e:          <path from local-workspace.yml or "not configured">
Memory links:
  self:         <state>
  backend:      <state>
  frontend:     <state>
  e2e:          <state>
Settings:
  <skill>.<key>: <value>
  <all others at default>
```

Rules:
- Replace `null` values with `—`
- Memory link state, per repo key:

  | State | When |
  |---|---|
  | `linked` | value is a path and that location exists |
  | `auto` | value is `auto` and the derived location exists |
  | `auto (empty)` | value is `auto` but nothing exists there yet |
  | `off` | value is `off` |
  | `unmapped` | the repo has a path but no key in `memory_links` |
  | `broken` | value is a path that does not exist |

- Only check that locations exist — never read their contents in this skill
- Omit the whole `Memory links` block when no `implementation_repos` are configured (monorepo)
- Settings: list only the keys actually present under `settings` in `specos-project.yml`, one per line as `<skill>.<key>: <value>`. Then one final line naming how many of the 10 are running on their default: `<N> others at default`. Never print all 10 with their defaults — `/specos-config` does that.
- If `settings` is absent or empty, the whole block is one line: `all at default`
- If `specos-project.yml` is missing but `specos-outputs.yml` or `specos-standards.yml` exists, replace the Settings block with: `config not migrated — run /specos-start`
- Omit the whole `Settings` block when no config file of any kind exists
- If any key is `unmapped` or `broken`, print one line after the summary: `Run /specos-start to map: [keys]`. Nothing else — no commentary.
- If `task_id` is null but `task_description` is set, show only the description
- If both are set, show: `TASK-XX — description`
- Do not add commentary, suggestions, or extra content after the summary
- Print and stop
