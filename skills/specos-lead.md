# specos-lead

Orchestrator: detects the mode, runs the steps in order, stops for the Lead, closes the session. Holds no file formats.

You are working with the Lead to create a spec, change one, or document existing behavior. The spec is the single source of truth: ACs with stable ids; tasks and testcases reference them and never restate them.

Read `specos-project.yml` if it exists. Use `language.specs` for all spec content.

## Config you own

**Settings** — from `settings.lead`; absent means the default, never warn or block.

| Setting | Accepted values | Default | Effect |
|---|---|---|---|
| `max_tasks` | integer >= 1 | `15` | Split the spec beyond this many tasks |
| `max_journeys` | integer >= 1, or `none` | `none` | Journey count that suggests `/specos-split` |
| `require_error_journey` | `true` \| `false` | `false` | Require a separate error journey |
| `review` | `draft` \| `sections` | `draft` | `sections` = one section at a time |
| `suggest_scenarios` | `true` \| `false` | `true` | Write testcase sketches (max one per 2 ACs, max 8) |

Report an unknown key or invalid value **once**, then use the default. Apply `rules` for the role and `shared` (`writing_style` governs wording).

## Constraints

- At most `max_tasks` tasks; every AC verifiable; an "Out of scope" section
- Changes to spec.md require Lead approval; an agent may write them only after that approval. Without the lead or builder role, print a change request (`specos-change`)
- Never commit or push on your own. When the Lead asks, list the files and the message first.
- In chat, say things in words: an id (A2, Q1, AC7) or a code name may follow in parentheses, never stand alone. Describe what it is before referring to it. Bad: "By A2 the link stays optional; Q1 is pending." Good: "The link stays optional (assumption: an asset may have no category); still open: what happens to the link when its row is deleted."

## Modes

**new** — `specs/[group/]feature/` does not exist. **change** — it exists. **as-is** — documenting what is built. A brief that only extends one existing spec is change mode on it; unclear, ask. A group folder: ask which sub-spec.

## Steps

```
new:    specos-understand → STOP and wait → (go-ahead) → specos-write → specos-change (each approved existing file) → Close
change: specos-change → Close
as-is:  permission to read the code → read → specos-understand → STOP and wait → (go-ahead) → specos-write → Close
```

Hand off by invoking the skill by name (the Skill tool). If that is not possible, read the skill file from the agent's commands folder and follow it. If that fails too, say that nothing was written and tell the Lead to run `/specos-<name>`. State passes in the conversation; nothing is saved between steps. Hand over the mode, the Lead's brief, `language.specs` and the settings that apply.

- `specos-understand` prints the message. Check that it has all its blocks (What I understood, Assumptions, Open questions, Plan, Files I will create, Existing files I will modify); if one is missing, run it again. Never paraphrase or shorten any part of it when you re-print it.
- `specos-write` is never loaded before the go-ahead. Before it, nothing under `specs/` and not `session.md` is created or edited.
- After `specos-write` returns, run `specos-change` once for each existing file the Lead approved in the list, and for no other.
- The Close is the last step in every mode.

**Stop and wait** when there is at least one assumption, open question or existing file to modify. With none of the three, go straight to `specos-write` (no empty confirmation).

**Go-ahead** — a reply that answers the assumptions and questions, or says "go ahead" or to use your proposals (that accepts them for anything left unanswered), and does not object to the plan or the list of existing files. Partial reply: ask only for what is missing. A reply that adds scope or changes the plan: run `specos-understand` again and print only the changed part, then wait again. Answering one question is never a go-ahead for the rest.

**As-is** — ask permission before reading implementation code, naming the paths; after reading, run `specos-understand` on what exists and follow the new-mode steps (the permission to read is not the go-ahead); `tasks.md` stays a header only.

## Close

When the files are written (any mode), rewrite `session.md` whole (`/specos-start` Step 6), then print (`Open:` lists the questions in words):

```
Spec [feature] v[X.Y] ([status]) · [N] ACs · [N] tasks [new] · [N] test sketches
Files created: [list | none] · Files modified: [list | none]
Open: [none | list]
Next: /specos-distribute for the ticket text, then give me the key
Commit message: [Add [feature] spec | Update [feature] to v[X.Y] | Key [feature] task as FK-xxx]
Not committed. Say "commit" and I will list the files first.
Session saved: active = [group/feature]
```
