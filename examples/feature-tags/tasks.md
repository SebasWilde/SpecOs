# Tasks — feature-tags

## Backend

- [TAGS-01] Add `tags` field as ArrayField to the Post model (migration included)
- [TAGS-02] Update Post serializer to include `tags` in request and response
- [TAGS-03] Validate in serializer: maximum 5 tags, each tag maximum 30 chars
- [TAGS-04] Normalize tags to lowercase before saving
- [TAGS-05] Silently deduplicate tags before persisting
- [TAGS-06] Unit tests: limit of 5 tags, duplicates, normalization, truncation

## Frontend

- [TAGS-07] Create TagInput component: text field + chips with X to remove
- [TAGS-08] Trigger tag confirmation with Enter and comma
- [TAGS-09] Show "Maximum 5 tags" message and disable field when limit is reached
- [TAGS-10] Silently ignore duplicate tag (no error message)
- [TAGS-11] Integrate TagInput in post creation and edit forms
- [TAGS-12] Display tags as chips on the public post view

## QA

- [TAGS-13] Happy path: create post with 3 tags, verify they appear on public view
- [TAGS-14] Edit tags: remove one existing tag and add a new one, verify update
- [TAGS-15] Limit: attempt to add 6th tag, verify input is blocked with correct message
