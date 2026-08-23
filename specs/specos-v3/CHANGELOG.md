# Changelog — specos-v3

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
