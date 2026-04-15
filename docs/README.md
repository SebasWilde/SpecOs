# docs/

Reference documentation for SpecOS v3.

---

## Guides

Step-by-step setup and usage guides for each supported agent.

| Guide | Agent |
|-------|-------|
| [Claude Code](guides/claude-code.md) | Claude Code CLI / desktop / IDE |
| [OpenCode](guides/opencode.md) | OpenCode |

---

## Flows

Conversational transcripts showing the real back-and-forth for each skill.
All flows use the `feature-tags` example project (see `examples/feature-tags/`).

| Flow | Skill | What it shows |
|------|-------|---------------|
| [01 — init](flows/01-init.md) | `/specos-init` | 6-question setup, files generated |
| [02 — lead](flows/02-lead.md) | `/specos-lead` | Spec built section by section, approval loop |
| [03 — dev](flows/03-dev.md) | `/specos-dev` | Task picked up, implemented with spec context |
| [04 — qa](flows/04-qa.md) | `/specos-qa` | Test cases generated batch by batch |
| [05 — distribute](flows/05-distribute.md) | `/specos-distribute` | Jira tasks, Confluence doc, and QA steps generated |

---

## How to use these docs

- **New to SpecOS?** Start with the guide for your agent, then read flow 01 and 02.
- **Dev picking up a task?** Read flow 03.
- **QA generating test cases?** Read flow 04.
- **Ready to push to Jira/Confluence?** Read flow 05 to see exactly what output to expect.
