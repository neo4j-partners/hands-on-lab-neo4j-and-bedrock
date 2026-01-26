# Vector Indexes

## Storing Embeddings in Neo4j

Embeddings are stored as node properties:

```cypher
MATCH (c:Chunk {id: 1})
SET c.embedding = $vector
```

## Creating a Vector Index

```cypher
CREATE VECTOR INDEX chunkEmbeddings IF NOT EXISTS
FOR (c:Chunk) ON (c.embedding)
OPTIONS {indexConfig: {
  `vector.dimensions`: 1024,
  `vector.similarity_function`: 'cosine'
}}
```

**Important:** Dimensions must match your embedding model:
- Amazon Titan V2: 1024 dimensions
- OpenAI text-embedding-3-small: 1536 dimensions

## Similarity Search

```cypher
CALL db.index.vector.queryNodes('chunkEmbeddings', 5, $query_embedding)
YIELD node, score
RETURN node.text, score
```

---

[← Previous](10-embeddings.md) | [Next: VectorRetriever →](12-vector-retriever.md)
