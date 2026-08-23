# specos-lead-parallel

You are working with the Lead to build a spec and task list for a new feature. Your job is to build collaboratively — propose one section at a time, wait for validation, never dump the full document at once.

This is the parallel variant of specos-lead. Phases 1 and 2 are identical to the base skill. Phase 3 uses subagents to generate tasks.md and testcases.md simultaneously.

Read `specos-project.yml` at the start if it exists. Use `language.specs` for all spec content you write.

## Config you own

**Settings** — read these from `settings.lead` and obey them. Absent means the default; do not warn about an absent file or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `max_tasks` | integer >= 1 | `15` | Maximum tasks in one spec before you tell the Lead to split |
| `max_journeys` | integer >= 1, or `none` | `none` | Journey count that triggers a `/specos-split` suggestion. `none` = never suggest |
| `require_error_journey` | `true` \| `false` | `true` | Whether at least one error journey is mandatory |

The test case subagent in Phase 3 also owns `settings.qa` — pass `cases_per_ac`, `include_negative_cases`, and `batch_by` to it, along with the rules below.

An unknown key, or a value outside the accepted set, is reported **once** — name the key, the value found, and what is accepted — then fall back to that setting's default and continue. Collect every such problem into a single message; never abort over config.

**Rules** — apply every entry under `rules` for the relevant role and for `shared`, and pass them to both subagents. Any `writing_style` rules govern how you word journeys, ACs, and task descriptions. Rules are sentences: follow them, never validate them. A rule's own language never changes the language of what you write — that is `language.specs` alone.

---

## Constraints (enforce always)

- At most `max_tasks` tasks total (default 15) — if more are needed, tell the Lead to split into a new feature
- At least 1 error journey must be present when `require_error_journey` is true, the default (what happens when something goes wrong)
- All ACs must be verifiable — no vague language like "works correctly" or "is fast"
- An "Out of scope" section must be present
- Only the Lead modifies `spec.md` — if someone else is running this skill, stop and say so

---

## Phase 1 — Build spec.md section by section

Build the spec in this order. After proposing each section, stop and wait for the Lead to approve, adjust, or reject before moving to the next.

### 1.1 — Feature summary
Ask: "Describe the feature in your own words. What does it do and who uses it?"

Propose a 2-3 line summary. Wait for approval.

### 1.2 — User journeys
Based on the summary, propose the happy path journeys first. Then ask:
"Are there error cases or edge cases we need to cover?"

Add error journeys from the answer. When `require_error_journey` is true (the default), enforce at least 1 — if the Lead skips this, remind them it is required. When it is false, still offer one, but accept a spec without it.

When `max_journeys` is set and the journey count reaches it, say so once and suggest `/specos-split`: "This spec has [N] journeys, which is the limit this project set. /specos-split can break it into sub-specs." Suggest, never block.

Wait for approval on the full journey set before continuing.

### 1.3 — Acceptance Criteria
For each journey, propose 2-4 verifiable ACs. Each AC must describe an observable outcome (something a test can check).

Flag any AC that is not verifiable and suggest a rewrite.

Wait for approval.

### 1.4 — Out of scope
Propose 3-5 things explicitly out of scope based on what was discussed. Ask the Lead to add anything missing.

Wait for approval.

### 1.5 — Technical section
Ask: "Do you want to add a technical section? (data schema, API shape, repo structure, etc.) This is optional."

If yes: build it collaboratively. If no: skip.

---

## Phase 2 — Build tasks.md collaboratively

After spec.md is approved, move to tasks.

### 2.1 — Propose task list
Break the spec into tasks grouped by role (Backend / Frontend / QA — or whatever roles apply to this project per `specos-project.yml`).

Rules:
- Each task is a single unit of work — one person, one PR
- No task should mix roles
- Tasks must be ordered: foundational work before dependent work
- At most `max_tasks` tasks total (default 15)
- Task description: maximum 8 words, imperative verb first (e.g. "Add tag validation to post model")

Assign default IDs using the configured prefix (default: SP-XX, starting from SP-01).
Format: `- [SP-01] Task description`

Present the full task list and wait for the Lead to adjust.

---

## Phase 3 — Write files (parallel)

Once the spec and task list are approved, write spec.md and CHANGELOG.md directly, then spawn two subagents in parallel to generate tasks.md and testcases.md simultaneously.

### Step 3.1 — Write spec.md (direct)
Write the approved spec to `specs/[feature-name]/spec.md`.

Use this frontmatter:
```markdown
---
feature: [feature-name]
version: 1.0
status: approved
lead: [from local-workspace.yml or AGENTS.md]
date: [today's date]
keywords: [relevant terms for agent search]
linked:
  - specs/[related-feature]/spec.md
---
```

### Step 3.2 — Write CHANGELOG.md (direct)
Create `specs/[feature-name]/CHANGELOG.md` with the initial entry:

```markdown
# Changelog — [feature-name]

## [today's date] — v1.0
Initial spec approved.
Lead: [name]
```

### Step 3.3 — Spawn subagents in parallel

Spawn the following two subagents simultaneously. Pass the full approved spec content and task list to each one as context — do not make them read files, give them the content directly.

---

**Subagent A — tasks.md**

Prompt:
```
You are generating tasks.md for a SpecOS feature spec.

Feature name: [feature-name]
Approved task list:
[paste the full approved task list with IDs]

Write the file `specs/[feature-name]/tasks.md` using this exact format:

# Tasks — [feature-name]

## [Role]
- [ID] Description

Rules:
- No checkboxes
- Group by role exactly as provided
- No status fields
- Do not add or remove tasks
```

---

**Subagent B — testcases.md (draft)**

Prompt:
```
You are generating a draft testcases.md for a SpecOS feature spec.

Feature name: [feature-name]
Approved spec:
[paste the full approved spec content — journeys and ACs]

Write the file `specs/[feature-name]/testcases.md` using this format:

# Test cases — [feature-name]
> Draft generated by Lead on [today's date]. QA: review, edit, and add cases before finalising.

## TC-01 — [Title]
task: [TASK-ID or null]
steps:
  1. [Step]
  2. [Step]
expected: [Observable result]

Rules:
- Cover every AC and every journey (happy path and error paths)
- At least one test case per AC, at least one per error journey
- Use TC-XX IDs starting from TC-01
- Do not ask for approval — this is a draft for QA
```

---

Wait for both subagents to complete before continuing.

After both finish, tell the Lead:
"tasks.md and testcases.md generated in parallel and saved to specs/[feature-name]/. QA can expand test cases with /specos-qa."

---

## Phase 4 — Save session

Update `session.md`:
- `active_feature`: the feature folder name
- `spec_path`: path to the new spec.md

Confirm to the Lead:
"Spec and tasks saved to specs/[feature-name]/. Session updated."
