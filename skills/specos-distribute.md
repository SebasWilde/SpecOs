# specos-distribute

You generate formatted outputs from a spec, task list, or test cases — ready to paste into any external tool.

---

## Step 1 — Identify what to output

Ask: "What do you want to generate output for?
1. Tasks — formatted for your task software
2. Test cases — formatted for your test tool
3. Confluence doc — full spec as a structured document
4. Flow diagrams — Mermaid diagrams for each journey"

Wait for the answer.

---

## Step 2 — Load the relevant files

Read `specos-outputs.yml` to get the configured destinations and ID prefixes.

Based on the selection:
- Tasks → read `specs/[feature-name]/tasks.md`
- Test cases → read `specs/[feature-name]/testcases.md`
- Confluence doc → read `specs/[feature-name]/spec.md`
- Flow diagrams → read `specs/[feature-name]/spec.md`

If the file does not exist: "No [file] found for this feature. Run /specos-lead or /specos-qa first."

---

## Step 3 — Generate output

### Tasks output

Ask only: "Do you have branch or PR info for these tasks?
1. Same for all tasks — tell me once
2. Per task — I'll ask as I go
3. None"

Wait for the answer. If option 1, ask for the branch/PR info now. If option 2, ask per task before generating it.

Then, for each task in `tasks.md`, generate using this exact format (always in English):

```
# [TITLE]

## Context
[Only include if background is needed to understand the task — e.g. relevant technical decisions, data model, or API contract from the spec's technical section. Skip entirely if scope is self-explanatory.]

## Scope
[What needs to be implemented. Pull from tasks.md description and relevant ACs from spec.md. Use bullets only if steps are clear and well-defined, otherwise prose.]

## Acceptance Criteria
- [criterion — specific and testable, pulled from the ACs in spec.md that this task covers]

## Dev Notes
[Only include if branch/PR/command info was provided. Skip entirely if none.]
⚠️ Branch from: `[branch]`
⚠️ PR to: `[branch]`
ℹ️ Run: `[command if any]`
```

Rules:
- Title must be concise and technical — maximum 8 words, imperative verb first (e.g. "Add JWT validation to /auth endpoint")
- Context only appears when strictly necessary — inject relevant technical details from spec.md (API shape, schema, decisions) into the tasks that need them
- Dev Notes only appears when branch or command info was provided
- ACs must be simple bullets — no nested lists, no vague language
- Never invent features or technical details not in the spec
- Infer obvious technical details when clearly implied by the spec
- Formatting rules (strict): no trailing spaces on any line, exactly one blank line between sections, no double blank lines anywhere

Print tasks sequentially, grouped by role. Pause between role groups and ask: "Ready for the next group?"

After printing all tasks, ask:
"Create these tasks in your task software, then come back with the real IDs so I can update tasks.md."

When the Lead provides the real IDs, update `specs/[feature-name]/tasks.md` replacing each SP-XX placeholder with the real ID.
Confirm: "tasks.md updated with real IDs: [list the mapping]"

### Test cases output

For each test case in `testcases.md`, generate a format appropriate for the destination:

**Manual / generic:**
Print the raw `testcases.md` content formatted for readability.

**Jira / Linear / GitHub Issues (manual paste):**
```
[TC-ID] Title
Task link: [task ID or none]
Steps:
  1. [Step]
  2. [Step]
Expected result: [result]
[Any additional fields as-is]
```

Note: "MCP integration is not active in v3. Copy the output above into [tool] manually."

### Confluence doc output

Ask only: "What is the Jira link for this feature? (or say TBD)"

Then generate the document from `spec.md` using this exact format:

```markdown
# [emoji] [Feature title]

---

📌 Summary
[MAX 3 LINES — what it does and why it matters. No fluff.]

📦 Scope

**In Scope**
- [item from spec]

**Out of Scope**
- [item from spec — at least one required]

✅ Acceptance Criteria
- [ ] [criterion — specific and testable]

🔗 References
- Jira: [link provided by Lead]
- Spec: [add link manually]

📜 Change History
| Date | Change | Requested by |
|---|---|---|
| [date from spec frontmatter] | Initial version | Client |
```

Rules:
- Infer the emoji and title from the feature name in the spec
- Summary must be 3 lines maximum
- Never invent scope items not in the spec
- ACs must be specific and testable — rewrite any vague ones
- Out of scope must have at least one item
- Use plain English, avoid technical jargon unless necessary
- Do not include User Journeys or Technical Notes sections
- Formatting rules (strict): no trailing spaces on any line, exactly one blank line between sections, table columns aligned with consistent spacing, no empty rows in tables

Print the document. Tell the Lead: "Copy this into Confluence manually and replace the Spec link in References."

### Flow diagrams output

Ask only: "How many diagrams do you need?
1. One combined diagram for all journeys
2. One diagram per journey
3. Let you decide based on the spec"

If option 3: use one combined diagram when the spec has 2 journeys or fewer; use one per journey when there are 3 or more. Tell the Lead which approach you chose and why.

Then generate Mermaid diagrams from the journeys in `spec.md` using this format:

````markdown
## [Journey name or "Full flow"]

```mermaid
flowchart TD
    ...
```
````

Rules:
- Use `flowchart TD` for all diagrams
- Happy path nodes: default style
- Error or rejection nodes: `style NodeName fill:#ff6b6b`
- Success end nodes: `style NodeName fill:#51cf66`
- Decision nodes use `{ }` with short Yes/No labels
- Node labels: 5 words maximum
- Every journey from the spec must appear — including all error journeys

After all diagrams, add:

```
**Legend**
🟢 Green — success / end state
🔴 Red — error or rejection
⬜ Default — action or step
◇ Diamond — decision point
```

Tell the Lead: "Copy each diagram block into a Confluence page and render with the Mermaid macro."

---

## Step 4 — Confirm

After output is generated:
"Output complete. Paste the content above into your tool."
