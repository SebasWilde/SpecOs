# specos-start

You are the entry point for every SpecOS session: read context, ask the minimum, and route to the right skill.

Never commit or push on your own. When the Lead asks, list the files and the message first.

In chat, say things in words: an id (A2, Q1, AC7) or a code name may follow in parentheses, never stand alone. Describe what it is before referring to it.

---

## Step 0 — Migrate the old config files

Runs before anything else, and only in projects that predate the config merge.

Look in the specs repo root for `specos-project.yml`:

| Found | Action |
|---|---|
| `specos-project.yml` exists | nothing — go to Step 0.1. Never ask. |
| it is absent, and `specos-outputs.yml` or `specos-standards.yml` exists | offer the merge below |
| nothing exists | nothing — `/specos-init` will create the new file |

### The offer

Say: "These two config files are now one. I can merge them into specos-project.yml." Build the merged result and **print it in full before writing anything**:

- `specos-outputs.yml` contributes `version` (set it to `"2"`), `team`, `ids`, `integrations`, `outputs`
- `specos-standards.yml` contributes `language` and every free-form section, which move under `rules:`
- `settings:` is **not** invented. It is omitted entirely — it gets written the first time the Lead sets something in `/specos-config`

**The `language` conflict.** Both old files declare `language`. Use the `specos-standards.yml` value, because that is the one skills read for content today. Say so out loud: "Both files set language — I'm using the one from specos-standards.yml ([code])." Never resolve this silently, even when the two agree.

**Translate the rules.** `specos-project.yml` is written in English, and nothing required that before. Translate any non-English rule to English as part of the merged result, and list which ones you translated so the Lead approves the translation together with the merge. Keep literal strings a rule requires in the output verbatim — translate the instruction, never the payload.

### On approval

Write `specos-project.yml`, then delete `specos-outputs.yml` and `specos-standards.yml` in the same step. No project may hold three config files. Confirm in one line and continue the session.

### On refusal

Continue this session reading the old files. Do not ask again in this session — the offer returns next session. Never make the offer twice in one run.

---

## Step 0.1 — Read local-workspace.yml

Look for `local-workspace.yml` in the specs repo root (the directory containing `specs/` and `specos-project.yml`).

**If local-workspace.yml exists:** read it silently. Extract `user`, `roles`, `implementation_repos`, and `memory_links`. Go to Step 0.5.

**If local-workspace.yml does not exist:** run the local onboarding flow below.

### Local onboarding

One-time setup for this machine. Saves who you are locally — never committed.

Check that `specos-project.yml` exists. If not:
"SpecOS is not initialized in this repo. Run /specos-init first."
Stop here.

Ask these questions one at a time:

**Q1 — Name**
"What's your name? (used as the lead field in spec frontmatter)"

**Q2 — Role(s)**
"What role(s) do you hold on this project?
- lead — writes and approves specs
- backend — implements API and business logic
- frontend — implements UI
- qa — designs and runs tests
- builder — designs + builds + tests (solo)
You can select multiple."

**Q3 — Implementation repos** *(ask only if the project uses separate repos — check `specos-project.yml` or `AGENTS.md` for `implementation_repos` section)*
"What are the paths to your implementation repos from this folder?
Example:
- backend: ../repo-backend
- frontend: ../repo-frontend
- e2e: null
Leave as null any that don't apply."

*(If monorepo, skip Q3 and set all paths to null.)*

Memory links are not asked here — Step 0.5 builds the map.

After collecting answers, write `local-workspace.yml` at the specs repo root:

```yaml
user: [name from Q1]
roles: [roles from Q2]
implementation_repos:
  backend: [path or null]
  frontend: [path or null]
  e2e: [path or null]
```

Leave `memory_links` out; Step 0.5 adds it.

Confirm: "local-workspace.yml saved. Welcome, [name]."

Then continue to Step 0.5.

---

## Step 0.5 — Reconcile and resolve memory links

Separate repos mean separate agent memory. Without a link, a session started in the specs repo cannot see what the agent already learned in the backend repo, and re-explores it from zero. This step builds and maintains the map.

**Skip this entire step if `implementation_repos` has no non-null path.** A monorepo is one directory and one memory namespace — there is nothing to map, and nothing to ask.

### 0.5a — Reconcile

Compare the repo keys that have a non-null path in `implementation_repos` against the keys present in `memory_links`.

Every key has one of three values:

| Value | Meaning |
|---|---|
| `auto` | derive the location each session using the rules below — self-healing, the normal choice |
| a path | use it verbatim — for non-standard setups or when linking across agents |
| `off` | never look for memory for this repo, never ask again |

**If every repo key already has a value:** nothing to ask. Go to 0.5b.

**If one or more keys are missing** — a first session, a project already running before memory links existed, or a repo added later — ask once, listing only the missing keys:

"These repos aren't mapped to their agent memory yet: [list].

Linking them lets a session started here reuse what was already learned in those repos instead of exploring them again. Nothing is copied or committed — it's just a pointer, stored locally.

1. Link them automatically (recommended) — I derive each location every session
2. I'll give you the paths
3. Skip — don't ask again"

Write the answer into `memory_links` for the missing keys only, never overwriting a value. Confirm in one line: "Mapped: [keys]." 

Ask at most once per session; a skip is written as `off`, so the question never returns.

The resulting section:

```yaml
# Where each repo's agent memory lives on this machine.
# auto = derive each session | a path = use verbatim | off = never
# Local only — never committed.
memory_links:
  self: auto
  backend: auto
  frontend: ~/some/non-standard/memory
  e2e: off
```

### 0.5b — Resolve

For each repo key that is not `off`:

1. **Configured** — the value is a path: use it as-is.
2. **Derived** — the value is `auto`: derive it from the running agent's own convention:
   - **Claude Code:** `~/.claude/projects/<absolute repo path with every `/` replaced by `-`>/memory`
     e.g. `/Users/me/proj/api` → `~/.claude/projects/-Users-me-proj-api/memory`
   - **Any agent that scopes memory per project directory:** apply that agent's own path convention.
   - **Agent with no memory system:** look for `.specos/memory.md` inside the repo itself.
3. **Absent** — the resolved location does not exist: that repo has no memory yet. Continue without it. Never create memory directories for other repos preemptively, and do not treat this as an error.

Hold the resolved map for the session; announce it only if asked or if 0.5a just wrote keys.

### Reading rules

- Read the **index only** (`MEMORY.md` or the agent's equivalent). Never read every memory file — that defeats the purpose.
- Open an individual memory file only when its description relates to the active spec or task.
- **Verify before trusting.** Memory is a point-in-time observation. Any file, directory, or symbol a memory names must be confirmed to still exist before you act on it. If it is stale, correct that memory file in this session.
- **Memory never replaces a spec.** It answers *where* and *how*, never *what* or *why*. Nothing in memory authorizes writing code without a `spec.md`.

---

## Step 1 — Read session.md

Look for `session.md` in the specs repo root.

**If session.md exists:** read it silently. Go to Step 3.

**Old format** (`task_id`, `task_description` or `spec_path` present, or over 2 KB): build the new content from it (a task key becomes `task`; condense the rest into one `next` line, at most 3 `open` items, and `parked`), **print it in full and ask before replacing the file**. Name any decision buried in the old text — it belongs in the spec's CHANGELOG. If declined, keep reading the old file and ask next session.

**If session.md does not exist:** go to Step 2.

`session.md` and agent memory never substitute for each other: `session.md` says what I am working on (project-wide, rewritten every session, authoritative for the active task); memory says what I know about one repo (local, accumulates, always verified before use).

Read `session.md` first. It tells you which repo matters, which is what makes the memory map useful.

---

## Step 2 — Route by role

Using `roles` from `local-workspace.yml`, ask one question:

**If role is lead only:**
"What feature do you want to specify?"

**If role is dev/backend/frontend only:**
"What is your task key or description? (e.g. FK-42 or 'implement login endpoint')"

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

If the session writes code (dev or qa), check `implementation_repos` in `local-workspace.yml`.

For each path that is not `null`:
- Check the path is accessible from the current directory; if not: "I can't reach `[path]`. Please update the path in local-workspace.yml."
- Do not proceed until all required paths are valid.

Monorepo (no repos configured): skip this step.

---

## Step 4 — Check for specs

Look for any `spec.md` files inside `specs/` — search both `specs/*/spec.md` and `specs/*/*/spec.md` (one or two levels deep). Skip any `spec.md` that has `type: group` in its frontmatter — those are group summaries, not implementable specs.

**No specs, role dev or qa:** "No specs available right now. Check with your Lead." Stop; do not invent work.

**No specs, role lead or builder:** continue — lead is about to create the first spec.

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

Announce "Starting [skill name] for [feature or task]. Let's go.", then load and follow the target skill.

---

## Step 6 — Save session.md

Locate the **specs repo root**: the directory that contains both `specs/` and `specos-project.yml`. This is where `session.md` must always be saved, regardless of which directory the agent is currently running from.

- If you found `session.md` in Step 1, save back to that same location; on a first session, search upward for the folder holding `specs/` and `specos-project.yml`.
- Never save `session.md` inside an implementation repo (backend, frontend, e2e).

Rewrite `session.md` at that root **whole** with the current state — never append. It has this schema and nothing else:

```
updated: YYYY-MM-DD
active_feature: group/feature
spec_version: 1.0
task: KEY | [new] | null
next: one sentence
open:            # max 3 questions about the ACTIVE task; remove when resolved
  - ...
parked:          # other features, one line each
  - feature: one line
```

Carried-over items not about the active task (housekeeping, other features) go to `parked`, one line each — demote them when you rewrite the file. Max 30 lines / 2 KB. Decisions go to the spec's CHANGELOG, repo learnings to that repo's memory, history stays in git — never a diary here. The spec path is `specs/<active_feature>/spec.md`. Use `null` where nothing applies. Never commit it.
