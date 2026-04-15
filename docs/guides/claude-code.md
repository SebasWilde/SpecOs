# SpecOS v3 — Claude Code Guide

> Complete guide for using SpecOS with Claude Code, from first install to distributing outputs.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (`claude` available in your terminal)
- A git repo for your project (can be empty)
- macOS or Linux

---

## Part 1 — One-time install (per machine)

Run the installer from the SpecOS repo root:

```bash
curl -fsSL https://raw.githubusercontent.com/SebasWilde/SpecOs/main/install.sh | bash
```

The installer detects Claude Code automatically and copies the 6 skill files to `~/.claude/commands/`:

```
~/.claude/commands/
├── specos-init.md
├── specos-start.md
├── specos-lead.md
├── specos-dev.md
├── specos-qa.md
└── specos-distribute.md
```

It also creates two symlinks in the SpecOS repo root:
- `CLAUDE.md → AGENTS.md` (Claude Code reads CLAUDE.md automatically)
- `.cursorrules → AGENTS.md` (for Cursor users on the same repo)

**Verify the install:**

```bash
ls ~/.claude/commands/specos-*.md
```

You should see all 6 files. If you see them, skills are ready to use from any Claude Code session.

---

## Part 2 — Per-repo setup: /specos-init

> Run once per project. From the root of the project repo.

Open Claude Code in your project directory:

```bash
cd your-project
claude
```

Then run:

```
/specos-init
```

Claude Code will ask you 6 questions, one at a time:

| # | Question | Example answer |
|---|----------|----------------|
| 1 | Project name | `TaskManager Pro` |
| 2 | Tech stack | `Django + React + PostgreSQL` |
| 3 | Team composition | `2` (small team) |
| 4 | Your roles | `lead, backend` |
| 5 | Repo structure | `1` (monorepo) |
| 6 | Impl. repo paths | *(skipped for monorepo)* |

After all answers, it generates:

```
your-project/
├── AGENTS.md           ← commit this
├── constitution.md     ← commit this
├── specos-outputs.yml  ← commit this
├── specs/              ← commit this (empty)
└── .gitignore          ← updated with session.md
```

Commit the generated files:

```bash
git add AGENTS.md constitution.md specos-outputs.yml specs/ .gitignore
git commit -m "chore: initialize SpecOS v3"
```

> See the full conversational flow at [`docs/flows/01-init.md`](../flows/01-init.md)

---

## Part 3 — Every session: /specos-start

Start every session with:

```
/specos-start
```

Claude Code reads `session.md` silently (if it exists) and routes you to the right skill automatically.

**First session** (no `session.md` yet): the agent asks your role and what you're working on.

**Subsequent sessions**: the agent resumes where you left off — no questions asked.

---

## Part 4 — Lead: writing a spec

After `/specos-start`, if your role is `lead`, you'll be routed to `/specos-lead`.

The agent builds the spec **section by section**, waiting for your approval at each step:

1. Feature summary
2. User journeys (happy paths + error cases)
3. Acceptance Criteria
4. Out of Scope
5. Technical section *(optional)*
6. Tasks grouped by role

At the end, it writes:
- `specs/[feature-name]/spec.md`
- `specs/[feature-name]/tasks.md`
- `specs/[feature-name]/CHANGELOG.md`

> See the full conversational flow at [`docs/flows/02-lead.md`](../flows/02-lead.md)

**Tips for Claude Code:**
- You can run `/specos-lead` directly if you already know you want to write a spec.
- Claude Code keeps the full conversation in context — you can scroll back to review proposals.
- Use `Esc` to interrupt if the agent produces a section you want to rewrite entirely.

---

## Part 5 — Dev: implementing a task

```
/specos-start
```

Provide your task ID (e.g., `SP-01` or `TAGS-01`). The agent:
1. Finds the task in `specs/*/tasks.md`
2. Loads only the relevant `spec.md`
3. Shows you the exact scope and relevant ACs
4. Implements in that context

> See the full conversational flow at [`docs/flows/03-dev.md`](../flows/03-dev.md)

**Tips for Claude Code:**
- Claude Code can read and edit implementation files directly. The agent will navigate to the right files based on `AGENTS.md` paths.
- If the spec is ambiguous, the agent will stop and tell you — escalate to the Lead rather than guessing.
- Session is saved after each task so `/specos-start` the next day picks up automatically.

---

## Part 6 — QA: generating test cases

```
/specos-start
```

Select role `QA`, provide the feature name. The agent:
1. Loads the spec
2. Proposes test cases in batches (one per journey or AC group)
3. Waits for approval before the next batch
4. Writes `specs/[feature]/testcases.md`

> See the full conversational flow at [`docs/flows/04-qa.md`](../flows/04-qa.md)

**Tips for Claude Code:**
- You can add custom fields to test cases (e.g., `priority`, `environment`, `automation`) — the agent accepts any free-form fields.
- If `qa: agent` is set in `specos-outputs.yml`, Claude Code takes the breaking perspective automatically without needing prompting.

---

## Part 7 — Distribute: generating outputs

```
/specos-distribute
```

The agent generates formatted outputs ready to paste:

| Output | Destination |
|--------|-------------|
| Jira tasks | One block per task, copy into Jira as subtasks |
| Confluence doc | Structured page, paste into your Confluence space |
| Steps to test | QA checklist, paste into your test management tool |

All outputs are saved to `specs/[feature]/outputs/` and printed in-session.

> See the full output format at [`docs/flows/05-distribute.md`](../flows/05-distribute.md)

---

## Uninstalling

To remove SpecOS skills from Claude Code (and all other detected agents):

```bash
bash uninstall.sh
```

This removes `~/.claude/commands/specos-*.md` and the repo symlinks. Project files (`AGENTS.md`, `specs/`, etc.) are not touched.

---

## Quick reference

| Command | Who | When |
|---------|-----|------|
| `bash install.sh` | Everyone | Once per machine |
| `/specos-init` | Lead | Once per repo |
| `/specos-start` | Everyone | Every session |
| `/specos-lead` | Lead | New feature |
| `/specos-dev` | Dev | Pick up a task |
| `/specos-qa` | QA | After spec approved |
| `/specos-distribute` | Lead | Before pushing to Jira/Confluence |
| `bash uninstall.sh` | Anyone | Remove SpecOS from machine |
