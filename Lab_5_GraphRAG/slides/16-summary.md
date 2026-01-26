# Summary

## What You Learned

- **LLMs have limitations** (hallucination, cutoff, relationship blindness)
- **RAG provides context** to address these limitations
- **Traditional RAG** has its own limits (ignores structure)
- **GraphRAG** adds graph traversal for richer context
- **neo4j-graphrag** provides production-ready components

## Retriever Selection Guide

| Scenario | Retriever |
|----------|-----------|
| Simple Q&A | `VectorRetriever` |
| Need surrounding context | `VectorCypherRetriever` |
| Technical terms/codes | `HybridRetriever` |
| Complex entity questions | `Text2CypherRetriever` |

## Next Up

**Lab 6: Aura Agents API**

Call your Aura Agent programmatically for application integration, automation, and custom interfaces.

---

[← Previous](15-graphrag-class.md) | [Back to Lab](../README.md)
