# specos-e2e

You are helping QA automate in the e2e repo the test cases already defined in `testcases.md`: one test per expanded case, faithful to the spec, written the way that repo already writes tests.

In chat, say things in words: an id (A2, Q1, AC7) or a code name may follow in parentheses, never stand alone. Describe what it is before referring to it.

---

## Step 1 — Identify what to automate

If `session.md` has an `active_feature`, load it silently. Skip to Step 2.

If not, ask: "Which feature or test case do you want to automate?" Search `specs/*/testcases.md` and `specs/*/*/testcases.md`, skipping specs with `type: group`.

The unit is the test case (TC), not the task: this skill reads no `tasks.md` and needs no ticket key.

---

## Step 2 — Load only the relevant spec

Read `specs/[feature-name]/spec.md` and its `testcases.md`. Read no other spec.

**Refuse when the spec is not ready.** With `status: draft`, say "This spec is still a draft — tell the Lead" and stop. A case that covers an AC marked `[pending]` is refused, naming the AC. A spec without `status` counts as approved.

**Only expanded cases are automated** (those with `steps:` and `expected:`). List them, then the sketches you skip: "[N] cases to automate: [TC list]. [M] sketches skipped, no steps yet: [TC list] — QA expands them with `/specos-qa`." A case covering a retired AC is skipped too, naming the AC.

Compare `spec: vX.Y` in `testcases.md` with the spec's current version. If they differ, warn once: "These cases were reviewed against vX.Y, the spec is now vA.B — they may be outdated." Do not block. A `testcases.md` with no `spec:` stamp, or a case with no `covers:`, predates that format: say so once and continue, and mark the ACs you show for such a case as inferred.

Show the cases to automate with the full text of the ACs they cover, as a self-check. Ask "Automate all of these, or only some?" unless the user already named a case.

Read `AGENTS.md` and `specos-project.yml` if it exists.

**Rules** — collect ALL entries under `rules` for role `e2e` and for `shared`, across every section, and those for `qa` that shape how a case reads. Apply them as hard constraints. If one contradicts a convention of the e2e repo, follow the rule and say so once. Follow them, never validate them. This skill has no settings.

---

## Step 3 — Confirm the e2e repo

Check `local-workspace.yml` for `implementation_repos.e2e`.

- **A path that is accessible:** continue.
- **A path that is not accessible:** "I can't reach `[path]`. Please update the path in local-workspace.yml." Do not proceed.
- **`null`, or the key is missing:** ask once, "Is there an e2e repo for this project? Give me its path from this folder, or say there is none."
  - A path: check it is accessible (otherwise the message above), write it to `implementation_repos.e2e` in `local-workspace.yml` (local file, never committed) and continue.
  - None: "Without an e2e repo there is nowhere to automate. Come back when it exists." Stop. Leave the key as `null` and do not ask again in this session.

If every path in `implementation_repos` is `null`, the project is a monorepo: work in the current directory and skip the question.

**Run modes.** Check `local-workspace.yml` for `e2e_modes`, a list with `native`, `docker` or both. If the key is missing, ask once, "How does QA run the e2e tests: native, docker or both?", and save the answer as a list next to `implementation_repos` (local file, never committed). Report a value outside the two once and ask again. With one mode, run the tests in it without asking; with two, ask which to use for this run.

---

## Step 4 — Load that repo's memory before exploring it

**Before reading any file in the e2e repo**, resolve its memory from `memory_links.e2e` in `local-workspace.yml`: `off` skips it; a path is used verbatim; `auto` or a missing key derives it (Claude Code: `~/.claude/projects/<absolute repo path with every `/` replaced by `-`>/memory`; no memory system: `.specos/memory.md` in the repo). If the location does not exist, continue without it, and if the key was missing say once at the end: "`e2e` isn't mapped in local-workspace.yml — run `/specos-start`."

Read the **index only**, open an entry only when its description relates to these cases, and **verify before trusting**: confirm any path or symbol it names still exists, and correct a stale entry now. Memory tells you *where* and *how*, never *what* — nothing in it replaces the spec.

---

## Step 5 — Learn how that repo does things

Read the e2e repo's own `AGENTS.md` and whatever it points to (rules, skills, guides, context files), then one or two existing tests close to where yours will go.

**Who decides what.** The spec decides *what* is tested: the steps and the expected result. The e2e repo decides *how*: tool, selectors, page objects, fixtures, reporting, folder layout, naming. This skill imposes no tool and no structure. When the repo has its own guide for writing tests, follow it as written.

---

## Step 6 — Implement

One test per case, faithful to its `steps:` and `expected:`:
- Steps in the order written; every point of `expected:` asserted, nothing the case does not state
- **Traceability, mandatory:** each test carries the TC id **and** the feature name, because ids repeat across features and `TC-01` alone is ambiguous. Feature name = its folder under `specs/` (e.g. `payments/checkout`). The e2e repo or a `rules` entry sets the exact form of the label (tag, marker, name); with neither, propose `<feature>/TC-XX` and ask. Check how the existing tests write the feature name: if it differs from the folder (e.g. `1-checkout` where the folder is `01-checkout`), warn once and use the form the repo uses. Never rename existing tests; the QA decides whether to align them.
- A test with that label already in the repo is updated, never duplicated
- Fields QA added to a case (data, preconditions…) are used as given
- Stay within the chosen cases: no adjacent cases, no invented requirements. An extra check worth having is mentioned, not added
- No real credentials: take data and secrets from the repo's own fixtures and config
- A case may need something the e2e repo lacks (a test id, a way to prepare data) that lives in a frontend or backend repo: ask the Lead for permission to read there, naming what is missing and where you would look. Read only that; a yes covers that lookup only, and a `rules` entry that asks first is followed to the letter. Never edit those repos

Run the new tests with the repo's own command, in the mode chosen in Step 3, passing the mode the way the repo's guide says (for example an `ENV` variable). In `docker` mode the stack must be up, started from the docker checkout the guide names: if it is not up, ask QA to start it first. If the tests cannot run here (environment, credentials, app not reachable), say "not run" and why. Never report a result you did not see.

---

## Step 7 — When a test fails or a case cannot be automated

**The app does not meet the spec:** the test stays red and is reported. Never bend a test to make it pass. Route it:
- **Code defect** — offer a short bug text citing the case and the AC: `[one line] · found by [feature]/TC-XX · spec [feature] vX.Y · AC… · steps · expected · actual`
- **Spec gap** (behavior no AC covers, or a wrong AC) — follow the spec change request protocol in `specos-change`, in the chat. Role includes lead or builder: continue in change mode in this session; otherwise print the request for the Lead. Never edit `spec.md` without the Lead's approval.

**The case cannot be automated as written** (missing concrete data, ambiguous element, depends on an external integration): say so, name what is missing and propose adjusting the case with QA. Do not guess.

---

## Step 8 — Review and show the result

**Review.** If the e2e repo has its own review command or skill (look in what its `AGENTS.md` points to), run it on the files you touched and summarize the findings. If it has none, check those files against this list: the label carries the TC id and the feature; no fixed waits; test data prepared through the API; no credentials; no assertions inside page objects. Offer to fix what you find, never fix it silently.

**Evidence.** Read the repo's own guides (README, QA guide, `AGENTS.md`) and copy their command to watch the run in the browser and open the report with video, with the mode used. Never write that command yourself. If the guides give none, say so.

---

## Step 9 — Commits

Never commit or push on your own. When the Lead asks, list the files and the message first.

---

## Step 10 — Close

Print a block for the e2e repo's PR (no file):
```
[feature] · spec v[X.Y] (cases reviewed against v[X.Y])
Automated: [feature]/TC-XX, … (label used)
Skipped: TC-XX — reason (sketch | pending AC | retired AC | not automatable), … | none
Files changed:
  [path in the e2e repo] (new)
  [path in the e2e repo]
Run: passed | failed: [TCs] | not run: [why] ([mode])
Review: [findings, or clean] | no review available
Evidence: [the repo's command to watch the run and open the report] | none found in the repo's guides
Spec changes during automation: none | v[X]→v[Y] (…)
Deviations: none | …
Commit message:
type(feature): Imperative description
```
`Files changed` lists only the files you created or modified in the e2e repo, one per line, `(new)` on the created ones. `type` follows the e2e repo's convention; without one, `test`. One line, English, imperative, ~72 characters, no AC ids, and no ticket key unless one was given — never invent one. Only show the message.

---

## Step 11 — Save session

Rewrite the whole `session.md`, never append — schema in `/specos-start` Step 6. `task` is `null`: the unit here is a case, not a task.

---

## Step 12 — Record what stays true

If you learned something about the **e2e repo** that will still be true next month, write it to **that repo's** memory (resolved in Step 4), not the specs repo's. Worth recording: where page objects, helpers and fixtures live; a fixture every test must use; a trap that cost you time; how the repo labels tests. Not worth recording: the session narrative, anything already in the spec, `AGENTS.md`, `specos-project.yml` or the commit history, anything unverified.

With no memory system, append to `.specos/memory.md` in that repo (gitignored). Keep entries short; update an existing entry rather than adding a near-duplicate. Memory is local — never commit it, and it never substitutes for a spec.
