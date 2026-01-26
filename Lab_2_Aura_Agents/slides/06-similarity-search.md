# Similarity Search Tool

## Semantic Content Discovery

Similarity search finds content by **meaning**, not keywords.

## How It Works

```
User Question: "What do filings say about artificial intelligence?"
    ↓
Question → Embedding (vector)
    ↓
Find chunks with similar embeddings
    ↓
Return semantically relevant passages
```

## Configuration

| Setting | Purpose |
|---------|---------|
| **Embedding Provider** | OpenAI, Bedrock, etc. |
| **Embedding Model** | text-embedding-ada-002 |
| **Vector Index** | chunkEmbeddings |
| **Top K** | Number of results (e.g., 5) |

## Best For

- "What does [topic] mean?"
- "Find information about..."
- Conceptual, exploratory questions

---

[← Previous](05-cypher-templates.md) | [Next: Text2Cypher →](07-text2cypher.md)
