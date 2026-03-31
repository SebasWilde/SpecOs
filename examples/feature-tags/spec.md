---
feature: feature-tags
version: 1.1
status: complete
lead: Ana Garcia
date: 2026-03-15
---

# Post Tags

## What it does and why it exists

Users need to organize and filter their posts by category. Tags allow labeling each post with keywords to make it easier to search and navigate related content.

---

## User Journeys

### Journey 1 — Add tags when creating a post
1. The user is in the post creation form
2. Types a word in the tags field and presses Enter or comma
3. The tag appears as a chip/badge below the field
4. The user can add up to 5 tags per post
5. The user publishes the post — tags are saved and appear visible on the post

### Journey 2 — Edit tags on an existing post
1. The user goes to one of their posts and clicks "Edit"
2. Sees the current tags as removable chips
3. Can remove a tag by clicking the X on the chip
4. Can add new tags as long as they don't exceed the limit of 5
5. Saves the changes — tags are updated on the post

### Journey 3 — Tag limit exceeded
1. The user tries to add a 6th tag
2. The field is disabled and shows: "Maximum 5 tags per post"
3. The user cannot add more tags until removing one

### Journey 4 — Duplicate tag
1. The user tries to add a tag that already exists on the post
2. The system silently ignores the duplicate
3. The field clears without adding the repeated chip

---

## Acceptance Criteria

- [ ] The tags field accepts Enter and comma as separators to confirm a tag
- [ ] Each tag displays as a chip with an X button to remove
- [ ] The maximum tags per post is exactly 5 — the 6th attempt is not added
- [ ] Duplicate tags on the same post are silently ignored
- [ ] Tags are saved when publishing or updating the post
- [ ] Tags are visible on the public post view
- [ ] Each tag has a maximum of 30 characters — silently truncated on confirm
- [ ] Tags are saved in lowercase regardless of the user's input

---

## Out of Scope

- Filtering posts by tag (next feature)
- Global or system-suggested tags
- Tags with custom colors
- Tag limit at the account level (only at the post level)

---

## Technical Section

### API Contracts

**PATCH /api/posts/:id**
```
Request body (partial):
{
  "tags": ["django", "python", "backend"]
}

Response 200:
{
  "id": "uuid",
  "tags": ["django", "python", "backend"],
  "updated_at": "2026-03-15T10:00:00Z"
}

Response 422 — if more than 5 tags:
{
  "error": "invalid_tags",
  "detail": "Maximum 5 tags per post"
}
```

### Data model

```
Post (existing table — add field):
  tags: ArrayField(CharField(max_length=30), max_length=5, default=list)

No separate table — tags live in the post as an array.
```

### Technical decisions

- **Array instead of separate table:** tags are simple strings with no relationships. A separate table adds unnecessary complexity.
- **Backend lowercase normalization:** the frontend shows input as the user types it (UX), but the backend normalizes before saving.
- **Silent truncation to 30 chars:** chosen over rejection to avoid interrupting the writing flow. (Changed in v1.1)
