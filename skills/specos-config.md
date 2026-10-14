# specos-config

You are helping the Lead configure `specos-project.yml` — the single committed config file for this project. Guide them through it collaboratively, one change at a time.

The file has three blocks. Know the difference before you start:

| Block | What it holds | How a skill uses it |
|---|---|---|
| team / ids / integrations / outputs | who does what, where output goes | reads values |
| `settings` | closed schema — numbers, booleans, a short list | **obeys** |
| `rules` | free-form sentences, by role | **interprets** |

A candidate is a `settings` entry only if the project answers it the same way every time **and** it is bounded (integer, boolean, or a listed set). Anything only a sentence can say is a rule — tone, naming style, review expectations: put it in `rules` and say why in one line.

**The file is written in English.** Keys, comments, and rule sentences, regardless of `language.specs`. See Step 4.

---

## Step 1 — Load current config

Look for `specos-project.yml` in the specs repo root.

**If it exists:** read it silently. Go to Step 2.

**If it does not exist, but `specos-outputs.yml` or `specos-standards.yml` does:** say "This project still has the old config files. `/specos-start` migrates them to specos-project.yml — run it first, then come back." and stop. Do not migrate or edit the old files here.

**If nothing exists:** say:
"No specos-project.yml found. I'll create one from scratch."
Go to Step 3.

---

## Step 2 — Show current state and ask what to do

Print a clean summary:

```
specos-project.yml — current config

Language: specs=[value], outputs=[value]

Team and destinations
  lead: [value]   qa: [value]
  IDs: task=[prefix], testcase=[prefix]
  Integrations enabled: [names, or "none"]
  Destinations: tasks=[value], testcases=[value], confluence_doc=[value]

Settings
  [skill].[key]: [value]
  [skill].[key]: [value]
  [If none set: "All at default."]

Rules
  [section-name]
    frontend: [N entries]
    backend: [N entries]
    shared: [N entries]
  [If none: "No rules defined yet."]
```

For settings, show only the keys present in the file; Step 3 Action 3 shows them all.

Then ask:
"What do you want to change?
1. Language
2. Team and destinations
3. Settings — how skills behave
4. Rules — how output should read
5. Done — write the file"

Wait for the answer before continuing.

---

## Step 3 — Handle each action

### Action 1 — Language

Ask: "What language for specs and outputs? (e.g. Spanish, English — or es, en)"

Set both `language.specs` and `language.outputs` to the same code unless the Lead specifies different values for each.

If the code is not English, add one line: "Note: this sets the language of generated specs and outputs. specos-project.yml itself stays in English."
Then return to Step 2.

---

### Action 2 — Team and destinations

Ask which one: team roles, ID prefixes, integrations, or output destinations.

- **Team:** `lead` and `qa`, each `human`, `agent`, or `both`.
- **IDs:** `task_prefix` (only a hint for the shape of task keys) and `testcase_prefix` — short strings, no spaces.
- **Integrations:** each one `enabled: true|false`, plus `mcp:` (a server name or `null`) for jira and confluence.
- **Destinations:** `tasks`, `testcases`, `confluence_doc` — `manual`, or the name of an enabled integration. `tasks` also accepts `jira-csv` (a CSV for Jira's import, no integration needed).

If the Lead points a destination at an integration that is not enabled, say so and offer to enable it.
Then return to Step 2.

---

### Action 3 — Settings

Print the full catalog, marking what is set and what is running on default:

```
lead
  max_tasks              integer >= 1                              default 15      [current: X]
  max_journeys           integer >= 1 | none                       default none    [current: X]
  require_error_journey  true | false                              default false   [current: X]
  review                 draft | sections                          default draft   [current: X]
  suggest_scenarios      true | false                              default true    [current: X]
qa
  cases_per_ac           minimal | standard | exhaustive | integer default standard [current: X]
  include_negative_cases true | false                              default true    [current: X]
  batch_by               journey | ac | all                        default journey  [current: X]
distribute
  diagrams               none | combined | per_journey | ask       default ask     [current: X]
  branch_info            ask | none                                default ask     [current: X]
  task_title_max_words   integer >= 1                              default 8       [current: X]
  task_detail            brief | full                              default brief   [current: X]
dev
  require_tests          true | false                              default false   [current: X]
```

Show `[current: ...]` only for keys present in the file. Omit the marker entirely for keys at their default.

Ask: "Which setting do you want to change? (or 'clear [skill].[key]' to go back to the default)"

Validate the value against the accepted set; if it does not match, say what is accepted and ask again — never write an invalid value. Explain in one line what changes, e.g. "diagrams: per_journey — /specos-distribute will generate one diagram per journey and stop asking."

**Never write a setting the Lead did not set.** Defaults stay out of the file; a cleared setting is removed.
Then return to Step 2.

---

### Action 4 — Rules

Ask: "What do you want to call this section? (e.g. writing_style, code_style, api_conventions, accessibility, security — or any name that fits your project)"

If the section already exists, offer to add to it, edit an entry, or remove one.

Ask: "Which roles does this apply to? (frontend, backend, qa, shared — or a combination)"

For each role selected, ask: "What are the rules for [role]? Give me one rule per line."

Present each rule back and ask: "Any changes before I add this?" Then move to the next role.

Apply the English rule from Step 4 to every sentence before writing.
Then return to Step 2.

---

## Step 4 — The English rule

Every rule sentence written into `specos-project.yml` is in English, no matter what `language.specs` says. A rule is an instruction the agent follows, and instructions are followed most reliably in English. The instruction language and the output language are independent — an English rule produces Spanish output when `language.specs: es`.

When the Lead states a rule in another language:

1. Translate it to English.
2. Show the English text back: "I'll write this as: '[English text]' — the file is in English so the agent reads it reliably. Your specs stay in [language]. Good?"
3. Write only after they confirm.

**Never reword silently.** The Lead must see the sentence that ends up in the file.

**Never translate a literal.** When a rule requires an exact string in the output, that string stays verbatim in its original language:

- Lead says: *"cada paso de test case empieza con `Dado que`"*
- Write: `"Every test case step starts with 'Dado que'"`
- The instruction is translated. `Dado que` is not — it has to appear in the output exactly as written.

A non-English rule already in the file is applied as written. Offer once to translate it; if declined, leave it and do not ask again.

---

## Step 5 — Done

Write the updated `specos-project.yml` to the specs repo root.

Preserve the template's header comments and structure. Block order: `version`, `language`, `team`, `ids`, `integrations`, `outputs`, `settings`, `rules`.

Omit `settings:` entirely when nothing is set. Omit `rules:` entirely when nothing is defined. Within `rules`, write only roles that have at least one entry.

Confirm: "specos-project.yml updated: [N] settings, [N] rule sections."
