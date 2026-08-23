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

### The 12 skills

| Skill | Who uses it |
|---|---|
| `/specos-init` | Lead — first-time project setup |
| `/specos-start` | Everyone — begins any session, runs local onboarding if needed, routes by role |
| `/specos-lead` | Lead — builds spec + tasks collaboratively |
| `/specos-lead-parallel` | Lead — drafts several specs in one pass |
| `/specos-dev` | Dev — implements with full spec context |
| `/specos-qa` | QA — generates testcases.md from spec |
| `/specos-distribute` | Lead — generates outputs per specos-project.yml settings and rules |
| `/specos-split` | Lead — splits a large spec into sub-specs under a group folder |
| `/specos-group` | Lead — groups related existing specs under a shared parent folder |
| `/specos-config` | Lead — configures specos-project.yml interactively |
| `/specos-status` | Everyone — shows current session state, read-only |
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

**`session.md`** — updated every session. Stores the active feature, task ID, and spec path. Ephemeral — changes every time you switch tasks.

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
│   └── specos-group.md
├── adapters/
│   ├── claude-code/          ← .claude/commands/ format
│   ├── opencode/             ← .config/opencode/commands/ format
│   ├── gemini/               ← .gemini/commands/ format (.toml, generated)
│   ├── cursor/               ← .cursor/rules/ format (.mdc)
│   └── generic/              ← AGENTS.md fallback for all other agents
├── specs/
│   └── specos-v3/
│       ├── spec.md
│       ├── tasks.md
│       ├── testcases.md
│       └── CHANGELOG.md
└── examples/
    └── feature-tags/
```

---

## Core files

### spec.md — all in one

```markdown
---
feature: feature-name-in-kebab-case
version: 1.0
lead: name
date: YYYY-MM-DD
keywords: [relevant terms for agent search]
linked:
  - specs/[related-feature]/spec.md
---

# Feature Title

## What it does and why it exists
[max 3 lines]

## User Journeys

### Journey 1 — [happy path]
1. [step]

### Journey 2 — [error path]
1. [step]

## Acceptance Criteria
- [ ] [verifiable criterion — verb + subject + measurable condition]

## Out of Scope
- [at least 1 item]

## Technical Section
### API Contracts [if applicable]
### Data model [if applicable]
### Technical decisions
```

> No status field. Presence in the repo = approved.

### tasks.md — no checkboxes

```markdown
## Backend
- [SP-01] Description

## Frontend
- [SP-02] Description

## QA
- [SP-03] Description
```

> No checkboxes. State lives in the team's task software.
> Max 15 tasks. If you need more, split the feature.

### testcases.md — generated by specos-qa

```markdown
# Test cases — feature-name

## TC-01 — Title
task: SP-03
steps:
  1. Step one
  2. Step two
expected: Expected result

## TC-02 — Independent case
task: null
steps:
  1. Step one
expected: Expected result
```

> ID prefix configurable in specos-project.yml. Default: TC.
> Additional fields are optional and free-form — never rejected.

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
  lead:
    max_tasks: 15

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

**Settings vs rules** is the only distinction you need. A **setting** is a number, a boolean, or one option from a short list — the skill reads it and obeys, with no interpretation. A **rule** is a sentence — the skill reads it and interprets it. `cases_per_ac: 2` gives two cases every time; `"Direct tone, no filler"` cannot be reduced to a value.

Anything that can only be said in a sentence is a rule. Tone belongs there, not in settings: `neutral | conversational` would be two labels over a continuous space that each skill reads differently, which is exactly the inconsistency settings exist to remove.

Every setting is optional and has one documented default, so an absent `settings` block behaves like a fresh install. An invalid value is reported once and falls back to its default — a bad config never blocks a session. `ask` is a real choice, not a fallback: it keeps a question being asked every run.

Rules keep the behaviour they always had: sections that read as quality gates are appended to task Acceptance Criteria, everything else is injected as a Standards section, and `specos-dev` enforces them during implementation.

Run `/specos-config` to edit any of it interactively.

**Settings catalog**

| Skill | Setting | Values | Default |
|---|---|---|---|
| `lead` | `max_tasks` | integer ≥ 1 | 15 |
| `lead` | `max_journeys` | integer ≥ 1 \| none | none |
| `lead` | `require_error_journey` | true \| false | true |
| `qa` | `cases_per_ac` | minimal \| standard \| exhaustive \| integer | standard |
| `qa` | `include_negative_cases` | true \| false | true |
| `qa` | `batch_by` | journey \| ac \| all | journey |
| `distribute` | `diagrams` | none \| combined \| per_journey \| ask | ask |
| `distribute` | `branch_info` | ask \| none | ask |
| `distribute` | `task_title_max_words` | integer ≥ 1 | 8 |
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

```markdown
# SpecOS session
updated: YYYY-MM-DD

active_feature: feature-folder-name   # or group/sub-feature for nested specs
task_id: SP-01
task_description: Short task description
spec_path: specs/feature-name/spec.md
```

---

## Role guide

### Lead
1. Run `curl install.sh | bash` once
2. Run `/specos-init` — answers 7 questions, generates project config
3. Run `/specos-start` — first time asks your name, role, and repo paths → saves `local-workspace.yml`
4. Run `/specos-start` (or `/specos-lead` directly) for each new feature
5. Build `spec.md` + `tasks.md` collaboratively, section by section
6. Assign real task IDs from your task software when ready
7. Run `/specos-distribute` to generate outputs

### Dev
1. Run `/specos-start` — first time asks your name, role, and repo paths → saves `local-workspace.yml`
2. Provide task ID or description
3. Agent loads only the relevant `spec.md` and implements in that context

### QA
1. Run `/specos-start` — first time asks your name, role, and repo paths → saves `local-workspace.yml`
2. Agent loads `spec.md` collaboratively builds `testcases.md`
3. Review, adjust, add custom fields freely
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
- Status fields anywhere

---

## Branching strategy

```
main      ← stable, always the version people should use
v2        ← frozen snapshot before v3 work
v3-dev    ← all v3 work, PR to main when ready
```

---

*SpecOS v3 — the perspective-aware agentic system for teams building with AI*
