# specos-group

You are helping the Lead group multiple related specs under a shared parent folder. Each spec keeps its full structure unchanged. The group gets a summary spec.md with no ACs, journeys, or tasks — only a domain summary and a list of sub-specs.

---

## Constraints

- Only the Lead can run this skill — if someone else is running it, stop and say so
- All specs to group must already exist in `specs/`
- The group spec.md contains only: summary + list of sub-specs with one-line descriptions
- No ACs, journeys, tasks, or technical content in the group spec.md

---

## Step 1 — Define the group

Ask:
"Which specs do you want to group? List the folder names.
What should the group be called?"

Wait for the answer.

Search `specs/` for each named folder and verify they exist. If any is missing, report it before continuing.

List the specs found and confirm:
"I found these specs: [list]. They will move to specs/[group-name]/[spec-name]/. The group folder will be 'specs/[group-name]/'. Correct?"

Wait for confirmation.

---

## Step 2 — Write the group spec.md

Ask: "Give me a 2-3 line description of what this group covers."

Wait for the answer.

Show the Lead the group spec.md you'll write:

```markdown
---
feature: [group-name]
type: group
version: 1.0
lead: [from local-workspace.yml or AGENTS.md]
date: [today]
---

# [Group name]

[2-3 line summary provided by Lead.]

## Sub-specs

- **[spec-1]** — [one-line description from that spec's summary] → `specs/[group-name]/[spec-1]/spec.md`
- **[spec-2]** — [one-line description] → `specs/[group-name]/[spec-2]/spec.md`
```

Derive each sub-spec's one-line description from its existing spec.md summary. Do not invent it.

Ask: "Any changes before I move the files?"

Wait for approval.

---

## Step 3 — Move files and write group spec

Move each spec folder from `specs/[spec-name]/` to `specs/[group-name]/[spec-name]/`.

Write `specs/[group-name]/spec.md` with the approved content.

For each moved spec.md, add `group: [group-name]` to its frontmatter.

---

## Step 4 — Save session

Update `session.md`:
- `active_feature`: `[group-name]/[first-spec]`
- `spec_path`: `specs/[group-name]/[first-spec]/spec.md`

Confirm to the Lead:
"Group created. [N] specs moved to specs/[group-name]/. Group summary written to specs/[group-name]/spec.md."
