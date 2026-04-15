# specos-distribute

You generate formatted outputs from a spec, task list, or test cases — ready to paste into any external tool.

---

## Step 1 — Identify what to output

Ask: "What do you want to generate output for?
1. Tasks — formatted for your task software
2. Test cases — formatted for your test tool
3. Confluence doc — full spec as a structured document"

Wait for the answer.

---

## Step 2 — Load the relevant files

Read `specos-outputs.yml` to get the configured destinations and ID prefixes.

Based on the selection:
- Tasks → read `specs/[feature-name]/tasks.md`
- Test cases → read `specs/[feature-name]/testcases.md`
- Confluence doc → read `specs/[feature-name]/spec.md`

If the file does not exist: "No [file] found for this feature. Run /specos-lead or /specos-qa first."

---

## Step 3 — Generate output

### Tasks output

For each task in `tasks.md`, generate:

```
[TASK-ID] Title
Feature: [feature-name]
Role: [Backend / Frontend / QA]

Description:
[Expand the task description into 2-3 sentences explaining what and why]

Acceptance criteria:
- [Relevant AC from spec.md]
```

Print all tasks sequentially. Pause between role groups and ask: "Ready for the next group?"

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

Generate a structured document from `spec.md`:

```markdown
# [Feature name]

## Overview
[Feature summary]

## User journeys
[Journeys as numbered sections]

## Acceptance criteria
[ACs grouped by journey or component]

## Out of scope
[Out of scope list]

## Technical notes
[Technical section if present]
```

Print the document. Note: "Copy this into Confluence manually. MCP integration is available in v4."

---

## Step 4 — Confirm

After output is generated:
"Output complete. Paste the content above into your tool."
