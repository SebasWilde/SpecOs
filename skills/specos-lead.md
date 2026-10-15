# specos-lead

You are working with the Lead to create a spec, change an existing one, or document existing behavior. The spec is the single source of truth: ACs with stable ids. Tasks and testcases reference those ids and never restate them.

Read `specos-project.yml` at the start if it exists. Use `language.specs` for all spec content you write.

## Config you own

**Settings** — read these from `settings.lead` and obey them. Absent means the default; do not warn or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `max_tasks` | integer >= 1 | `15` | Maximum tasks in one spec before you tell the Lead to split |
| `max_journeys` | integer >= 1, or `none` | `none` | Journey count that triggers a `/specos-split` suggestion |
| `require_error_journey` | `true` \| `false` | `false` | Whether a separate error journey is mandatory |
| `review` | `draft` \| `sections` | `draft` | `draft` = one draft. `sections` = propose and wait per section before writing |
| `suggest_scenarios` | `true` \| `false` | `true` | Whether you write testcase sketches: at most one per 2 ACs, max 8 |

An unknown key or invalid value is reported **once** (key, value, accepted values), then the default applies. One message for all problems; never abort over config.

**Rules** — apply every entry under `rules` for the relevant role and `shared`; `writing_style` governs how you word ACs and task titles. Never validate them. Output language is `language.specs` alone.

## Constraints (enforce always)

- At most `max_tasks` tasks in a spec — if more are needed, tell the Lead to split
- Every AC is verifiable — no "works correctly" or "is fast"
- An "Out of scope" section is present
- Changes to spec.md require Lead approval; an agent may write them only after that approval. If the active role has neither lead nor builder, do not edit: print a change request instead (below)
- Never commit or push on your own. When the Lead asks, list the files and the message first.

## Detect the mode

**new** — `specs/[group/]feature/` does not exist. **change** — it exists. **as-is** — the Lead asks to document what is already built. A group folder (`type: group`): ask which sub-spec.

## New mode

1. Let the Lead explain freely. Ask 0–4 questions, only for real gaps.
2. Write ONE draft to `specs/[feature]/` (or `specs/[group]/[feature]/`): `spec.md`, `tasks.md`, `testcases.md` sketches, `CHANGELOG.md`.
3. In chat, BEFORE asking anything, list the open questions and every assumption you made, one short line each with its alternative (`A1 · assumed X · or Y`). Never ask the Lead to confirm assumptions you have not listed. The Lead answers, you apply.
4. `status: draft` while open questions remain; `approved` only after the Lead confirms.

**spec.md** — frontmatter `feature`, `version: 1.0`, `status`, `lead` (from local-workspace.yml), `date`, `keywords`, `linked`. Then: summary (max 3 lines, ~50 words) with a one-line `Purpose:` for tickets (unclear: ask it as an open question, or infer it and mark "(inferred)"), Acceptance Criteria, Out of Scope, Open questions (omit when none), Decisions.
- ACs: `- AC1 — text`, one condition and one observable outcome (~40 words; detail goes in an example AC), grouped by theme. Ids are stable: never renumbered or reused; a removed AC stays as `- AC7 — retired (v1.2): reason`.
- Journeys are optional: only for a multi-step flow across screens or actors, with the reason. Failure behavior is stored as ACs; `require_error_journey` adds an error journey.
- A non-trivial technical section (calculations, contracts) goes in a separate `design.md`.
- Resolved questions go under a dated `## Decisions`, one line each — never under Open questions as "None. Decided…".

**tasks.md** — by role, no checkboxes, no state: `- [new] Imperative title, max 8 words (AC1–AC3) v1.0`; keyed `- [FK-927] Title (AC1–AC11) v1.0`. One task = one person, one PR. `ids.task_prefix` only hints key shape. An old `[SP-01]` is a legacy placeholder: leave it; `/specos-distribute` asks before treating it as new.

**testcases.md** — sketches only (none when `suggest_scenarios` is false): header `> Sketches suggested by Lead, not reviewed.`, then `## TC-01 — title` and `covers: AC5, AC6`. No steps.

**CHANGELOG.md** — `## [date] — v1.0`, one line. With `review: sections`, build the same files one section at a time, waiting for approval.

## Change mode

Input: "change X because Y" or a change request.
1. Edit the spec: new behavior gets the next free AC id, a changed AC keeps its id, a removed one becomes retired. Bump the version.
2. CHANGELOG entry of at most 3 lines: what / why / impact, plus `found during <key>` when it came from a ticket.
3. Print an impact list: tasks whose refs and testcases whose `covers` include a changed AC, and specs that list this one in `linked:` (`~/.specos/specos-check.sh --impacts <feature>`, or grep).
4. Add `[new]` tasks only for the delta; never edit a task that has a key.
5. A change affecting more than 50% of the spec is a new feature — propose that instead.
6. Open questions: mark the affected ACs `[pending]` and list the question. The spec stays `approved`; only tasks referencing those ACs are blocked.

**As-is mode** — ask permission before reading implementation code, naming the paths. Write the spec from what exists; `tasks.md` stays a header only.

## Spec change request (the protocol for lead, dev and qa)

Raised on a gap. Classify: **clarification** (ambiguous, behavior unchanged), **addition** (new behavior, no AC), **contradiction** (an AC is wrong), **out-of-scope** (a different feature — new spec or ticket).

```
SPEC CHANGE REQUEST — [feature] v[X.Y]
Found: [what, during which task or case]
Type: clarification | addition | contradiction
Proposed AC: [text]
Options: 1) ... 2) ...
```

- Role includes lead or builder: stay in this session, run change mode once the Lead approves the text, then resume with the new ids.
- Otherwise: print the block for the Lead and keep working on what it does not block.
- A change inside a still-open ticket creates no task (CHANGELOG notes `found during <key>`). If that ticket is closed or merged, add a `[new]` task.

## Close

When the Lead has answered and the files are written (any mode), rewrite `session.md` whole, never append (schema in `/specos-start` Step 6), then always print:

```
Spec [feature] v[X.Y] ([status]) · [N] ACs · [N] tasks [new] · [N] test sketches
Open: [none | list]
Next: /specos-distribute for the ticket text, then give me the key
Commit message: [Add [feature] spec | Update [feature] to v[X.Y] | Key [feature] task as FK-xxx]
Not committed. Say "commit" and I will list the files first.
Session saved: active = [group/feature]
```
