# specos-dev

You are helping a developer implement a task. Your job is to load only the relevant spec, understand the task, and work in the correct implementation repo.

---

## Step 1 — Identify the task

If `session.md` exists and has a `task_id`, load it silently. Skip to Step 2.

If no task is loaded, ask:
"What is your task ID or description? (e.g. SP-42 or 'implement login endpoint')"

Search all `tasks.md` files in `specs/` for the task ID or a description match — look in both `specs/*/tasks.md` and `specs/*/*/tasks.md`. Skip group-level folders (they have no tasks.md).

If found: confirm — "Found task [ID] in feature [feature-name]: [task description]. Is this correct?"
If not found: "I couldn't find that task in any spec. Check the task ID or ask your Lead."

---

## Step 2 — Load only the relevant spec

Read `specs/[feature-name]/spec.md` for the matched feature.

Do not read any other spec. Do not load unrelated context.

Read `AGENTS.md` to understand the project structure (stack, conventions, repo layout).

Read `specos-standards.yml` if it exists. Collect ALL entries for the task's role and `shared` across every section (except `language`). Apply them as hard constraints throughout implementation — they override any convention not explicitly stated in the spec.

---

## Step 3 — Confirm the implementation repo

Check `local-workspace.yml` for `implementation_repos`.

If the task role requires a specific repo (e.g. backend task → `implementation_repos.backend`):
- Check that the path exists and is accessible
- If not accessible: "I can't reach `[path]`. Please update the path in local-workspace.yml."
- Do not proceed until the path is valid

If the project is a monorepo, work in the current directory.

---

## Step 4 — Implement

Work from the spec. For each piece of code you write:
- Reference the AC or journey it satisfies
- Stay within the scope of the assigned task — do not implement adjacent tasks
- Follow conventions from `AGENTS.md`
- Do not use `print()` or `console.log()` unless the spec explicitly requires logging output

If you encounter something that requires a spec change (missing AC, ambiguous requirement, discovered edge case):
"This case is not covered by the spec: [description]. I'll stop here — this needs a spec update before I continue."
Do not invent requirements.

---

## Step 5 — Save session

After the session, update `session.md`:
- `task_id`: the current task ID
- `task_description`: short description
- `active_feature`: the feature folder name
- `spec_path`: path to the spec
