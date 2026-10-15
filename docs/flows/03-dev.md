# Flow: /specos-dev

> **When to run:** Any developer picking up a task.
> **What it does:** Loads the relevant spec, shows the task's ACs, implements in full context, and closes with a block for the PR.

---

## Full conversational transcript

A backend developer picks up `TAGS-03` (limit of five tags) from the `feature-tags` spec, finds a gap, and finishes.

> **User**
> ```
> /specos-start
> ```

> **Agent**
>
> No session found. What is your task key or description?

---

> **User**
>
> TAGS-03

---

> **Agent**
>
> Found in `specs/feature-tags/tasks.md`:
> > **[TAGS-03]** Validate maximum five tags in serializer (AC3, AC8) v1.0
>
> Loading `specs/feature-tags/spec.md` (v1.0, approved). No AC of this task is pending.
>
> **Your ACs**
> - **AC3** — A post has at most 5 tags; at the 5th the field is disabled and shows "Maximum 5 tags per post"
> - **AC8** — The API answers 422 `invalid_tags` with detail "Maximum 5 tags per post" when more than 5 tags are sent
>
> **Flows that will be tested** (from the sketches): TC-02 *Tag limit blocked at 6th tag* covers AC3 · TC-04 *API rejects more than 5 tags* covers AC8.
>
> AC3's field behavior belongs to the frontend task; yours is the serializer side (AC8). Proceed?

---

> **User**
>
> yes

---

> **Agent**
>
> Implementing in `posts/serializers.py`... *(code and tests)*
>
> One thing the spec does not say: AC5 rejects a tag over 30 characters, but nothing says what the API returns for it.
>
> ```
> SPEC CHANGE REQUEST — feature-tags v1.0
> Found: the error shape for a tag over 30 chars is undefined (found during TAGS-03)
> Type: clarification
> Proposed AC: A tag over 30 characters makes the API answer 422 invalid_tags
> Options: 1) 422 invalid_tags, same as AC8   2) 400 with a field error
> ```
>
> Your role is `backend` only, so I cannot edit the spec. Hand this to the Lead. I'll keep going on AC3 and AC8, which it does not block. I'm not leaving this in `session.md` `open`: it is in this message, and the Lead needs to see it.

---

> **User**
>
> *(a day later — the Lead answered by dropping the error altogether: v1.1)* continue

---

> **Agent**
>
> Spec is v1.1. AC5 is now retired and AC11 says tags over 30 characters are truncated silently, so the request is answered by the new text. `TAGS-03` references neither — nothing to redo.
>
> Done. For the PR description:
>
> ```
> TAGS-03 · spec feature-tags v1.1 · covers AC3, AC8
> Spec changes during dev: v1.0→v1.1 (AC5 retired, AC11 added — not in this task)
> Deviations: none
> Commit message:
> feat(TAGS-03): Validate a maximum of five tags in the serializer
> ```
>
> I only show the message; I don't commit. Session saved.

---

## Notes

- The agent reads **only the spec for the active task**.
- It refuses a spec with `status: draft`, and any task whose ACs are marked `[pending]`.
- The AC refs in `tasks.md` are what it shows at the start — the task never restates them.
- On a gap, a developer without the lead role gets a request to hand over; with `lead` or `builder` the agent continues in change mode in the same session and resumes with the new AC ids.
- The closing block is printed, not written to a file — paste it into the PR or ticket. Its commit message is `type(KEY): Imperative description` (`feat`, `change`, `improvement` or `chore`); for a `[new]` task the agent asks for the key instead of inventing one.
- The agent never commits on its own.

---

## Separate repos — memory links

The transcript above shows a monorepo. When the implementation repo is separate, one extra thing happens before the agent reads any source file: it resolves that repo's **agent memory** and reads its index.

This matters because agents scope memory per project directory. Without the link, a session started in the specs repo cannot see what the agent already learned in the backend repo last week, and re-explores it from zero.

- The map lives in `local-workspace.yml` under `memory_links` — each repo key holds `auto`, a path, or `off`
- `/specos-start` maintains it by difference: it asks only about repos that have no value yet, and never re-asks
- `/specos-dev` only *resolves* — it never stops mid-task to ask. A missing key falls back to automatic derivation and is mentioned once at the end of the session
- Anything memory names is verified to still exist before the agent acts on it, and corrected when stale
- Learnings are written back to the memory of the repo they describe, not the repo the session started in

Memory answers *where* and *how*. The spec still answers *what* and *why* — nothing in memory authorizes work without a `spec.md`.

Run `/specos-status` to see the state of each link.
