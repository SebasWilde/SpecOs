# examples/

Complete end-to-end examples of SpecOS in action.

Use these as a reference to understand the expected level of detail
in each file before creating your first real feature.

---

## feature-tags

A complete feature from start to finish: adding tags to posts.

```
feature-tags/
├── spec.md              ← complete spec with journeys, ACs, and technical section
├── tasks.md             ← tasks by role, all completed [x]
├── CHANGELOG.md         ← spec change history
└── outputs/
    ├── confluence-page.md    ← generated page for Confluence
    ├── confluence-flows.md   ← generated Mermaid diagrams
    ├── jira-tasks.md         ← generated tasks for Jira
    └── steps-to-test.md      ← generated test cases for QA
```

**What to learn from this example:**
- How to write verifiable ACs (not descriptive)
- How to define out of scope clearly
- How to include the technical section without over-documenting
- What the output of each prompt looks like when applied to a real spec

**Want to see how this was built?**
The full conversational transcripts — from `/specos-init` through `/specos-distribute` — are in [`docs/flows/`](../docs/flows/).
Each flow uses this `feature-tags` project as the example.
