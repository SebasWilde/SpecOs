# AGENTS.md — [Project Name]

> This file is automatically read by Claude Code, Cursor, Copilot,
> Gemini CLI and any compatible agent. It defines the global project context.
> Update it whenever the stack or team conventions change.

---

## Project context

[2-3 lines about what the product does and who it's for]

---

## Tech stack

- **Backend:** [framework, language, version]
- **Database:** [engine and version]
- **Queue / jobs:** [if applicable]
- **Frontend:** [framework and version]
- **Infra:** [cloud, containers, etc.]
- **CI/CD:** [tool]

---

## Code conventions

- [Language]: [style, linting, formatter]
- Tests: [framework, minimum expected coverage]
- Commits: conventional commits — `feat/fix/chore/docs/refactor`
- PRs: always reference the Jira task — `PROJ-XX #done` in the message

---

## What the agent MUST NEVER do

- Never change the database schema without creating a migration
- Never add dependencies without updating the dependencies file
- Never commit directly to `main` or `master`
- Never use `print()` or `console.log()` instead of the logging system
- [add project-specific rules]

---

## Specs structure

Each feature has its own folder in `/specs/[feature-name]/` with:
- `spec.md` — everything: journeys, ACs, technical section
- `tasks.md` — subtasks by role: Backend / Frontend / QA
- `CHANGELOG.md` — spec change history

Working prompts are in `/prompts/`.
Reference examples are in `/examples/`.

---

## Team and roles

- **Lead:** [name] — writes specs, approves PRs, generates outputs
- **Backend:** [name/s] — implements API and business logic
- **Frontend:** [name/s] — implements UI and validations
- **QA:** [name/s] — writes and executes test cases
