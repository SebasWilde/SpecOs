# specs/

This folder contains your project features.

Each feature has its own folder:

```
[feature-name]/
├── spec.md        ← everything: journeys + ACs + technical
├── tasks.md       ← subtasks by role
├── testcases.md   ← QA test cases with TC-XX IDs
└── CHANGELOG.md   ← spec change history
```

Features can also be nested under a group folder, where the group's `spec.md` carries
`type: group` and holds only a domain summary and a list of sub-specs.

To create a feature, run `/specos-lead`. See `examples/feature-tags/` for a complete
end-to-end example.

---

## About `specos-v3/`

That folder is the spec for **SpecOS itself** — the framework in this repo, not a product
feature. It intentionally has only `spec.md` and `CHANGELOG.md`.

SpecOS is designed for product projects: work that ships behavior a QA can execute against.
A framework whose deliverable is Markdown prompts has no runtime, so `tasks.md` and
`testcases.md` would be ceremony with no reader — a `TC` whose expected result is "the agent
asks the right question" is not executable, and its ACs already say the same thing.

The breaking perspective still applies here; it just takes the form the deliverable allows.
For this repo that is `verify.sh`, which tests the part that *is* executable: `install.sh`,
`update.sh`, and the contracts between them and `skills/`.

Do not generate `tasks.md` or `testcases.md` for `specos-v3/`. Their absence is a decision.
