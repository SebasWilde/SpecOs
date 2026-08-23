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
  /specos-distribute  Generate outputs per specos-project.yml
  /specos-split       Split a large spec into sub-specs under a group folder
  /specos-group       Group related specs under a shared parent folder
  /specos-config      Configure specos-project.yml interactively
  /specos-status      Show current session state
  /specos-help        Show this help

KEY FILES
  AGENTS.md              Global project context — read by all agents
  constitution.md        Non-negotiable rules for this project
  specos-project.yml     Everything configurable: language, team, IDs,
                         integrations, destinations, settings, rules
  local-workspace.yml    Local identity: user, roles, repo paths, memory links — never committed
  session.md             Active session state — never committed (in .gitignore)
  specs/<feature>/
    spec.md              Journeys, ACs, technical definition
    tasks.md             Subtasks by role, no checkboxes
    testcases.md         QA test cases with TC-XX IDs
    CHANGELOG.md         Spec change history
  specs/<group>/         Group folder for related specs
    spec.md              Domain summary + list of sub-specs only
    <sub-feature>/       Each sub-spec has the full structure above

Run /specos-start to begin.
```

Do not add commentary, suggestions, or extra content. Print and stop.
