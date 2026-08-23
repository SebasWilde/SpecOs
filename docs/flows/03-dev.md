# Flow: /specos-dev

> **When to run:** Any developer picking up a task.
> **What it does:** Loads the relevant spec, confirms the task scope, and implements in full context.

---

## Full conversational transcript

This transcript shows a backend developer picking up task `TAGS-01` (add `tags` field to the Post model) from the `feature-tags` spec.

---

> **User**
> ```
> /specos-start
> ```

> **Agent**
>
> No session found. Let me get some context.
>
> What is your role on this project?
>
> 1. Lead
> 2. Backend dev
> 3. Frontend dev
> 4. QA
> 5. Full-stack / builder

---

> **User**
>
> 2 — backend dev

---

> **Agent**
>
> What task are you picking up? Provide the task ID (e.g., `SP-01` or `TAGS-01`) or describe it briefly.

---

> **User**
>
> TAGS-01

---

> **Agent**
>
> Loading spec for `TAGS-01`...
>
> Found in `specs/feature-tags/tasks.md`:
> > **[TAGS-01]** Add `tags` field as ArrayField to the Post model (migration included)
>
> Loading `specs/feature-tags/spec.md`...
>
> ---
>
> **Context loaded. Here is your task scope:**
>
> **Task:** TAGS-01 — Add `tags` field as ArrayField to the Post model (migration included)
>
> **Relevant acceptance criteria:**
> - Tags are saved in lowercase regardless of the user's input *(normalization is backend responsibility)*
> - Tags are saved when publishing or updating the post
>
> **Data model from spec:**
> ```
> Post (existing table — add field):
>   tags: ArrayField(CharField(max_length=30), max_length=5, default=list)
> No separate table — tags live in the post as an array.
> ```
>
> **Technical decision (from spec):**
> - Array instead of separate table: tags are simple strings with no relationships.
> - Backend normalizes to lowercase (not the frontend).
>
> **Out of scope for this task:**
> - Serializer validation (TAGS-02, TAGS-03)
> - Normalization logic (TAGS-04)
> - Deduplication logic (TAGS-05)
>
> Ready to implement. Shall I proceed?

---

> **User**
>
> yes, go ahead

---

> **Agent**
>
> Implementing TAGS-01.
>
> **Step 1 — Add the field to the model**
>
> In `posts/models.py`:
> ```python
> from django.contrib.postgres.fields import ArrayField
> from django.db import models
>
> class Post(models.Model):
>     # ... existing fields ...
>     tags = ArrayField(
>         models.CharField(max_length=30),
>         size=5,
>         default=list,
>         blank=True,
>     )
> ```
>
> **Step 2 — Create the migration**
>
> ```bash
> python manage.py makemigrations posts --name="add_tags_to_post"
> ```
>
> This generates `posts/migrations/0005_add_tags_to_post.py` (number depends on your existing migrations).
>
> **Step 3 — Apply locally**
>
> ```bash
> python manage.py migrate
> ```
>
> **Step 4 — Verify**
>
> ```bash
> python manage.py shell
> >>> from posts.models import Post
> >>> p = Post.objects.first()
> >>> p.tags
> []
> >>> p.tags = ["django", "python"]
> >>> p.save()
> >>> Post.objects.get(pk=p.pk).tags
> ['django', 'python']
> ```
>
> ---
>
> TAGS-01 complete. The field is in place with the correct constraints.
>
> **Normalization and deduplication are NOT in this task** — those are TAGS-04 and TAGS-05. Do not add that logic here.
>
> Session updated: `task_id: TAGS-01`, `active_feature: feature-tags`.

---

> **User**
>
> the migration number on my project would be 0003, not 0005 — that's fine right?

---

> **Agent**
>
> Yes, completely fine. Django generates migration numbers sequentially based on your existing migrations. The number itself doesn't matter — what matters is that it comes after all existing migrations for the `posts` app, which it will automatically.

---

## Notes

- The agent reads **only the spec for the active task**. It does not load unrelated specs.
- Scope boundaries are explicit — the agent calls out what is NOT part of the current task and references the task IDs where that work belongs.
- If the spec is ambiguous or missing a detail the dev needs, the agent stops and asks the Lead to update the spec rather than inventing requirements.
- Session is saved at the end so the next `/specos-start` picks up from `TAGS-01` / `feature-tags` automatically.

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
