# Changelog — specos-v3

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
