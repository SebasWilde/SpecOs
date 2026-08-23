# SpecOS v3 — Agent instructions

> Add this section to your project's AGENTS.md (or .cursorrules, Copilot instructions, etc.)
> if your agent does not support slash commands.

---

## SpecOS skills

This project uses SpecOS v3. The following skills are available in the `skills/` folder.
When the user types one of the commands below, read the corresponding skill file and follow all instructions in it.

| Command | Skill file | When to use |
|---|---|---|
| `/specos-init` | `skills/specos-init.md` | First-time project setup |
| `/specos-start` | `skills/specos-start.md` | Start or resume any session |
| `/specos-lead` | `skills/specos-lead.md` | Build a spec + task list as Lead |
| `/specos-lead-parallel` | `skills/specos-lead-parallel.md` | Draft several related specs in one pass |
| `/specos-dev` | `skills/specos-dev.md` | Implement a task as Dev |
| `/specos-qa` | `skills/specos-qa.md` | Generate test cases as QA |
| `/specos-distribute` | `skills/specos-distribute.md` | Generate formatted outputs |
| `/specos-split` | `skills/specos-split.md` | Split a large spec into sub-specs |
| `/specos-group` | `skills/specos-group.md` | Group related specs under a parent folder |
| `/specos-config` | `skills/specos-config.md` | Configure specos-project.yml |
| `/specos-status` | `skills/specos-status.md` | Show current session state |
| `/specos-help` | `skills/specos-help.md` | List commands and key files |

If the user does not type a command but describes an intention (e.g. "I want to write a spec" or "I need to implement task SP-03"), map it to the closest skill and load that file.

## SpecOS rules (always enforced)

- Never write code without a spec committed to `specs/`
- Never modify `spec.md` unless the user holds the Lead role
- `session.md` and `local-workspace.yml` are never committed — they are always in `.gitignore`
- Always ask which perspective to take when the user holds multiple roles

## Memory links

When the project uses separate repos, each repo has its own agent memory namespace. `local-workspace.yml` maps them under `memory_links`. Each key holds `auto` (derive the location each session), a path (use verbatim), or `off` (never look).

At the start of a session, compare the repo keys that have a path in `implementation_repos` against the keys present in `memory_links`, and ask once about any key that has no value — never about a key that already has one. Skip this entirely for monorepos. At most one such question per session.

Before exploring an implementation repo, resolve its memory: a path is used verbatim; `auto` or a missing key derives from this agent's own memory-path convention, falling back to `.specos/memory.md` inside the repo when the agent has no memory system. If nothing exists there, continue without it.

Read the memory index first and open a single entry only when its description matches the task. Verify that anything memory names still exists before acting on it, and correct it when stale. Memory answers *where* and *how* — it never authorizes writing code without a `spec.md`. Write learnings back to the repo they describe, never to the repo the session started in.
