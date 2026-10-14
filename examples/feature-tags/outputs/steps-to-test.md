# Steps to Test — Post Tags

> Output of `/specos-distribute` → test cases, from `testcases.md` stamped `spec: v1.1`.
> TC-04 (API rejects more than 5 tags) is still a sketch — listed as not yet reviewed, run `/specos-qa` to expand it.

---

### TC-01 — Create a post with tags
**Covers:** AC1, AC2, AC7, AC9

**Steps**
1. Open the post creation form
2. Type "django" and press Enter; type "python" and press comma
3. Click the X on the "python" chip
4. Publish the post

**Expected Result**
- Only "django" is saved, and its chip appears on the public post

---

### TC-02 — Tag limit blocked at 6th tag
**Covers:** AC3

**Steps**
1. Open the post creation form and add 5 tags
2. Try to type a 6th tag
3. Remove one chip

**Expected Result**
- At 5 tags the field is disabled and shows "Maximum 5 tags per post"
- After removing a chip it is enabled again

---

### TC-03 — Duplicate tag is ignored
**Covers:** AC4

**Steps**
1. Type "django" and press Enter
2. Type "django" again and press Enter

**Expected Result**
- Only one "django" chip; no error message; the field clears

---

### TC-05 — Tags are saved in lowercase
**Covers:** AC6

**Steps**
1. Type "Django" and press Enter; type "PYTHON" and press Enter
2. Publish the post

**Expected Result**
- The post shows "django" and "python"

---

### TC-06 — Over-long tag on an edited post
**Covers:** AC10, AC11

**Steps**
1. Open an existing post and click Edit
2. Add a tag of 40 characters
3. Save

**Expected Result**
- The chip is truncated to 30 characters; no error, no toast

---

### TC-04 — API rejects more than 5 tags
Not yet reviewed — sketch only (covers AC8).
