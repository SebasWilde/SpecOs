# Tasks — feature-tags

> Output of `/specos-distribute` with `task_detail: brief`. Only `[new]` tasks are printed; each ticket points to the spec instead of copying it.
> Create them as subtasks of User Story PROJ-87, then give the keys back in order and `tasks.md` is updated.

## First distribution — spec v1.0, twelve `[new]` tasks

# Add tags array field to Post model
Spec: specs/feature-tags/spec.md (v1.0) · AC7
Array column plus migration; no separate table (see design.md).
---
# Expose tags in Post serializer
Spec: specs/feature-tags/spec.md (v1.0) · AC7
Accept and return `tags` on create and PATCH.
---
# Validate maximum five tags in serializer
Spec: specs/feature-tags/spec.md (v1.0) · AC3, AC8
Reject more than 5 tags with 422 `invalid_tags`.
---
# Normalize tags to lowercase
Spec: specs/feature-tags/spec.md (v1.0) · AC6
Normalize in the backend before saving; the frontend shows what was typed.
---
# Deduplicate tags before saving
Spec: specs/feature-tags/spec.md (v1.0) · AC4
Drop repeated tags silently; return no error.
---
# Build TagInput component
Spec: specs/feature-tags/spec.md (v1.0) · AC1, AC2
Reusable chips input; Enter and comma confirm, X removes a chip.
---
# Disable field at five tags
Spec: specs/feature-tags/spec.md (v1.0) · AC3
Show "Maximum 5 tags per post" and re-enable when a chip is removed.
---
# Ignore duplicate tags silently
Spec: specs/feature-tags/spec.md (v1.0) · AC4
No chip, no message; the field clears.
---
# Integrate TagInput in create and edit forms
Spec: specs/feature-tags/spec.md (v1.0) · AC1, AC10
Wire to form state; pre-populate with existing tags on edit.
## Dev Notes
⚠️ Branch from: `main`
⚠️ PR to: `main`
---
# Show tags on public post view
Spec: specs/feature-tags/spec.md (v1.0) · AC9
Read-only chips on the post page and list cards.
---
# Test creating a post with tags
Spec: specs/feature-tags/spec.md (v1.0) · AC1, AC2, AC7, AC9
Run TC-01 once the frontend and backend tasks are merged.
---
# Test editing tags and the limits
Spec: specs/feature-tags/spec.md (v1.0) · AC3, AC4, AC10
Run TC-02 and TC-03 on an existing post.

> Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand.

## Second distribution — spec v1.1, one `[new]` task

The twelve keyed tasks are skipped.

# Truncate tags to 30 chars on save
Spec: specs/feature-tags/spec.md (v1.1) · AC11
Cut any tag over 30 characters silently before persisting; replaces the rejection of AC5.

> Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand.
