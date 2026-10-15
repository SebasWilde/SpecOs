# Tasks — feature-tags

> Output of `/specos-distribute` with `task_detail: standard`. Only `[new]` tasks are printed. Each ticket explains itself: it carries no AC ids and can be read without opening the spec.
> Create them as subtasks of User Story PROJ-87, then give the keys back in order and `tasks.md` is updated.

## First distribution — spec v1.0, twelve `[new]` tasks

Add tags field to Post model
Spec: specs/feature-tags/spec.md (v1.0)

Context
* Users label their posts to organize and filter them by category, so each post can carry up to 5 tags.

Scope
* Add a `tags` list to the Post model, with its migration.
* Keep it on the post itself; no separate table.

Test cases (specs/feature-tags/testcases.md)
* Create a post with tags

Acceptance criteria
- [ ] A post can be saved with up to 5 tags and returns them when read.
- [ ] A post saved without tags returns an empty list.
- [ ] The migration runs on existing posts without changing them.
---
Expose tags in Post serializer
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Accept `tags` on create and update.
* Return `tags` in every post response.

Test cases (specs/feature-tags/testcases.md)
* Create a post with tags

Acceptance criteria
- [ ] Publishing or updating a post saves the tags sent with it.
- [ ] The post response shows the saved tags.
---
Validate maximum five tags in serializer
Spec: specs/feature-tags/spec.md (v1.0)

Context
* The limit is also enforced in the form, but the API must not trust it.

Scope
* Reject a request with more than 5 tags.
* Answer with 422, error `invalid_tags` and the detail "Maximum 5 tags per post".

Test cases (specs/feature-tags/testcases.md)
* Tag limit blocked at 6th tag
* API rejects more than 5 tags

Acceptance criteria
- [ ] A request with 5 tags is accepted.
- [ ] A request with 6 tags is rejected with 422 `invalid_tags`.
- [ ] The detail reads "Maximum 5 tags per post".
- [ ] Nothing is saved when the request is rejected.
---
Normalize tags to lowercase
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Lowercase every tag before saving.
* Do it in the backend; the form keeps showing what was typed.

Acceptance criteria
- [ ] Tags are saved in lowercase whatever the user typed.
- [ ] Example: "Django" and "PYTHON" are saved as "django" and "python".
---
Deduplicate tags before saving
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Drop repeated tags before saving.
* Return no error for them.

Test cases (specs/feature-tags/testcases.md)
* Duplicate tag is ignored

Acceptance criteria
- [ ] A tag that already exists on the post is saved once.
- [ ] The request is accepted without an error.
---
Build TagInput component
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Create a reusable chips input, not tied to posts.
* Confirm a tag with Enter or comma.
* Show each confirmed tag as a chip with an X to remove it.

Test cases (specs/feature-tags/testcases.md)
* Create a post with tags

Acceptance criteria
- [ ] Enter and comma both confirm the tag being typed.
- [ ] Each confirmed tag shows as a chip.
- [ ] The X on a chip removes that tag.
- [ ] The component works outside the post form.
---
Disable field at five tags
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Disable the field once 5 tags are present.
* Show "Maximum 5 tags per post" while it is disabled.
* Enable it again when a chip is removed.

Test cases (specs/feature-tags/testcases.md)
* Tag limit blocked at 6th tag

Acceptance criteria
- [ ] With 5 tags the field is disabled and shows "Maximum 5 tags per post".
- [ ] Removing one chip enables the field again.
- [ ] A 6th tag cannot be added.
---
Ignore duplicate tags silently
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Skip a tag that is already on the post.
* Clear the field without any message.

Test cases (specs/feature-tags/testcases.md)
* Duplicate tag is ignored

Acceptance criteria
- [ ] Typing a tag already on the post adds no chip.
- [ ] No error or message is shown.
- [ ] The field clears.
---
Integrate TagInput in create and edit forms
Spec: specs/feature-tags/spec.md (v1.0)

Context
* People should set tags when writing a post and change them later.

Scope
* Add the tags field to the post creation form.
* Add it to the edit form, filled with the tags the post already has.
* Send the tags with the save request.

Test cases (specs/feature-tags/testcases.md)
* Create a post with tags

Acceptance criteria
- [ ] The creation form has a tags field.
- [ ] The edit form shows the post's current tags as chips.
- [ ] The owner can remove and add tags when editing, within the 5-tag limit.
- [ ] Saving sends the tags and the post shows the new ones.
---
Show tags on public post view
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Show the tags as read-only chips on the post page.

Test cases (specs/feature-tags/testcases.md)
* Create a post with tags

Acceptance criteria
- [ ] A post with tags shows them as chips on its public page.
- [ ] A post without tags shows no tag area.
---
Test creating a post with tags
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Run the creation flow once the frontend and backend tasks are merged.

Test cases (specs/feature-tags/testcases.md)
* Create a post with tags

Acceptance criteria
- [ ] Three tags are confirmed with Enter and comma and show as chips.
- [ ] After publishing, the public post shows the same tags.
---
Test editing tags and the limits
Spec: specs/feature-tags/spec.md (v1.0)

Scope
* Run the edit, limit and duplicate flows on an existing post.

Test cases (specs/feature-tags/testcases.md)
* Tag limit blocked at 6th tag
* Duplicate tag is ignored

Acceptance criteria
- [ ] Removing one tag and adding another updates the post.
- [ ] The 6th tag is blocked with the limit message.
- [ ] A repeated tag is ignored without an error.

> Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand.

## Second distribution — spec v1.1, one `[new]` task

The twelve keyed tasks are skipped.

Truncate tags to 30 characters on save
Spec: specs/feature-tags/spec.md (v1.1)

Context
* A tag that is too long used to be rejected with an error, which interrupted people while typing.

Scope
* Cut any tag longer than 30 characters before saving it.
* Return no error for it.

Test cases (specs/feature-tags/testcases.md)
* Over-long tag on an edited post

Acceptance criteria
- [ ] A tag longer than 30 characters is saved cut to 30 characters, with no error.
- [ ] Example: a tag of 40 characters comes back with its first 30 characters.

> Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand.
