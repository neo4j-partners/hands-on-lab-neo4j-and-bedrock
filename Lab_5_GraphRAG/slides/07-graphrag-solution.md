# The GraphRAG Solution

## From Unstructured to Structured

Documents contain structure that traditional RAG ignores:

- **Entities**: Companies, people, products, risks
- **Relationships**: Owns, faces, mentions, works for

## GraphRAG Extracts This Structure

```
Traditional RAG asks: "What chunks are similar to this query?"

GraphRAG asks: "What entities and relationships are relevant?"
```

## The Difference

**Traditional RAG:**
```
Question → Vector Search → Chunks → LLM → Answer
```

**GraphRAG:**
```
Question → Vector Search → Nodes → Graph Traversal → Enriched Context → LLM → Answer
```

Graph traversal adds relationship context that similarity search alone cannot provide.

---

[← Previous](06-traditional-rag-limits.md) | [Next: Document-Chunk Model →](08-document-chunk.md)
