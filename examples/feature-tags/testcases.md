# Test cases — feature-tags
> Sketches suggested by Lead, not reviewed.
spec: v1.1

## TC-01 — Create a post with tags
covers: AC1, AC2, AC7, AC9
steps:
  1. Open the post creation form
  2. Type "django" and press Enter; type "python" and press comma
  3. Click the X on the "python" chip
  4. Publish the post
expected: Only "django" is saved, and its chip appears on the public post

## TC-02 — Tag limit blocked at 6th tag
covers: AC3
steps:
  1. Open the post creation form and add 5 tags
  2. Try to type a 6th tag
  3. Remove one chip
expected: At 5 tags the field is disabled and shows "Maximum 5 tags per post"; after removing a chip it is enabled again

## TC-03 — Duplicate tag is ignored
covers: AC4
steps:
  1. Type "django" and press Enter
  2. Type "django" again and press Enter
expected: Only one "django" chip; no error; the field clears

## TC-04 — API rejects more than 5 tags
covers: AC8

## TC-05 — Tags are saved in lowercase
covers: AC6
steps:
  1. Type "Django" and press Enter; type "PYTHON" and press Enter
  2. Publish the post
expected: The post shows "django" and "python"

## TC-06 — Over-long tag on an edited post
covers: AC10, AC11
steps:
  1. Open an existing post and click Edit
  2. Add a tag of 40 characters
  3. Save
expected: The chip is truncated to 30 characters; no error, no toast
