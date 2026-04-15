---
feature: specos-v3
version: 2.0
status: approved
lead: Sebastian Wilde
date: 2026-04-15
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
- [ ] All skills work in Claude Code, OpenCode via slash commands
- [ ] All skills work in Cursor, Codex, Kiro, Antigravity, Windsurf, Copilot via AGENTS.md
- [ ] No external library, API, or binary dependency

### Repo structure flexibility
- [ ] Works in monorepo
- [ ] Works with separate repos — specs repo as entry point, implementation repos as destinations
- [ ] Implementation repo paths in session.md — local, never committed
- [ ] Agent validates paths before any session requiring code writing

---

## Out of Scope
- CLI binary — bash script only for v3
- Engram or any persistent memory system — session.md is sufficient
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
├── CHEATSHEET.md
├── CREDITS.md
├── LICENSE
├── .gitignore                      ← includes .specos/session.md
├── skills/
│   ├── specos-init.md
│   ├── specos-start.md
│   ├── specos-lead.md
│   ├── specos-dev.md
│   ├── specos-qa.md
│   └── specos-distribute.md
├── adapters/
│   ├── claude-code/
│   ├── opencode/
│   ├── cursor/
│   └── generic/
├── specs/
│   └── specos-v3/
│       ├── spec.md
│       ├── tasks.md
│       ├── testcases.md
│       └── CHANGELOG.md
└── examples/
    └── feature-tags/
```

### session.md schema

```markdown
# SpecOS session
updated: YYYY-MM-DD

roles: [lead, backend]
active_feature: feature-folder-name
task_id: TASK-42
task_description: Short task description
spec_path: specs/feature-name/spec.md
implementation_repos:
  backend: ../repo_back
  frontend: ../repo_front
  e2e: null
```

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
