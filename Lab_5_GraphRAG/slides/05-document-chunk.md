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

- **Sequential context**: Retrieve chunks before/after a match
- **Document filtering**: Constrain searches to specific sources
- **Provenance tracking**: Know where information came from

---

[← Previous](04-why-graphrag.md) | [Next: Retrievers →](06-retrievers.md)
