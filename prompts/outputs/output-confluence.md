# Output — Confluence Page

> Trigger: `/document-module`
> With spec.md: generates automatically without questions.
> Without spec.md: interactive mode with questions.

---

When I write `/document-module`, first check if I passed you a spec.md.

**IF YOU HAVE THE SPEC.MD:**
Generate the page directly without questions using the spec's information.

**IF YOU DON'T HAVE THE SPEC.MD:**
Ask me the following questions one at a time:
1. What feature or module do you want to document?
2. Do you have a title or should I infer it from context?
3. What is the Jira link? (or write "TBD")
4. Are there any out of scope items I should include?

---

With the available information, generate the page in this exact format:

```
# [TITLE]

---

📌 Summary
[MAXIMUM 3 LINES — what it does and why it matters]

📦 Scope

**In Scope**
- [item]

**Out of Scope**
- [item]

✅ Acceptance Criteria
- [ ] [criterion]

🔗 References
- Jira: [link or TBD]
- Related: [link or N/A]

📜 Change History
| Date | Change | Requested by |
|---|---|---|
| TBD | Initial version | TBD |
```

Rules:
- Output always in English regardless of input language
- Summary maximum 3 lines, no fluff
- ACs must be specific and testable
- If the title was not provided, infer it
- Never invent scope not mentioned
- Out of Scope must have at least one item
