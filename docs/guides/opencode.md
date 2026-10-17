# SpecOS v3 — OpenCode Guide

> Complete guide for using SpecOS with OpenCode, from first install to distributing outputs.

---

## Prerequisites

- [OpenCode](https://opencode.ai) installed (`opencode` available in your terminal)
- A git repo for your project (can be empty)
- macOS or Linux

---

## Part 1 — One-time install (per machine)

Run the installer from the SpecOS repo root:

```bash
curl -fsSL https://raw.githubusercontent.com/SebasWilde/SpecOs/main/install.sh | bash
```

The installer detects OpenCode automatically and copies the 14 skill files to `~/.config/opencode/commands/`:

```
~/.config/opencode/commands/
├── specos-init.md
├── specos-start.md
├── specos-lead.md
├── specos-understand.md
├── specos-write.md
├── specos-change.md
├── specos-dev.md
├── specos-qa.md
├── specos-distribute.md
├── specos-split.md
├── specos-group.md
├── specos-config.md
├── specos-status.md
└── specos-help.md
```

It also creates two symlinks in the SpecOS repo root:
- `CLAUDE.md → AGENTS.md`
- `.cursorrules → AGENTS.md`

These symlinks ensure that whatever agent reads the repo, it sees the same project context.

**Verify the install:**

```bash
ls ~/.config/opencode/commands/specos-*.md
```

You should see all 14 files. If you see them, skills are ready to use from any OpenCode session.

---

## Part 2 — Per-repo setup: /specos-init

> Run once per project. From the root of the project repo.

Open OpenCode in your project directory:

```bash
cd your-project
opencode
```

Then run:

```
/specos-init
```

OpenCode will ask you 6 questions, one at a time:

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
├── specos-project.yml  ← commit this
├── specs/              ← commit this (empty)
└── .gitignore          ← updated with session.md
```

Commit the generated files:

```bash
git add AGENTS.md constitution.md specos-project.yml specs/ .gitignore
git commit -m "chore: initialize SpecOS v3"
```

> See the full conversational flow at [`docs/flows/01-init.md`](../flows/01-init.md)

---

## Part 3 — Every session: /specos-start

Start every session with:

```
/specos-start
```

OpenCode reads `session.md` silently (if it exists) and routes you to the right skill automatically.

**First session** (no `session.md` yet): the agent asks your role and what you're working on.

**Subsequent sessions**: the agent resumes where you left off — no questions asked.

---

## Part 4 — Lead: writing a spec

After `/specos-start`, if your role is `lead`, you'll be routed to `/specos-lead`.

Explain the feature freely. The agent asks 0–4 questions, only for real gaps, then writes **one draft**:

- `specs/[feature-name]/spec.md` — ACs with stable ids, out of scope, open questions
- `specs/[feature-name]/tasks.md` — tasks as `[new]`, each referencing its ACs
- `specs/[feature-name]/testcases.md` — sketches only
- `specs/[feature-name]/CHANGELOG.md`

In chat you only see the open questions and the assumptions the agent made for you. Answer them and the spec becomes `approved`. To change a spec later, say "change X because Y" — the agent bumps the version, writes the CHANGELOG entry and lists what is affected.

> See the full conversational flow at [`docs/flows/02-lead.md`](../flows/02-lead.md)

**Tips for OpenCode:**
- You can run `/specos-lead` directly if you already know you want to write a spec.
- OpenCode renders markdown inline — the spec proposals will display cleanly with headers and lists.
- To revise a section, type your change directly (e.g., "change the limit to 10 tags") and the agent will update and re-propose.

---

## Part 5 — Dev: implementing a task

```
/specos-start
```

Provide your task key (e.g., `TAGS-01`). The agent:
1. Finds the task in `specs/*/tasks.md`
2. Loads only the relevant `spec.md` (it refuses a draft)
3. Shows you the task's ACs and the flows that will be tested
4. Implements in that context, and closes with a block for your PR

> See the full conversational flow at [`docs/flows/03-dev.md`](../flows/03-dev.md)

**Tips for OpenCode:**
- OpenCode can open and edit files directly from the session. The agent will navigate to the correct implementation files.
- If the spec has a gap, the agent stops and writes a spec change request — hand it to the Lead rather than guessing.
- Session is saved after each task so `/specos-start` the next day picks up automatically.

---

## Part 6 — QA: generating test cases

```
/specos-start
```

Select role `QA`, provide the feature name. The agent:
1. Loads the spec
2. Loads the Lead's sketches and expands them into test cases in batches
3. Shows the draft in chat before writing anything
4. Writes `specs/[feature]/testcases.md` with a `spec: vX.Y` stamp

> See the full conversational flow at [`docs/flows/04-qa.md`](../flows/04-qa.md)

**Tips for OpenCode:**
- You can add custom fields to test cases (e.g., `priority`, `environment`, `automation`) — the agent accepts any free-form fields.
- If `qa: agent` is set in `specos-project.yml`, OpenCode takes the breaking perspective automatically.

---

## Part 7 — Distribute: generating outputs

```
/specos-distribute
```

The agent generates formatted outputs ready to paste:

| Output | Destination |
|--------|-------------|
| Tasks | Brief `[new]` tickets that point to the spec; give back the keys and `tasks.md` is updated |
| Confluence doc | Structured page, paste into your Confluence space |
| Steps to test | Reviewed test cases, paste into your test management tool |

All outputs are printed in-session.

> See the full output format at [`docs/flows/05-distribute.md`](../flows/05-distribute.md)

---

## Uninstalling

To remove SpecOS skills from OpenCode (and all other detected agents):

```bash
bash uninstall.sh
```

This removes `~/.config/opencode/commands/specos-*.md` and the repo symlinks. Project files (`AGENTS.md`, `specs/`, etc.) are not touched.

---

## Quick reference

| Command | Who | When |
|---------|-----|------|
| `bash install.sh` | Everyone | Once per machine |
| `/specos-init` | Lead | Once per repo |
| `/specos-start` | Everyone | Every session |
| `/specos-lead` | Lead | New feature |
| `/specos-dev` | Dev | Pick up a task |
| `/specos-qa` | QA | After the Lead's sketches exist |
| `/specos-distribute` | Lead | Before pushing to Jira/Confluence |
| `bash uninstall.sh` | Anyone | Remove SpecOS from machine |
