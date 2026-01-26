# VectorCypherRetriever

## Vector Search + Graph Traversal

Combines semantic search with custom Cypher:

```python
from neo4j_graphrag.retrievers import VectorCypherRetriever

retrieval_query = """
MATCH (node)-[:FROM_DOCUMENT]->(doc:Document)
OPTIONAL MATCH (prev:Chunk)-[:NEXT_CHUNK]->(node)
OPTIONAL MATCH (node)-[:NEXT_CHUNK]->(next:Chunk)
RETURN
    COALESCE(prev.text, '') + node.text + COALESCE(next.text, '') AS context,
    doc.path AS source
"""

retriever = VectorCypherRetriever(
    driver=driver,
    index_name="chunkEmbeddings",
    retrieval_query=retrieval_query,
    embedder=embedder
)
```

## The Power

You get the **matched chunk** plus **surrounding context** from graph traversal.

---

[← Previous](12-vector-retriever.md) | [Next: Expanded Context Pattern →](14-expanded-context.md)
