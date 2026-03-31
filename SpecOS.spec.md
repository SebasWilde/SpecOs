---
feature: specos-framework
version: 1.0
status: approved
lead: TBD
date: 2026-03-26
---

# SpecOS — Framework Spec

## What it does and why it exists

SpecOS defines how product teams collaborate with AI agents using a single source of truth: the specs-repo. It exists because teams that adopt AI without a defined process end up with duplicated context, rework from unclear criteria, and knowledge that disappears with team turnover.

---

## User Journeys

### Journey 1 — Lead starts a new feature
1. The lead describes the feature in natural language
2. With the AI, builds spec.md collaboratively (section by section)
3. The AI proposes, the lead validates and adjusts before continuing
4. spec.md is approved with journeys, ACs, technical section, and metadata
5. In the same session, they build tasks.md together
6. The lead pushes to the specs-repo

### Journey 2 — A team member starts their work
1. The dev opens their preferred AI tool
2. Pastes spec.md + their specific task from tasks.md
3. Implements with the agent
4. Marks the task as [x] in tasks.md
5. Opens PR with reference to the Jira task

### Journey 3 — Generate outputs for team tools
1. The lead takes spec.md + tasks.md
2. Uses the corresponding output prompts
3. Generates the Confluence doc, Jira tasks, and Notion test cases
4. Copies and pastes into each tool (manual mode v1.0)

### Journey 4 — A new team adopts SpecOS
1. The lead uses prompt 00-repo-setup.md
2. The AI asks questions about the project, stack, and team
3. Generates AGENTS.md, constitution.md, and folder structure
4. The lead adapts output prompts with the meta-prompt
5. First feature: uses the collaborative session prompt

### Journey 5 — The spec changes during development
1. The dev finds an uncovered case
2. Notifies the lead
3. The lead updates spec.md with the new version
4. Adds an entry to CHANGELOG.md with the reason
5. The team continues with the updated spec

### Journey 6 — Adapt SpecOS to another project
1. The team reviews existing output prompts
2. Decides which tools they use (e.g. Linear instead of Jira)
3. Uses meta/how-to-create-output-prompt.md to generate new prompts
4. Saves them in their own prompts/outputs/ folder

---

## Acceptance Criteria

### spec.md
- [ ] Has header with feature, version, status, lead, and date
- [ ] Contains at least 1 complete journey (happy path)
- [ ] Contains at least 1 error journey
- [ ] All ACs are verifiable without interpretation
- [ ] Has technical section with API contracts if applicable
- [ ] Has out of scope with at least 1 item
- [ ] Does not exceed 150 lines (if over, split it)
- [ ] Has approval checklist at the bottom (deleted when approved)

### tasks.md
- [ ] Tasks grouped by role: Backend / Frontend / QA
- [ ] No more than 15 total tasks
- [ ] Each task is testable in isolation
- [ ] Format: `- [ ] concrete description`

### CHANGELOG.md
- [ ] Exists in each feature folder
- [ ] Each change has date, description, and reason

### Prompts
- [ ] 00-repo-setup.md generates complete structure interactively
- [ ] 01-collaborative-session.md builds spec section by section without generating everything at once
- [ ] Output prompts work in auto mode (with spec) and interactive mode (without spec)
- [ ] Meta-prompt generates new prompts compatible with SpecOS

---

## Out of Scope (v1.0)

- Automated output agent with MCP
- Automatic AI Spec Review
- Domain-specific spec templates
- Automatic feature retrospective
- Weekly health check of the specs-repo
- Automatic onboarding
- Spec Diff between versions
- Analytics dashboard
- CLI `npx create-specos`
- PM/PO RAG

---

## Technical Section

### Repo structure
See README.md — section "Repo structure"

### Modes of operation
- **Manual (v1.0):** prompts the lead copies and pastes into their AI
- **Agentic (v2.0):** agent with MCP that executes outputs automatically

### Agent compatibility
AGENTS.md is compatible with Claude Code (CLAUDE.md), Cursor (.cursorrules),
GitHub Copilot, Gemini CLI, and any tool that supports context files.

---

## Future Improvements (v2.0+)

- [ ] Output agent with MCP for Jira, Confluence, Notion
- [ ] Automatic AI Spec Review
- [ ] Domain templates (auth, integration, migration, CRUD)
- [ ] Automatic retrospective when all tasks close
- [ ] Weekly health check of the specs-repo
- [ ] Automatic onboarding for new team members
- [ ] Spec Diff between versions
- [ ] CLI `npx create-specos my-project`
- [ ] Analytics: Spec Quality Score, timing prediction, evolved DORA metrics
- [ ] PM/PO RAG over the full specs-repo
