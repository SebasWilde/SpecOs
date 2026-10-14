# Flows — Post Tags

---

## Flow 1 — Post with tags, from creation to edit

```mermaid
flowchart TD
    A[User in post form] --> B[Types tag, presses Enter or comma]
    B --> C{Already 5 tags?}
    C -- Yes --> D[Field disabled\nMaximum 5 tags]
    C -- No --> E{Duplicate tag?}
    E -- Yes --> F[Ignored silently\nField clears]
    E -- No --> G[Tag becomes a chip]
    G --> H{Add more?}
    H -- Yes --> B
    H -- No --> I[Publishes post]
    I --> J[Tags saved in lowercase]
    J --> K[Tags visible on public view]
    K --> L[Owner opens Edit]
    L --> M{Remove or add a tag?}
    M -- Remove --> N[Chip removed]
    N --> M
    M -- Add --> B
    M -- Save --> O[Post updated with new tags]

style D fill:#ff6b6b
style F fill:#ff6b6b
style K fill:#51cf66
style O fill:#51cf66
```

---

**Legend:**
- 🟥 Red (`fill:#ff6b6b`) — error or blocked state
- 🟩 Green (`fill:#51cf66`) — success or end of flow
- ⬜ No color — normal flow steps
