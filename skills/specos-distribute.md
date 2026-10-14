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

Read `specos-project.yml` — it holds destinations, ID prefixes, settings, and rules.

**Settings** — read these from `settings.distribute` and obey them. Absent means the default; do not warn about an absent file or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `diagrams` | `none` \| `combined` \| `per_journey` \| `ask` | `ask` | How many flow diagrams to generate. Only `ask` asks. |
| `branch_info` | `ask` \| `none` | `ask` | Whether to ask for branch/PR info before generating tasks |
| `task_title_max_words` | integer ≥ 1 | `8` | Maximum words in a task title |
| `task_detail` | `brief` \| `full` | `brief` | `brief` = title, spec reference, 1–3 lines of scope. `full` = the complete ticket template |

An unknown key under `settings.distribute`, or a value outside the accepted set, is reported **once** — name the key, the value found, and what is accepted — then that setting falls back to its default. Collect every problem into one message; never abort over config.

**Rules** — collect all entries under `rules` for the task's role and for `shared`, across every section, and apply them as described below. `writing_style` rules govern how you word the output. Rules are sentences: follow them, never validate them. A rule's own language never changes the output language — that is `language.outputs` alone.

Based on the selection and the `active_feature` in session.md (which may be `group/sub-feature`):
- Tasks → read `specs/[active_feature]/tasks.md` and the matching `spec.md`; output only the `[new]` tasks. Tasks that already have a key are skipped. If some have an old `SP-` placeholder (`[SP-01]`), ask once: "[N] tasks with an SP- placeholder: treat them as new?" Yes: output them like `[new]`. No: skip them. With none, say "No [new] tasks."
- Test cases → read `specs/[active_feature]/testcases.md`
- Confluence doc → read `specs/[active_feature]/spec.md`
- Flow diagrams → read `specs/[active_feature]/spec.md`

If the file does not exist: "No [file] found for this feature. Run /specos-lead or /specos-qa first."

---

## Step 3 — Generate output

### Tasks output

When `branch_info` is `none`, skip this question entirely and omit the Dev Notes section from every task.

When `branch_info` is `ask`, ask only: "Do you have branch or PR info for these tasks?
1. Same for all tasks — tell me once
2. Per task — I'll ask as I go
3. None"

Wait for the answer. If option 1, ask for the branch/PR info now. If option 2, ask per task before generating it.

Then, for each `[new]` task, output it as raw markdown — never wrap it in a code block. Print every role's tasks at once, grouped by role, no pauses.

**`task_detail: brief`** (default) — the spec is the source of truth, so the ticket points to it instead of copying it:

# [TITLE]
Spec: specs/[feature]/spec.md (v[X.Y]) · AC1–AC3
[1–3 lines: what to build, in prose. Name only what the ACs do not already say.]
## Dev Notes
[Only when branch/PR/command info was provided.]
⚠️ Branch from: `[branch]`
⚠️ PR to: `[branch]`
ℹ️ Run: `[command if any]`

The AC refs and version come from the task line in `tasks.md`. Brief has no Acceptance Criteria or Standards section: the ACs live in the spec, and `specos-dev` enforces `rules`.

**`task_detail: full`** — the complete template:

# [TITLE]

## Context
[Only when the task needs background (API contract, data model decision, architectural constraint from spec.md). Otherwise omit.]

## Scope
[What must be implemented, from tasks.md and the matching ACs and technical notes: endpoint and field names, validation rules, business logic, edge cases. Prose; bullets only for parallel steps.]

## Acceptance Criteria
- [One self-contained sentence per referenced AC: trigger and observable result, max 2 lines.]
- [Append `rules` entries from quality-gate sections (e.g. `acceptance_criteria`, `qa_gates`, `definition_of_done`). Omit if none.]

## Standards
[Only when `rules` has non-AC entries for this role or `shared` (e.g. `code_style`, `security`). Bullets grouped by section name. Otherwise omit.]

## Dev Notes
[As in brief, only when provided.]

Formatting rules (strict — apply before printing):
- Separate tasks with a line containing only `---`
- No blank line between `# TITLE` and the next line; exactly one blank line between `##` sections
- No blank lines inside a section's content, no trailing spaces, no double blank lines
- An omitted section leaves no blank line in its place

Content rules:
- Title: at most `task_title_max_words` words (default 8), imperative verb first ("Add JWT validation to /auth endpoint")
- Invent nothing absent from the spec; no vague language ("should work")

**Destination `jira-csv`** (`outputs.tasks.destination`) — print one CSV for Jira's CSV import in a fenced block instead of the blocks above. Columns `Summary,Description,Issue Type,Parent`: Summary = the title; Description = the ticket body per `task_detail`; Issue Type = `Sub-task`; Parent = the story key, asked once ("Parent issue key, or none?"). Double-quote every field, doubling inner `"`. Offer to save it as `specs/[feature]/outputs/jira-tasks.csv`.

After printing, say:
"Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand."

When the Lead gives the keys, replace each `[new]` in printed order, keep the AC refs and version, and confirm the mapping; if the count differs, ask. With no keys, `[new]` stays and is offered again next time.

### Test cases output

For each expanded test case in `testcases.md` (one with `steps:`), generate a format appropriate for the destination. List sketches (no `steps:`) as "not yet reviewed — run /specos-qa" and do not format them.

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

`diagrams` decides this, and only `ask` asks:

| Value | Behaviour |
|---|---|
| `none` | Generate nothing. Say so in one line and stop. |
| `combined` | One combined diagram for all journeys. |
| `per_journey` | One diagram per journey. |
| `ask` | Ask the question below. |

When `diagrams` is `ask`, ask only: "How many diagrams do you need?
1. One combined diagram for all journeys
2. One diagram per journey
3. Let you decide based on the spec"

If option 3: use one combined diagram when the spec has 2 journeys or fewer; use one per journey when there are 3 or more. Tell the Lead which approach you chose and why.

If the spec has no journeys, say so in one line and stop. Otherwise generate Mermaid diagrams from the journeys in `spec.md` using this format:

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
