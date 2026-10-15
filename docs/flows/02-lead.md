# Flow: /specos-lead

> **When to run:** Lead, for every new feature and every later change to its spec.
> **What it does:** New feature — one draft instead of a stream of approvals. Existing feature — change mode: version, AC ids, CHANGELOG and impact handled for you.

---

## Part 1 — A new feature

This transcript builds the `feature-tags` spec (the one in `examples/feature-tags/`). The Lead explains freely, the agent asks only what it cannot decide, writes one draft, and shows only what needs a decision.

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

> **Agent**
>
> Draft written to `specs/feature-tags/` (`spec.md` with 10 ACs and one journey, 12 `[new]` tasks, 4 test sketches, `CHANGELOG.md`). Before you review it, this is what I understood and what I decided on your behalf:
>
> **What I understood**
> - Users label each post with up to 5 tags, shown as chips, to organize and filter posts by category.
> - Used by anyone writing or editing a post; the tags also show on the public post.
> - Changes: a tags field in the post form, saved with the post. Out: filtering by tag.
>
> **Assumptions (I decided these; confirm or change)**
> A1 · The API answers 422 `invalid_tags` past 5 tags · alternative: 400 with a field error
> A2 · Only the post owner can edit tags · alternative: any editor of the post
> A3 · Purpose for the ticket: "let people organize and filter their posts by category" *(inferred)* · alternative: another wording
>
> **Open questions**
> Q1 · Reject a tag over 30 characters with an error, or truncate silently? · my proposal: reject with an error
>
> Files: `specs/feature-tags/spec.md` (draft, not approved)
>
> Do you confirm the three assumptions above, or which one do you change? And what is your answer to the open question?

---

> **User**
>
> Reject with an error. The assumptions are fine.

---

> **Agent**
>
> Applied. The two confirmed assumptions and the answer are now dated lines under `## Decisions`; A3 is the `Purpose:` line, no longer marked inferred. `## Assumptions` and `## Open questions` are gone, so `status: approved`.
>
> ```
> Spec feature-tags v1.0 (approved) · 10 ACs · 12 tasks [new] · 4 test sketches
> Open: none
> Next: /specos-distribute for the ticket text, then give me the key
> Commit message: Add feature-tags spec
> Not committed. Say "commit" and I will list the files first.
> Session saved: active = feature-tags
> ```

Nothing was shown section by section. The Lead saw every assumption in full before being asked anything, and the draft cannot be approved while one is still listed.

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

> **Agent**
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
