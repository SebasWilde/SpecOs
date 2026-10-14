# specos-dev

You are helping a developer implement a task. Your job is to load only the relevant spec, understand the task, and work in the correct implementation repo.

---

## Step 1 — Identify the task

If `session.md` exists and has a `task` other than `null`, load it silently (for `[new]`, match by `next` or title in `active_feature`'s `tasks.md`). Skip to Step 2.

If no task is loaded, ask:
"What is your task key or description? (e.g. FK-42 or 'implement login endpoint')"

Search all `tasks.md` files in `specs/` for the key or a title match — look in both `specs/*/tasks.md` and `specs/*/*/tasks.md`. Skip group-level folders (they have no tasks.md). Old `[SP-01]` lines are legacy placeholders, not ticket keys.

If found, confirm: "Found task [key] in [feature-name]: [title]. Correct?"
If not: "I couldn't find that task in any spec. Check the key or ask your Lead."

---

## Step 2 — Load only the relevant spec

Read `specs/[feature-name]/spec.md` for the matched feature.

Read no other spec and load no unrelated context.

**Refuse when the spec is not ready.** If it has `status: draft` or its Open questions is not empty and the task cannot be separated from them, say "This spec is still a draft — tell the Lead" and stop. If an AC the task references is marked `[pending]`, refuse only this task and name the AC. A spec without `status` is treated as approved.

**Show the task's ACs** — the full text of each AC in the task's refs (`AC1–AC3`, ranges included) — and the sketched flows in `testcases.md` that cover them, as a self-check before coding.

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

**Before reading any source file in the implementation repo**, recover what was learned there. Resolve the location from `memory_links` in `local-workspace.yml`:

- **`off`** — skip memory. Go to Step 4.
- **A path** — use it verbatim.
- **`auto`, or the key is missing** — derive it from the running agent's convention. Claude Code: `~/.claude/projects/<absolute repo path with every `/` replaced by `-`>/memory`. Agent with no memory system: `.specos/memory.md` inside the repo.

If the location does not exist, continue without memory; never create directories for other repos. If the key was missing, mention once at the end: "`[key]` isn't mapped in local-workspace.yml — run `/specos-start` to map it."

Read the **index only** and open an entry only when its description relates to this task. **Verify before trusting**: confirm any path, module, or symbol it names still exists, and correct a stale entry now. Memory tells you *where* and *how*, never *what* — nothing in it authorizes work without a spec. If it already answers where this task's code belongs, go straight there.

---

## Step 4 — Implement

Work from the spec. For each piece of code you write:
- Reference the AC or journey it satisfies
- Stay within the scope of the assigned task — do not implement adjacent tasks
- Follow conventions from `AGENTS.md`
- Do not use `print()` or `console.log()` unless the spec explicitly requires logging output

On a gap (missing AC, ambiguity, a wrong AC, an edge case): stop and follow the spec change request protocol in `specos-lead` — classify it, state what you found, the proposed AC text and 1–2 options. If your role includes lead or builder, continue in change mode in this same session; otherwise print the request for the Lead and keep working on what it does not block. Changes to spec.md require Lead approval; an agent may write them only after that approval. Never invent requirements.

---

## Step 5 — Save session

Rewrite the whole `session.md`, never append — schema in `/specos-start` Step 6.

Then print a closing block for the PR or ticket (no file):
```
[key] · spec [feature] v[X.Y] · covers AC…
Spec changes during dev: v[X]→v[Y] (…)
Deviations: …
```

---

## Step 6 — Record what stays true

If you learned something about the **implementation repo** that will still be true next month, write it to **that repo's** memory location — the one resolved in Step 3.5 — not to the specs repo's memory. Knowledge has to land where the next session will look for it.

Worth recording:
- Where a kind of code lives, and why
- A convention not written in `AGENTS.md` or `specos-project.yml`
- A gotcha that cost you time
- Which files a feature touched, when not obvious from the spec

Not worth recording:
- The narrative of this session
- Anything already in the spec, `AGENTS.md`, `specos-project.yml`, or the commit history
- Anything you did not verify

With no memory system, append to `.specos/memory.md` in that repo (gitignored).

Keep entries short and factual; update an existing entry rather than adding a near-duplicate. Memory is local — never commit it, and it never substitutes for a spec.
