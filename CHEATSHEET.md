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
| `/specos-init` | Lead | First-time setup — 7 questions, generates AGENTS.md + constitution.md + specos-outputs.yml + specos-standards.yml |
| `/specos-start` | Everyone | Begins any session, routes by role and session state |
| `/specos-lead` | Lead | Builds spec + tasks collaboratively, assigns SP-XX IDs, collects real IDs |
| `/specos-lead-parallel` | Lead | Drafts several related specs in one pass |
| `/specos-dev` | Dev | Loads only the relevant spec, writes to implementation repo |
| `/specos-qa` | QA | Generates testcases.md collaboratively, assigns TC-XX IDs |
| `/specos-distribute` | Lead / QA | Generates outputs per specos-outputs.yml + standards |
| `/specos-split` | Lead | Splits a large spec into sub-specs under a group folder |
| `/specos-group` | Lead | Groups related existing specs under a shared parent folder |
| `/specos-config` | Lead | Configures specos-standards.yml interactively |
| `/specos-status` | Everyone | Shows current session state (read-only) |
| `/specos-help` | Everyone | Lists all commands and key files (no session needed) |

---

## Perspective flows

**Lead — new feature:**
```
/specos-start → construction perspective
→ spec.md section by section → Lead validates each
→ tasks.md collaboratively → Lead adjusts
→ SP-XX IDs assigned → real IDs collected → tasks.md updated
```

**Dev — implement task:**
```
/specos-start → provide task ID or description
→ agent loads spec.md → implement in context
```

**QA — generate test cases:**
```
/specos-start → provide feature or task ID
→ agent loads spec.md → testcases.md collaboratively
→ QA edits freely → /specos-distribute
```

**Solo builder (agent takes breaking perspective):**
```
/specos-start → construction → finish feature
→ agent proposes: "Want me to take the breaking perspective?"
→ agent generates testcases.md, flags edge cases
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
| `spec.md` | Lead + agent (collaborative) | Journeys, ACs, technical — everything |
| `tasks.md` | Lead + agent (collaborative) | Tasks by role, no checkboxes, max 15 |
| `testcases.md` | QA + agent (collaborative) | Test cases with TC-XX IDs, free-form fields |
| `CHANGELOG.md` | Lead | Spec changes with date and reason |

---

## tasks.md format

```markdown
## Backend
- [SP-01] Description

## Frontend
- [SP-02] Description

## QA
- [SP-03] Description
```

No checkboxes. State lives in the team's task software.

---

## testcases.md format

```markdown
## TC-01 — Title
task: SP-03
steps:
  1. Step one
  2. Step two
expected: Expected result
```

Additional fields are optional and free-form — agent never rejects them.

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

**`session.md`** — what you are working on right now. Rewritten every session.

```markdown
# SpecOS session
updated: YYYY-MM-DD

active_feature: feature-folder-name
task_id: SP-01
task_description: Short description
spec_path: specs/feature-name/spec.md
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

## specos-standards.yml

Committed config. Edit as the project evolves.

```yaml
# Only `language` is reserved. Add any section your project needs.
language:
  specs: en
  outputs: en

acceptance_criteria:   # → injected into task ACs in /specos-distribute
  backend:
    - "All error responses must include an error code and a message"
  shared:
    - "..."

code_style:            # → injected as ## Standards in task output, enforced by /specos-dev
  backend:
    - "..."
  shared:
    - "No hardcoded environment-specific values — use environment variables"

# Other sections teams add: api_conventions, accessibility, security, naming_conventions
```

Skills read the entire file. No fixed schema beyond `language`. Each section's entries are applied to the matching role and `shared`.

---

## Golden rules

- **No code without a spec** — repo presence = approved
- **No status fields** — task software is the source of truth
- **Max 15 tasks** — if more, split the feature
- **Spec change >50% of content** — create a new feature
- **Every spec change** — add CHANGELOG.md entry

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
