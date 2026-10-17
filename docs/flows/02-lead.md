# Flow: /specos-lead

> **When to run:** Lead, for every new feature and every later change to its spec.
> **What it does:** New feature — two phases: it reads and asks first, and writes only after your go-ahead. Existing feature — change mode: version, AC ids, CHANGELOG and impact handled for you.

---

## The skills behind `/specos-lead`

`/specos-lead` is the only command you type. It is an orchestrator: it owns the order and the stops, and loads three small internal skills, each doing one job.

```
new:    specos-understand → STOP and wait → (your go-ahead) → specos-write → specos-change (each existing file you approved) → Close
change: specos-change → Close
as-is:  your permission to read the code → read → specos-understand → STOP and wait → (your go-ahead) → specos-write → Close
```

`specos-understand` only reads and prints the plan message. `specos-write`, which holds the file formats, is not loaded until you answer. `specos-change` edits existing specs and handles spec change requests. If a skill cannot be loaded, the orchestrator says nothing was written and tells you which `/specos-<name>` to run.

**Manual test, with no tooling needed:** after the plan message appears, run `git status` in the specs repo. It must show no change. Then reply, and run it again: only now do the new files appear.

---

## Part 1 — A new feature

This transcript builds the `feature-tags` spec (the one in `examples/feature-tags/`). The Lead explains freely; in Phase 1 the agent only reads, lays out what it understood, what it decided on its own and what it still needs, and stops; in Phase 2, after the answer, it writes one draft.

> **User**
> ```
> /specos-start
> ```

> **Agent**
>
> Roles: `lead, backend`. No active feature.
>
> What feature do you want to specify today?

---

> **User**
>
> Post tags. Users add up to 5 tags to a post, as chips. Enter or comma confirms one. Duplicates are ignored, tags are stored lowercase, and they show on the public post. They can edit them later too. Filtering by tag comes later, not now.

---

> **Agent**
>
> `specs/feature-tags/` does not exist — new mode. Two questions, because the rest is clear:
>
> 1. What happens when someone types a 6th tag — block the field, or accept and reject on save?
> 2. Is there a maximum length for one tag?

---

> **User**
>
> 1. Block the field with a message. 2. 30 characters.

---

> **Agent** — `specos-understand` (Phase 1, read-only). Nothing is written yet.
>
> **What I understood**
> - Users label each post with up to 5 tags, shown as chips, to organize and filter posts by category.
> - Used by anyone writing or editing a post; the tags also show on the public post. Out: filtering by tag.
> - Purpose (inferred): let people organize and filter their posts by category.
>
> **Assumptions (I decided these; confirm or change)**
> A1 · The API answers 422 `invalid_tags` past 5 tags · alternative: 400 with a field error
> A2 · Only the post owner can edit tags · alternative: any editor of the post
>
> **Open questions**
> Q1 · Reject a tag over 30 characters with an error, or truncate silently? · my proposal: reject with an error
>
> **Plan — what I will write**
> - Entering tags in the form (about 3 ACs)
> - The limits: count, duplicates, length, lowercase (about 4 ACs)
> - Saving and showing tags (about 3 ACs)
>
> **Files I will create**
> - specs/feature-tags/spec.md, tasks.md, testcases.md, CHANGELOG.md, design.md (the API contract)
>
> **Existing files I will modify (needs your yes)**
> - none
>
> Do you confirm the two assumptions above and the plan, and what is your answer to the open question?

---

> **User**
>
> Reject with an error. The assumptions are fine.

---

> **Agent** — `specos-write` (Phase 2), then the Close.
>
> Written: the five files, with one journey (the flow crosses screens: create form → public post → edit form). The two confirmed assumptions and the answer are dated lines under `## Decisions`; the inferred purpose is now the `Purpose:` line. `## Assumptions` and `## Open questions` are gone, so `status: approved`.
>
> ```
> Spec feature-tags v1.0 (approved) · 10 ACs · 12 tasks [new] · 4 test sketches
> Files created: spec.md, tasks.md, testcases.md, CHANGELOG.md, design.md · Files modified: none
> Open: none
> Next: /specos-distribute for the ticket text, then give me the key
> Commit message: Add feature-tags spec
> Not committed. Say "commit" and I will list the files first.
> Session saved: active = feature-tags
> ```

Nothing was written until the Lead had answered. The Lead saw every assumption in full, and the draft cannot be approved while one is still listed. If there had been no assumption, no question and no existing file to modify, the agent would have printed the understanding and the plan and written straight away.

---

## Part 2 — A change (two weeks later)

QA reported that rejecting a long tag interrupts the writing flow. Dev found it while working on `TAGS-03`.

> **User**
>
> change AC5: truncate silently instead of rejecting. QA says the error interrupts typing. Found during TAGS-03.

---

> **Agent**
>
> `specs/feature-tags/` exists — change mode. Proposed text:
>
> > AC5 → retired (v1.1). New **AC11** — A tag longer than 30 characters is truncated silently on confirm.
>
> Approve?

---

> **User**
>
> yes

---

> **Agent** — `specos-change`, then the Close.
>
> Spec now v1.1. CHANGELOG entry:
>
> ```
> ## 2026-03-18 v1.1
> - What: AC5 retired, AC11 added — a tag over 30 characters is truncated silently instead of rejected
> - Why: QA reported that rejecting the tag interrupted the writing flow (found during TAGS-03)
> - Impact: TAGS-03 is closed, so a [new] task covers AC11; no testcase covered AC5; no linked specs
> ```
>
> **Impact**
> - Tasks whose refs include AC5: none (`TAGS-03` refs AC3, AC8)
> - Testcases covering AC5: none (the sketches TC-01–TC-04 cover other ACs)
> - Specs that link to this one: none
>
> Added `[new] Truncate tags to 30 chars on save (AC11) v1.1`. `TAGS-03` was not touched.
>
> ```
> Spec feature-tags v1.1 (approved) · 10 ACs · 1 task [new] · 4 test sketches
> Open: none
> Next: /specos-distribute for the ticket text, then give me the key
> Commit message: Update feature-tags to v1.1
> Not committed. Say "commit" and I will list the files first.
> Session saved: active = feature-tags
> ```

The ids of the other ACs did not change, so every other task and test case still points at the right thing.

---

## Notes

- `review: sections` (in `specos-project.yml`) forces section-by-section approval. Otherwise one draft is the default, and an extra gate opens only on a trigger (more than 5 assumptions or 3 open questions, an assumption about calculations, data model, permissions or money, a contradiction with an approved spec, more than 15 ACs or 2 journeys, a self-contradicting request), and the agent says why.
- A change that would rewrite more than half of the spec is proposed as a new feature instead.
- Open questions in a change mark only the affected ACs `[pending]`; the spec stays approved and only the tasks that reference those ACs wait.
- "Document what already exists" runs as-is mode: the agent asks permission before reading any implementation code.
- The agent never commits on its own. Say "commit" and it lists the files and the message first.
- A reply that only answers one question is not a go-ahead for the rest. A reply that adds scope or changes the plan gets only the changed part re-printed. An explicit "go ahead" accepts the agent's proposals for anything left unanswered.
- An existing spec is edited from new mode only if it was listed under "Existing files I will modify" and you said yes; each edit goes through change mode (version bump, 3-line CHANGELOG, impact list).
- In chat the agent says things in words: an id may follow in parentheses, never stand alone.

---

## Reference scenario — for manual testing

Use this brief in a real specs repo that has a budget module with rows and an Excel import/export (the example paths are from the finokapi specs). A real session should print Phase 1 like the message below and **stop**: no file under `specs/` may exist or change until you reply (`git status` shows nothing). Compare wording loosely; compare structure strictly (the six blocks, the full text of every assumption and question, the stop).

> **Brief from the Lead**
>
> Add a "notes" field to budget rows, shown in the budget table and included in the Excel import and export.

Expected Phase 1 message (read-only; the agent has only read the budget specs):

```
What I understood
- Each budget row gets an optional free-text note.
- The note shows in the budget table and travels in the Excel export and import.
- Used by budget editors. It is not the row comments of the comments spec, and not the notes of the budget header. Out: notes on month columns or cells.
- Purpose (inferred): let editors keep a short explanation next to a row.

Assumptions (I decided these; confirm or change)
A1 · The note is a new field on the row, separate from comments · alternative: reuse the row comment
A2 · One plain-text note per row, up to 500 characters · alternative: no limit, or several notes
A3 · Editable while the budget is a draft, read-only once it is active · alternative: editable when active, like the budget-level notes
A4 · In the Excel file, a visible Notes column right after the row name, unlocked on editable rows · alternative: a column at the end, or a cell comment
A5 · Import replaces each row's note with the file's cell; an empty cell clears it · alternative: an empty cell keeps the current note

Open questions
Q1 · How does the table show the note? · my proposal: a narrow column with the first line, full text on hover
Q2 · Do notes appear in the aggregated view? · my proposal: no, it only shows totals
Q3 · What happens when someone imports a file exported before this change, with no Notes column? · my proposal: it imports and leaves the notes as they are

Plan — what I will write
- Notes on rows: the field, its limit, who can edit it (about 5 ACs)
- Notes in the budget table (about 3 ACs)
- Notes in the Excel export (about 2 ACs)
- Notes in the Excel import (about 3 ACs)

Files I will create
- specs/29-budget-planning/29-7-row-notes/spec.md, tasks.md, testcases.md, CHANGELOG.md

Existing files I will modify (needs your yes)
- specs/29-budget-planning/29-2-rows/spec.md (+ its CHANGELOG), v1.5 → v1.6 — add one AC saying rows carry an optional note
- specs/29-budget-planning/29-3-import-export/spec.md (+ its CHANGELOG), v2.4 → v2.5 — its table AC (name column, then month columns) and its "only value cells are editable" AC stop being true for notes; I would add an AC for the Notes column and leave the old ones
Opening a gate because the new field changes the data model and the Excel layout, and because two statements of the import/export spec would stop being true.

Do you confirm the five assumptions above, the plan and the two existing files, and what do you answer to the three open questions?
```

Then reply, for example, "Yes to the first assumption, change the second to a limit of 1,000 characters, go ahead":
- "go ahead" accepts the proposals for the other assumptions and the three questions;
- Phase 2 creates the four files of the new spec, adds one AC to each of the two existing specs (ids above every id they used), bumps their versions and adds a 3-line CHANGELOG entry to each;
- the new tasks go in the new spec's `tasks.md`, and the Close summary lists the four files created and the two modified.
