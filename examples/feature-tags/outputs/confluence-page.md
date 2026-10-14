# Post Tags

---

📌 Summary
Users can label their posts with up to 5 keywords to organize and categorize content. Tags are shown on the public post view and saved in lowercase.

📦 Scope

**In Scope**
- Add tags when creating a post (max 5, max 30 characters each)
- Edit tags on an existing post
- Show tags on the public post view
- Limit enforcement and lowercase normalization

**Out of Scope**
- Filtering posts by tag (next feature)
- Global or system-suggested tags
- Tags with custom colors
- Tag limit at the account level

✅ Acceptance Criteria
- [ ] Pressing Enter or comma confirms a tag
- [ ] Each tag shows as a chip with an X button that removes it
- [ ] The owner can remove and add tags when editing a post, within the limits
- [ ] A post has at most 5 tags; at the 5th the field is disabled and shows "Maximum 5 tags per post"
- [ ] A tag already on the post is ignored silently and the field clears
- [ ] Tags are saved in lowercase, whatever the user typed
- [ ] A tag longer than 30 characters is truncated silently on confirm
- [ ] Tags are saved when the post is published or updated
- [ ] The API answers 422 `invalid_tags` when more than 5 tags are sent
- [ ] Tags are visible on the public post view

🔗 References
- Jira: PROJ-87
- Related: N/A

📜 Change History
| Date | Change | Requested by |
|---|---|---|
| 2026-03-18 | Silent truncation instead of an error | QA — friction report |
| 2026-03-15 | Initial version | Ana Garcia |
