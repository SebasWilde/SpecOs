# Jira Tasks — feature-tags

> These tasks are created as subtasks of User Story PROJ-87.
> Copy each block into Jira manually, or use output-jira.md with the AI.

---

# [BE] Add tags field to Post model

## Scope
Add `tags` as an ArrayField to the Post model. Run migration. Field accepts up to 5 strings, each up to 30 characters. Normalize to lowercase before saving. Silently deduplicate before persisting.

## Acceptance Criteria
- Tags field added to Post model with correct constraints
- Migration runs without errors on local and staging
- Tags are stored in lowercase regardless of input
- Duplicate tags in the same post are deduplicated before saving

## Dev Notes
⚠️ Branch from: `main`
⚠️ PR to: `main`
ℹ️ Run: `python manage.py makemigrations && python manage.py migrate`

---

# [BE] Update Post serializer to handle tags

## Scope
Update the Post serializer to accept and return the `tags` field. Validate: maximum 5 tags per post, each up to 30 characters. Return 422 with `invalid_tags` error code if validation fails.

## Acceptance Criteria
- PATCH /api/posts/:id accepts `tags` array in request body
- Response 200 includes updated `tags` array
- Response 422 returned when more than 5 tags
- Unit tests cover: limit of 5, duplicates, normalization, truncation

---

# [BE] Unit tests for tags validation

## Scope
Write unit tests covering all tag validation scenarios from the spec.

## Acceptance Criteria
- Test: adding exactly 5 tags succeeds
- Test: adding 6 tags returns 422
- Test: duplicate tags are deduplicated
- Test: tags normalized to lowercase
- Test: tag silently truncated to 30 chars

---

# [FE] Build TagInput component

## Scope
Create a reusable TagInput component. Confirms tag on Enter or comma keypress. Displays confirmed tags as chips with an X button to remove. Disables input and shows "Maximum 5 tags" when limit is reached. Silently ignores duplicate tags.

## Acceptance Criteria
- Enter and comma confirm the current tag
- Each tag displays as a chip with remove button
- Field disabled with message when 5 tags are present
- Duplicate tag is ignored without error message
- Component is reusable and not coupled to post logic

---

# [FE] Integrate TagInput in post create and edit forms

## Scope
Add TagInput to the post creation and edit forms. Wire to form state. Ensure tags are included in the API request payload on submit. Pre-populate with existing tags when opening edit form.

## Acceptance Criteria
- TagInput visible in create form
- TagInput visible in edit form pre-populated with existing tags
- Tags included in PATCH request body on save
- Existing tags load correctly when opening edit form

---

# [FE] Display tags on public post view

## Scope
Show tags as read-only chips on the public post detail page and post list cards.

## Acceptance Criteria
- Tags visible on post detail page
- Tags visible on post list cards
- No tag container shown if post has no tags

---

# [QA] Tags — full test suite

## Scope
Execute the complete test suite for the tags feature per the spec.

## Acceptance Criteria
- Happy path: create post with 3 tags, verify visible on public view
- Edit tags: remove one, add a new one, verify update
- Limit: attempt 6th tag, verify input blocked with correct message
- Duplicate: add same tag twice, verify only one instance saved
- Normalization: input "Django" and "DJANGO", verify stored as "django"

## Dev Notes
⚠️ Test alongside: `feat/tags` (backend + frontend)
ℹ️ Run: `python manage.py migrate` before testing locally
