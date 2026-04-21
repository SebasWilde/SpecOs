# Tasks — specos-v3

## Git setup
- [SP-01] Create branch `v2` from current `main` to freeze v2
- [SP-02] Create branch `v3-dev` from `main` for all v3 work

## Repository cleanup
- [SP-03] Remove or archive `prompts/` folder — replaced by `skills/`
- [SP-04] Update root `.gitignore` to include `.specos/session.md`
- [SP-05] Move this spec to `specs/specos-v3/` in `v3-dev` branch

## Skills
- [SP-06] Write `skills/specos-init.md` — 6-question setup, generates AGENTS.md + constitution.md + specos-outputs.yml
- [SP-07] Write `skills/specos-start.md` — reads session.md or asks by role, handles perspective selection, validates repo paths
- [SP-08] Write `skills/specos-lead.md` — collaborative spec + tasks, SP-XX IDs, real ID collection
- [SP-09] Write `skills/specos-dev.md` — task selection, loads only relevant spec, writes to implementation repo
- [SP-10] Write `skills/specos-qa.md` — generates testcases.md collaboratively, TC-XX IDs, free-form fields, output generation
- [SP-11] Write `skills/specos-distribute.md` — generates outputs per specos-outputs.yml config

## Adapters
- [SP-12] Write `adapters/claude-code/` — slash command format for `.claude/commands/`
- [SP-13] Write `adapters/opencode/` — format for `.opencode/`
- [SP-14] Write `adapters/cursor/` — format for `.cursor/rules/`
- [SP-15] Write `adapters/generic/` — AGENTS.md fallback for Codex, Kiro, Antigravity, Windsurf, Copilot

## Templates
- [SP-16] Write `AGENTS.md` template — project map, structure, rules summary, implementation repo paths
- [SP-17] Write `constitution.md` template — 8 rules including construction + breaking perspectives, English default
- [SP-18] Write `specos-outputs.yml` template — team config (qa: human|agent|both), ID prefixes (SP, TC), integrations disabled by default

## install.sh
- [SP-19] Write `install.sh` — OS detection, agent detection, skills copy, symlinks, confirmation message
- [SP-20] Test `install.sh` on macOS
- [SP-21] Test `install.sh` on Ubuntu

## Documentation
- [SP-22] Update `README.md` for v3 — new philosophy, structure, quickstart with curl command, branching note
- [SP-23] Update `CHEATSHEET.md` — v3 commands and perspective flows for all roles
- [SP-24] Update root `AGENTS.md` to reflect v3 structure

## Examples
- [SP-25] Update `examples/` with a complete v3 end-to-end example — new skill format, testcases.md, tasks.md without checkboxes

## Help and status skills
- [SP-26] Write `skills/specos-help.md` — lists all commands and key project files, no session required
- [SP-27] Write `skills/specos-status.md` — reads session.md and displays current state, read-only
- [SP-28] Add adapters for `specos-help` and `specos-status` to claude-code, opencode, cursor, and generic
