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

Read `specos-project.yml` if it exists.

**Settings** — read `settings.dev` and obey it. Absent means the default; do not warn about an absent file or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `require_tests` | `true` \| `false` | `false` | Whether the task is incomplete until it ships tests |

When `require_tests` is true, write tests for what you implement and do not report the task as done without them. If the repo has no test setup at all, say so and ask how to proceed rather than skipping silently.

An unknown key under `settings.dev`, or a value outside the accepted set, is reported **once** — name the key, the value found, and what is accepted — then fall back to the default and continue. Never abort over config.

**Rules** — collect ALL entries under `rules` for the task's role and `shared`, across every section. Apply them as hard constraints throughout implementation — they override any convention not explicitly stated in the spec. Rules are sentences: follow them, never validate them.

---

## Step 3 — Confirm the implementation repo

Check `local-workspace.yml` for `implementation_repos`.

If the task role requires a specific repo (e.g. backend task → `implementation_repos.backend`):
- Check that the path exists and is accessible
- If not accessible: "I can't reach `[path]`. Please update the path in local-workspace.yml."
- Do not proceed until the path is valid

If the project is a monorepo, work in the current directory.

---

## Step 3.5 — Load that repo's memory before exploring it

**Do this before reading any source file in the implementation repo.** Separate repos mean separate agent memory: what you learned last time you worked in the backend repo is not in scope when the session starts from the specs repo. This step recovers it.

Resolve the memory location for the target repo from `memory_links` in `local-workspace.yml`:

- **`off`** — skip memory entirely for this repo. Go to Step 4.
- **A path** — use it verbatim.
- **`auto`, or the key is missing** — derive it from the running agent's own convention:
  - **Claude Code:** `~/.claude/projects/<absolute repo path with every `/` replaced by `-`>/memory`
  - **Any agent that scopes memory per project directory:** apply that agent's convention.
  - **Agent with no memory system:** look for `.specos/memory.md` inside the repo.

If the resolved location does not exist, that repo has no memory yet — continue without it and go to Step 4. Never create memory directories for other repos preemptively.

If the key was missing rather than set, mention it once at the end of the session: "`[key]` isn't mapped in local-workspace.yml — run `/specos-start` to map it." Do not stop to ask mid-task.

Then:
- Read the **index only** (`MEMORY.md` or equivalent). Open an individual memory file only when its description relates to this task.
- **Verify before trusting.** Any path, module, or symbol a memory names must be confirmed to still exist before you act on it. If it is stale, correct that memory file now.
- **Memory never replaces the spec.** It tells you *where* code lives and *how* this repo does things. It never tells you *what* to build — that is the spec's job, and nothing in memory authorizes work without one.

If memory already answers where this task's code belongs, go straight there. Do not re-explore what memory and verification already confirmed.

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

---

## Step 6 — Record what stays true

If you learned something about the **implementation repo** that will still be true next month, write it to **that repo's** memory location — the one resolved in Step 3.5 — not to the specs repo's memory. Knowledge has to land where the next session will look for it.

Worth recording:
- Where a kind of code lives, and why it lives there
- A convention this repo follows that is not written in `AGENTS.md` or `specos-project.yml`
- A gotcha that cost you time and will cost the next session the same
- Which files a feature actually touched, when that mapping is not obvious from the spec

Not worth recording:
- The narrative of this session
- Anything already in the spec, `AGENTS.md`, `specos-project.yml`, or the commit history
- Anything you did not verify

If the agent has no memory system, append to `.specos/memory.md` in that repo and make sure `.specos/` is gitignored there.

Keep entries short and factual, and update an existing entry rather than adding a near-duplicate. Memory is local and per-machine — never commit it, and never treat it as a substitute for a spec.
