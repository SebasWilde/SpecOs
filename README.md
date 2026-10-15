# SpecOS v3

> The perspective-aware agentic system for teams building with AI.
> Two perspectives. Any agent. Pure Markdown.

**Created by [Sebastian Wilde](https://github.com/SebasWilde)**
Licensed under [MIT](./LICENSE) · Free to use with attribution · [Credits](./CREDITS.md)

---

## Quickstart

```bash
curl -fsSL https://raw.githubusercontent.com/SebasWilde/SpecOs/main/install.sh | bash
```

Then in your AI agent:

```
/specos-init
```

That's it. The agent asks 7 questions and generates your project config.

---

## What is SpecOS

SpecOS v3 is not a tool — it's an engineering practice, like TDD. It forces intentional thinking before execution by requiring two perspectives on every feature: someone who **builds** and someone who **breaks**.

The core insight: AI agents will write whatever you ask them to. SpecOS makes sure there is always a spec before anyone asks them anything, and always a breaking perspective after.

### The 2 perspectives

| Perspective | Role | What they do |
|---|---|---|
| Construction | Lead + Dev | Define the spec, build the feature |
| Breaking | QA (human or agent) | Challenge the spec, test the edges |

Both perspectives are required. They cannot be the same logic.

### The 11 skills

| Skill | Who uses it |
|---|---|
| `/specos-init` | Lead — first-time project setup |
| `/specos-start` | Everyone — begins any session, runs local onboarding if needed, routes by role |
| `/specos-lead` | Lead — creates a spec in one draft, changes an existing one, or documents what is already built |
| `/specos-dev` | Dev — implements with full spec context |
| `/specos-qa` | QA — expands the Lead's testcase sketches into test cases |
| `/specos-distribute` | Lead — generates outputs per specos-project.yml settings and rules |
| `/specos-split` | Lead — splits a large spec into sub-specs under a group folder |
| `/specos-group` | Lead — groups related existing specs under a shared parent folder |
| `/specos-config` | Lead — configures specos-project.yml interactively |
| `/specos-status` | Everyone — shows current session state, read-only; `--check` runs the spec checks |
| `/specos-help` | Everyone — lists commands and key files, no session needed |

---

## How it works

### Any agent

SpecOS works with Claude Code, OpenCode, Cursor, Codex, Kiro, Antigravity, Windsurf, and Copilot. Pure Markdown, zero dependencies, no binary, no runtime.

### Any repo structure

- **Monorepo:** set all `implementation_repos` paths to `.`
- **Separate repos:** specs repo is the entry point, implementation repos are destinations. Agent validates paths before any session.

### Local state — two files, never committed

**`local-workspace.yml`** — created once per machine on the first `/specos-start`. Stores who you are on this project: your name, roles, implementation repo paths, and memory links. Stable across sessions.

**`session.md`** — rewritten whole every session: active feature, spec version, task, one `next` line, up to 3 `open` items, and `parked` features. Ephemeral, 30 lines at most — decisions go to the spec's CHANGELOG, repo learnings to that repo's memory.

Both are always in `.gitignore`. Never committed.

### Memory links — separate repos, connected memory

Agents scope memory per project directory. In a separate-repo setup that means the specs repo and each implementation repo get their own memory namespace, and none of them can see the others. A session started in the specs repo re-explores the backend repo from scratch, even though the agent already learned it last week.

Memory links fix that. SpecOS does not store memory — every agent already has its own. SpecOS stores **the map of where each repo's memory lives**, and the skills resolve that map before exploring anything.

```yaml
# in local-workspace.yml — local only, never committed
memory_links:
  self: auto                            # derive each session
  backend: auto
  frontend: ~/some/non-standard/memory  # or a path, used verbatim
  e2e: off                              # or off — never look, never ask
```

**How the map gets built.** Not by a one-time question. `/specos-start` compares `implementation_repos` against `memory_links` on every session and asks only about the difference — the keys that have a repo path but no value yet. A key that already has a value is never overwritten and never re-asked.

That single rule covers every entry point without special cases:

| Situation | What happens |
|---|---|
| New project | first `/specos-start` finds no keys, asks once, writes them |
| Project already running before this feature | `memory_links` is absent, so all keys are missing — asked once on the next start |
| A repo added months later | only the new key is missing — asked about that key alone |
| Monorepo | no repo paths, so the whole step is skipped — never asked |

At most one question per session, and `off` is permanent: it is the answer that makes the question stop.

**How a link resolves**, for any key that is not `off`:

1. **A path** — used verbatim. For non-standard setups or linking across agents.
2. **`auto`** — derived from the running agent's own convention. Claude Code maps `/Users/me/proj/api` to `~/.claude/projects/-Users-me-proj-api/memory`. Agents that scope memory per project directory apply their own rule. Agents with no memory system fall back to `.specos/memory.md` inside the repo.
3. **Nothing there** — no memory for that repo yet. The session continues exactly as before.

`auto` is the recommended value: it survives a repo being moved or renamed, and needs no knowledge of any agent's internals.

`/specos-status` shows the state of every link — `linked`, `auto`, `off`, `unmapped`, or `broken`.

Three rules keep it honest:

- **Index first.** Skills read the memory index and open a single entry only when its description matches the task. Reading everything would cost more than exploring.
- **Verify before trusting.** Memory is a point-in-time observation. Any path or symbol it names is confirmed to still exist before the agent acts on it — and corrected on the spot when it is stale.
- **Memory never replaces a spec.** It answers *where* and *how*. The spec answers *what* and *why*. Nothing in memory authorizes writing code without a `spec.md`.

Learnings are written back to the repo they are about, not to the repo the session started in — so the knowledge lands where the next session will look for it.

### session.md is not memory

They coexist because they answer different questions.

| | `session.md` | Agent memory |
|---|---|---|
| Answers | what I am working on | what I know about this repo |
| Scope | the project | one repo, one agent |
| Lifetime | rewritten every session | accumulates across sessions |
| Portable | yes — same content for anyone on the team | no — local and agent-specific |
| Authoritative | yes, for the active task | no — always verified before use |

`session.md` is read first. It names the repo that matters, which is what makes the memory map worth resolving at all.

---

## Repo structure

```
SpecOs/
├── install.sh
├── README.md
├── AGENTS.md                 ← global agent context (template)
├── constitution.md           ← rules template
├── specos-project.yml        ← the one committed config: destinations, settings, rules
├── CHEATSHEET.md
├── skills/
│   ├── specos-init.md
│   ├── specos-start.md
│   ├── specos-lead.md
│   ├── specos-dev.md
│   ├── specos-qa.md
│   ├── specos-distribute.md
│   ├── specos-split.md
│   ├── specos-group.md
│   ├── specos-config.md
│   ├── specos-status.md
│   └── specos-help.md
├── scripts/
│   └── specos-check.sh       ← deterministic check, deployed to ~/.specos/ by the installer
├── adapters/
│   ├── claude-code/          ← .claude/commands/ format
│   ├── opencode/             ← .config/opencode/commands/ format
│   ├── gemini/               ← .gemini/commands/ format (.toml, generated)
│   ├── cursor/               ← .cursor/rules/ format (.mdc)
│   └── generic/              ← AGENTS.md fallback for all other agents
├── specs/
│   └── specos-v3/
│       ├── spec.md
│       └── CHANGELOG.md
└── examples/
    ├── feature-tags/
    └── check-fixture/        ← intentional defects, asserted by verify.sh
```

---

## Core files

### spec.md — behavior, as ACs with stable ids

```markdown
---
feature: feature-name-in-kebab-case
version: 1.0
status: approved           # draft while open questions remain
lead: name
date: YYYY-MM-DD
keywords: [relevant terms for agent search]
linked:
  - specs/[related-feature]/spec.md
---

# Feature Title

## What it does and why it exists
[max 3 lines, ~50 words]
Purpose: [one line — the ticket's Context reads it; "(inferred)" if the agent guessed it]

## Acceptance Criteria

### Limits
- AC1 — The tags field accepts at most 5 tags; the 6th is not added
- AC2 — A tag longer than 30 characters is truncated silently on confirm
- AC3 — retired (v1.1): tags were rejected over 30 characters

## Journeys                 # optional — only for a multi-step flow across screens or actors

## Out of Scope
- [at least 1 item]

## Assumptions              # only while draft: A1 — assumed X. Alternative: Y.

## Open questions           # each names the ACs it touches; omitted when none

## Decisions                # resolved questions, dated, one line each
```

AC ids are stable: never renumbered, never reused; a removed AC stays as *retired*. Failure behavior is written as ACs, not as a separate error journey. A technical section is optional — when it is non-trivial (calculations, contracts) it goes in a separate `design.md` next to `spec.md`.

> `status: draft` while open questions remain, `approved` once the Lead confirms. In a change to an approved spec, an open question marks only the affected ACs `[pending]` — the spec stays approved.

### tasks.md — a role view that references ACs

```markdown
## Backend
- [FK-927] Add tag validation to post model (AC1–AC3) v1.0

## Frontend
- [new] Build TagInput component (AC1, AC4) v1.0
```

`[new]` until you give `/specos-distribute` the real key from your task software. The trailing `v1.0` is the spec version the task was written against. No checkboxes, no done/open state — that lives in the task software. Max 15 tasks; if you need more, split the feature. Old `[SP-01]` placeholders are still read, never silently treated as new: `/specos-distribute` asks first.

### testcases.md — sketches first, cases when QA reviews

```markdown
# Test cases — feature-name
> Sketches suggested by Lead, not reviewed.
spec: v1.1

## TC-01 — Create a post with tags
covers: AC1, AC4

## TC-02 — Tag over 30 characters
covers: AC2
steps:
  1. Type a word longer than 30 characters and press Enter
expected: The chip is truncated to 30 characters, no error shown
```

The Lead writes sketches only (a title and the ACs it `covers`). `/specos-qa` adds `steps:` and `expected:` and sets the `spec:` stamp. A case with `steps:` is expanded; one without is a sketch — there is no status field. Every AC must be covered by at least one case. ID prefix configurable in specos-project.yml (default `TC`); additional fields are free-form and never rejected.

### Changing a spec

Specs change constantly, especially during dev. Anyone who finds a gap raises a **spec change request** — classified as *clarification*, *addition*, *contradiction* or *out-of-scope* — with what was found, the proposed AC text and 1–2 options. If your role includes lead or builder, `/specos-lead` continues in change mode in the same session; otherwise the request is printed for the Lead and you keep working on what it does not block.

Change mode edits the spec, bumps the version, writes a CHANGELOG entry of at most 3 lines (what / why / impact), and prints what is affected: tasks whose AC refs changed, testcases whose `covers` changed, and specs that `linked:` to this one. Only the delta gets `[new]` tasks; a task that already has a key is never edited.

### Commits

Skills never commit or push on their own. When you ask, they list the files and the message first. `/specos-lead` closes with a suggested spec commit message (`Add <feature> spec`, `Update <feature> to vX.Y`, `Key <feature> task as FK-xxx`) and `/specos-dev` with a code one.

### Optional files

- `design.md` — the *how* for one feature (calculations, contracts). Keeps `spec.md` about behavior.
- `00-architecture.md` — context shared by a group; the group `spec.md` stays a summary plus a list.

SpecOS documents them but never creates them for you.

### Checking a specs repo

`/specos-status --check` runs `specos-check.sh` (the installer copies it to `~/.specos/`) and prints warnings: ACs no test case covers, `covers` or task refs pointing to an AC that does not exist, `linked:` paths that are gone, a testcases stamp behind the spec version, AC ids repeated within a spec, sketches never expanded, a spec version missing from its CHANGELOG, `[new]` tasks still waiting for a key, an oversized `session.md`, or one with more than 3 `open` entries. Warnings only; `--strict` exits 1. `--impacts <feature>` lists the specs linking to a feature.

To run it before every commit, add this to `.git/hooks/pre-commit` (SpecOS does not install it):

```bash
#!/usr/bin/env bash
exec bash "$HOME/.specos/specos-check.sh" --strict .
```

### specos-project.yml — everything configurable, committed

One file, three blocks. `local-workspace.yml` holds machine-specific paths and is never committed — that is the only other config file.

```yaml
version: "2"

language:
  specs: en       # ISO 639-1 — language of spec.md, tasks.md, testcases.md
  outputs: en     # language of generated outputs

# --- Team and destinations ---
team: { lead: human, qa: human }
ids:  { task_prefix: SP, testcase_prefix: TC }
integrations:
  jira: { enabled: false, mcp: null }
outputs:
  tasks: { destination: manual }

# --- Settings: closed schema. Skills read these and obey. ---
settings:
  qa:
    cases_per_ac: 2             # minimal | standard | exhaustive | integer
    include_negative_cases: true
  distribute:
    diagrams: per_journey       # none | combined | per_journey | ask
    task_detail: standard       # standard | link | full
  lead:
    max_tasks: 15
    review: draft               # draft | sections

# --- Rules: free-form. Skills read these and interpret. ---
rules:
  writing_style:
    shared:
      - "Direct tone, no filler. Never 'should work correctly'"
  acceptance_criteria:
    backend:
      - "All error responses must include an error code and a human-readable message"
  code_style:
    shared:
      - "No hardcoded environment-specific values — use environment variables"
```

**Settings vs rules** is the only distinction you need. A **setting** is a number, a boolean, or one option from a short list — the skill reads it and obeys, with no interpretation. A **rule** is a sentence — the skill reads it and interprets it. `cases_per_ac: 2` aims for two cases per AC every time; `"Direct tone, no filler"` cannot be reduced to a value.

Anything that can only be said in a sentence is a rule. Tone belongs there, not in settings: `neutral | conversational` would be two labels over a continuous space that each skill reads differently, which is exactly the inconsistency settings exist to remove.

Every setting is optional and has one documented default, so an absent `settings` block behaves like a fresh install. An invalid value is reported once and falls back to its default — a bad config never blocks a session. `ask` is a real choice, not a fallback: it keeps a question being asked every run.

Rules keep the behaviour they always had: sections that read as quality gates are appended to task Acceptance Criteria, everything else is injected as a Standards section, and `specos-dev` enforces them during implementation.

Run `/specos-config` to edit any of it interactively. `distribute.task_detail` picks the ticket: `standard` (default) is self-contained — context, scope, test case titles and a short acceptance checklist, no AC ids — `link` only points to the spec (it was called `brief`), `full` is the long template. Set `outputs.tasks.destination: jira-csv` and `/specos-distribute` prints the tasks as a CSV (`Summary, Description, Issue Type, Parent`) ready for Jira's CSV import — no integration involved.

**Settings catalog**

| Skill | Setting | Values | Default |
|---|---|---|---|
| `lead` | `max_tasks` | integer ≥ 1 | 15 |
| `lead` | `max_journeys` | integer ≥ 1 \| none | none |
| `lead` | `require_error_journey` | true \| false | false |
| `lead` | `review` | draft \| sections | draft |
| `lead` | `suggest_scenarios` | true \| false | true |
| `qa` | `cases_per_ac` | minimal \| standard \| exhaustive \| integer | standard |
| `qa` | `include_negative_cases` | true \| false | true |
| `qa` | `batch_by` | journey \| ac \| all | journey |
| `distribute` | `diagrams` | none \| combined \| per_journey \| ask | ask |
| `distribute` | `branch_info` | ask \| none | ask |
| `distribute` | `task_title_max_words` | integer ≥ 1 | 8 |
| `distribute` | `task_detail` | standard \| link \| full | standard |
| `dev` | `require_tests` | true \| false | false |

**The file is written in English** — keys, comments, and rules alike — regardless of `language.specs`. The two are independent: an English config file produces Spanish specs when `language.specs: es`. Rules are instructions the agent follows, and instructions are followed most reliably in English. `/specos-config` accepts a rule in any language, translates it, and shows you the English text before writing — nothing is reworded silently, and a literal string a rule requires in the output is never translated.

**Coming from the two old files?** Projects with `specos-outputs.yml` and `specos-standards.yml` are offered a merge on the next `/specos-start`. It prints the merged result before writing anything, and deletes both old files on approval.

### local-workspace.yml — local identity, never committed

Created on the first `/specos-start` in a cloned repo. One-time setup per machine.

```yaml
user: Your Name
roles: [lead, backend]
implementation_repos:
  backend: ../repo-backend
  frontend: ../repo-frontend
  e2e: null

# Where each repo's agent memory lives on this machine.
# auto = derive each session | a path = use verbatim | off = never
# Added and maintained by /specos-start. Absent = not yet mapped.
memory_links:
  self: auto
  backend: auto
  frontend: ~/some/non-standard/memory
  e2e: off
```

### session.md — active session state, never committed

```
updated: YYYY-MM-DD
active_feature: group/feature   # or just feature
spec_version: 1.0
task: KEY | [new] | null   # a ticket key, [new] or null — never prose
next: one sentence
open:            # max 3 questions about the ACTIVE task, remove when resolved
  - ...
parked:          # other features, one line each
  - feature: one line
```

`open` is only for questions about the active task; anything else carried over goes to `parked`. Skills rewrite the whole file, never append. A session.md in the old format (`task_id`, `task_description`, `spec_path`, or over 2 KB) is shown re-written and replaced only after you agree.

---

## Role guide

### Lead
1. Run `curl install.sh | bash` once
2. Run `/specos-init` — answers 7 questions, generates project config
3. Run `/specos-start` — first time asks your name, role, and repo paths → saves `local-workspace.yml`
4. Run `/specos-start` (or `/specos-lead` directly) for each new feature: explain it freely, answer the few questions, and get one draft — spec, tasks and testcase sketches
5. Read the message it prints before asking anything — what it understood, every assumption (each with its alternative), every open question (each with its proposal) — and answer. Confirmed assumptions move to `## Decisions`; the spec becomes `approved` when `## Assumptions` and `## Open questions` are empty. It closes with a summary, a commit message, and the session saved — it never commits on its own
6. Run `/specos-distribute`, create the tasks in your task software, and give back the keys in order
7. When something changes, say "change X because Y" — `/specos-lead` handles versions, AC ids, CHANGELOG and impact

### Dev
1. Run `/specos-start` — first time asks your name, role, and repo paths → saves `local-workspace.yml`
2. Provide task key or description
3. Agent shows the task's ACs and the flows that will be tested, then implements in that context
4. If the spec has a gap, it raises a spec change request in the chat instead of guessing (never parked in `session.md`)
5. At the end it prints a closing block for the PR or ticket, with a commit message `type(KEY): Imperative description` (`feat`, `change`, `improvement`, `chore`). It only shows the message; it never commits

### QA
1. Run `/specos-start` — first time asks your name, role, and repo paths → saves `local-workspace.yml`
2. Agent loads the spec and the Lead's sketches, and expands them in batches
3. Review, adjust, add cases live, add custom fields freely
4. Run `/specos-distribute` to push output

---

## Full guides

- [Claude Code — setup and usage guide](docs/guides/claude-code.md)
- [OpenCode — setup and usage guide](docs/guides/opencode.md)

Complete conversational flow transcripts (init → lead → dev → qa → distribute) in [`docs/flows/`](docs/flows/).

---

## Out of scope for v3

- CLI binary — bash script only
- Automatic MCP integration — outputs are manual, MCP declared in specos-project.yml for v4
- GitHub Actions or CI/CD pipelines
- Web dashboard or UI
- Windows support
- Automatic translation — language is configured in specos-project.yml but content is written by the agent in the configured language, not translated
- Per-feature or per-role setting overrides — `settings` is project-wide
- Status tracking of tasks or test cases — the only state is the spec's `status` and immutable facts (spec version, AC refs, presence of a ticket key)

---

## Branching strategy

```
main      ← stable, always the version people should use
v2        ← frozen snapshot before v3 work
v3-dev    ← all v3 work, PR to main when ready
```

---

*SpecOS v3 — the perspective-aware agentic system for teams building with AI*
