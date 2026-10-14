# Flow: /specos-distribute

> **When to run:** Lead, after the spec is approved (tasks), and again after QA reviews (steps to test).
> **What it does:** Prints formatted outputs ready to paste into Jira, Confluence, or any test tool. Tasks come out brief by default: they point to the spec instead of copying it.

---

## Full conversational transcript

The Lead distributes the tasks of `feature-tags`, then the QA steps and the Confluence page.

> **User**
> ```
> /specos-distribute
> ```

> **Agent**
>
> Session loaded: `active_feature: feature-tags`
>
> What do you want to generate output for?
>
> 1. Tasks — formatted for your task software
> 2. Test cases — formatted for your test tool
> 3. Confluence doc — full spec as a structured document
> 4. Flow diagrams — Mermaid diagrams for each journey

---

> **User**
>
> 1

---

### Output 1 — Tasks (`task_detail: brief`)

`tasks.md` has 12 tasks, all `[new]`. `branch_info` is `none` in this project, so there is no Dev Notes section. All roles print at once.

> **Agent**
>
> # Add tags array field to Post model
> Spec: specs/feature-tags/spec.md (v1.0) · AC7
> Array column with the migration; no separate table.
> ---
> # Expose tags in Post serializer
> Spec: specs/feature-tags/spec.md (v1.0) · AC7
> Accept and return `tags` on create and PATCH.
> ---
> # Validate maximum five tags in serializer
> Spec: specs/feature-tags/spec.md (v1.0) · AC3, AC8
> Reject more than 5 tags with 422 `invalid_tags`.
> ---
> # Build TagInput component
> Spec: specs/feature-tags/spec.md (v1.0) · AC1, AC2
> Reusable chips input; Enter and comma confirm, X removes.
>
> *(…eight more, same shape, grouped by role)*
>
> Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand.

---

> **User**
>
> TAGS-01 TAGS-02 TAGS-03 TAGS-04 TAGS-05 TAGS-06 TAGS-07 TAGS-08 TAGS-09 TAGS-10 TAGS-11 TAGS-12

---

> **Agent**
>
> `tasks.md` updated, in the order printed: `[new]` → `TAGS-01` … `TAGS-12`. AC refs and versions kept.

The Lead pastes each brief into Jira and edits nothing by hand.

---

### Output 2 — Steps to test

After the v1.1 change and QA's review (`testcases.md` stamped `spec: v1.1`):

> **User**
>
> /specos-distribute → 2

> **Agent**
>
> 5 expanded cases formatted below. TC-04 is still a sketch — not yet reviewed, run `/specos-qa` to expand it.
>
> ```
> [TC-02] Tag limit blocked at 6th tag
> Covers: AC3
> Steps:
>   1. Add 5 tags to a new post
>   2. Try to type a 6th
> Expected result: The field is disabled and shows "Maximum 5 tags per post"
> ```
> *(…four more)*
>
> MCP integration is not active in v3. Copy the output above into your test tool manually.

---

### Output 3 — Tasks again, after a change

The v1.1 change added one task, `[new] Truncate tags to 30 chars on save (AC11) v1.1`. Distribute prints **only** that one — the twelve keyed tasks are skipped.

> **Agent**
>
> # Truncate tags to 30 chars on save
> Spec: specs/feature-tags/spec.md (v1.1) · AC11
> Cut any tag over 30 characters silently before persisting.
>
> Give me the keys in order (e.g. FK-930 FK-931) and I'll replace `[new]` in tasks.md, or edit it by hand.

If the Lead gives no key, `[new]` stays in `tasks.md` and the same task is offered next time. `task_detail: full` restores the long ticket (Context, Scope, Acceptance Criteria, Standards).

---

### Output 4 — Confluence page

> **Agent**
>
> What is the Jira link for this feature? (or say TBD)

> **User**
>
> https://jira.company.com/browse/TAGS

> **Agent** prints the page from `spec.md` — summary, scope, the ten active ACs rewritten to be testable, references, and a change history that lists both versions — and says: "Copy this into Confluence manually and replace the Spec link in References."

See `examples/feature-tags/outputs/` for each output as it is saved.

---

## Notes

- Tasks are the only output that changes: brief by default, `[new]` only, all roles at once, keys replaced in order. With `outputs.tasks.destination: jira-csv` they come out as one CSV for Jira's import instead.
- Test cases, the Confluence page and the diagrams are generated as before. Sketches are listed as not yet reviewed instead of being formatted without steps.
- A spec without journeys has no diagrams; the agent says so in one line.
- Outputs are printed in session; copy them into your tool. Nothing is created in Jira for you.
