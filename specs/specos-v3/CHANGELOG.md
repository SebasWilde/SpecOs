# Changelog — specos-v3

## 2026-08-22 v2.6
- `specos-project.yml` introduced — `specos-outputs.yml` and `specos-standards.yml` merge into one committed config file holding everything configurable about a project
- Problem solved: the split between the two old files had no defensible line. Both were committed, both were project-level, and the boundary cut through single concerns — `ids.testcase_prefix` lived in outputs while *how many* test cases to write would have gone to standards. `language` was declared in **both files**, a duplication the merge removes by construction
- Second problem solved: neither file could configure skill *behaviour*, so three things had no home — decisions hardcoded in a skill prompt (`max_tasks: 15`, 8-word task titles), questions re-asked identically on every run (`/specos-distribute` diagrams and branch info), and decisions left to model discretion so output size varied run to run (`/specos-qa` case count)
- Three blocks defined, distinguished by who consumes them: **team and destinations** (from the old outputs file), **settings** (new, closed schema, the skill obeys), **rules** (the old free-form sections, the skill interprets)
- The core distinction is settings vs rules: a setting is a number, boolean, or one option from a short list, and produces the same result every time; a rule is a sentence that must be read as language. `cases_per_ac: 2` gives two cases; `"Direct tone, no filler"` cannot be reduced to a value
- Qualification test recorded — a candidate is a setting only if the project answers it identically every time, it is bounded, and today it is a free decision. Failing bounded-ness sends it to `rules`
- Settings catalog defined: 10 settings across `lead` (3), `qa` (3), `distribute` (3), `dev` (1), each with accepted values, one documented default, and the specific gap it closes
- `ask` defined as a first-class value, not a fallback — it is how a project keeps a question it genuinely wants asked every run
- Tone resolved rather than rejected: it belongs in `rules`, not `settings`. `neutral | conversational` is two labels over a continuous space that each skill would read differently, which is the non-determinism `settings` exists to remove. As a sentence under `rules.writing_style` it says what a label cannot, and applies to every skill that writes content
- Output format deliberately not made a setting — the shape of an output is a property of its destination, which `specos-project.yml` already owns in the same file. `task_title_max_words` kept, since it is bounded and currently hardcoded
- `local-workspace.yml` deliberately **not** merged, and the two-file boundary documented: one question decides which file something goes in — does the whole team share this? Local, uncommitted, machine-specific location in one; shared, committed, project-level configuration in the other
- Reading contract defined: absent file or block → defaults silently, no rules; unknown key or invalid value → one report per run naming key, value found, and accepted values, then fall back to the default. An invalid config never aborts a session, and `verify.sh` fails on it so it cannot ship silently
- Defaults are never materialized into the file — `/specos-config` writes only what the Lead set, so an absent block and a fresh project behave identically
- Migration defined at `/specos-start`, offered only when `specos-project.yml` is absent and an old file is present: merge is mechanical, the result is printed before anything is written, both old files are deleted on approval so no project ever holds three config files, and refusal defers to the next session without repeating in this one
- One migration conflict resolved by rule: `language` exists in both old files. The `specos-standards.yml` value wins, because that is the one skills read for content today, and the choice is stated out loud rather than applied silently
- `specos-project.yml` is written in English end to end — keys, comments, and rule sentences — independently of `language.specs`. A rule is an instruction the agent follows, and instructions are followed most reliably in the language the model is strongest in; the instruction language and the output language never needed to match, so a Spanish project keeps an English config file and still produces Spanish specs
- Only rule sentences are actually affected, since keys, setting values, and ISO language codes are English or language-neutral by construction
- Two guards recorded so this does not become a trap: `/specos-config` accepts a rule in any language, translates it, and shows the English text back **before** writing — nothing is silently reworded; and a literal string a rule requires in the output (`"steps start with 'Dado que'"`) is preserved verbatim, since translating the payload would break the rule stating it
- A hand-written non-English rule is applied as written, never rejected and never ignored — `/specos-config` offers to translate it on the next run. Migration translates rules carried over from `specos-standards.yml` and reports which ones, inside the result printed for review, so the translation is approved with the merge rather than after it
- Out of Scope: per-feature and per-role overrides, settings for `init`/`start`/`split`/`group`/`status`/`help`, and merging `local-workspace.yml`
- Journeys 14 (settings), 14b (a rule, stated in Spanish and stored in English), 14c (nothing configured), 14d (migration) and 14e (invalid setting) added, plus a 42-item AC block across file, language, settings, rules, migration, and tooling
- Implemented: `specos-project.yml` template added, `specos-outputs.yml` and `specos-standards.yml` deleted
- `specos-config` rewritten around the three blocks — shows accepted values and defaults per setting, validates before writing, never materializes a default, and redirects to `/specos-start` when a project still holds the old files
- `specos-start` Step 0 added — the migration, ahead of every other step; existing steps renumbered from 0.1
- `specos-qa` reads `cases_per_ac`, `include_negative_cases`, `batch_by`; `specos-distribute` reads `diagrams`, `branch_info`, `task_title_max_words`; `specos-lead` and `specos-lead-parallel` read `max_tasks`, `max_journeys`, `require_error_journey`; `specos-dev` reads `require_tests`
- `specos-lead-parallel` passes `settings.qa` and the rules to its test case subagent, which previously had no config path at all
- `specos-init` generates `specos-project.yml` with `settings:` and `rules:` as commented examples only, so a fresh project runs entirely on documented defaults
- `specos-status` reports set settings and a count of those on default, and flags an unmigrated project
- `constitution.md` rule 5 no longer hardcodes 15 — it names `settings.lead.max_tasks` as the single source, which is the drift this setting existed to remove
- `verify.sh` extended to 52 checks with a Config section: the template exists, both old files are gone, no skill outside the migration path reads a merged file, `specos-start` carries the migration, all 10 settings are read by their owning skill, and the template ships its defaults commented out. Verified against four deliberate regressions
- README, CHEATSHEET, AGENTS.md, the generic and Cursor adapters, both agent guides, and the init and qa flow docs updated

## 2026-08-22 v2.5
- Memory links introduced — `local-workspace.yml` gains an optional `memory_links` section mapping each repo key to where that repo's agent memory lives
- Problem solved: agents scope memory per project directory, so in a separate-repo setup a session started in the specs repo cannot see what was already learned in an implementation repo, and re-explores it from scratch
- Design boundary: SpecOS does not store memory — every agent already has its own. SpecOS stores the map of where memory lives. Kept agnostic by defining the contract in the skills and leaving the path convention to each agent
- Resolution order defined: configured entry → agent's own convention → `.specos/memory.md` in the repo → none. A missing location degrades to current behaviour
- `specos-start` Step 0.5 added — maintains the map by **reconciliation**, not by a one-time question: every session compares `implementation_repos` against `memory_links` and asks only about keys that have a repo path but no value
- Three key states defined: `auto` (derive each session, recommended and self-healing), a path (verbatim, for non-standard or cross-agent setups), `off` (permanent opt-out)
- Reconciliation makes new projects, projects that predate the feature, and repos added later behave identically — no special case, and no migration step
- Guards: a key with a value is never overwritten or re-asked, at most one question per session, and the whole step is skipped for monorepos
- `session.md` vs agent memory boundary documented — portable and authoritative for the active task vs local, accumulated, and always verified before use. They coexist, they never substitute
- `specos-dev` Step 3.5 added — resolves and reads the target repo's memory before reading any source file in it; Step 6 writes durable learnings back to that repo's memory, not the specs repo's
- `specos-qa` reads repo memory before exploring and records durable findings to the repo under test
- `specos-status` reports each link as linked / auto / auto (empty) / off / unmapped / broken, without reading contents, and points at `/specos-start` when anything is unmapped or broken
- Read contract: index only, open one entry when its description matches, verify before trusting, correct when stale
- Boundary rule: memory answers *where* and *how*, the spec answers *what* and *why* — memory never authorizes code without a `spec.md`
- Out of Scope reworded — the exclusion is a SpecOS-owned memory store, not memory reuse
- Journeys 13, 13b, 13c (project older than the feature) and 13d (repo added later) added, plus a 15-item AC block for memory links
- `local-workspace.yml` schema documented in the spec; `session.md` schema corrected to drop `roles` and `implementation_repos`, which moved to `local-workspace.yml`
- `specos-init` header corrected — claimed 6 questions while asking 7; that line is also what the Gemini installer extracts as the command description
- Memory links documented in `docs/flows/03-dev.md`
- Docs corrected to 12 skills — `lead-parallel`, `config`, `status` and `help` were missing from README, AGENTS.md, CHEATSHEET and the generic adapter
- Cursor adapter completed — `split`, `group`, `config`, `lead-parallel` `.mdc` delegators added
- `adapters/claude-code/` and `adapters/opencode/` deleted — 24 unreferenced copies that had drifted from `skills/`. Both agents install straight from `skills/` and always did
- Single source rule added to the spec: `skills/` holds content, `adapters/` holds format only — a delegator, a generated artifact, or a shared section, never a copy
- Install and update verified end to end against a clean HOME for all five agents: Claude Code and OpenCode (12 skills copied), Gemini CLI (12 `.toml` generated, descriptions intact), Cursor (12 `.mdc`), Codex/Copilot (generic section with all 12 listed)
- `.gitignore` fixed — `local-workspace.yml` was not ignored in the SpecOS repo itself; `.specos/` now covers session and the memory fallback
- `verify.sh` added — release verification for the part of SpecOS that is executable. 45 checks: every skill installs to all five agents from a clean HOME, line 3 of each skill is a valid Gemini description, every skill has a Cursor delegator, no adapter duplicates a skill, installer paths resolve, `update.sh` leaves installed skills byte-identical to source, local files stay gitignored. Verified against four deliberate regressions
- `specs/specos-v3/tasks.md` removed, and `testcases.md` deliberately not created — SpecOS targets product projects, and a framework whose deliverable is Markdown prompts has no runtime to execute a test case against. The ACs already carry those expectations; a second copy would only drift
- Rule recorded in the spec and in `specs/README.md`: the two perspectives stay mandatory, but the artifact carrying the breaking perspective follows the deliverable — executable product → `testcases.md`, non-executable deliverable → whatever actually verifies it. What is never optional is that something adversarial exists and runs

## 2026-05-14 v2.4
- specos-lead-parallel.md introduced — parallel variant of specos-lead that spawns two subagents simultaneously for tasks.md and testcases.md generation
- Claude Code and OpenCode adapters now reference specos-lead-parallel.md instead of specos-lead.md
- Generic skill (specos-lead.md) remains sequential for agents without subagent support

## 2026-05-14 v2.3
- Task descriptions capped at 8 words, imperative verb first — enforced in specos-lead and specos-distribute
- Formatting rules added to specos-distribute: no trailing spaces, single blank line between sections, consistent table alignment

## 2026-05-14 v2.2
- `keywords` added to spec.md frontmatter — free-form tags for agent search across the specs repo
- `linked` added to spec.md frontmatter — explicit references to related specs for navigation and context loading

## 2026-04-21 v2.1
- Journey 11 added: `/specos-help` — lists all skills and key project files, no session required
- Journey 12 added: `/specos-status` — reads session.md and displays current state, read-only
- ACs added for `specos-help` and `specos-status` skills
- Tasks SP-26, SP-27, SP-28 added for implementation and adapters of both skills
- Spec structure updated to include `specos-help.md` and `specos-status.md` in `skills/`

## 2026-04-15 v2.0
- Roles changed from fixed identities to configurable perspectives
- Two mandatory perspectives defined: construction (Lead) and breaking (QA)
- Multiple roles per person now supported
- session.md extended with roles and implementation_repos fields
- repo_spec established as universal entry point (any folder name)
- Separate repos support added via session.md local paths
- testcases.md introduced as QA output file with free-form fields and TC-XX IDs
- tasks.md checkboxes removed — state lives in task software
- Default SP-XX IDs added to tasks, replaceable with real IDs
- Task and test case ID prefixes made configurable in specos-outputs.yml
- status field removed entirely — repo presence = approved
- specos-outputs.yml extended with team config (qa: human|agent|both) and id prefixes
- Journey 10 added: validation of implementation repo paths before session starts

## 2026-04-10 v1.0
- Initial spec created
- Covers: install.sh, 5 skills, adapters, templates, branching strategy
