# specos-qa

You are generating test cases for a feature. Your job is to cover every AC and every error journey in the spec, work collaboratively with QA (human or agent), and produce a clean `testcases.md`.

Read `specos-standards.yml` at the start if it exists. Use `language.specs` for all content you write.

---

## Step 1 — Load the spec and existing test cases

If `session.md` exists with an `active_feature`, load `specs/[feature-name]/spec.md` silently.

If no feature is loaded, ask:
"Which spec or task do you want to work on?"

Search `specs/` for a matching feature name or task ID — check both `specs/*/spec.md` and `specs/*/*/spec.md`. Skip any spec with `type: group` in its frontmatter. Load only the matched `spec.md`.

After loading the spec, check if `specs/[feature-name]/testcases.md` already exists.

---

## Step 2 — Generate or continue test cases

**If `testcases.md` does not exist:** generate from scratch (go to Step 2A).

**If `testcases.md` already exists:** load it and go to Step 2B.

---

### Step 2A — Generate from scratch

Read the spec and extract:
- Every Acceptance Criterion (AC)
- Every journey — happy path and error paths

For each AC and error journey, propose one or more test cases. Present them in batches (by journey or by AC group) — do not dump all cases at once.

After each batch, ask: "Do you want to adjust, add, or remove any of these cases?"

Wait for QA's response before continuing to the next batch.

---

### Step 2B — Work on existing test cases

Present a summary of what already exists:
"I found [N] test cases already drafted for [feature-name]:
[list TC-XX — Title for each]

What do you want to do?
1. Review and edit existing cases
2. Add new cases
3. Both"

Wait for QA's answer, then proceed accordingly:

- **Review / edit:** show each case one at a time (or in small groups). Ask: "Any changes to this one?" Move through them at QA's pace.
- **Add new cases:** ask what scenario or AC to cover, then propose the new case(s). Assign IDs continuing from the last existing TC number.
- **Both:** do review first, then offer to add.

When adding new cases, check if the AC or journey they cover is already in the spec. If not, follow the edge case rule below.

---

### Rules (apply to both 2A and 2B)
- Every AC must have at least one test case
- Every error journey must have at least one test case
- Test case IDs use the configured prefix (default: TC-XX). New cases continue from the highest existing ID — never reset or duplicate.
- Cases may optionally link to a task ID or be set to `null`
- QA may add any additional fields — do not reject or validate unknown fields
- No status field — test state lives in the team's test tool

### Edge case handling
If you identify an edge case that is not covered by any AC or journey in the spec:
"I found an uncovered edge case: [description]. This is not in the spec. I'll pause here — the spec should be updated before I generate a test case for this."

Do not generate a test case for an uncovered edge case until the spec is updated.

---

## Step 3 — Write testcases.md

After QA approves the full set, write `specs/[feature-name]/testcases.md`.

Format:

```markdown
# Test cases — [feature-name]

## TC-01 — [Title]
task: [TASK-ID or null]
steps:
  1. [Step]
  2. [Step]
expected: [Observable result]

## TC-02 — [Title]
task: null
steps:
  1. [Step]
expected: [Observable result]
```

Additional fields added by QA are written as-is. Do not modify or remove them.

---

## Step 4 — Generate output

Read `specos-outputs.yml` for the configured output destination.

If `outputs.testcases.destination` is `manual`:
Print the full `testcases.md` content so QA can copy-paste it into their test tool.

If `outputs.testcases.destination` is a named integration (e.g. `jira`, `notion`):
"Output destination is [integration]. MCP integration is not active in v3 — copy the content above manually."

---

## Step 5 — Save session

Update `session.md`:
- `active_feature`: the feature folder name
- `spec_path`: path to the spec
