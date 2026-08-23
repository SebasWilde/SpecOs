---
feature: specos-v3
version: 2.6
status: approved
lead: Sebastian Wilde
date: 2026-08-22
keywords: [specs, perspectives, agent-agnostic, memory-links, multi-repo, monorepo, project-config]
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
8. Agent generates output per `specos-project.yml` destination

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
5. Agent generates: `AGENTS.md`, `constitution.md`, `specos-project.yml`, `.gitignore` with `session.md`
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

### Journey 14 — Lead configures how the project works
1. Lead notices `/specos-qa` produces a different number of cases per AC on every run, and that `/specos-distribute` asks about diagrams every single time even though the answer is always the same
2. Lead runs `/specos-config`
3. Agent shows the whole of `specos-project.yml` in three blocks: **Team and destinations**, **Settings**, **Rules**
4. Lead picks "settings"
5. Agent lists the settings grouped by skill, showing for each: what it controls, its accepted values, and the default that applies when unset
6. Lead sets `qa.cases_per_ac: 2` and `distribute.diagrams: per_journey`
7. Agent writes only those two keys — settings left at their default are never written to the file
8. Next `/specos-qa` run produces two cases per AC without being asked; next `/specos-distribute` run generates one diagram per journey and never asks the question

### Journey 14b — Lead sets something a value cannot express
1. Lead wants every test case written in second person and every task description free of filler
2. Lead runs `/specos-config` and picks "rules"
3. Agent asks which section and which roles
4. Lead answers in Spanish — their project writes specs in Spanish and that is the language they think in
5. Agent translates the rules to English before writing them, and shows the English text back for confirmation
6. Agent writes them under `rules.writing_style.shared` in `specos-project.yml`
7. Every skill that writes content reads those English sentences and follows them — while still producing its output in Spanish, because `language.specs` is what decides the content language

### Journey 14c — Project with nothing configured
1. Any skill runs in a project whose `specos-project.yml` has no `settings:` block, or that has no `specos-project.yml` at all
2. Skill applies its documented default for every setting, and finds no rules to apply
3. Behaviour is identical to the version before this feature existed — nothing to migrate, nothing to answer

### Journey 14d — Project still has the two old files
1. Lead runs `/specos-start` in a project created before the merge — it has `specos-outputs.yml` and `specos-standards.yml`, and no `specos-project.yml`
2. Agent detects both, and proposes: "These two files are now one. I can merge them into specos-project.yml."
3. Agent prints the merged result for review before writing anything
4. `language` appears in both files: agent uses the `specos-standards.yml` value, and says so explicitly, because that is the one skills read for content today
5. Lead approves; agent writes `specos-project.yml`, deletes the two old files, and continues the session
6. Lead declines; agent continues reading the old files this session and does not ask again until the next session

### Journey 14e — Invalid setting
1. Lead hand-edits `specos-project.yml` and writes `qa.cases_per_ac: lots` and `qa.case_flavour: spicy`
2. Next skill run reads the block and finds one invalid value and one unknown key
3. Skill reports both in one message, naming the key, what it found, and what is accepted
4. Skill falls back to the default for those two settings and continues — a bad config never blocks the session
5. `verify.sh` fails on the same file, so the invalid config cannot ship silently

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
- [ ] Generates `specos-project.yml` with language, team config, ID prefixes, integrations, and output destinations
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
- [ ] Generates output per `specos-project.yml`
- [ ] Works whether QA is human or agent
- [ ] Saves session state to `session.md`

### specos-help skill
- [ ] Lists all SpecOS v3 skills with a one-line description each
- [ ] Lists key project files (AGENTS.md, constitution.md, specos-project.yml, session.md) and their purpose
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
- [ ] Test case ID prefix configurable in `specos-project.yml` (default: TC)
- [ ] Each case has: ID, title, optional task link, steps, expected result
- [ ] Additional fields are optional and free-form — agent never rejects them
- [ ] No status field — state lives in the team's test tool
- [ ] Output generated from this file per specos-project.yml destination

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

### specos-project.yml — one file for everything configurable

**The file**
- [ ] `specos-project.yml` is the single committed config file, holding `language`, `team`, `ids`, `integrations`, `outputs`, `settings`, and `rules`
- [ ] `specos-outputs.yml` and `specos-standards.yml` no longer exist — all their content lives in `specos-project.yml`
- [ ] `language` is declared exactly once, ending the duplication that existed across the two old files
- [ ] `local-workspace.yml` is untouched — it stays local, uncommitted, and owns machine-specific location only
- [ ] Every block is optional; an absent file behaves exactly as an empty one
- [ ] No skill reads `specos-outputs.yml` or `specos-standards.yml` after migration

**The file is written in English**
- [ ] Every key, every comment, and every rule sentence in `specos-project.yml` is in English, regardless of `language.specs`
- [ ] The file's language is independent of the content language — a project with `language.specs: es` still has an English config file and still produces Spanish specs
- [ ] `/specos-config` accepts a rule stated in any language and translates it to English before writing
- [ ] The translated text is shown back for confirmation before it is written — the Lead never discovers a silent rewording of their own rule
- [ ] A literal string a rule requires in the output is preserved verbatim in its original language, never translated
- [ ] Migration translates any non-English rule carried over from `specos-standards.yml`, and reports which rules it translated
- [ ] `language.specs` and `language.outputs` keep ISO 639-1 codes — they are unaffected by this
- [ ] A hand-written non-English rule is never rejected and never ignored — it is applied as written, and `/specos-config` offers to translate it on the next run

**Settings — values a skill obeys**
- [ ] `settings:` is grouped by skill name (`lead`, `qa`, `distribute`, `dev`) — never by role
- [ ] The schema is closed: every key and every accepted value is enumerated in this spec
- [ ] Every setting is optional; an absent setting resolves to its documented default
- [ ] Each setting has exactly one documented default, stated in this spec and in the file's header comment
- [ ] An unknown key or an invalid value is reported once, naming the key, the value found, and the accepted values
- [ ] After reporting, the skill falls back to that setting's default and continues — an invalid config never aborts a session
- [ ] Errors are collected into a single message per run, not one message per bad key
- [ ] A setting whose value is `ask` makes the skill ask, exactly as it does today
- [ ] A setting's value is never surfaced as content in a spec, task, or test case

**Rules — sentences a skill interprets**
- [ ] `rules:` holds free-form sections, each organized by role (`frontend`, `backend`, `qa`, `shared`)
- [ ] Section names are unconstrained — no fixed schema, no rejection of unknown sections
- [ ] `shared` applies to every role
- [ ] Sections that read as quality gates are appended to Acceptance Criteria in task output; all others are injected as a Standards section — the behaviour that exists today, unchanged
- [ ] Skills that write content (`lead`, `qa`, `distribute`) apply any `writing_style` rules to what they produce
- [ ] A rule is never validated against a list of accepted values

**Migration**
- [ ] `/specos-start` detects a project holding either old file and no `specos-project.yml`, and offers to merge
- [ ] The merged result is printed in full before anything is written
- [ ] When `language` differs between the two old files, the `specos-standards.yml` value wins and the choice is stated out loud
- [ ] On approval: `specos-project.yml` is written and both old files are deleted in the same step
- [ ] On refusal: the session continues reading the old files, and the offer is not repeated until the next session
- [ ] Migration is offered at most once per session
- [ ] A project with only `specos-project.yml` is never asked anything

**Tooling**
- [ ] `/specos-config` edits all three blocks, and shows accepted values and the default for every setting
- [ ] `/specos-config` writes only what the Lead set — it never materializes defaults into the file
- [ ] `/specos-init` generates `specos-project.yml` and neither old file
- [ ] `/specos-status` reports which settings are set and which are running on default
- [ ] `verify.sh` fails on an unknown key or an invalid value under `settings:`
- [ ] `verify.sh` fails when a setting documented in this spec is not read by the skill that owns it
- [ ] `verify.sh` fails if any skill still references `specos-outputs.yml` or `specos-standards.yml`

---

## Out of Scope
- CLI binary — bash script only for v3
- Settings for anything a value cannot express — those are rules, see the qualification test below
- Per-feature or per-role setting overrides — `settings:` is project-wide in this version
- Settings for `init`, `start`, `split`, `group`, `status`, `help` — those skills have no repeated free decision worth pinning
- Merging `local-workspace.yml` into `specos-project.yml` — one is local and uncommitted, the other is shared and committed. Different lifetimes, different audiences, deliberately separate
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
- Automatic MCP integration — outputs are manual in v3, MCP declared in specos-project.yml for v4
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
├── specos-project.yml              ← the one committed config: destinations, settings, rules
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

Write contract: durable, verified facts about a repo go to that repo's memory. Never the session narrative, never anything already in the spec, `AGENTS.md`, or `specos-project.yml`.

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

### The two config files

SpecOS has exactly two config files, split by one question: **does the whole team share this?**

| | `local-workspace.yml` | `specos-project.yml` |
|---|---|---|
| Holds | who you are, your roles, repo paths, memory links | language, team, ids, integrations, outputs, settings, rules |
| Answers | where everything is on **my** machine | how **this project** works |
| Committed | never — always in `.gitignore` | yes — identical for everyone on the team |
| Changes when | you switch machines | the team changes how it works |

This is why `specos-outputs.yml` and `specos-standards.yml` merge and `local-workspace.yml` does not: the first two were the same thing split arbitrarily — both committed, both project-level — while the third answers a different question with a different lifetime.

The old split had no defensible line. `ids.testcase_prefix` (how a test case is numbered) lived in outputs, while how many test cases to write would have gone to standards — one concern in two files. `language` was declared in **both**, which is a defect the merge removes by construction.

### specos-project.yml schema

Three blocks, distinguished by who consumes them and how.

```yaml
# specos-project.yml — everything configurable about this project.
# Committed. Machine-specific paths live in local-workspace.yml.
#
# This file is written in English — keys, comments, and rules alike — whatever
# language.specs says. The config language and the content language are
# independent: the example below is an English file for a Spanish project.
version: "2"

language:
  specs: es       # ISO 639-1 — language for spec.md, tasks.md, testcases.md
  outputs: es     # language for generated outputs

# --- Team and destinations: who does what, and where output goes ---
team:
  lead: human
  qa: human               # human | agent | both
ids:
  task_prefix: SP
  testcase_prefix: TC
integrations:
  jira: { enabled: false, mcp: null }
  confluence: { enabled: false, mcp: null }
  notion: { enabled: false }
  linear: { enabled: false }
  github_issues: { enabled: false }
  slack: { enabled: false }
outputs:
  tasks: { destination: manual }
  testcases: { destination: manual }
  confluence_doc: { destination: manual }

# --- Settings: closed schema. Skills read these and obey. ---
# Every key optional. Absent = the documented default.
settings:
  lead:
    max_tasks: 15
    max_journeys: none
    require_error_journey: true
  qa:
    cases_per_ac: standard
    include_negative_cases: true
    batch_by: journey
  distribute:
    diagrams: ask
    branch_info: ask
    task_title_max_words: 8
  dev:
    require_tests: false

# --- Rules: free-form. Skills read these and interpret. ---
# Any section name, organized by role. `shared` applies to every role.
rules:
  writing_style:
    shared:
      - "Direct tone, no filler. Never 'should work correctly'"
      - "Second person in test case steps"
  code_style:
    backend:
      - "Validate every request body with Zod"
```

### The config file is English, the content is not

`specos-project.yml` is written in English end to end — keys, comments, and rule sentences — no matter what `language.specs` says. The two are independent, and the schema above shows exactly that case: `specs: es` with English rules.

| | Language |
|---|---|
| Keys and setting values | English — fixed by the closed schema |
| Comments | English |
| Rule sentences | English |
| `language.specs` / `language.outputs` | ISO 639-1 codes — not text, unaffected |
| `spec.md`, `tasks.md`, `testcases.md`, generated outputs | whatever `language.specs` / `language.outputs` says |

Only rule sentences are actually affected, since everything else is English by construction. The reason to fix them too: a rule is an instruction the agent follows, and instructions are followed most reliably in the language the model is strongest in. A rule that reads *"Direct tone, no filler"* produces Spanish output just as well when `language.specs: es` — the instruction language and the output language never needed to match.

Two guards keep this from becoming a trap:

**Nothing is silently reworded.** `/specos-config` takes a rule in any language, translates it, and shows the English text back before writing. A Lead who thinks in Spanish keeps working in Spanish and never has to discover that their rule was quietly rephrased.

**Literal strings are never translated.** A rule like *"Every test case step starts with `Dado que`"* keeps `Dado que` verbatim — that string has to appear in the output exactly as written, so translating it would break the rule it is stating. The instruction is translated; the payload is not.

A non-English rule written by hand still works. It is applied as written, never rejected and never ignored — `/specos-config` simply offers to translate it next time it runs.

### Settings vs rules

This is the only distinction the design rests on.

| | `settings` | `rules` |
|---|---|---|
| Shape | a number, a boolean, one option from a short list | a sentence |
| The skill | **obeys** it | **interprets** it |
| Schema | closed — every key and value enumerated here | open — any section, any role, never rejected |
| Invalid input | reported, falls back to default | impossible — there is nothing to validate against |
| Answers | *how many, how long, whether to ask* | *how it should read* |

`cases_per_ac: 2` produces two cases, every time, with no interpretation. `"Direct tone, no filler"` cannot be reduced to a value and must be read as language.

### What qualifies as a setting

`settings:` is not a second place to write rules. A candidate belongs there only if all three hold:

1. **The project answers it the same way every time.** A one-off decision is a conversation, not config.
2. **It is bounded** — an enum, an integer, or a boolean. If it can only be said in prose, it is a rule.
3. **Today it is a free decision**: hardcoded in a skill prompt, asked on every run, or left to model discretion so the output varies between runs.

Anything failing (2) goes to `rules`. This is the line that keeps `settings` deterministic.

Tone is the clearest example of a candidate that fails (2) and belongs in `rules`. `neutral | conversational` is two labels over a continuous space, and each skill would read them differently — the exact non-determinism `settings` exists to remove. As a sentence under `rules.writing_style` it says what a label cannot, and it applies to every skill that writes content.

### Settings catalog

| Skill | Setting | Accepted values | Default | What it fixes today |
|---|---|---|---|---|
| `lead` | `max_tasks` | integer ≥ 1 | `15` | Hardcoded in the skill and in `constitution.md` — two places that can drift |
| `lead` | `max_journeys` | integer ≥ 1, or `none` | `none` | No threshold exists, so nothing ever suggests `/specos-split` |
| `lead` | `require_error_journey` | `true` \| `false` | `true` | Hardcoded; some teams model errors elsewhere |
| `qa` | `cases_per_ac` | `minimal` (1) \| `standard` (1–2) \| `exhaustive` (2–4) \| integer | `standard` | Nothing specifies a count — output size varies every run |
| `qa` | `include_negative_cases` | `true` \| `false` | `true` | Left to model discretion, so error cases appear inconsistently |
| `qa` | `batch_by` | `journey` \| `ac` \| `all` | `journey` | Hardcoded batching in Step 2A |
| `distribute` | `diagrams` | `none` \| `combined` \| `per_journey` \| `ask` | `ask` | Asked on every run, always answered the same |
| `distribute` | `branch_info` | `ask` \| `none` | `ask` | Same — a question with a stable per-project answer |
| `distribute` | `task_title_max_words` | integer ≥ 1 | `8` | Hardcoded; teams whose tracker allows longer titles cannot change it |
| `dev` | `require_tests` | `true` \| `false` | `false` | No setting exists; teams enforce it outside SpecOS |

`ask` is a first-class value, not a fallback: it is how a project keeps a question it genuinely wants asked every run.

### Reading contract

Every skill follows the same steps, in this order:

1. Read `specos-project.yml`. Absent file, or absent block → every setting is at its default and there are no rules. Do not warn.
2. For each setting the skill owns: unknown key or value outside the accepted set → report once, naming the key, the value found, and what is accepted; then use the default. Collect all such errors into one message per run.
3. Apply `rules` as they are written, in whatever language they are written in. Never validate them, never reject an unknown section, and never let a rule's language change the language of the output — that is `language.specs` alone.
4. Never surface a setting's value as content. A setting changes what the skill *does*; it is not text to inject into a spec, a task, or a test case.

### Migration from the two old files

Runs at `/specos-start`, before anything else, and only when `specos-project.yml` is absent and at least one old file is present.

| Found | Action |
|---|---|
| `specos-project.yml` | nothing — never asked |
| either or both old files, no new file | offer to merge, print the result, write on approval |
| nothing | nothing — a fresh project starts on the new file |

The merge is mechanical: `specos-outputs.yml` contributes `team`, `ids`, `integrations`, `outputs`; `specos-standards.yml` contributes `language` and every free-form section, which move under `rules:`. `settings:` is not invented — it is written only when the Lead later sets something.

One conflict is possible and is resolved by rule: `language` exists in both files. The `specos-standards.yml` value wins, because that is the one skills read for content today, and the choice is stated out loud rather than applied silently.

Rules carried over from `specos-standards.yml` may be in any language, since nothing required English before. The merge translates them and reports which ones it translated, as part of the result printed for review — so the translation is approved together with the merge, not after it.

On approval both old files are deleted in the same step, so no project ever holds three config files. On refusal the session proceeds against the old files and the offer returns next session — it is never repeated twice in one session.

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
