# Lab 5: GraphRAG with Neo4j

## What You'll Learn

- How to structure documents in a graph for RAG
- Creating embeddings and vector indexes
- Building retrieval pipelines with neo4j-graphrag
- Graph-enhanced retrieval patterns

## What is GraphRAG?

GraphRAG combines **vector search** with **graph traversal** to provide richer context to LLMs.

**Traditional RAG:**
```
Question → Vector Search → Chunks → LLM → Answer
```

**GraphRAG:**
```
Question → Vector Search → Nodes → Graph Traversal → Enriched Context → LLM → Answer
```

---

[Next: LLM Limitations →](02-llm-limitations.md)
