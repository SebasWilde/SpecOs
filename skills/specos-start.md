# specos-start

You are the entry point for every SpecOS session. Your job is to read context, ask the minimum necessary questions, and route to the correct skill.

---

## Step 0 — Read local-workspace.yml

Look for `local-workspace.yml` in the specs repo root (the directory containing `specs/` and `specos-outputs.yml`).

**If local-workspace.yml exists:** read it silently. Extract `user`, `roles`, `implementation_repos`, and `memory_links`. Go to Step 0.5.

**If local-workspace.yml does not exist:** run the local onboarding flow below.

### Local onboarding

One-time setup for this machine. Saves who you are locally — never committed.

Check that `specos-outputs.yml` exists. If not:
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

**Q3 — Implementation repos** *(ask only if the project uses separate repos — check `specos-outputs.yml` or `AGENTS.md` for `implementation_repos` section)*
"What are the paths to your implementation repos from this folder?
Example:
- backend: ../repo-backend
- frontend: ../repo-frontend
- e2e: null
Leave as null any that don't apply."

*(If monorepo, skip Q3 and set all paths to null.)*

Do not ask about memory links here. Q3 is the last question — the map is built in Step 0.5, which handles first-time and already-running projects the same way.

After collecting answers, write `local-workspace.yml` at the specs repo root:

```yaml
user: [name from Q1]
roles: [roles from Q2]
implementation_repos:
  backend: [path or null]
  frontend: [path or null]
  e2e: [path or null]
```

Leave `memory_links` out of the file entirely. Step 0.5 adds it.

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

Write the answer into `memory_links` for the missing keys only. Never overwrite a key that already has a value. Then confirm in one line: "Mapped: [keys]." and continue.

Ask at most once per session. If the user skips, write `off` — the point of `off` is that this question never returns.

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

Hold the resolved map for the rest of the session. Do not announce it unless the user asks, or unless 0.5a just wrote new keys.

### Reading rules

- Read the **index only** (`MEMORY.md` or the agent's equivalent). Never read every memory file — that defeats the purpose.
- Open an individual memory file only when its description relates to the active spec or task.
- **Verify before trusting.** Memory is a point-in-time observation. Any file, directory, or symbol a memory names must be confirmed to still exist before you act on it. If it is stale, correct that memory file in this session.
- **Memory never replaces a spec.** It answers *where* and *how*, never *what* or *why*. Nothing in memory authorizes writing code without a `spec.md`.

Hold the resolved map for the rest of the session. Do not announce it unless the user asks.

---

## Step 1 — Read session.md

Look for `session.md` in the specs repo root.

**If session.md exists:** read it silently. Go to Step 3.

**If session.md does not exist:** go to Step 2.

`session.md` and agent memory answer different questions and never substitute for each other:

| | `session.md` | Agent memory |
|---|---|---|
| Answers | what I am working on | what I know about this repo |
| Scope | the project | one repo, one agent |
| Lifetime | rewritten every session | accumulates across sessions |
| Portable | yes — same content for anyone | no — local and agent-specific |
| Authoritative | yes, for the active task | no, always verified before use |

Read `session.md` first. It tells you which repo matters, which is what makes the memory map useful.

---

## Step 2 — Route by role

Using the `roles` from `local-workspace.yml`, ask one question:

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

If the session requires writing code (dev or qa roles), check `implementation_repos` from `local-workspace.yml`.

For each path that is not `null`:
- Check if the path is accessible from the current directory
- If not accessible: "I can't reach `[path]`. Please update the path in local-workspace.yml."
- Do not proceed until all required paths are valid.

If no implementation repos are configured (monorepo), skip this step.

---

## Step 4 — Check for specs

Look for any `spec.md` files inside `specs/` — search both `specs/*/spec.md` and `specs/*/*/spec.md` (one or two levels deep). Skip any `spec.md` that has `type: group` in its frontmatter — those are group summaries, not implementable specs.

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

active_feature: feature-folder-name        # can be group/sub-feature for nested specs
task_id: TASK-XX
task_description: Short description of the current task
spec_path: specs/feature-name/spec.md     # e.g. specs/payments/checkout/spec.md
```

Use `null` for any field that does not apply. Do not commit this file — it is in `.gitignore`.
