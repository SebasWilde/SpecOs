# specos-help

Display all available SpecOS v3 skills and key project files. No session required.

---

## Output

Print the following exactly, substituting nothing:

```
SpecOS v3 — available commands

SKILLS
  /specos-start       Begin or resume any session — routes automatically by role
  /specos-init        First-time project setup (run once per project)
  /specos-lead        Create or update a spec collaboratively (Lead role)
  /specos-dev         Implement a task with full spec context (Dev role)
  /specos-qa          Generate test cases from a spec (QA role)
  /specos-distribute  Generate outputs per specos-outputs.yml
  /specos-status      Show current session state
  /specos-help        Show this help

KEY FILES
  AGENTS.md              Global project context — read by all agents
  constitution.md        Non-negotiable rules for this project
  specos-outputs.yml     Team config, ID prefixes, integrations
  session.md             Local session state — never committed (in .gitignore)
  specs/<feature>/
    spec.md              Journeys, ACs, technical definition
    tasks.md             Subtasks by role, no checkboxes
    testcases.md         QA test cases with TC-XX IDs
    CHANGELOG.md         Spec change history

Run /specos-start to begin.
```

Do not add commentary, suggestions, or extra content. Print and stop.
