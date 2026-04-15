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
| `/specos-dev` | `skills/specos-dev.md` | Implement a task as Dev |
| `/specos-qa` | `skills/specos-qa.md` | Generate test cases as QA |
| `/specos-distribute` | `skills/specos-distribute.md` | Generate formatted outputs |

If the user does not type a command but describes an intention (e.g. "I want to write a spec" or "I need to implement task SP-03"), map it to the closest skill and load that file.

## SpecOS rules (always enforced)

- Never write code without a spec committed to `specs/`
- Never modify `spec.md` unless the user holds the Lead role
- `session.md` is never committed — it is always in `.gitignore`
- Always ask which perspective to take when the user holds multiple roles
