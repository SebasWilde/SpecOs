# SpecOS v3 — Cheat Sheet

> One page. Everything you need for daily work.

---

## The 2 perspectives

```
CONSTRUCTION   Lead defines spec → Dev implements
BREAKING       QA (human or agent) challenges, tests, flags gaps
```

Both always required. Never the same logic.

---

## Session startup

```
/specos-start
```

Agent reads `session.md`. If it exists: resumes. If not: asks based on your role.

---

## Skill reference

| Skill | Who | What |
|---|---|---|
| `/specos-init` | Lead | First-time setup — 7 questions, generates AGENTS.md + constitution.md + specos-project.yml |
| `/specos-start` | Everyone | Begins any session, routes by role and session state |
| `/specos-lead` | Lead | New spec in one draft, change an existing spec, or document what exists |
| `/specos-dev` | Dev | Loads only the relevant spec, shows the task's ACs, writes to implementation repo |
| `/specos-qa` | QA | Expands the Lead's sketches into test cases, every AC covered |
| `/specos-distribute` | Lead / QA | Brief `[new]` tasks, tests, Confluence, diagrams — per specos-project.yml |
| `/specos-split` | Lead | Splits a large spec into sub-specs under a group folder |
| `/specos-group` | Lead | Groups related existing specs under a shared parent folder |
| `/specos-config` | Lead | Configures specos-project.yml interactively |
| `/specos-status` | Everyone | Shows current session state; `--check` runs the spec checks (read-only) |
| `/specos-help` | Everyone | Lists all commands and key files (no session needed) |

---

## Perspective flows

**Lead — new feature:**
```
/specos-start → construction perspective → explain the feature freely
→ 0–4 questions only for real gaps → ONE draft: spec + tasks + sketches + CHANGELOG
→ answer the open questions → status: approved
→ /specos-distribute → create tasks → give the keys in order → [new] replaced
```

**Anyone — the spec has a gap:**
```
stop → classify: clarification | addition | contradiction | out-of-scope
→ request: what was found + proposed AC text + 1–2 options
→ lead/builder role: change mode in the same session, then resume with the new AC ids
→ other roles: hand the printed block to the Lead, keep working on what it does not block
```

**Lead — change a spec:**
```
"change X because Y" → edit the spec, bump version, CHANGELOG (max 3 lines)
→ impact list: tasks · testcases · linked specs → [new] tasks only for the delta
```

**Dev — implement task:**
```
/specos-start → provide task key or description
→ agent shows the task's ACs + sketched flows → implement
→ closing block for the PR: key · spec vX.Y · covers AC… · changes · deviations
```

**QA — expand test cases:**
```
/specos-start → provide feature or task key
→ agent loads spec + sketches → expands in batches, shows the draft before writing
→ "add TC: ..." adds cases live → /specos-distribute
```

**Solo builder (agent takes breaking perspective):**
```
/specos-start → construction → finish feature
→ agent proposes: "Want me to take the breaking perspective?"
→ /specos-qa from the spec alone, flags gaps as spec change requests
```

**Person with multiple roles:**
```
/specos-start → roles: [lead, backend]
→ "Which perspective today? Construction / Breaking / Both"
→ same session, both perspectives, no restart
```

---

## Files per feature

| File | Who writes | What |
|---|---|---|
| `spec.md` | Lead + agent | ACs with stable ids (`AC1`, `AC21b`), out of scope, open questions. `status: draft \| approved` |
| `tasks.md` | Lead + agent | Tasks by role: `[new]` or `[KEY]`, AC refs, spec version. No state, max 15 |
| `testcases.md` | Lead (sketches) + QA | `## TC-01 — title`, `covers:` ACs; QA adds `steps:` / `expected:` |
| `CHANGELOG.md` | Lead | Spec changes — what / why / impact, max 3 lines |
| `design.md` | Lead (optional) | The how, when non-trivial. Never automated |
| `00-architecture.md` | Lead (optional) | Context shared by a group. Never automated |

---

## tasks.md format

```markdown
## Backend
- [FK-927] Add tag validation to post model (AC1–AC3) v1.0

## Frontend
- [new] Build TagInput component (AC1, AC4) v1.0
```

No checkboxes, no state. Tasks reference ACs; they never restate them. Old `[SP-01]` placeholders are left alone; `/specos-distribute` asks before treating them as new.

---

## testcases.md format

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
expected: Chip truncated to 30 characters, no error
```

A case with `steps:` is expanded, one without is a sketch — no status field. Additional fields are free-form.

---

## Checks

```
/specos-status --check            warnings: uncovered ACs, dangling refs, stale stamp, [new] tasks...
/specos-status --check --strict   same, exit code 1 on any warning
specos-check.sh --impacts <feature>   specs that link to a feature
```

---

## Local files — two, never committed

**`local-workspace.yml`** — who you are on this machine. Written once by the first `/specos-start`.

```yaml
user: Your Name
roles: [lead, backend]
implementation_repos:
  backend: ../repo_back
  frontend: null
  e2e: null
memory_links:            # auto | a path | off
  self: auto
  backend: auto
  frontend: ~/some/non-standard/memory
  e2e: off
```

**`session.md`** — what you are working on right now. Rewritten whole every session, 30 lines at most.

```
updated: YYYY-MM-DD
active_feature: group/feature
spec_version: 1.0
task: KEY | [new] | null
next: one line
open:            # max 3
  - ...
parked:          # other features
  - feature: one line
```

Both always in `.gitignore`. Never committed.

---

## Memory links

Separate repos = separate agent memory namespaces. Without a link, a session started in the specs repo re-explores the backend repo it already learned.

SpecOS does not store memory — it stores the map of where memory lives.

**How the map gets built** — `/specos-start` Step 0.5, every session. Compares `implementation_repos` against `memory_links` and asks only about keys that have a repo path but no value. A key with a value is never re-asked.

| Situation | What happens |
|---|---|
| New project | asked once on first start |
| Project older than this feature | all keys missing → asked once on next start |
| Repo added later | only the new key is asked about |
| Monorepo | step skipped entirely — never asked |

Max one question per session. `off` is permanent.

**Values:** `auto` (derive each session, recommended) · a path (verbatim) · `off` (never)

**Resolution, for any key that is not `off`:**

| Step | Rule |
|---|---|
| Path | used verbatim |
| `auto` | agent's own convention — Claude Code: `/Users/me/proj/api` → `~/.claude/projects/-Users-me-proj-api/memory` |
| Fallback | agent with no memory system → `.specos/memory.md` inside the repo |
| Absent | no memory yet — session proceeds as before |

**Three rules:**
- Index first — open a single entry only when its description matches the task
- Verify before trusting — confirm any path or symbol still exists, correct it if stale
- Memory answers *where* and *how*; the spec answers *what* and *why*. Memory never authorizes code without a `spec.md`

Learnings are written back to the repo they describe, not the repo the session started in.

`/specos-status` prints each link as `linked` · `auto` · `off` · `unmapped` · `broken`.

**session.md is not memory:**

| | `session.md` | Agent memory |
|---|---|---|
| Answers | what I am working on | what I know about this repo |
| Scope | the project | one repo, one agent |
| Lifetime | rewritten each session | accumulates |
| Portable | yes — shared by the team | no — local, agent-specific |
| Authoritative | yes, for the active task | no — verified before use |

---

## Grouped specs

Use when a feature is too large or when specs share a domain.

```
specs/
└── payments/              ← group folder
    ├── spec.md            ← summary + list of sub-specs only (type: group)
    ├── checkout/
    │   ├── spec.md
    │   └── tasks.md
    └── refunds/
        ├── spec.md
        └── tasks.md
```

| When | Skill |
|---|---|
| Spec is too large, split into parts | `/specos-split` |
| Multiple specs share a domain | `/specos-group` |

`active_feature` in session.md: `payments/checkout`

---

## specos-project.yml

The one committed config file. `local-workspace.yml` holds machine-specific paths and is never committed.

Written in English — keys, comments, and rules alike — regardless of `language.specs`. Config language and content language are independent.

```yaml
version: "2"

language:
  specs: en           # language of spec.md, tasks.md, testcases.md
  outputs: en         # language of generated outputs

# --- Team and destinations ---
team:      { lead: human, qa: human }      # human | agent | both
ids:       { task_prefix: SP, testcase_prefix: TC }
integrations: { jira: { enabled: false, mcp: null }, ... }
outputs:   { tasks: { destination: manual }, ... }

# --- Settings: closed schema. Skills obey. Every key optional. ---
settings:
  lead:       { max_tasks: 15, max_journeys: none, require_error_journey: false, review: draft, suggest_scenarios: true }
  qa:         { cases_per_ac: standard, include_negative_cases: true, batch_by: journey }
  distribute: { diagrams: ask, branch_info: ask, task_title_max_words: 8, task_detail: brief }
  dev:        { require_tests: false }

# --- Rules: free-form. Skills interpret. Any section, by role. ---
rules:
  acceptance_criteria:   # → injected into task ACs in /specos-distribute
    backend:
      - "All error responses must include an error code and a message"
  code_style:            # → injected as ## Standards, enforced by /specos-dev
    shared:
      - "No hardcoded environment-specific values — use environment variables"
  writing_style:         # → governs how every skill words its output
    shared:
      - "Direct tone, no filler. Never 'should work correctly'"
```

### Settings vs rules

| | `settings` | `rules` |
|---|---|---|
| Shape | number, boolean, one of a listed set | a sentence |
| The skill | **obeys** it | **interprets** it |
| Schema | closed — invalid values fall back to the default | open — any section, never rejected |
| Use for | how many, how long, whether to ask | how it should read |

Anything that can only be said in a sentence — tone, naming style, review expectations — is a rule. Settings are for what a value can express.

### Settings catalog

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
| `distribute` | `task_detail` | brief \| full | brief |
| `dev` | `require_tests` | true \| false | false |

An absent key uses its default silently. An invalid value is reported once, then falls back to the default — a bad config never blocks a session. `ask` is a real choice: it keeps a question being asked every run.

Run `/specos-config` to edit any of this interactively.

### Migrating from the old files

Projects with `specos-outputs.yml` and `specos-standards.yml` are offered a merge on the next `/specos-start`. It prints the result before writing, and deletes both old files on approval.

---

## Golden rules

- **No code without an approved spec** — `status: approved`, in the repo, up to date; commit before handing to anyone else
- **No task or test state** — task software is the source of truth; the spec's `status` is the only one
- **Max 15 tasks** — if more, split the feature
- **Spec change >50% of content** — create a new feature
- **Every spec change** — Lead approves the text, then a CHANGELOG.md entry (what / why / impact, max 3 lines)

---

## Verifiable AC checklist

```
✓  "Token expires in exactly 24h"
✗  "Should look good"
✓  "Maximum 5 tags — 6th attempt is rejected with error message"
✗  "Tags work correctly"
```

---

*SpecOS v3*
