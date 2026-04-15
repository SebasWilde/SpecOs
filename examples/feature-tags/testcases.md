# Test cases — feature-tags

## TC-01 — Create post with tags (happy path)
task: TAGS-13
steps:
  1. Open the post creation form
  2. Type "django" in the tags field and press Enter
  3. Type "python" and press comma
  4. Type "backend" and press Enter
  5. Publish the post
expected: Three tag chips appear below the field. Tags are visible on the public post view as "django", "python", "backend".

## TC-02 — Edit tags on existing post
task: TAGS-14
steps:
  1. Go to an existing post with tags and click "Edit"
  2. Click the X on the "python" chip to remove it
  3. Type "api" in the tags field and press Enter
  4. Save the post
expected: Tags updated — "python" removed, "api" added. Changes visible on public post view.

## TC-03 — Tag limit blocked at 6th tag
task: TAGS-15
steps:
  1. Open the post creation form
  2. Add 5 tags (any words)
  3. Attempt to type a 6th tag in the field
expected: The tags field is disabled. Message "Maximum 5 tags per post" is visible. No 6th tag is added.

## TC-04 — Duplicate tag is silently ignored
task: TAGS-10
steps:
  1. Open the post creation form
  2. Type "django" and press Enter
  3. Type "django" again and press Enter
expected: Only one "django" chip appears. No error message shown. Field clears silently.

## TC-05 — Tags normalized to lowercase
task: TAGS-04
steps:
  1. Open the post creation form
  2. Type "Django" and press Enter
  3. Type "PYTHON" and press Enter
  4. Publish the post
expected: Tags are stored and displayed as "django" and "python" (lowercase).

## TC-06 — Tag truncated at 30 characters
task: TAGS-03
steps:
  1. Open the post creation form
  2. Type a word longer than 30 characters and press Enter
expected: Tag chip is created with the input silently truncated to 30 characters. No error message.

## TC-07 — Tags saved on post update (PATCH endpoint)
task: TAGS-02
steps:
  1. Send PATCH /api/posts/:id with body {"tags": ["django", "python"]}
expected: Response 200 with tags field containing ["django", "python"]. Tags persisted.

## TC-08 — API rejects more than 5 tags
task: TAGS-03
steps:
  1. Send PATCH /api/posts/:id with body {"tags": ["a","b","c","d","e","f"]}
expected: Response 422 with {"error": "invalid_tags", "detail": "Maximum 5 tags per post"}.
