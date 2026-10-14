---
feature: checkout
group: payments
version: 1.0
status: approved
lead: Fixture Lead
date: 2026-01-01
linked:
  - specs/payments/refunds/spec.md
---

# Checkout

Two folders deep, with a range in the tasks and a suffix id. Exactly one defect: the linked refunds spec does not exist.

## Acceptance Criteria

### Paying
- AC1 — The cart total is charged once
- AC2 — A failed charge shows the reason
- AC3 — A paid cart cannot be paid again
- AC21b — Totals round half up

## Out of Scope
- Refunds
