# specos-config

You are helping the Lead configure `specos-standards.yml` — the project-level standards file. Your job is to guide them through adding, editing, or removing sections collaboratively, one section at a time.

---

## Step 1 — Load current config

Look for `specos-standards.yml` in the specs repo root.

**If it exists:** read it silently. Go to Step 2.

**If it does not exist:** say:
"No specos-standards.yml found. I'll create one from scratch."
Go to Step 3.

---

## Step 2 — Show current state and ask what to do

Print a clean summary of the current config:

```
specos-standards.yml — current config

Language: specs=[value], outputs=[value]

Sections:
  [section-name]
    frontend: [N entries]
    backend: [N entries]
    shared: [N entries]
  [section-name]
    ...

[If no sections beyond language: "No standards sections defined yet."]
```

Then ask:
"What do you want to do?
1. Set or change the language
2. Add a new standards section
3. Edit an existing section
4. Remove a section
5. Done — write the file"

Wait for the answer before continuing.

---

## Step 3 — Handle each action

### Action 1 — Language

Ask: "What language should specs and outputs be written in? (e.g. Spanish, English, Portuguese — or the ISO code: es, en, pt)"

Set both `language.specs` and `language.outputs` to the same code unless the Lead specifies different values for each.

Confirm: "Language set to [code]. Anything else?"

Return to Step 2.

---

### Action 2 — Add a new section

Ask: "What do you want to call this section? (e.g. acceptance_criteria, code_style, api_conventions, accessibility, security — or any name that fits your project)"

Wait for the name.

Ask: "Which roles does this apply to? (frontend, backend, qa, shared — or a combination)"

Wait for the answer.

For each role selected, ask: "What are the rules for [role]? Give me one rule per line."

Wait for the list. Present each rule back and ask: "Any changes before I add this?"

Wait for confirmation. Then move to the next role.

After all roles: return to Step 2.

---

### Action 3 — Edit an existing section

List the existing sections and ask: "Which section do you want to edit?"

Wait for the answer. Load that section and show its current entries grouped by role.

Ask: "What do you want to change?
1. Add rules to a role
2. Remove a rule
3. Edit a rule"

Handle the change. Confirm it. Return to Step 2.

---

### Action 4 — Remove a section

List the existing sections and ask: "Which section do you want to remove?"

Wait for the answer. Confirm: "Remove section '[name]' and all its entries. Are you sure?"

Wait for confirmation. Return to Step 2.

---

### Action 5 — Done

Write the updated `specos-standards.yml` to the specs repo root.

Use this format:

```yaml
# specos-standards.yml
# Project-level standards for SpecOS v3.
# Committed to the repo. Edit as your project evolves.
#
# `language` is the only reserved key. Everything else is free-form.
# Skills read the entire file and apply all entries for the relevant role.

language:
  specs: [value]
  outputs: [value]

[section-name]:
  [role]:
    - "[rule]"
  [role]:
    - "[rule]"

[section-name]:
  ...
```

Only write roles that have at least one entry. Omit empty roles.

Confirm: "specos-standards.yml updated. [N] sections configured."
