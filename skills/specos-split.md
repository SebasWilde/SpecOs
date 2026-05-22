# specos-split

You are helping the Lead split a large spec into smaller, focused sub-specs grouped under the same parent folder. The original spec folder becomes the group. Each sub-spec is a full SpecOS feature with its own spec.md, tasks.md, testcases.md, and CHANGELOG.md.

---

## Constraints

- Only the Lead can run this skill — if someone else is running it, stop and say so
- The original spec must have a spec.md present
- Each sub-spec must have at least 1 AC and 1 task
- The group spec.md contains only: summary + list of sub-specs with one-line descriptions — no ACs, journeys, tasks, or technical content
- The original tasks.md and testcases.md are archived, not deleted

---

## Step 1 — Load the spec to split

If `session.md` has an `active_feature`, load `specs/[active_feature]/spec.md` silently.

If no feature is loaded, ask: "Which spec do you want to split?"

Search `specs/` for the matching spec.md and load it.

---

## Step 2 — Define the sub-features

Present a brief summary of the loaded spec (feature name, number of ACs, number of tasks) and ask:
"How do you want to split this spec? Give me the names and a one-line description for each sub-feature."

Wait for the Lead's answer.

Based on the answer, propose the breakdown:
- List of sub-feature names with descriptions
- Which ACs and tasks from the original spec go to each sub-feature
- Flag any ACs or tasks that don't fit clearly and suggest where they belong

Ask: "Does this breakdown look right, or do you want to adjust?"

Wait for approval before continuing.

---

## Step 3 — Build each sub-spec

For each sub-feature, in order:

1. Propose the full `spec.md` content — summary, journeys, ACs, out of scope, technical section if applicable — based on the portion assigned in Step 2
2. Present it and ask: "Any changes to this sub-spec before I write it?"
3. Wait for approval

Do not write any files until all sub-specs are approved.

---

## Step 4 — Write files

### Write each sub-spec

For each sub-feature, write the following files to `specs/[original-feature]/[sub-feature]/`:

**spec.md** — with this frontmatter:
```markdown
---
feature: [sub-feature-name]
group: [original-feature-name]
version: 1.0
status: approved
lead: [from session.md or AGENTS.md]
date: [today]
keywords: [relevant terms]
linked:
  - specs/[original-feature]/spec.md
---
```

**tasks.md** — tasks for that sub-feature only, using the same format as specos-lead.

**CHANGELOG.md** — initial entry only.

**testcases.md** — draft generated from the sub-spec ACs and journeys. Mark it as a draft at the top.

### Rewrite the group spec.md

Replace `specs/[original-feature]/spec.md` with a group summary using this format:

```markdown
---
feature: [original-feature-name]
type: group
version: 1.0
lead: [name]
date: [today]
---

# [Original feature name]

[2-3 line summary of the domain — what this group covers and why it exists.]

## Sub-specs

- **[sub-feature-1]** — [one-line description] → `specs/[original]/[sub-feature-1]/spec.md`
- **[sub-feature-2]** — [one-line description] → `specs/[original]/[sub-feature-2]/spec.md`
```

### Archive original files

Rename `specs/[original-feature]/tasks.md` → `specs/[original-feature]/tasks.archived.md`
Rename `specs/[original-feature]/testcases.md` → `specs/[original-feature]/testcases.archived.md`
Rename `specs/[original-feature]/CHANGELOG.md` → `specs/[original-feature]/CHANGELOG.archived.md`

Do not delete them.

---

## Step 5 — Save session

Update `session.md`:
- `active_feature`: `[original-feature]/[first-sub-feature]`
- `spec_path`: `specs/[original-feature]/[first-sub-feature]/spec.md`

Confirm to the Lead:
"Split complete. [N] sub-specs created under specs/[original-feature]/. Original files archived."
