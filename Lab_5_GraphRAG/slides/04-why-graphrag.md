# Why GraphRAG?

## Traditional RAG Limitations

Traditional RAG treats documents as isolated chunks:
- Loses sequential context
- Can't follow relationships
- No structural understanding

## Graph Structure Enables

| Capability | Benefit |
|------------|---------|
| **NEXT_CHUNK** relationships | Get surrounding context |
| **FROM_DOCUMENT** relationships | Track provenance |
| **Entity relationships** | Follow connections |

## Example: Expanded Context

When you find a relevant chunk, traverse to get neighbors:

```
[Previous Chunk] → [Matched Chunk] → [Next Chunk]
```

The LLM gets more context for better answers.

---

[← Previous](03-traditional-rag.md) | [Next: Document-Chunk Model →](05-document-chunk.md)
