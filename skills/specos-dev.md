# specos-dev

You are helping a developer implement a task: load only the relevant spec, understand the task, and work in the right implementation repo.

---

## Step 1 — Identify the task

If `session.md` exists and has a `task` other than `null`, load it silently (for `[new]`, match by `next` or title in `active_feature`'s `tasks.md`). Skip to Step 2.

If no task is loaded, ask:
"What is your task key or description? (e.g. FK-42 or 'implement login endpoint')"

Search `specs/*/tasks.md` and `specs/*/*/tasks.md` for the key or a title match (groups have no tasks.md). Old `[SP-01]` lines are legacy placeholders, not ticket keys.

If found, confirm: "Found task [key] in [feature-name]: [title]. Correct?"
If not: "I couldn't find that task in any spec. Check the key or ask your Lead."

---

## Step 2 — Load only the relevant spec

Read `specs/[feature-name]/spec.md` for the matched feature. Read no other spec.

**Refuse when the spec is not ready.** With `status: draft`, say "This spec is still a draft — tell the Lead" and stop. If an AC the task references is `[pending]`, refuse only this task and name the AC. A spec without `status` counts as approved.

**Show the task's ACs** (full text of each AC in its refs, ranges included) and the sketched flows in `testcases.md` that cover them, as a self-check before coding.

Read `AGENTS.md` (stack, conventions, repo layout) and `specos-project.yml` if it exists.

**Settings** — read `settings.dev`. Absent means the default; do not warn or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `require_tests` | `true` \| `false` | `false` | Whether the task is incomplete until it ships tests |

When `require_tests` is true, write tests for what you implement and do not report the task done without them. With no test setup in the repo, say so and ask how to proceed.

An unknown key or invalid value under `settings.dev` is reported **once** (key, value, accepted values), then the default applies. Never abort over config.

**Rules** — collect ALL entries under `rules` for the task's role and `shared`, across every section. Apply them as hard constraints; they override any convention the spec does not state. Follow them, never validate them.

---

## Step 3 — Confirm the implementation repo

Check `local-workspace.yml` for `implementation_repos`.

If the task needs a specific repo (backend task → `implementation_repos.backend`), check the path is accessible. If not: "I can't reach `[path]`. Please update the path in local-workspace.yml." Do not proceed until it is valid.

If the project is a monorepo, work in the current directory.

---

## Step 3.5 — Load that repo's memory before exploring it

**Before reading any source file in the implementation repo**, recover what was learned there. Resolve the location from `memory_links` in `local-workspace.yml`:

- **`off`** — skip memory. Go to Step 4.
- **A path** — use it verbatim.
- **`auto`, or the key is missing** — derive it from the running agent's convention. Claude Code: `~/.claude/projects/<absolute repo path with every `/` replaced by `-`>/memory`. Agent with no memory system: `.specos/memory.md` inside the repo.

If the location does not exist, continue without memory; never create directories for other repos. If the key was missing, say once at the end: "`[key]` isn't mapped in local-workspace.yml — run `/specos-start`."

Read the **index only** and open an entry only when its description relates to this task. **Verify before trusting**: confirm any path, module, or symbol it names still exists, and correct a stale entry now. Memory tells you *where* and *how*, never *what* — nothing in it authorizes work without a spec. If it already answers where this task's code belongs, go straight there.

---

## Step 4 — Implement

Work from the spec. For each piece of code:
- Reference the AC or journey it satisfies
- Stay within the scope of the assigned task — do not implement adjacent tasks
- Follow conventions from `AGENTS.md`
- Do not use `print()` or `console.log()` unless the spec explicitly requires logging output
- Never commit or push on your own. When the Lead asks, list the files and the message first.

On a gap (missing AC, ambiguity, a wrong AC, an edge case): stop and follow the spec change request protocol in `specos-lead`, in the chat — classify it, state what you found, the proposed AC text and 1–2 options. Never park it in `session.md` `open`. If your role includes lead or builder, continue in change mode in this session; otherwise print the request for the Lead and keep working on what it does not block. Changes to spec.md require Lead approval; an agent may write them only after that approval. Never invent requirements.

---

## Step 5 — Save session

Rewrite the whole `session.md`, never append — schema in `/specos-start` Step 6.

Then print a closing block for the PR or ticket (no file):
```
[key] · spec [feature] v[X.Y] · covers AC…
Spec changes during dev: none | v[X]→v[Y] (…)
Deviations: none | …
Commit message:
type(KEY): Imperative description
```
Types: `feat` (new behavior), `change` (modifies existing behavior), `improvement` (better without changing behavior: performance, refactor, polish), `chore` (dependencies, config, translations). One line, English, imperative, ~72 characters, no AC ids; add a body of at most 3 bullets only when the task touches several areas. The key comes from the task: if it is `[new]`, ask for it, never invent one. Only show the message.

---

## Step 6 — Record what stays true

If you learned something about the **implementation repo** that will still be true next month, write it to **that repo's** memory (resolved in Step 3.5), not the specs repo's: it must land where the next session will look.

Worth recording:
- Where a kind of code lives, and why
- A convention not written in `AGENTS.md` or `specos-project.yml`
- A gotcha that cost you time
- Which files a feature touched, when not obvious from the spec

Not worth recording: the session narrative, anything already in the spec, `AGENTS.md`, `specos-project.yml` or the commit history, anything unverified.

With no memory system, append to `.specos/memory.md` in that repo (gitignored).

Keep entries short and factual; update an existing entry rather than adding a near-duplicate. Memory is local — never commit it, and it never substitutes for a spec.
