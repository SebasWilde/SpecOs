# examples/

Complete end-to-end examples of SpecOS in action.

Use these as a reference to understand the expected level of detail
in each file before creating your first real feature.

---

## feature-tags

A complete feature from start to finish: adding tags to posts. It is the canonical demo of the v2.7 flow.

```
feature-tags/
├── spec.md              ← ACs with stable ids (AC5 retired, AC11 added in v1.1), one journey, no technical section
├── design.md            ← optional: the API contract and decisions, kept out of spec.md
├── tasks.md             ← keyed tasks and one [new] task, each with AC refs and a spec version
├── testcases.md         ← five reviewed cases and one sketch, stamped spec: v1.1
├── CHANGELOG.md         ← three-line entries: what / why / impact
└── outputs/
    ├── jira-tasks.md         ← brief tickets, as /specos-distribute prints them
    ├── confluence-page.md    ← page for Confluence
    ├── confluence-flows.md   ← Mermaid diagram of the journey
    └── steps-to-test.md      ← reviewed test cases for QA
```

**What to learn from this example:**
- ACs carry stable ids; a changed requirement retires one and adds the next free id
- `tasks.md` and `testcases.md` reference ACs and never restate them
- A change found during `TAGS-03` (closed) adds a `[new]` task instead of editing the keyed one
- A sketch (`TC-04`, no `steps:`) sits next to expanded cases — there is no status field
- `design.md` holds the how when it would crowd the spec

`/specos-status --check` on this folder reports exactly two findings, both on purpose: the unexpanded sketch (`TC-04`) and the `[new]` task still waiting for its key.

---

## check-fixture

A tiny specs repo with intentional defects, used by `verify.sh` to test `scripts/specos-check.sh`:
a spec covering every parser case (`clean-feature`), one with every warning (`broken-feature`),
an old-format spec (`legacy-feature`), and a group with a spec two levels deep (`payments/checkout`).
It is not an example to copy; `verify.sh` asserts the exact warnings it produces.

```bash
bash scripts/specos-check.sh examples/check-fixture --session examples/check-fixture/oversized-session.md
```

---

**Want to see how this was built?**
The full conversational transcripts — from `/specos-init` through `/specos-distribute` — are in [`docs/flows/`](../docs/flows/).
Each flow uses this `feature-tags` project as the example.
