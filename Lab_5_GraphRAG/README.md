# Lab 5 - GraphRAG with Neo4j

This lab teaches you how to build Graph Retrieval-Augmented Generation (GraphRAG) applications using the official **neo4j-graphrag** Python library. Through four hands-on notebooks, you'll progress from understanding graph structure to building production-ready GraphRAG pipelines.

## What is GraphRAG?

GraphRAG combines the semantic understanding of vector search with the structural relationships in knowledge graphs. Unlike traditional RAG that treats documents as isolated chunks, GraphRAG leverages graph connections to provide richer context to LLMs.

**Traditional RAG:**
```
Question → Embed → Vector Search → Top-K Chunks → LLM → Answer
```

**GraphRAG:**
```
Question → Embed → Vector Search → Top-K Nodes → Graph Traversal → Enriched Context → LLM → Answer
```

The graph structure allows you to:
- Follow relationships to find related information
- Understand entity connections (people, companies, products)
- Retrieve contextual information not present in the original text

## The neo4j-graphrag Library

The `neo4j-graphrag` package is Neo4j's official Python library for building GraphRAG applications. It provides:

| Component | Purpose |
|-----------|---------|
| **Retrievers** | Fetch relevant information from Neo4j (Vector, VectorCypher, Hybrid, Text2Cypher) |
| **Embedders** | Generate vector embeddings from text (Bedrock, OpenAI, etc.) |
| **LLM Interfaces** | Connect to language models (Bedrock, OpenAI, etc.) |
| **GraphRAG** | Orchestrate retriever + LLM into a complete RAG pipeline |

---

## Notebook 1: Understanding Graph Structure for RAG

Before diving into embeddings and retrieval, it's essential to understand how documents should be structured in a graph database for effective RAG.

### The Document-Chunk Model

In GraphRAG, we don't store documents as monolithic text blobs. Instead, we:

1. **Split documents into chunks** - Smaller text segments that fit within embedding model limits
2. **Create relationships between chunks** - Preserve the sequential order with `NEXT_CHUNK` relationships
3. **Link chunks to their source** - Track provenance with `FROM_DOCUMENT` relationships

```
┌──────────┐     NEXT_CHUNK      ┌──────────┐     NEXT_CHUNK      ┌──────────┐
│  Chunk   │────────────────────▶│  Chunk   │────────────────────▶│  Chunk   │
│  (1)     │                     │  (2)     │                     │  (3)     │
└────┬─────┘                     └────┬─────┘                     └────┬─────┘
     │                                │                                │
     │ FROM_DOCUMENT                  │ FROM_DOCUMENT                  │ FROM_DOCUMENT
     │                                │                                │
     ▼                                ▼                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                               Document                                       │
│                        (apple-10k-2024.pdf)                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Why Split Documents into Chunks?

Chunking is necessary for several reasons:

- **Context window limits** - LLMs can only process a certain amount of text at once
- **Retrieval precision** - Smaller chunks allow more precise matching to user queries
- **Cost efficiency** - Processing smaller chunks is faster and cheaper
- **Embedding quality** - Embedding models work better with focused, coherent text segments

### Why Graph Structure Matters

This structure enables powerful retrieval patterns:
- **Sequential context**: When you find a relevant chunk, you can easily retrieve the chunks before and after it
- **Document filtering**: Constrain searches to specific documents or document types
- **Multi-hop traversal**: Follow relationships to find related entities extracted from the text

### Run the Notebook

**To learn these concepts hands-on, run [`01_data_loading.ipynb`](01_data_loading.ipynb)**

In this notebook, you will:
- Load sample SEC 10-K filing text from a data file
- Create Document nodes with metadata (path, page number)
- Use `FixedSizeSplitter` to split text into chunks with configurable size and overlap
- Create Chunk nodes linked to Documents via `FROM_DOCUMENT` relationships
- Chain chunks together with `NEXT_CHUNK` relationships
- Query the graph to verify the structure

**Expected outcome:** A Document-Chunk graph structure ready for embeddings.

---

## Notebook 2: Creating Embeddings and Vector Indexes

With the graph structure in place, the next step is to enable semantic search by adding vector embeddings to your chunks.

### What Are Embeddings?

Embeddings are numerical representations (vectors) that capture the semantic meaning of text. The key insight is that **similar texts have similar embeddings**, enabling "meaning-based" search rather than just keyword matching.

```python
# These two sentences have very similar embeddings despite different words:
"Apple makes iPhones"           → [0.12, -0.45, 0.78, ...]  # 1024 dimensions
"The company produces smartphones" → [0.11, -0.44, 0.77, ...]  # Similar vector!
```

This is powerful because a search for "smartphone manufacturer" will find content about "Apple makes iPhones" even though none of those exact words appear in the query.

### The neo4j-graphrag Embeddings API

The library provides embedders for various providers:

```python
# AWS Bedrock (used in this lab)
from neo4j_graphrag.embeddings import BedrockEmbeddings

embedder = BedrockEmbeddings(model_id="amazon.titan-embed-text-v2:0")

# Generate an embedding
vector = embedder.embed_query("What are the company's risk factors?")
# Returns: list[float] with 1024 dimensions
```

### Text Chunking with FixedSizeSplitter

Before embedding, documents need to be split into appropriately-sized chunks:

```python
from neo4j_graphrag.experimental.components.text_splitters import FixedSizeSplitter

splitter = FixedSizeSplitter(
    chunk_size=4000,      # Characters per chunk
    chunk_overlap=200     # Overlap between chunks for context continuity
)

chunks = await splitter.run(text=document_text)
```

The `chunk_overlap` parameter is important - it ensures that information at chunk boundaries isn't lost by including some text from the previous chunk.

### Creating Vector Indexes in Neo4j

Neo4j stores embeddings as node properties and uses vector indexes for fast similarity search:

```cypher
CREATE VECTOR INDEX chunkEmbeddings IF NOT EXISTS
FOR (c:Chunk) ON (c.embedding)
OPTIONS {indexConfig: {
  `vector.dimensions`: 1024,
  `vector.similarity_function`: 'cosine'
}}
```

> **Important:** The `vector.dimensions` must match your embedding model output. Amazon Titan Text Embeddings V2 produces 1024-dimensional vectors.

### Raw Vector Search

Once the index is created, you can perform similarity searches directly with Cypher:

```cypher
CALL db.index.vector.queryNodes('chunkEmbeddings', 5, $query_embedding)
YIELD node, score
RETURN node.text, score
ORDER BY score DESC
```

### Run the Notebook

**To implement embeddings, run [`02_embeddings.ipynb`](02_embeddings.ipynb)**

In this notebook, you will:
- Load sample SEC 10-K filing text
- Use `FixedSizeSplitter` to chunk text (400 chars with 50 char overlap for demo)
- Generate embeddings for each chunk using Amazon Titan via `BedrockEmbeddings`
- Store embeddings as the `embedding` property on Chunk nodes
- Create a vector index named `chunkEmbeddings`
- Perform raw vector searches using `db.index.vector.queryNodes()`
- Compare different queries to see how semantic search finds relevant content

**Expected outcome:** Chunk nodes with embeddings and a working vector index that returns semantically similar results.

---

## Notebook 3: Building Your First GraphRAG Pipeline

With embeddings in place, you can now build a complete question-answering system using the `VectorRetriever` and `GraphRAG` classes.

### VectorRetriever

The `VectorRetriever` abstracts away the complexity of vector search, handling embedding generation and Neo4j queries for you:

```python
from neo4j_graphrag.retrievers import VectorRetriever

retriever = VectorRetriever(
    driver=driver,
    index_name="chunkEmbeddings",
    embedder=embedder,
    return_properties=["text"]  # Which node properties to return
)

# Search by text (embedder creates the vector automatically)
results = retriever.search(query_text="What are the company's products?", top_k=5)
```

The `return_properties` parameter controls which properties from the matched Chunk nodes are included in the results. You can add additional properties like `index` or `source` if needed.

**When to use:** Simple semantic search where you need the most relevant chunks based on meaning.

### Diagnostic Search Pattern

Before building the full RAG pipeline, it's useful to inspect raw retrieval results:

```python
result = retriever.search(query_text="What products does Apple make?", top_k=5)

for item in result.items:
    score = item.metadata.get('score', 'N/A')
    print(f"Score: {score:.4f}, Content: {item.content[:100]}...")
```

This helps you verify that:
- The vector index is working correctly
- The right chunks are being retrieved
- Similarity scores are reasonable (higher is better)

### The GraphRAG Class

The `GraphRAG` class orchestrates the complete RAG pipeline - retrieval followed by LLM generation:

```python
from neo4j_graphrag.generation import GraphRAG
from neo4j_graphrag.llm import BedrockLLM

llm = BedrockLLM(model_id="us.anthropic.claude-sonnet-4-20250514-v1:0")

rag = GraphRAG(
    retriever=retriever,
    llm=llm
)

# Ask a question - retrieves context and generates answer
response = rag.search(
    query_text="What are the main risk factors?",
    retriever_config={"top_k": 5},  # Pass parameters to the retriever
    return_context=True              # Include retrieved chunks in response
)

print(response.answer)           # The LLM-generated answer
print(response.retriever_result) # The retrieved context
```

The `retriever_config` dictionary passes parameters directly to the retriever's `search()` method. Common parameters include `top_k` for controlling how many chunks to retrieve.

### Run the Notebook

**To build your first pipeline, run [`03_vector_retriever.ipynb`](03_vector_retriever.ipynb)**

In this notebook, you will:
- Initialize a `VectorRetriever` with the `chunkEmbeddings` index
- Run diagnostic searches to inspect retrieval results and scores
- Configure a `BedrockLLM` for answer generation (Claude via Bedrock)
- Build a complete `GraphRAG` pipeline combining retrieval and generation
- Ask questions and receive grounded answers based on retrieved context
- Experiment with different queries to see how the pipeline responds

**Expected outcome:** A working GraphRAG pipeline that answers questions using your SEC filing data, with the ability to inspect both the retrieved context and generated answers.

---

## Notebook 4: Graph-Enhanced Retrieval

The real power of GraphRAG comes from combining vector search with graph traversal. The `VectorCypherRetriever` lets you enrich retrieved chunks with additional context from the graph.

### VectorCypherRetriever

This retriever adds a custom Cypher query that runs after vector search, allowing you to traverse relationships:

```python
from neo4j_graphrag.retrievers import VectorCypherRetriever

# Retrieve the matched chunk plus document info and neighbors
retrieval_query = """
MATCH (node)-[:FROM_DOCUMENT]->(doc:Document)
OPTIONAL MATCH (prev:Chunk)-[:NEXT_CHUNK]->(node)
OPTIONAL MATCH (node)-[:NEXT_CHUNK]->(next:Chunk)
RETURN
    node.text AS context,
    doc.path AS document,
    node.index AS chunk_index,
    prev.text AS previous_chunk,
    next.text AS next_chunk
"""

retriever = VectorCypherRetriever(
    driver=driver,
    index_name="chunkEmbeddings",
    retrieval_query=retrieval_query,
    embedder=embedder
)
```

The `node` variable in the retrieval query refers to each chunk returned by the vector search. You can traverse any relationships from there - to documents, to adjacent chunks, or to extracted entities.

### Expanded Context Window Pattern

A powerful pattern is to concatenate adjacent chunks into a single expanded context, giving the LLM more surrounding information:

```python
expanded_context_query = """
MATCH (node)-[:FROM_DOCUMENT]->(doc:Document)
OPTIONAL MATCH (prev:Chunk)-[:NEXT_CHUNK]->(node)
OPTIONAL MATCH (node)-[:NEXT_CHUNK]->(next:Chunk)
WITH node, doc, prev, next
RETURN
    COALESCE(prev.text + ' ', '') + node.text + COALESCE(' ' + next.text, '') AS expanded_context,
    doc.path AS source_document,
    node.index AS center_chunk_index
"""
```

This query:
1. Finds the matched chunk (`node`) from vector search
2. Looks up its source document
3. Finds the previous and next chunks via `NEXT_CHUNK` relationships
4. Concatenates all three chunks into a single `expanded_context` string

### Why This Matters

Consider a question like "What were Apple's revenue trends?" The most relevant chunk might mention a specific quarter, but the surrounding chunks contain the full context needed for a complete answer. By including `NEXT_CHUNK` traversal, you get:

- **Previous chunk**: Setup and context leading into the topic
- **Matched chunk**: The semantically relevant content that matched the query
- **Next chunk**: Continuation, conclusions, and follow-up details

This expanded context often produces significantly better answers because the LLM has more information to work with.

### Run the Notebook

**To implement graph-enhanced retrieval, run [`04_vector_cypher_retriever.ipynb`](04_vector_cypher_retriever.ipynb)**

In this notebook, you will:
- Write custom Cypher retrieval queries that traverse graph relationships
- Configure `VectorCypherRetriever` with document and chunk context
- Implement the expanded context window pattern
- Inspect the retrieved context to see what the LLM receives
- Compare answers from standard `VectorRetriever` vs `VectorCypherRetriever`
- See how graph-enhanced context improves answer quality

**Expected outcome:** Understanding of how to leverage graph relationships for richer, more contextual retrieval that produces better answers.

---

## Additional Retriever Types (Reference)

The neo4j-graphrag library provides additional retrievers not covered in these notebooks. These are documented here for reference:

### HybridRetriever

Combines vector search with full-text search for better recall on queries with specific terms:

```python
from neo4j_graphrag.retrievers import HybridRetriever

retriever = HybridRetriever(
    driver=driver,
    vector_index_name="chunkEmbeddings",
    fulltext_index_name="chunkText",
    embedder=embedder
)

# ranker controls how results are combined: "naive" (default) or "linear"
# alpha is used with "linear" ranker: 0.0 = fulltext only, 1.0 = vector only
results = retriever.search(
    query_text="SEC Form 10-K filing requirements",
    top_k=5,
    ranker="linear",
    alpha=0.7  # 70% vector, 30% fulltext
)
```

**When to use:** Queries containing specific terms, product names, or codes that benefit from exact matching.

### Text2CypherRetriever

Uses an LLM to convert natural language questions into Cypher queries:

```python
from neo4j_graphrag.retrievers import Text2CypherRetriever

retriever = Text2CypherRetriever(
    driver=driver,
    llm=llm,
    neo4j_schema=schema_string,  # Optional: provide schema for better accuracy
    examples=[
        "Question: Who founded the company?\nCypher: MATCH (p:Person)-[:FOUNDED]->(c:Company) RETURN p.name"
    ]
)

# The LLM generates and executes a Cypher query
results = retriever.search(query_text="What products does Apple sell?")
```

**When to use:** Questions better answered by structured graph queries than similarity search.

### Retriever Selection Guide

| Scenario | Recommended Retriever |
|----------|----------------------|
| Simple Q&A over documents | `VectorRetriever` |
| Need surrounding context | `VectorCypherRetriever` |
| Technical terms, codes, names | `HybridRetriever` |
| Complex questions about entities | `Text2CypherRetriever` |
| Best of both worlds | `HybridCypherRetriever` |

---

## Prerequisites

- **Lab 1** completed (Neo4j Aura database running)
- **Lab 4** completed (SageMaker with `CONFIG.txt` configured)
- AWS credentials with Bedrock access

## Installation

```bash
cd Lab_5_GraphRAG/src
pip install -e .
```

## Configuration

Ensure `CONFIG.txt` in the project root contains:

```ini
# AWS Bedrock
MODEL_ID=us.anthropic.claude-sonnet-4-20250514-v1:0
EMBEDDING_MODEL_ID=amazon.titan-embed-text-v2:0
REGION=us-west-2

# Neo4j Aura
NEO4J_URI=neo4j+s://xxxxxxxx.databases.neo4j.io
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password_here
```

## Key Concepts Reference

| Concept | Description |
|---------|-------------|
| **Chunk** | A segment of text small enough for embedding and retrieval |
| **Embedding** | A vector (list of floats) capturing semantic meaning |
| **Vector Index** | Neo4j index enabling fast similarity search |
| **Retriever** | Component that fetches relevant data from Neo4j |
| **top_k** | Number of most similar results to return |
| **Retrieval Query** | Custom Cypher appended after vector search |

## Troubleshooting

### "Could not import boto3"
```bash
pip install boto3
```

### Embedding dimension mismatch
Ensure your vector index dimensions match the embedder output:
- Amazon Titan V2: 1024 dimensions
- OpenAI text-embedding-3-large: 3072 dimensions
- OpenAI text-embedding-3-small: 1536 dimensions

### Neo4j connection issues
1. Verify `NEO4J_URI` starts with `neo4j+s://`
2. Check your Aura instance is running
3. Confirm credentials are correct

## Next Steps

**This completes Part 2 - Introduction to Agents and GraphRAG with Neo4j.**

To continue, proceed to **Part 3 - Advanced Agents and API Integration**:

[Lab 6 - Aura Agents API](../Lab_6_Aura_Agents_API) - Learn how to call your Aura Agent programmatically via REST API, enabling integration into applications and automated workflows.

## Additional Resources

- [neo4j-graphrag Documentation](https://neo4j.com/docs/neo4j-graphrag-python/)
- [GraphRAG Manifesto](https://neo4j.com/blog/graphrag-manifesto/)
- [Neo4j Vector Index Documentation](https://neo4j.com/docs/cypher-manual/current/indexes-for-vector-search/)
