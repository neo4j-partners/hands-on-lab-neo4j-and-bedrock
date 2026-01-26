# Summary

## What You Learned

- **LLMs have limitations** that RAG helps address
- **Chunking** breaks documents into searchable pieces
- **Embeddings** encode meaning as vectors
- **Graph structure** enables relationship traversal
- **neo4j-graphrag** provides production-ready components

## Retriever Selection Guide

| Scenario | Retriever |
|----------|-----------|
| Simple Q&A | VectorRetriever |
| Need context around matches | VectorCypherRetriever |
| Technical terms/codes | HybridRetriever |
| Complex entity questions | Text2CypherRetriever |

## Next Up

**Lab 6: Aura Agents API**

Learn to call your Aura Agent programmatically, enabling:
- Application integration
- Automated workflows
- Custom chat interfaces

---

[← Previous](07-notebooks.md) | [Back to Lab](../README.md)
