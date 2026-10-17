# specos-understand

Internal step of /specos-lead: reads specs, writes nothing, prints the plan message.

## Constraints

- Never commit or push on your own. When the Lead asks, list the files and the message first.
- In chat, say things in words: an id (A2, Q1, AC7) or a code name may follow in parentheses, never stand alone. Describe what it is before referring to it.

**Phase 1 — read-only.** Read files (existing specs too, to find conflicts) and list up to 4 open questions, only for real gaps: the questions are the Open questions block of the message, never asked separately. In this turn create or edit nothing (`session.md` included): no file tool, no shell command that writes. Print as plain chat text, in the language of the Lead's last message (headings translated; spec content stays `language.specs`):

```
What I understood
- The balance sheet shows each asset and loan against the row the client chose.
- Used by finance staff; the link is set once. Out: editing the sheet layout.
- Purpose (inferred): see which balance sheet row each asset or loan feeds.

Assumptions (I decided these; confirm or change)
A1 · The link is a mapping key that resolves to a row · alternative: store the row itself, as the client asked
A2 · One asset or loan links to one row · alternative: several rows

Open questions
Q1 · What happens to the link when its row is deleted? · my proposal: the asset keeps its data and shows "unlinked"

Plan — what I will write
- Link on assets and loans (about 6 ACs)
- Reading the link in the balance sheet (about 4 ACs)

Files I will create
- specs/32-live-balance-sheet/32-3-assets-and-loans/spec.md, tasks.md, testcases.md, CHANGELOG.md

Existing files I will modify (needs your yes)
- specs/32-live-balance-sheet/32-1-sheet/spec.md (+ its CHANGELOG) — add the link row to its layout (v1.1); today it says the layout has no link row
```

Write every assumption and question in full, with its alternative or proposal; an id never stands alone (see Constraints). Message first, then the question; nothing to list: "No assumptions, no open questions", and "none" under the modify list.

## Gates

One draft is the default. Open a gate only on a trigger, and say why in one line ("Opening a gate because …"):

| Trigger | Gate |
|---|---|
| more than 5 assumptions or 3 open questions | review by blocks of the affected parts, each with its assumptions |
| an assumption touches calculations, data model or migrations, permissions or security, money or VAT | confirm it BEFORE writing the ACs that depend on it (assumption, alternative, ACs that change) |
| the spec contradicts or makes conditional a statement of an approved spec | pause with the affected statements (what the other spec says, what becomes false) |
| more than 15 ACs or 2 journeys | propose `/specos-split` with the cut |
| the request contradicts itself | one question, the contradiction in two lines |

In new mode the Phase 1 stop already covers the second and third rows: say "Opening a gate because …" in the message and list the affected statements (what the other spec says, what becomes false) under "Existing files I will modify". Fixed gates: the Phase 1 message before writing; permission before reading implementation code (as-is) and before committing. The Lead can open any gate ("AC by AC"); `review: sections` forces sections.

**From as-is** (code read with permission): the same message. "What I understood" = how it works today; "Assumptions" = your readings of intent where the code is ambiguous; nothing to modify. Writing waits for the go-ahead.
