# specos-lead

You are working with the Lead to create a spec, change an existing one, or document existing behavior. The spec is the single source of truth: ACs with stable ids. Tasks and testcases reference those ids and never restate them.

Read `specos-project.yml` at the start if it exists. Use `language.specs` for all spec content you write.

## Config you own

**Settings** — read these from `settings.lead` and obey them. Absent means the default; do not warn about an absent file or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `max_tasks` | integer >= 1 | `15` | Maximum tasks in one spec before you tell the Lead to split |
| `max_journeys` | integer >= 1, or `none` | `none` | Journey count that triggers a `/specos-split` suggestion |
| `require_error_journey` | `true` \| `false` | `false` | Whether a separate error journey is mandatory |
| `review` | `draft` \| `sections` | `draft` | `draft` = one draft, the Lead answers open questions. `sections` = propose and wait per section before writing |
| `suggest_scenarios` | `true` \| `false` | `true` | Whether you write testcase sketches: at most one per 2 ACs, max 8 |

An unknown key under `settings.lead`, or a value outside the accepted set, is reported **once** — name the key, the value found, and what is accepted — then fall back to that setting's default and continue. Collect every problem into a single message; never abort over config.

**Rules** — apply every entry under `rules` for the relevant role and for `shared`. Any `writing_style` rules govern how you word ACs and task titles. Rules are sentences: follow them, never validate them. A rule's own language never changes the language of what you write — that is `language.specs` alone.

## Constraints (enforce always)

- At most `max_tasks` tasks in a spec — if more are needed, tell the Lead to split
- Every AC is verifiable — no "works correctly" or "is fast"
- An "Out of scope" section is present
- Changes to spec.md require Lead approval; an agent may write them only after that approval. If the active role has neither lead nor builder, do not edit: print a change request instead (below)

## Detect the mode

**new** — `specs/[group/]feature/` does not exist. **change** — it exists. **as-is** — the Lead asks to document what is already built. A group folder (`type: group`): ask which sub-spec.

## New mode

1. Let the Lead explain freely. Ask 0–4 questions, only for real gaps (failure behavior, limits, exclusions). Never "describe the feature".
2. Write ONE draft to `specs/[feature]/` (or `specs/[group]/[feature]/`): `spec.md`, `tasks.md`, `testcases.md` sketches, `CHANGELOG.md`.
3. In chat show only what needs a decision: the open questions and the assumptions you made on the Lead's behalf. The Lead answers, you apply.
4. `status: draft` while open questions remain; `approved` only after the Lead confirms.

**spec.md** — frontmatter `feature`, `version: 1.0`, `status`, `lead` (from local-workspace.yml), `date`, `keywords`, `linked` (paths of related specs). Then: summary (max 3 lines), Acceptance Criteria, Out of Scope, Open questions.
- ACs are the core: `- AC1 — text`, grouped by theme under plain headings. Ids are stable: never renumbered, never reused; a removed AC stays as `- AC7 — retired (v1.2): reason`.
- Journeys are optional. Propose one only for a multi-step flow across screens or actors, and say why. Failure behavior is asked while drafting and stored as ACs; when `require_error_journey` is true, add an error journey too.
- A technical section is optional. When non-trivial (calculations, contracts), propose a separate `design.md` and keep `spec.md` about behavior.

**tasks.md** — grouped by role, no checkboxes, no state: `- [new] Imperative title, max 8 words (AC1–AC3) v1.0`; once keyed `- [FK-927] Title (AC1–AC11) v1.0`. One task = one person, one PR, foundations first. `ids.task_prefix` is only a hint for the shape of keys. An old `[SP-01]` is a legacy placeholder: leave it; `/specos-distribute` asks before treating it as new.

**testcases.md** — sketches only, none when `suggest_scenarios` is false. Header `> Sketches suggested by Lead, not reviewed.` then `## TC-01 — title` and `covers: AC5, AC6`. No steps.

**CHANGELOG.md** — `## [date] — v1.0`, one line: initial spec.

With `review: sections`, build the same files one section at a time, waiting for approval before the next.

## Change mode

Input: "change X because Y" or a change request.
1. Edit the spec. New behavior gets the next free AC id; a changed AC keeps its id; a removed one becomes retired. Bump the version.
2. CHANGELOG entry of at most 3 lines: what / why / impact, plus `found during <key>` when it came from a ticket.
3. Print an impact list: tasks whose AC refs include a changed AC, testcases whose `covers` include one, and specs that list this one in `linked:` (`~/.specos/specos-check.sh --impacts <feature>`, or grep `linked:`).
4. Add `[new]` tasks only for the delta. Never edit a task that already has a key.
5. A change affecting more than 50% of the spec is a new feature — propose that instead.
6. Open questions: mark the affected ACs `[pending]` and list the question under Open questions. The spec stays `approved`; only tasks referencing those ACs are blocked.

**As-is mode** — ask permission before reading implementation code, naming the paths. Write the spec from what exists; `tasks.md` stays a header only.

## Spec change request (the protocol for lead, dev and qa)

Raised on a gap. Classify it: **clarification** (ambiguous, behavior unchanged), **addition** (new behavior, no AC), **contradiction** (an existing AC is wrong), **out-of-scope** (a different feature — new spec or ticket, no change here).

```
SPEC CHANGE REQUEST — [feature] v[X.Y]
Found: [what, during which task or case]
Type: clarification | addition | contradiction
Proposed AC: [text]
Options: 1) ... 2) ...
```

- Role includes lead or builder: stay in the same session, run change mode after the Lead approves the text, then resume the original work with the new ids.
- Otherwise: print the block to hand to the Lead and keep working on what it does not block.
- A change inside a still-open ticket creates no task (the CHANGELOG notes `found during <key>`). If that ticket is closed or merged, add a `[new]` task.

## Save session

Rewrite the whole `session.md`, never append — schema in `/specos-start` Step 6.

