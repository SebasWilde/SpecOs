# Prompt 00 — Repo Setup

> Use this prompt once, when creating the specs-repo for a new project.
> Paste it into your AI and answer the questions.

---

We're going to create the specs-repo for a new project using the SpecOS methodology.

Ask me the following questions one at a time and wait for my answer before continuing:

1. What is the project name and what does it do in 2-3 lines?
2. What is the tech stack? (backend, frontend, database, infra, CI/CD)
3. How many team members are there and what are their roles?
4. What tools do you use for management and documentation? (Jira, Linear, Notion, Confluence, etc.)
5. Are there already established code conventions? (or say "none" and I'll define the basics)
6. Is there anything the agent MUST NEVER do in this project?

With those answers, generate the following:

---

### AGENTS.md
Global project context. Specific to this project — not generic.
Includes: product description, full stack, code conventions,
explicit prohibitions for the agent, and explanation of the specs structure.

### constitution.md
Non-negotiable principles adapted to the described team.
Includes: Definition of Ready, Definition of Done, and communication rules.

### specos-outputs.yml
Output configuration based on the tools the team uses.
If they use Jira + Confluence + Notion: generate those entries.
If they use other tools: adapt based on their answers.

### Folder structure and setup commands
The complete directory tree and exact commands to:
- Create the folder structure
- Create CLAUDE.md and .cursorrules symlinks pointing to AGENTS.md
- Make the first commit

---

Rules:
- AGENTS.md must be specific to this project, not a generic template
- constitution.md must reflect the level and culture of the described team
- Commands must be directly executable in the terminal
- If anything wasn't clear from the answers, ask before generating
