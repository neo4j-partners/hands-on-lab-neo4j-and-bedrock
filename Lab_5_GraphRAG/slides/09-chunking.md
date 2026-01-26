# Chunking Strategies

## The Dual Impact of Chunk Size

Chunk size creates a fundamental trade-off:

| Larger Chunks | Smaller Chunks |
|---------------|----------------|
| Better context for extraction | More precise retrieval |
| The LLM sees more surrounding text | Less irrelevant content |
| May include unrelated content | May lose context |

## FixedSizeSplitter

```python
from neo4j_graphrag.experimental.components.text_splitters import FixedSizeSplitter

splitter = FixedSizeSplitter(
    chunk_size=500,     # Characters per chunk
    chunk_overlap=50    # Overlap for context continuity
)
```

## Typical Sizes

| Size | Best For |
|------|----------|
| 200-500 chars | High-precision retrieval |
| 500-1000 chars | Balanced |
| 1000+ chars | Context-heavy extraction |

---

[← Previous](08-document-chunk.md) | [Next: Embeddings →](10-embeddings.md)
