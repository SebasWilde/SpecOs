# Design — feature-tags

The how. `spec.md` stays about behavior; this file holds what only a developer needs.

## API

`PATCH /api/posts/:id`

```
Request body (partial):   { "tags": ["django", "python", "backend"] }
Response 200:             { "id": "uuid", "tags": [...], "updated_at": "2026-03-15T10:00:00Z" }
Response 422 (AC8):       { "error": "invalid_tags", "detail": "Maximum 5 tags per post" }
```

## Data model

```
Post (existing table — add field):
  tags: ArrayField(CharField(max_length=30), size=5, default=list)
```

## Decisions

- **Array instead of a separate table:** tags are plain strings with no relationships.
- **Lowercase on the backend (AC6):** the frontend shows what the user typed; the backend normalizes before saving.
- **Silent truncation (AC11):** chosen over rejection so the writing flow is never interrupted. Changed in v1.1.
