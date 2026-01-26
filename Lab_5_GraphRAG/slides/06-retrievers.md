# neo4j-graphrag Retrievers

## The neo4j-graphrag Library

Neo4j's official Python library for GraphRAG applications.

## Retriever Types

| Retriever | Purpose |
|-----------|---------|
| **VectorRetriever** | Simple semantic search |
| **VectorCypherRetriever** | Vector search + graph traversal |
| **HybridRetriever** | Vector + full-text search |
| **Text2CypherRetriever** | Natural language to Cypher |

## VectorRetriever

```python
retriever = VectorRetriever(
    driver=driver,
    index_name="chunkEmbeddings",
    embedder=embedder
)
results = retriever.search("What are the risks?", top_k=5)
```

## VectorCypherRetriever

Adds custom Cypher after vector search:
```python
retrieval_query = """
MATCH (node)-[:NEXT_CHUNK]->(next)
RETURN node.text + next.text AS context
"""
```

---

[← Previous](05-document-chunk.md) | [Next: Lab Notebooks →](07-notebooks.md)
