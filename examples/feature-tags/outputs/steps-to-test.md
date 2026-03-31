# Steps to Test — Post Tags

---

### Test 1 — Happy path: create post with tags

**Environment:** Local

**Setup**
- Logged in as user@example.com
- Run: `python manage.py migrate`
- At least one post exists or create a new one

**Verify**
1. Go to Create Post
2. Fill in title and content
3. Click the tags field and type "django"
4. Press Enter — verify "django" chip appears
5. Type "python" and press comma — verify "python" chip appears
6. Type "backend" and press Enter — verify "backend" chip appears
7. Click Publish
8. Open the published post in public view

**Expected Result**
- Tags "django", "python", "backend" are visible as chips on the post detail page
- Tags are stored in lowercase in the database

---

### Test 2 — Edit tags on existing post

**Environment:** Local

**Setup**
- Post with tags ["django", "python"] already exists
- Logged in as the post owner

**Verify**
1. Go to the post and click Edit
2. Verify tags "django" and "python" appear pre-loaded as chips
3. Click X on "python" chip — verify it disappears
4. Type "api" and press Enter — verify "api" chip appears
5. Click Save
6. Open the post in public view

**Expected Result**
- Tags on the post are now: "django", "api"
- "python" is no longer visible

---

### Test 3 — Tag limit

**Environment:** Local

**Setup**
- Logged in as user@example.com
- Creating a new post

**Verify**
1. Go to Create Post
2. Add 5 tags one by one: "one", "two", "three", "four", "five"
3. Verify all 5 chips appear
4. Attempt to type a 6th tag "six" in the field

**Expected Result**
- After the 5th tag, the field is disabled
- Message "Maximum 5 tags per post" is visible
- The 6th tag cannot be added

---

### Test 4 — Duplicate tag ignored

**Environment:** Local

**Setup**
- Logged in as user@example.com
- Creating a new post

**Verify**
1. Go to Create Post
2. Type "django" and press Enter — verify chip appears
3. Type "django" again and press Enter

**Expected Result**
- Only one "django" chip is visible
- No error message is shown
- The field clears silently

---

### Test 5 — Lowercase normalization

**Environment:** Local

**Setup**
- Logged in as user@example.com

**Verify**
1. Go to Create Post
2. Type "Django" (capital D) and press Enter
3. Type "PYTHON" (all caps) and press Enter
4. Publish the post
5. Check the database: `SELECT tags FROM posts WHERE id = [id]`

**Expected Result**
- Post displays chips as typed (UX)
- Database stores: `["django", "python"]` — all lowercase
