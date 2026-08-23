---
feature: specos-v3
version: 2.5
status: approved
lead: Sebastian Wilde
date: 2026-08-22
keywords: [specs, perspectives, agent-agnostic, memory-links, multi-repo, monorepo]
---

# SpecOS v3

## What it does and why it exists
SpecOS v3 transforms the methodology from a manual copy-paste workflow into a perspective-aware agentic system.
The core value is forcing intentional thinking before execution — not synchronizing fixed roles.
Two perspectives are always required (construction and breaking) but roles are fully configurable per team and per person.
Works with any AI agent (Claude Code, OpenCode, Cursor, Codex, Kiro, Antigravity, Windsurf, Copilot) — pure Markdown, zero dependencies.

---

## User Journeys

### Journey 1 — Lead creates a spec from scratch (no prior session)
1. Lead opens their AI agent standing in the specs repo (any folder name)
2. Lead runs `/specos-start`
3. Agent reads `session.md` — does not exist, asks: "What feature do you want to specify?"
4. Lead describes the feature in natural language
5. Agent builds `spec.md` section by section, proposing and waiting for Lead validation at each step
6. Agent collaboratively builds `tasks.md` with the Lead — proposes, Lead adjusts
7. Agent assigns default SpecOS IDs to each task: `[SP-01]`, `[SP-02]`, etc.
8. Agent generates task descriptions formatted for copy-paste into the team's task software
9. Agent asks: "What are the real IDs from your task software?"
10. Lead provides IDs, agent updates `tasks.md` replacing SP-XX with real IDs
11. Lead pushes to repo — presence in repo means approved, no status field needed

### Journey 2 — Lead resumes a session
1. Lead runs `/specos-start`
2. Agent reads `session.md` — resumes where they left off, no questions asked

### Journey 3 — Dev starts working (no prior session)
1. Dev opens agent standing in the specs repo
2. Dev runs `/specos-start`
3. Agent reads `session.md` — does not exist, asks: "What is your task ID or description?"
4. Dev provides `TASK-42` or a description
5. Agent finds the task in `tasks.md`, identifies the feature folder
6. Agent loads only that feature's `spec.md` — nothing else
7. Dev implements with full spec context
8. Agent saves task and feature to `session.md`

### Journey 4 — Dev resumes a session
1. Dev runs `/specos-start`
2. Agent reads `session.md` — loads feature and task automatically, no questions asked

### Journey 5 — QA designs test cases (no prior session)
1. QA (human or agent) runs `/specos-start`
2. Agent reads `session.md` — does not exist, asks: "Which spec or task do you want to work on?"
3. QA provides feature name or task ID
4. Agent loads only that `spec.md`
5. Agent collaboratively generates `testcases.md` from ACs and journeys
6. QA edits freely — adds, removes, modifies cases and any additional custom fields
7. If QA finds an uncovered edge case, agent flags it and suggests updating the spec before continuing
8. Agent generates output per `specos-outputs.yml` destination

### Journey 6 — Person with multiple roles in same session (e.g. Lead + Backend)
1. Person runs `/specos-start`
2. Agent reads `session.md` — roles: [lead, backend]
3. Agent asks: "What perspective do you take today? Construction / Breaking / Both"
4. Person picks "Both"
5. Agent runs construction perspective: builds spec + tasks collaboratively
6. Agent proposes: "Spec is ready. Want me to switch to Backend perspective and start implementing?"
7. Person confirms — agent loads implementation context from `session.md`
8. Same session, two perspectives, no restart needed

### Journey 7 — Solo builder (agent takes breaking perspective)
1. Builder finishes implementing a feature
2. Runs `/specos-start`
3. Agent reads `session.md` — role: builder, qa: agent in config
4. Agent proposes: "You just finished user-auth. Want me to take the breaking perspective and challenge what we built?"
5. Builder confirms — agent generates `testcases.md`, flags edge cases, suggests improvements

### Journey 11 — Person wants to know what commands are available
1. Person runs `/specos-help`
2. Agent displays all available SpecOS v3 skills with a one-line description each
3. Agent shows the key project files and their purpose
4. No session required — works from any state

### Journey 12 — Person wants to know the current session state
1. Person runs `/specos-status`
2. Agent reads `session.md`
3. If session exists: displays roles, active feature, task ID, spec path, and implementation repos in a clean summary
4. If session does not exist: responds "No active session. Run /specos-start to begin."
5. No questions asked — read-only, no side effects

### Journey 8 — No specs available
1. Dev or QA runs `/specos-start`
2. Agent finds no specs in the repo
3. Agent responds: "No specs available right now. Check with your Lead."
4. Session ends — agent does not invent work

### Journey 9 — First time setup
1. Person runs `curl -fsSL https://raw.githubusercontent.com/SebasWilde/SpecOs/main/install.sh | bash`
2. Script detects installed agents and copies skills to correct locations
3. Person runs `/specos-init`
4. Agent asks 6 questions:
   - Project name
   - Stack (languages, frameworks)
   - Team composition (solo builder / small team / full team / custom)
   - Roles for this person (multiple selection: lead, backend, frontend, qa, builder)
   - Project structure (monorepo / separate repos)
   - If separate repos: paths to implementation repos per role
5. Agent generates: `AGENTS.md`, `constitution.md`, `specos-outputs.yml`, `.gitignore` with `session.md`
6. Person makes first commit

### Journey 10 — Implementation repo path not found
1. Dev runs `/specos-start`
2. Agent reads `session.md` — implementation_repos.backend: ../repo_back
3. Agent checks if path is accessible before starting
4. Path not found: "I can't reach ../repo_back. Please check the path in your session.md."
5. Session does not proceed until path is valid

### Journey 13 — Dev works on a repo the agent already knows
1. Dev runs `/specos-start` in the specs repo — a separate repo from the backend
2. Agent reads `local-workspace.yml` and resolves `memory_links` for each configured repo
3. Dev picks a backend task; agent hands off to `specos-dev`
4. Before reading any source file, agent resolves the backend repo's memory location and reads its index
5. One entry matches the task; agent opens it and confirms the paths it names still exist
6. Agent goes straight to the right module instead of exploring the repo again
7. At the end of the session, a new durable fact is written to the **backend repo's** memory, not the specs repo's

### Journey 13b — No memory exists for the repo
1. Same start, but the resolved memory location does not exist
2. Agent continues exactly as it would without memory links — explores, implements
3. Agent does not create memory directories for other repos preemptively

### Journey 13c — Project already running before memory links existed
1. Person runs `/specos-start` in a project whose `local-workspace.yml` predates this feature
2. Agent reads it — `implementation_repos` has backend and frontend, `memory_links` is absent entirely
3. Agent compares the two and finds both keys unmapped
4. Agent asks once, listing only the unmapped keys, and offers: link automatically / give paths / skip
5. Person picks automatic; agent writes `memory_links` with `auto` for both and confirms in one line
6. Every later session finds the keys present and asks nothing

### Journey 13d — A repo is added months later
1. Lead adds an `e2e` path to `implementation_repos`
2. Next `/specos-start` finds `e2e` has a path but no `memory_links` key
3. Agent asks about `e2e` only — never re-asks about keys that already have a value
4. Person answers "skip"; agent writes `e2e: off` and never asks again

---

## Acceptance Criteria

### install.sh
- [ ] Running the curl command installs SpecOS without any manual step
- [ ] Detects: Claude Code, OpenCode, Cursor, Codex, Windsurf, Copilot
- [ ] Copies skills to the correct directory for each detected agent
- [ ] Creates symlinks: CLAUDE.md → AGENTS.md, .cursorrules → AGENTS.md
- [ ] Works on macOS and Linux (Ubuntu)
- [ ] Idempotent — running twice does not break anything
- [ ] No binary, runtime, or package manager required

### specos-init skill
- [ ] Asks exactly 6 questions before generating any file
- [ ] Supports multiple role selection per person
- [ ] Generates `AGENTS.md` with project map
- [ ] Generates `constitution.md` with all non-negotiable rules
- [ ] Generates `specos-outputs.yml` with team config, ID prefixes, and integrations
- [ ] Adds `session.md` to `.gitignore`
- [ ] Creates `specs/` directory

### specos-start skill
- [ ] If `session.md` exists, resumes without questions
- [ ] If `session.md` does not exist, asks based on declared roles — not a fixed list
- [ ] If roles include multiple options, asks which perspective to take today
- [ ] Offers "Both" when person has lead + implementation role
- [ ] If qa is declared as agent in config, proactively offers breaking perspective after construction
- [ ] Validates implementation repo paths before starting dev or qa session
- [ ] If no specs exist, responds clearly and ends session

### specos-lead skill
- [ ] Builds `spec.md` section by section — never dumps full document at once
- [ ] Waits for Lead validation before moving to next section
- [ ] Builds `tasks.md` collaboratively — proposes, Lead adjusts
- [ ] Enforces: max 15 tasks, at least 1 error journey, ACs verifiable, out of scope present
- [ ] Assigns default IDs using configured prefix (default SP-XX)
- [ ] Generates task descriptions for copy-paste into any task software
- [ ] Asks for real task IDs after Lead creates them in their software
- [ ] Updates `tasks.md` replacing SP-XX with real IDs
- [ ] Saves session state to `session.md`

### specos-dev skill
- [ ] Loads only the `spec.md` of the selected feature — no other files
- [ ] Knows project structure from `AGENTS.md`
- [ ] Knows which implementation repo to write to from `session.md`
- [ ] Saves task and feature to `session.md` after session

### specos-qa skill
- [ ] Generates `testcases.md` collaboratively — proposes cases, QA adjusts
- [ ] Assigns default IDs using configured prefix (default TC-XX)
- [ ] Covers every AC and every error journey in the spec
- [ ] Cases can link to a task ID or be null (independent)
- [ ] QA can freely add, remove, edit cases and any custom fields
- [ ] Does not validate or reject unknown fields in testcases.md
- [ ] If uncovered edge case found, flags it and pauses output until resolved
- [ ] Generates output per `specos-outputs.yml`
- [ ] Works whether QA is human or agent
- [ ] Saves session state to `session.md`

### specos-help skill
- [ ] Lists all SpecOS v3 skills with a one-line description each
- [ ] Lists key project files (AGENTS.md, constitution.md, specos-outputs.yml, session.md) and their purpose
- [ ] Requires no session — works from any state
- [ ] Output is read-only — no files created or modified

### specos-status skill
- [ ] Reads `session.md` and displays current state in a clean, human-readable format
- [ ] Shows: roles, active feature, task ID, spec path, implementation repos
- [ ] If `session.md` does not exist, responds clearly and suggests running `/specos-start`
- [ ] Read-only — does not modify `session.md` or any other file
- [ ] No questions asked — instant output

### constitution.md (generated by specos-init)
- [ ] Rule: construction perspective always exists — someone defines and approves the spec
- [ ] Rule: breaking perspective always exists — cannot be the same logic that built
- [ ] Rule: no agent writes code without a spec in the repo
- [ ] Rule: only Lead role modifies spec.md
- [ ] Rule: max 15 tasks per feature — split if more needed
- [ ] Rule: all outputs written in English by default
- [ ] Rule: spec change affecting more than 50% of content is a new feature
- [ ] Rule: every spec change requires a CHANGELOG.md entry: date, what changed, why

### session.md
- [ ] Always in `.gitignore` — never committed
- [ ] If missing, agent handles first-time flow gracefully
- [ ] Stores: roles, active feature, task ID, spec path, implementation repo paths
- [ ] Agent updates session.md at end of every session

### testcases.md
- [ ] Lives inside the feature folder alongside spec.md and tasks.md
- [ ] Generated collaboratively by agent + QA from spec ACs and journeys
- [ ] Test case ID prefix configurable in `specos-outputs.yml` (default: TC)
- [ ] Each case has: ID, title, optional task link, steps, expected result
- [ ] Additional fields are optional and free-form — agent never rejects them
- [ ] No status field — state lives in the team's test tool
- [ ] Output generated from this file per specos-outputs.yml destination

### tasks.md
- [ ] No checkboxes — state lives in team's task software
- [ ] Default IDs assigned by agent using configured prefix (default: SP-XX)
- [ ] IDs updated to real task software IDs when available
- [ ] Format: `- [ID] Task description`
- [ ] Agnostic to task software — any ID format accepted

### Agent-agnostic compatibility
- [ ] All skills work in Claude Code, OpenCode, Gemini CLI via slash commands
- [ ] All skills work in Cursor, Codex, Kiro, Antigravity, Windsurf, Copilot via AGENTS.md
- [ ] No external library, API, or binary dependency

### Single source rule
- [ ] `skills/` is the only place a skill's content is written
- [ ] `adapters/` exists only for agents that cannot consume `skills/*.md` directly, and holds format, never content
- [ ] An adapter is a delegator (Cursor `.mdc`), a generated artifact (Gemini `.toml`), or a shared section (generic) — never a copy of a skill
- [ ] Adding a skill requires no edit to any per-agent adapter that delegates or is generated
- [ ] `install.sh` and `update.sh` read every skill by glob from `skills/`, so a new skill ships without touching either script

### Repo structure flexibility
- [ ] Works in monorepo
- [ ] Works with separate repos — specs repo as entry point, implementation repos as destinations
- [ ] Implementation repo paths in local-workspace.yml — local, never committed
- [ ] Agent validates paths before any session requiring code writing

### Memory links
- [ ] `local-workspace.yml` accepts an optional `memory_links` section mapping each repo key to `auto`, a path, or `off`
- [ ] `/specos-start` reconciles `implementation_repos` against `memory_links` on every session, and asks only about keys that have no value
- [ ] A key that already has a value is never overwritten and never re-asked
- [ ] `off` is permanent — that key is never asked about again
- [ ] Reconciliation covers three entry points identically: a new project, a project that predates the feature, and a repo added later
- [ ] The whole step is skipped when `implementation_repos` has no non-null path
- [ ] At most one memory-link question per session
- [ ] Resolution order is: explicit path → `auto` derived from the agent's own convention → `.specos/memory.md` in the repo → none
- [ ] A missing memory location degrades to current behaviour — the session proceeds, nothing is created
- [ ] `specos-dev` resolves and reads the target repo's memory before reading any source file in it
- [ ] Only the memory index is read; an individual entry is opened only when its description matches the task
- [ ] Anything a memory names is verified to still exist before the agent acts on it, and corrected when stale
- [ ] Learnings are written to the memory of the repo they describe, not the repo the session started in
- [ ] Memory never satisfies the spec requirement — no code is written without a `spec.md`
- [ ] Monorepo projects skip memory links entirely
- [ ] No SpecOS-owned memory store is created — SpecOS maps locations, the agent owns the memory

---

## Out of Scope
- CLI binary — bash script only for v3
- A SpecOS-owned memory store — v3 maps where each agent's own memory lives (`memory_links`), it never stores memory itself
- `tasks.md` and `testcases.md` for this spec — see below

---

## This spec is the framework, not a project

SpecOS is built for product projects: work that ships behavior someone can execute against. This spec describes SpecOS itself, whose deliverable is Markdown prompts. That difference changes which artifacts are worth keeping.

`spec.md` and `CHANGELOG.md` earn their place — the first is the design record, the second is why each decision was made. `tasks.md` and `testcases.md` do not, and this folder deliberately has neither:

- There is no runtime to execute a test case against. A `TC` whose expected result is "the agent asks only about unmapped keys" is not executable and not deterministic — it depends on the agent, the model, and the day.
- The Acceptance Criteria above already state every one of those expectations, in one place. A `testcases.md` would restate them in a second place that nothing reads and that drifts.
- The task list was a build log for a framework with no team splitting work by role. The changelog covers it better.

**The breaking perspective still applies.** It is not waived — it takes the form this deliverable allows. For this repo that is `verify.sh`, which tests the part that genuinely is executable: `install.sh`, `update.sh`, and the invisible contracts between them and `skills/` — that line 3 of every skill becomes a Gemini command description, that every skill has a Cursor delegator, that no adapter has become a copy, that local files stay gitignored. Each of those has already broken once.

**The general rule, for any project using SpecOS:** the two perspectives are mandatory, but the artifact that carries the breaking perspective follows the deliverable. Executable product → `testcases.md`. Non-executable deliverable → whatever actually verifies it. What is never optional is that something adversarial exists and runs.
- Automatic MCP integration — outputs are manual in v3, MCP declared in specos-outputs.yml for v4
- Automatic PR or merge detection — feature closure is manual
- GitHub Actions or CI/CD pipelines
- Web dashboard or UI
- Windows support — macOS and Linux only
- Multi-language output — English only, field reserved for v4
- Status fields anywhere — repo presence = approved, task software = source of truth for task state

---

## Technical Section

### Repository structure

```
SpecOs/                             ← root (any folder name)
├── install.sh
├── README.md
├── AGENTS.md                       ← global agent context (template)
├── constitution.md                 ← rules template
├── specos-outputs.yml              ← config template
├── specos-standards.yml            ← project standards template
├── CHEATSHEET.md
├── CREDITS.md
├── LICENSE
├── .gitignore                      ← local-workspace.yml, .specos/, session.md
├── skills/                         ← the single source for every skill
│   ├── specos-init.md
│   ├── specos-start.md
│   ├── specos-lead.md
│   ├── specos-lead-parallel.md
│   ├── specos-dev.md
│   ├── specos-qa.md
│   ├── specos-distribute.md
│   ├── specos-split.md
│   ├── specos-group.md
│   ├── specos-config.md
│   ├── specos-help.md
│   └── specos-status.md
├── adapters/                       ← only for agents that need a different format
│   ├── cursor/                     ← .mdc delegators, one per skill
│   ├── gemini/                     ← README only — .toml generated from skills/
│   └── generic/                    ← AGENTS.md section for Codex, Copilot, Kiro…
├── specs/
│   └── specos-v3/
│       ├── spec.md
│       ├── tasks.md
│       ├── testcases.md
│       └── CHANGELOG.md
└── examples/
    └── feature-tags/
```

### local-workspace.yml schema

Local identity, one per machine. Never committed.

```yaml
user: Sebastian Wilde
roles: [lead, backend]
implementation_repos:
  backend: ../repo_back
  frontend: ../repo_front
  e2e: null

# Optional. Where each repo's agent memory lives on this machine.
# auto = derive each session | a path = use verbatim | off = never
# Added and maintained by /specos-start Step 0.5. Absent = not yet mapped.
memory_links:
  self: auto
  backend: auto
  frontend: ~/some/non-standard/memory
  e2e: off
```

### session.md schema

Active session state. Rewritten every session, never committed.

```markdown
# SpecOS session
updated: YYYY-MM-DD

active_feature: feature-folder-name
task_id: TASK-42
task_description: Short task description
spec_path: specs/feature-name/spec.md
```

### Memory link reconciliation

Runs at `/specos-start` Step 0.5, on every session. Skipped entirely when `implementation_repos` has no non-null path.

The map is maintained by difference, not by a one-time question: compare the repo keys that have a path against the keys present in `memory_links`, and ask only about the difference. This is what makes a new project, a project that predates the feature, and a repo added later all behave the same — none of them is a special case.

| Key state | Behaviour |
|---|---|
| has a value (`auto`, a path, or `off`) | never asked about, never overwritten |
| missing | asked once, then written |

At most one question per session, listing only the missing keys. `off` is permanent by design — it is the answer that makes the question stop.

### Memory link resolution

Applies to any repo key that is not `off`.

| Order | Source | Rule |
|---|---|---|
| 1 | Configured | the value is a path — used verbatim. For non-standard setups or cross-agent linking |
| 2 | Derived | the value is `auto` — the running agent's own memory-path convention. Claude Code: absolute repo path with every `/` replaced by `-`, under `~/.claude/projects/`, plus `/memory` |
| 3 | Fallback | agent with no memory system → `.specos/memory.md` inside the repo |
| 4 | None | nothing resolves → session proceeds as if the feature did not exist |

`auto` is the recommended value: it survives a repo being moved or renamed, and requires no knowledge of any agent's internals.

### session.md vs agent memory

They answer different questions and never substitute for each other.

| | `session.md` | Agent memory |
|---|---|---|
| Answers | what I am working on | what I know about this repo |
| Scope | the project | one repo, one agent |
| Lifetime | rewritten every session | accumulates across sessions |
| Portable | yes — same content for anyone on the team | no — local and agent-specific |
| Authoritative | yes, for the active task | no — always verified before use |

`session.md` is read first: it names the repo that matters, which is what makes the memory map worth resolving.

Read contract: index only; open one entry when its description matches the task; verify what it names before acting; correct it when stale.

Write contract: durable, verified facts about a repo go to that repo's memory. Never the session narrative, never anything already in the spec, `AGENTS.md`, or `specos-standards.yml`.

Boundary: memory answers *where* and *how*. The spec answers *what* and *why*. Memory never authorizes code without a `spec.md`.

### tasks.md format

```markdown
## Backend
- [SP-01] Description

## Frontend
- [SP-02] Description

## QA
- [SP-03] Description
```

### testcases.md format

```markdown
# Test cases — feature-name

## TC-01 — Title
task: TASK-42
steps:
  1. Step one
  2. Step two
expected: Expected result

## TC-02 — Independent case
task: null
steps:
  1. Step one
expected: Expected result
[any additional fields are valid and free-form]
```

### specos-outputs.yml schema

```yaml
version: "1.0"
language: en

team:
  lead: human
  qa: human           # human | agent | both

ids:
  task_prefix: SP
  testcase_prefix: TC

integrations:
  jira:
    enabled: false
    mcp: null
  confluence:
    enabled: false
    mcp: null
  notion:
    enabled: false
  linear:
    enabled: false
  github_issues:
    enabled: false
  slack:
    enabled: false

outputs:
  tasks:
    destination: manual
  testcases:
    destination: manual
  confluence_doc:
    destination: manual
```

### GitHub branching strategy

```
main      ← stable, always the version people should use
v2        ← frozen snapshot before v3 work begins
v3-dev    ← all v3 work, PR to main when ready
```

Steps before starting:
1. Create branch `v2` from current `main`
2. Create branch `v3-dev` from `main`
3. All commits go to `v3-dev`
4. When v3 complete: PR `v3-dev` → `main`

---

## Approval checklist
- [x] Has at least 1 error journey (Journey 8, Journey 10)
- [x] All ACs are verifiable
- [x] Out of scope present
- [x] No new API endpoints — markdown-only project
- [x] Exceeds 150 lines — approved as system spec exception
