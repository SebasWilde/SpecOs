---
feature: feature-tags
version: 1.1
status: approved
lead: Ana Garcia
date: 2026-03-18
keywords: [tags, posts, chips]
---

# Post Tags

## What it does and why it exists

Users label each post with keywords so related content is easier to search and navigate.
Purpose: let people organize and filter their posts by category.

## Acceptance Criteria

### Entering tags
- AC1 — The tags field confirms a tag when the user presses Enter or comma
- AC2 — Each confirmed tag shows as a chip with an X button that removes it
- AC10 — The owner of a post can remove and add tags when editing it, within the limits below

### Limits
- AC3 — A post has at most 5 tags; at the 5th the field is disabled and shows "Maximum 5 tags per post"
- AC4 — A tag that already exists on the post is ignored silently and the field clears
- AC5 — retired (v1.1): a tag over 30 characters was rejected with an error; replaced by AC11
- AC6 — Tags are saved in lowercase, whatever the user typed
- AC11 — A tag longer than 30 characters is truncated silently on confirm

### Saving and viewing
- AC7 — Tags are saved when the post is published or updated
- AC8 — The API answers 422 `invalid_tags` with detail "Maximum 5 tags per post" when more than 5 tags are sent
- AC9 — Tags are visible on the public post view

## Journey

### Post with tags, from creation to edit
1. In the creation form the user types tags; each becomes a chip (AC1, AC2)
2. The user publishes; the public post shows the tags (AC7, AC9)
3. Later the user opens Edit, removes one chip and adds another (AC10)

## Out of Scope

- Filtering posts by tag (next feature)
- Global or system-suggested tags
- Tags with custom colors
- Tag limit at the account level (only at the post level)

## Decisions

- 2026-03-15 · The API answers 422 `invalid_tags` past 5 tags (AC8).
- 2026-03-15 · Only the post owner can edit tags (AC10).
- 2026-03-15 · A tag over 30 characters is rejected with an error (AC5).
- 2026-03-18 · Changed to silent truncation (AC11): the error interrupted typing. Found during TAGS-03.
