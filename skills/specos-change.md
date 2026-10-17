# specos-change

Internal step of /specos-lead: edits an existing spec and handles spec change requests.

## Constraints

- Changes to spec.md require Lead approval; an agent may write them only after that approval. Without the lead or builder role, print a change request (below)
- Never commit or push on your own. When the Lead asks, list the files and the message first.
- In chat, say things in words: an id (A2, Q1, AC7) or a code name may follow in parentheses, never stand alone. Describe what it is before referring to it.

## Change mode

Input: "change X because Y", or a change request.
1. Edit the spec: new behavior gets an AC id above every id the spec has used (retired too), a changed AC keeps its id, a removed one is retired; bump the version. A changed decision gets a new dated line under `## Decisions`; the old line stays.
2. CHANGELOG entry of at most 3 lines: what / why / impact (+ `found during <key>`).
3. Print the impact: tasks whose refs and testcases whose `covers` include a changed AC, and specs linking here (`~/.specos/specos-check.sh --impacts <feature>`).
4. `[new]` tasks only for the delta; never edit a keyed task. A change over 50% of the spec is a new feature.
5. Open questions: mark the affected ACs `[pending]`; the spec stays `approved`, only their tasks wait.

## Spec change request (for lead, dev and qa)

On a gap, classify: **clarification** (ambiguous), **addition** (new behavior, no AC), **contradiction** (an AC is wrong), **out-of-scope** (another feature: new spec or ticket).

```
SPEC CHANGE REQUEST — [feature] v[X.Y]
Found: [what, and during which task or case]
Type: clarification | addition | contradiction
Proposed AC: [text]
Options: 1) ... 2) ...
```

Role includes lead or builder: stay here, run change mode once the Lead approves the text, then resume with the new ids. Otherwise print the block for the Lead and keep working on what it does not block. A change inside an open ticket adds no task; if that ticket is closed or merged, add a `[new]` task.

When done, report the files modified; the orchestrator prints the Close.
