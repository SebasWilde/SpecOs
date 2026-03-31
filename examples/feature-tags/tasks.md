# Tasks — feature-tags

## Backend

- [x] add `tags` field as ArrayField to the Post model (migration included)
- [x] update Post serializer to include `tags` in request and response
- [x] validate in serializer: maximum 5 tags, each tag maximum 30 chars
- [x] normalize tags to lowercase before saving
- [x] silently deduplicate tags before persisting
- [x] unit tests: limit of 5 tags, duplicates, normalization, truncation

## Frontend

- [x] create TagInput component: text field + chips with X to remove
- [x] trigger tag confirmation with Enter and comma
- [x] show "Maximum 5 tags" message and disable field when limit is reached
- [x] silently ignore duplicate tag (no error message)
- [x] integrate TagInput in post creation and edit forms
- [x] display tags as chips on the public post view

## QA

- [x] happy path: create post with 3 tags, verify they appear on public view
- [x] edit tags: remove one existing tag and add a new one, verify update
- [x] limit: attempt to add 6th tag, verify input is blocked with correct message
- [x] duplicate: add the same tag twice, verify only one instance is saved
- [x] normalization: type "Django" and "DJANGO", verify stored as "django"
