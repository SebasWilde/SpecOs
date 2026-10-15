# check-fixture

Intentional defects for `scripts/specos-check.sh`. `verify.sh` runs the script here and asserts every warning below — change a spec in this folder and `verify.sh` will tell you what moved.

Run it:

```bash
bash scripts/specos-check.sh examples/check-fixture --session examples/check-fixture/oversized-session.md
```

| Folder | What it tests | Expected |
|---|---|---|
| `specs/clean-feature` | The AC styles (`- **AC1** —`, `- AC2:`, `- AC21b —`, `- AC22 *(example)*:`), an en-dash range, `[FK-10]` keys | silent |
| `specs/broken-feature` | An uncovered AC, a missing / retired / `[pending]` AC referenced by a task, a `covers:` to a missing AC, a sketch, a stale stamp, a `[new]` task, a missing `linked:` path, a version without a CHANGELOG entry | 10 warnings + 1 info |
| `specs/duplicate-ids` | Per-journey numbering (AC1, AC2 defined twice), expanded cases without a `spec:` stamp | 1 grouped warning + 1 info |
| `specs/legacy-feature` | Checkbox ACs without ids, `[SP-01]` tasks, full testcases without `covers:` | two info lines |
| `specs/draft-empty` | `status: draft` with no `## Assumptions` or `## Open questions` | 1 warning |
| `specs/approved-assumptions` | `status: approved` that still lists an assumption | 1 warning |
| `specs/draft-ok` | A draft with assumptions, an open question and a decision | silent |
| `specs/payments` | A group spec (`type: group`) | skipped |
| `specs/payments/checkout` | A spec two folders deep, `[FK-123]`, `AC1–AC3` and `AC21b` | 1 warning (`linked:` path) |
| `oversized-session.md` | A `session.md` over 30 lines (passed with `--session`; the real file is gitignored) | 1 warning |
| `session-open-overflow.md` / `session-ok.md` / `session-bad-task.md` | 5 `open` entries / a valid session / `task: none (draft, no keys)` | 1 warning / silent / 1 warning |

Total: 15 warnings with `oversized-session.md` (the `SP-` placeholders and the missing stamp are `info`, not warnings).
