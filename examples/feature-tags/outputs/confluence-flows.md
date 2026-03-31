# Flows — Post Tags

---

## Flow 1 — Add tag (happy path + limit)

```mermaid
flowchart TD
    A[User in post form] --> B[Types tag and presses Enter or comma]
    B --> C{Already has 5 tags?}
    C -- Yes --> D[Field disabled\nMessage: Maximum 5 tags]
    C -- No --> E{Duplicate tag?}
    E -- Yes --> F[Silently ignored\nField clears]
    E -- No --> G[Tag appears as chip]
    G --> H{Want to add more?}
    H -- Yes --> B
    H -- No --> I[Publishes or saves post]
    I --> J[Tags saved in lowercase]
    J --> K[Tags visible on public view]

style D fill:#ff6b6b
style F fill:#ff6b6b
style K fill:#51cf66
```

---

## Flow 2 — Edit tags on existing post

```mermaid
flowchart TD
    A[User opens their post] --> B[Clicks Edit]
    B --> C[Sees current tags as removable chips]
    C --> D{What action do they take?}
    D -- Remove tag --> E[Clicks X on chip]
    E --> F[Tag removed from form]
    F --> D
    D -- Add tag --> G[Types and confirms new tag]
    G --> H{Exceeds limit of 5?}
    H -- Yes --> I[Field locked\nMessage: Maximum 5 tags]
    H -- No --> J[New chip appears]
    J --> D
    D -- Save --> K[PATCH /api/posts/:id with updated tags]
    K --> L[Post updated with new tags]

style I fill:#ff6b6b
style L fill:#51cf66
```

---

**Legend:**
- 🟥 Red (`fill:#ff6b6b`) — error or blocked state
- 🟩 Green (`fill:#51cf66`) — success or end of flow
- ⬜ No color — normal flow steps
