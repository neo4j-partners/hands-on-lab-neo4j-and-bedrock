# Document-Chunk Model

## Graph Structure for RAG

```
┌──────────┐   NEXT_CHUNK   ┌──────────┐   NEXT_CHUNK   ┌──────────┐
│  Chunk 1 │───────────────▶│  Chunk 2 │───────────────▶│  Chunk 3 │
└────┬─────┘                └────┬─────┘                └────┬─────┘
     │                           │                           │
     │ FROM_DOCUMENT             │ FROM_DOCUMENT             │ FROM_DOCUMENT
     ▼                           ▼                           ▼
┌────────────────────────────────────────────────────────────────────┐
│                           Document                                  │
└────────────────────────────────────────────────────────────────────┘
```

## Why This Structure?

| Relationship | Purpose |
|--------------|---------|
| `NEXT_CHUNK` | Retrieve sequential context |
| `FROM_DOCUMENT` | Track provenance |
| Entity links | Connect to extracted entities |

---

[← Previous](07-graphrag-solution.md) | [Next: Chunking Strategies →](09-chunking.md)
