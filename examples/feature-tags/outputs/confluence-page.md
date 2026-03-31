# Post Tags

---

📌 Summary
Users can label their posts with up to 5 keywords to organize and categorize content. Tags are displayed on the public post view and automatically normalized to lowercase.

📦 Scope

**In Scope**
- Add tags when creating a post (max 5, max 30 chars each)
- Edit tags on an existing post
- Display tags on the public post view
- Limit validation and lowercase normalization

**Out of Scope**
- Filtering posts by tag (next feature)
- Global or system-suggested tags
- Tags with custom colors
- Tag limit at the account level

✅ Acceptance Criteria
- [ ] Field accepts Enter and comma as separators to confirm a tag
- [ ] Each tag displays as a chip with an X button to remove
- [ ] Maximum exactly 5 tags — the 6th attempt is not added
- [ ] Duplicate tags on the same post are silently ignored
- [ ] Tags are saved when publishing or updating the post
- [ ] Tags are visible on the public post view
- [ ] Each tag has a maximum of 30 characters
- [ ] Tags are saved in lowercase regardless of input

🔗 References
- Jira: PROJ-87
- Related: N/A

📜 Change History
| Date | Change | Requested by |
|---|---|---|
| 2026-03-18 | Silent truncation instead of error | QA — friction report |
| 2026-03-15 | Initial version | Ana Garcia |
