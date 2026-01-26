# VectorRetriever

## Basic Semantic Search

The `VectorRetriever` handles embedding and search for you:

```python
from neo4j_graphrag.retrievers import VectorRetriever

retriever = VectorRetriever(
    driver=driver,
    index_name="chunkEmbeddings",
    embedder=embedder,
    return_properties=["text"]
)

# Search by text
results = retriever.search(
    query_text="What are the company's products?",
    top_k=5
)
```

## When to Use

- Simple Q&A over documents
- "What is...", "Tell me about..."
- Conceptual, exploratory questions

## Limitation

Returns text chunks only - no entity relationships.

---

[← Previous](11-vector-indexes.md) | [Next: VectorCypherRetriever →](13-vector-cypher.md)
