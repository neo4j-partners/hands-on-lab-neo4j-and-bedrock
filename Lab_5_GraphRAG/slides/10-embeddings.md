# Embeddings

## What Are Embeddings?

Numerical representations (vectors) that capture semantic meaning.

## The Smart Librarian Analogy

**Traditional catalog (keywords):**
- Books organized by title, author, subject
- Search for "dogs" only finds books with "dogs" in the title

**Smart librarian (embeddings):**
- Understands what each book is *about*
- "I want something about loyal companions" → finds dog books

## Using BedrockEmbeddings

```python
from neo4j_graphrag.embeddings import BedrockEmbeddings

embedder = BedrockEmbeddings(model_id="amazon.titan-embed-text-v2:0")

# Generate an embedding
vector = embedder.embed_query("What are the company's risk factors?")
# Returns: list[float] with 1024 dimensions
```

---

[← Previous](09-chunking.md) | [Next: Vector Indexes →](11-vector-indexes.md)
