# Traditional RAG

## How It Works

1. **Index documents** - Break into chunks, create embeddings
2. **Receive query** - User asks a question
3. **Retrieve context** - Find similar chunks
4. **Generate response** - LLM uses chunks as context

## Chunking

Documents are split into smaller pieces because:
- LLMs have context window limits
- Smaller chunks enable precise retrieval
- Embedding models work better with focused text

## Embeddings

Vectors that capture the **semantic meaning** of text.

```
"Apple makes iPhones"        → [0.12, -0.45, 0.78, ...]
"The company produces phones" → [0.11, -0.44, 0.77, ...]
```

Similar meanings = similar vectors

---

[← Previous](02-llm-limitations.md) | [Next: Why GraphRAG? →](04-why-graphrag.md)
