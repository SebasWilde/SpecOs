# Flow: /specos-distribute

> **When to run:** Lead, after spec + tasks + testcases are ready.
> **What it does:** Generates formatted outputs ready to copy-paste into Jira, Confluence, Linear, or any test management tool.

---

## Full conversational transcript

This transcript shows the Lead generating Jira tasks, a Confluence doc, and QA steps-to-test for the `feature-tags` feature.

---

> **User**
> ```
> /specos-distribute
> ```

> **Agent**
>
> Session loaded: `active_feature: feature-tags`
>
> What output do you need?
>
> 1. **Jira tasks** — one block per task, ready to copy into Jira
> 2. **Confluence doc** — structured spec page ready to paste
> 3. **Steps to test** — QA checklist formatted for your test tool
> 4. **All three**

---

> **User**
>
> 4 — all three

---

> **Agent**
>
> Loading:
> - `specs/feature-tags/spec.md` ✓
> - `specs/feature-tags/tasks.md` ✓
> - `specs/feature-tags/testcases.md` ✓
>
> Generating outputs...

---

### Output 1 — Jira Tasks

> **Agent**
>
> ---
> **JIRA TASKS — feature-tags**
> Copy each block into Jira as a subtask under your user story.
> ---
>
> ---
>
> **[TAGS-01] Add tags field to Post model**
>
> **Role:** Backend
> **Feature:** feature-tags
>
> **Scope:**
> Add `tags` as an ArrayField to the Post model. Run migration. Field accepts up to 5 strings, each up to 30 characters.
>
> **Acceptance criteria:**
> - Tags field added to Post model with correct constraints
> - Migration runs without errors on local and staging
>
> **Dev notes:**
> ⚠️ Branch from: `main` | PR to: `main`
> Run: `python manage.py makemigrations && python manage.py migrate`
>
> ---
>
> **[TAGS-02] Update Post serializer to handle tags**
>
> **Role:** Backend
> **Feature:** feature-tags
>
> **Scope:**
> Update the Post serializer to accept and return the `tags` field. Validate: maximum 5 tags per post, each up to 30 characters. Return 422 with `invalid_tags` error code if validation fails.
>
> **Acceptance criteria:**
> - PATCH /api/posts/:id accepts `tags` array in request body
> - Response 200 includes updated `tags` array
> - Response 422 returned when more than 5 tags
>
> ---
>
> **[TAGS-03] Validate tags in serializer**
>
> **Role:** Backend
> **Feature:** feature-tags
>
> **Scope:**
> Enforce: max 5 tags, each max 30 chars, return 422 with `invalid_tags` on failure.
>
> **Acceptance criteria:**
> - Limit of 5 tags enforced with 422 response
> - Each tag silently truncated to 30 chars before saving
>
> ---
>
> **[TAGS-04] Normalize tags to lowercase**
>
> **Role:** Backend
> **Feature:** feature-tags
>
> **Scope:**
> Normalize all tag strings to lowercase before persisting. Frontend displays input as typed — normalization happens on save only.
>
> **Acceptance criteria:**
> - Tags stored as lowercase regardless of input casing
>
> ---
>
> **[TAGS-05] Deduplicate tags before saving**
>
> **Role:** Backend
> **Feature:** feature-tags
>
> **Scope:**
> Silently remove duplicate tags before persisting. No error returned to client.
>
> **Acceptance criteria:**
> - Duplicate tags removed silently before save
>
> ---
>
> **[TAGS-06] Unit tests — tags validation**
>
> **Role:** Backend
> **Feature:** feature-tags
>
> **Scope:**
> Write unit tests for all tag validation scenarios from the spec.
>
> **Acceptance criteria:**
> - Test: adding exactly 5 tags succeeds
> - Test: adding 6 tags returns 422
> - Test: duplicate tags are deduplicated
> - Test: tags normalized to lowercase
> - Test: tag silently truncated to 30 chars
>
> ---
>
> **[TAGS-07] Build TagInput component**
>
> **Role:** Frontend
> **Feature:** feature-tags
>
> **Scope:**
> Create a reusable TagInput component. Confirms tag on Enter or comma. Displays confirmed tags as chips with X to remove. Disables input and shows "Maximum 5 tags" when limit reached. Silently ignores duplicates.
>
> **Acceptance criteria:**
> - Enter and comma confirm the current tag
> - Each tag displays as a chip with remove button
> - Field disabled with message when 5 tags present
> - Duplicate tag ignored without error message
>
> ---
>
> **[TAGS-08] Wire Enter and comma as tag separators**
>
> **Role:** Frontend
> **Feature:** feature-tags
>
> **Acceptance criteria:**
> - Enter key confirms current tag input
> - Comma key confirms current tag input
>
> ---
>
> **[TAGS-09] Show limit message and disable field at 5 tags**
>
> **Role:** Frontend
> **Feature:** feature-tags
>
> **Acceptance criteria:**
> - Message "Maximum 5 tags per post" shown when limit reached
> - Input disabled when 5 tags present
>
> ---
>
> **[TAGS-10] Silently ignore duplicate tags**
>
> **Role:** Frontend
> **Feature:** feature-tags
>
> **Acceptance criteria:**
> - Duplicate tag entry ignored — no chip added, no error shown
> - Field clears after duplicate attempt
>
> ---
>
> **[TAGS-11] Integrate TagInput in post forms**
>
> **Role:** Frontend
> **Feature:** feature-tags
>
> **Scope:**
> Add TagInput to post creation and edit forms. Wire to form state. Pre-populate with existing tags on edit. Include in PATCH request body.
>
> **Acceptance criteria:**
> - TagInput visible in create form
> - TagInput visible in edit form, pre-populated with existing tags
> - Tags included in PATCH request body on save
>
> ---
>
> **[TAGS-12] Display tags on public post view**
>
> **Role:** Frontend
> **Feature:** feature-tags
>
> **Acceptance criteria:**
> - Tags visible on post detail page
> - Tags visible on post list cards
> - No tag container shown if post has no tags
>
> ---
>
> **[TAGS-13] QA — happy path**
>
> **Role:** QA
> **Feature:** feature-tags
>
> **Scope:**
> Execute happy path test cases: create post with 3 tags, verify visible on public view.
>
> ---
>
> **[TAGS-14] QA — edit tags**
>
> **Role:** QA
> **Feature:** feature-tags
>
> **Scope:**
> Remove one tag and add a new one on an existing post. Verify update.
>
> ---
>
> **[TAGS-15] QA — tag limit**
>
> **Role:** QA
> **Feature:** feature-tags
>
> **Scope:**
> Attempt to add 6th tag. Verify field is blocked with correct message.
>
> ---
>
> 15 tasks generated. Copy each block into Jira.

---

### Output 2 — Confluence Doc

> **Agent**
>
> What is the Jira link for this feature? (or say TBD)

---

> **User**
>
> https://jira.company.com/browse/TAGS

---

> **Agent**
>
> ---
> **CONFLUENCE PAGE — Post Tags**
> Paste this into a new Confluence page under your project's Feature Specs space.
> ---
>
> # 🏷️ Post Tags
>
> ---
>
> 📌 Summary
> Users can label their posts with up to 5 tags to make content easier to organize and find.
> Tags are saved in lowercase, duplicates are ignored, and each tag is limited to 30 characters.
> This is the foundation for post filtering in a future feature.
>
> 📦 Scope
>
> **In Scope**
> - Add tags to posts (up to 5 per post)
> - Display tags on post view
> - Edit tags on existing posts
>
> **Out of Scope**
> - Filtering posts by tag (next feature)
> - Global or system-suggested tags
> - Tags with custom colors
> - Tag limit at the account level
>
> ✅ Acceptance Criteria
> - [ ] Tags field accepts Enter and comma as separators
> - [ ] Each tag displays as a chip with X to remove
> - [ ] Maximum 5 tags per post — 6th attempt not added
> - [ ] Duplicate tags silently ignored
> - [ ] Tags saved when publishing or updating
> - [ ] Tags visible on public post view
> - [ ] Tags silently truncated to 30 characters
> - [ ] Tags saved in lowercase regardless of input
>
> 🔗 References
> - Jira: https://jira.company.com/browse/TAGS
> - Spec: [add link manually]
>
> 📜 Change History
> | Date | Change | Requested by |
> |---|---|---|
> | 2026-03-10 | Initial version | Client |
>
> ---
>
> Copy this into Confluence manually and replace the Spec link in References.

---

### Output 3 — Steps to Test

> **Agent**
>
> ---
> **STEPS TO TEST — feature-tags**
> Paste into your QA tool or test management system.
> ---
>
> **Test 1 — Create post with tags (TC-01)**
> Environment: Local
> Setup: Logged-in user with no existing posts
>
> Steps:
> 1. Open the post creation form
> 2. Type "django" in the tags field and press Enter
> 3. Type "python" and press comma
> 4. Type "backend" and press Enter
> 5. Publish the post
>
> Expected: Three chips appear. Tags visible on public view as "django", "python", "backend".
>
> ---
>
> **Test 2 — Edit tags (TC-02)**
> Environment: Local
> Setup: Existing post with tags ["django", "python", "backend"]
>
> Steps:
> 1. Go to the post and click "Edit"
> 2. Click X on "python" chip
> 3. Type "api" and press Enter
> 4. Save
>
> Expected: Tags updated — "python" removed, "api" added.
>
> ---
>
> **Test 3 — Tag limit (TC-03)**
> Environment: Local
>
> Steps:
> 1. Open post creation form
> 2. Add 5 tags
> 3. Try to type a 6th tag
>
> Expected: Field disabled, "Maximum 5 tags per post" shown.
>
> ---
>
> **Test 4 — Duplicate tag (TC-04)**
>
> Steps:
> 1. Type "django" → Enter
> 2. Type "django" → Enter again
>
> Expected: Only one chip. No error. Field clears silently.
>
> ---
>
> **Test 5 — Lowercase normalization (TC-05)**
>
> Steps:
> 1. Type "Django" → Enter
> 2. Type "PYTHON" → Enter
> 3. Publish
>
> Expected: Stored and displayed as "django", "python".
>
> ---
>
> **Test 6 — Truncation (TC-06)**
>
> Steps:
> 1. Type a string longer than 30 characters → Enter
>
> Expected: Chip created, truncated to 30 chars. No error, no toast.
>
> ---
>
> **Test 7 — PATCH saves tags (TC-07)**
>
> Steps:
> 1. Send: PATCH /api/posts/:id  `{"tags": ["django", "python"]}`
>
> Expected: 200 response with `tags: ["django", "python"]`.
>
> ---
>
> **Test 8 — API rejects 6 tags (TC-08)**
>
> Steps:
> 1. Send: PATCH /api/posts/:id  `{"tags": ["a","b","c","d","e","f"]}`
>
> Expected: 422 with `{"error": "invalid_tags", "detail": "Maximum 5 tags per post"}`.

---

> **Agent**
>
> All 3 outputs generated.
>
> **Saving to `specs/feature-tags/outputs/`...**
> ✓ `outputs/jira-tasks.md`
> ✓ `outputs/confluence-page.md`
> ✓ `outputs/steps-to-test.md`
>
> Copy each output into your tool manually. In v4, MCP integration will push these automatically.
>
> ---
>
> Create these tasks in your task software, then come back with the real IDs so I can update `tasks.md`.

---

> **User**
>
> Done. IDs are: SP-01 → TAGS-01, SP-02 → TAGS-02, SP-03 → TAGS-03, SP-04 → TAGS-04, SP-05 → TAGS-05, SP-06 → TAGS-06, SP-07 → TAGS-07, SP-08 → TAGS-08, SP-09 → TAGS-09, SP-10 → TAGS-10, SP-11 → TAGS-11, SP-12 → TAGS-12, SP-13 → TAGS-13, SP-14 → TAGS-14, SP-15 → TAGS-15

---

> **Agent**
>
> `tasks.md` updated with real IDs:
>
> SP-01 → TAGS-01, SP-02 → TAGS-02, SP-03 → TAGS-03, SP-04 → TAGS-04, SP-05 → TAGS-05, SP-06 → TAGS-06, SP-07 → TAGS-07, SP-08 → TAGS-08, SP-09 → TAGS-09, SP-10 → TAGS-10, SP-11 → TAGS-11, SP-12 → TAGS-12, SP-13 → TAGS-13, SP-14 → TAGS-14, SP-15 → TAGS-15

---

## Notes

- Outputs are saved to `specs/[feature]/outputs/` and also printed in-session for immediate copy-paste.
- You can request individual outputs instead of all three — just answer `1`, `2`, or `3` when prompted.
- Real task IDs are assigned during distribute — `tasks.md` always starts with SP-XX placeholders from the lead session and gets updated here.
