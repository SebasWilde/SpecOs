# Meta — How to Create an Output Prompt

> Use this prompt when you need a new output prompt
> for a tool that's not in the collection.
> Examples: Linear, Trello, GitHub Issues, Slack, Notion CSV, briefing email.

---

I need to create a new output prompt for SpecOS.

A SpecOS output prompt works like this:
- **AUTO mode:** if given a `spec.md` (and optionally `tasks.md`), generates without asking
- **INTERACTIVE mode:** if given nothing, asks questions one at a time
- Has a specific and consistent output format
- Has explicit rules that control the behavior
- Is triggered with a command like `/command-name`

Ask me the following questions one at a time:

1. What tool or format is the output for?
   (e.g. Linear, Trello, GitHub Issues, CSV for Notion, Slack, briefing email)

2. What command do you want to trigger it with?
   (e.g. `/linear-task`, `/github-issue`, `/briefing`)

3. What information from `spec.md` would it use in AUTO mode?
   (e.g. journeys, ACs, technical section, out of scope, title)

4. What additional information would it need that's not in the spec?
   (e.g. assignee, priority, sprint, label — these would be the interactive mode questions)

5. What is the exact output format?
   (describe how you want it to look or paste an example)

6. Are there any specific output rules?
   (e.g. always in English, maximum N characters, certain fields are optional)

---

With those answers I'll generate the complete prompt ready to save in
`prompts/outputs/output-[tool].md` and add to `specos-outputs.yml`.

The generated prompt will follow the same pattern as the other SpecOS prompts
to keep it consistent with the system.
