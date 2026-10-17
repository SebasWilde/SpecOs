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
  /specos-lead        Create, change or document a spec (Lead role)
  /specos-understand  Internal, via /specos-lead (plan message)
  /specos-write       Internal, via /specos-lead (writes specs)
  /specos-change      Internal, via /specos-lead (edits a spec)
  /specos-dev         Implement a task with its spec context (Dev role)
  /specos-qa          Expand testcase sketches into test cases (QA role)
  /specos-distribute  Generate outputs per specos-project.yml
  /specos-split       Split a large spec into sub-specs under a group folder
  /specos-group       Group related specs under a shared parent folder
  /specos-config      Configure specos-project.yml interactively
  /specos-status      Show session state (--check: spec checks)
  /specos-help        Show this help

KEY FILES
  AGENTS.md              Global project context — read by all agents
  constitution.md        Non-negotiable rules for this project
  specos-project.yml     Everything configurable: language, team, IDs,
                         integrations, destinations, settings, rules
  local-workspace.yml    Local identity: user, roles, repo paths, memory links — never committed
  session.md             Active session state — never committed (in .gitignore)
  specs/<feature>/
    spec.md              ACs with stable ids, out of scope, open questions
    tasks.md             Tasks: [new] or [KEY], AC refs, no state
    testcases.md         Sketches and test cases (TC-XX) covering ACs
    CHANGELOG.md         Spec change history
    design.md            Optional — the how
  specs/<group>/         Group folder for related specs
    spec.md              Domain summary + list of sub-specs only
    00-architecture.md   Optional — shared context
    <sub-feature>/       Each sub-spec has the full structure above

Run /specos-start to begin.
```

Do not add commentary, suggestions, or extra content. Print and stop.
