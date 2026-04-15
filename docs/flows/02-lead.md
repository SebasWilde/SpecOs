# Flow: /specos-lead

> **When to run:** Lead, at the start of every new feature.
> **What it does:** Builds spec.md and tasks.md collaboratively, section by section, waiting for approval at each step.

---

## Full conversational transcript

This transcript shows the Lead building the `feature-tags` spec (the same one in `examples/feature-tags/`). Each section is proposed by the agent and approved or adjusted by the Lead before moving on.

---

> **User**
> ```
> /specos-start
> ```

> **Agent**
>
> Session loaded. Welcome back.
>
> Roles: `lead, backend`
> No active feature.
>
> What feature do you want to specify today?

---

> **User**
>
> Post tags — users should be able to add tags to their posts

---

> **Agent**
>
> Starting `/specos-lead` for feature: **post-tags**.
>
> I'll build the spec section by section. Approve each section before we move to the next.
>
> ---
>
> **Section 1 of 5 — Feature summary**
>
> Proposed:
>
> > Users need to organize and filter their posts by category. Tags allow labeling each post with keywords to make it easier to search and navigate related content.
>
> Approve, or tell me what to change.

---

> **User**
>
> approved

---

> **Agent**
>
> **Section 2 of 5 — User journeys**
>
> Proposed:
>
> **Journey 1 — Add tags when creating a post**
> 1. The user is in the post creation form
> 2. Types a word in the tags field and presses Enter or comma
> 3. The tag appears as a chip/badge below the field
> 4. The user can add up to 5 tags per post
> 5. The user publishes the post — tags are saved and appear visible on the post
>
> **Journey 2 — Edit tags on an existing post**
> 1. The user goes to one of their posts and clicks "Edit"
> 2. Sees the current tags as removable chips
> 3. Can remove a tag by clicking the X on the chip
> 4. Can add new tags as long as they don't exceed the limit of 5
> 5. Saves the changes — tags are updated on the post
>
> **Journey 3 — Tag limit exceeded**
> 1. The user tries to add a 6th tag
> 2. The field is disabled and shows: "Maximum 5 tags per post"
> 3. The user cannot add more tags until removing one
>
> **Journey 4 — Duplicate tag**
> 1. The user tries to add a tag that already exists on the post
> 2. The system silently ignores the duplicate
> 3. The field clears without adding the repeated chip
>
> Approve, or tell me what to change.

---

> **User**
>
> approved

---

> **Agent**
>
> **Section 3 of 5 — Acceptance Criteria**
>
> Proposed (one verifiable criterion per observable behavior):
>
> - [ ] The tags field accepts Enter and comma as separators to confirm a tag
> - [ ] Each tag displays as a chip with an X button to remove
> - [ ] The maximum tags per post is exactly 5 — the 6th attempt is not added
> - [ ] Duplicate tags on the same post are silently ignored
> - [ ] Tags are saved when publishing or updating the post
> - [ ] Tags are visible on the public post view
> - [ ] Each tag has a maximum of 30 characters — silently truncated on confirm
> - [ ] Tags are saved in lowercase regardless of the user's input
>
> Approve, or tell me what to change.

---

> **User**
>
> for the truncation, I want it to be silent — no error shown to the user

---

> **Agent**
>
> Updated:
>
> - [ ] Each tag has a maximum of 30 characters — **silently truncated on confirm, no error shown**
>
> All other criteria unchanged. Approve?

---

> **User**
>
> yes

---

> **Agent**
>
> **Section 4 of 5 — Out of Scope**
>
> Proposed:
>
> - Filtering posts by tag (next feature)
> - Global or system-suggested tags
> - Tags with custom colors
> - Tag limit at the account level (only at the post level)
>
> Approve, or tell me what to add or remove.

---

> **User**
>
> approved

---

> **Agent**
>
> **Section 5 of 5 — Technical section** *(optional)*
>
> Do you want to include a technical section? This is useful for API contracts, data model decisions, or notes for the dev team.
>
> Reply with `yes`, `no`, or describe what to include.

---

> **User**
>
> yes — add API contracts and data model. Tags live in the Post as an array, no separate table. Backend normalizes to lowercase.

---

> **Agent**
>
> Proposed technical section:
>
> **API Contracts**
>
> `PATCH /api/posts/:id`
> ```json
> // Request body (partial):
> { "tags": ["django", "python", "backend"] }
>
> // Response 200:
> { "id": "uuid", "tags": ["django", "python", "backend"], "updated_at": "..." }
>
> // Response 422 — if more than 5 tags:
> { "error": "invalid_tags", "detail": "Maximum 5 tags per post" }
> ```
>
> **Data model**
> ```
> Post (existing table — add field):
>   tags: ArrayField(CharField(max_length=30), max_length=5, default=list)
> No separate table — tags live in the post as an array.
> ```
>
> **Technical decisions**
> - Array instead of separate table: tags are simple strings with no relationships. A separate table adds unnecessary complexity.
> - Backend lowercase normalization: the frontend shows input as the user types it (UX), but the backend normalizes before saving.
> - Silent truncation to 30 chars: chosen over rejection to avoid interrupting the writing flow.
>
> Approve?

---

> **User**
>
> approved

---

> **Agent**
>
> Spec complete. Building tasks.
>
> ---
>
> **Tasks — proposed list**
>
> ## Backend
> - [SP-01] Add `tags` field as ArrayField to the Post model (migration included)
> - [SP-02] Update Post serializer to include `tags` in request and response
> - [SP-03] Validate in serializer: maximum 5 tags, each tag maximum 30 chars
> - [SP-04] Normalize tags to lowercase before saving
> - [SP-05] Silently deduplicate tags before persisting
> - [SP-06] Unit tests: limit of 5 tags, duplicates, normalization, truncation
>
> ## Frontend
> - [SP-07] Create TagInput component: text field + chips with X to remove
> - [SP-08] Trigger tag confirmation with Enter and comma
> - [SP-09] Show "Maximum 5 tags" message and disable field when limit is reached
> - [SP-10] Silently ignore duplicate tag (no error message)
> - [SP-11] Integrate TagInput in post creation and edit forms
> - [SP-12] Display tags as chips on the public post view
>
> ## QA
> - [SP-13] Happy path: create post with 3 tags, verify they appear on public view
> - [SP-14] Edit tags: remove one existing tag and add a new one, verify update
> - [SP-15] Limit: attempt to add 6th tag, verify input is blocked with correct message
>
> Total: 15 tasks. Approve, or tell me what to adjust.

---

> **User**
>
> approved. Once we create the tasks in Jira I'll give you the real IDs.

---

> **Agent**
>
> Understood. Using `SP-XX` as placeholders for now. Replace them with real IDs after running `/specos-distribute` and creating the tasks in Jira.
>
> Writing files...
>
> ✓ `specs/feature-tags/spec.md` — version 1.0
> ✓ `specs/feature-tags/tasks.md`
> ✓ `specs/feature-tags/CHANGELOG.md` — initial entry
>
> Session updated.
>
> ---
>
> **Spec is approved.** Its presence in the repo is the approval signal — no status field needed.
>
> **Next steps:**
> - Run `/specos-distribute` to generate Jira-ready task output
> - Assign real IDs, then hand off to dev with `/specos-start`
> - QA runs `/specos-qa` to generate test cases from this spec

---

## Notes

- The agent proposes each section and waits for explicit approval before continuing. It never moves forward on its own.
- If you say "add X" or "change Y", the agent shows the updated version and asks for approval again.
- Once files are written, the spec version is `1.0`. Any future change bumps it to `1.1`, `1.2`, etc. and gets a CHANGELOG entry.
- The `SP-XX` placeholders are intentional — real IDs come from your task software after distribution.
