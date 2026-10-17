# specos-write

Internal step of /specos-lead: writes the files of a new spec after the Lead's go-ahead.

## Constraints

- At most `max_tasks` tasks; every AC verifiable; an "Out of scope" section
- Never commit or push on your own. When the Lead asks, list the files and the message first.
- In chat, say things in words: an id (A2, Q1, AC7) or a code name may follow in parentheses, never stand alone. Describe what it is before referring to it.

**Phase 2 — write.** Create `spec.md`, `tasks.md`, `testcases.md` sketches, `CHANGELOG.md` (`design.md` if needed). A confirmed assumption becomes a dated line under `## Decisions` (the Lead's changed choice, if any); a rejected one disappears; Decisions holds only what the Lead confirmed. `status: approved` only if every assumption and question was answered or the Lead said to use your proposals; otherwise `draft`, with the rest under `## Assumptions` / `## Open questions`.
- Before the go-ahead nothing under `specs/` is created or edited.
- An existing spec is not edited here: list it for the orchestrator, which runs `specos-change` on it (version bump, 3-line CHANGELOG, impact list) only if it was listed under "Existing files I will modify" and the Lead said yes; the `[new]` tasks go in the new spec's `tasks.md`, not in the edited one. If an approved spec would point at a spec still `draft`, say so on that line.

**spec.md** — frontmatter `feature`, `version: 1.0`, `status`, `lead`, `date`, `keywords`, `linked`. Then: summary (max 3 lines, ~50 words) with a one-line `Purpose:` (unclear: infer it, mark "(inferred)", and show it under "What I understood"), Acceptance Criteria, Out of Scope, `## Assumptions` (`A1 — assumed X. Alternative: Y.`, same ids as the chat, only while draft), Open questions, Decisions. Omit empty sections. `approved` only when Assumptions and Open questions are empty or removed and the Lead confirmed.
- ACs: `- AC1 — text`, one condition and one observable outcome (~40 words; detail in an example AC), by theme. Ids are never renumbered or reused; a removed AC stays as `- AC7 — retired (v1.2): reason`.
- Journeys only for a multi-step flow across screens or actors, with the reason; failure behavior is ACs. Calculations and contracts go in `design.md`.

**tasks.md** — by role, no checkboxes, no state: `- [new] Imperative title, max 8 words (AC1–AC3) v1.0`; keyed `- [FK-927] Title (AC1–AC11) v1.0`. One task = one person, one PR. Leave an old `[SP-01]` as is; `/specos-distribute` asks before treating it as new.

**testcases.md** — sketches only: header `> Sketches suggested by Lead, not reviewed.`, then `## TC-01 — title` and `covers: AC5, AC6`; no steps. **CHANGELOG.md** — `## [date] — v1.0`, one line.

**Sections** — `review: sections` makes Phase 2 write one section at a time, each approved.

From as-is: describe what exists as ACs, `tasks.md` a header only.

When done, report the files created and the files modified; the orchestrator prints the Close.
