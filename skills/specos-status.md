# specos-status

Display the current session state, or with `--check` run the deterministic check (see the Check step). Read-only.

---

## Step 1 — Find session files

Look for `local-workspace.yml`, `session.md`, and `specos-project.yml` in the current and parent directories.

**If none exists**, print `No active session.` and `Run /specos-start to begin.`, then stop.

---

## Step 2 — Read and display session state

Read the files silently (whichever exist) and print:

```
SpecOS session — <active_feature or "no feature set">
updated: <updated value or "—">

User:           <user or "—">
Roles:          <roles or "—">
Feature:        <active_feature or "—">
Spec version:   <spec_version or "—">
Task:           <task or "—">
Next:           <next or "—">
Open:           <open items, one per line>
Parked:         <parked items, one per line>
Implementation repos:
  backend:      <path or "not configured">
  frontend:     <path or "not configured">
  e2e:          <path or "not configured">
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
- `null` shows as `—`; user, roles and repos come from local-workspace.yml
- Memory link state, per repo key:

  | State | When |
  |---|---|
  | `linked` | value is a path and that location exists |
  | `auto` | value is `auto` and the derived location exists |
  | `auto (empty)` | value is `auto` but nothing exists there yet |
  | `off` | value is `off` |
  | `unmapped` | the repo has a path but no key in `memory_links` |
  | `broken` | value is a path that does not exist |

- Only check that locations exist — never read their contents
- Omit the whole `Memory links` block when no `implementation_repos` are configured (monorepo)
- Settings: list only keys present under `settings`, one per line as `<skill>.<key>: <value>`, then `<N> others at default` (N of the 13). Never print all 13 — `/specos-config` does that. Absent or empty `settings`: one line, `all at default`.
- No `specos-project.yml` but an old config file: Settings block = `config not migrated — run /specos-start`; no config at all: omit the block
- If any key is `unmapped` or `broken`, print after the summary: `Run /specos-start to map: [keys]`
- Omit `Open` and `Parked` when empty
- An old-format session.md is shown as-is plus `old session format — /specos-start offers to migrate it`
- No other commentary — print and stop

---

## Check — `/specos-status --check`

Run `bash ~/.specos/specos-check.sh <specs repo root>` and print its output unchanged. Flags: `--strict` (exit 1 on any warning), `--impacts <feature>` (specs linking to it). If the script is missing: "Run update.sh from the SpecOS repo." Warnings are advice, never a reason to stop.
