# Lab 6 - GraphRAG with Neo4j

This lab teaches you how to build Graph Retrieval-Augmented Generation (GraphRAG) applications using the official **neo4j-graphrag** Python library. You'll learn to load data into Neo4j, create embeddings, and use various retrieval strategies to build intelligent question-answering systems.

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

### Core Components

| Component | Purpose |
|-----------|---------|
| **Retrievers** | Fetch relevant information from Neo4j |
| **Embedders** | Generate vector embeddings from text |
| **LLM Interfaces** | Connect to language models (Bedrock, OpenAI, etc.) |
| **GraphRAG** | Orchestrate retriever + LLM into a RAG pipeline |
| **KG Pipelines** | Build knowledge graphs from documents (experimental) |

### Retriever Types

The library provides multiple retriever strategies, each suited to different use cases:

#### VectorRetriever
Pure semantic similarity search using vector embeddings.

```python
from neo4j_graphrag.retrievers import VectorRetriever

retriever = VectorRetriever(
    driver=driver,
    index_name="chunk_embeddings",
    embedder=embedder,
    return_properties=["text", "source"]
)

# Search by text (embedder creates the vector)
results = retriever.search(query_text="What are the company's products?", top_k=5)

# Or search by pre-computed vector
results = retriever.search(query_vector=[0.1, 0.2, ...], top_k=5)
```

**When to use:** Simple semantic search where graph relationships aren't needed.

#### VectorCypherRetriever
Combines vector search with custom Cypher queries for graph traversal.

```python
from neo4j_graphrag.retrievers import VectorCypherRetriever

# Retrieve the matched chunk plus its neighbors
retrieval_query = """
OPTIONAL MATCH (node)-[:NEXT_CHUNK]->(next)
OPTIONAL MATCH (prev)-[:NEXT_CHUNK]->(node)
RETURN node.text AS matched_text,
       prev.text AS previous_context,
       next.text AS following_context
"""

retriever = VectorCypherRetriever(
    driver=driver,
    index_name="chunk_embeddings",
    retrieval_query=retrieval_query,
    embedder=embedder
)
```

**When to use:** You need additional context from graph relationships after vector matching.

#### HybridRetriever
Combines vector search with full-text search for better recall.

```python
from neo4j_graphrag.retrievers import HybridRetriever

retriever = HybridRetriever(
    driver=driver,
    vector_index_name="chunk_embeddings",
    fulltext_index_name="chunk_text",
    embedder=embedder
)

# alpha controls vector vs fulltext weight (0.0 = fulltext only, 1.0 = vector only)
results = retriever.search(
    query_text="SEC Form 10-K filing requirements",
    top_k=5,
    alpha=0.7  # 70% vector, 30% fulltext
)
```

**When to use:** Queries contain specific terms (product names, codes) that benefit from exact matching.

#### Text2CypherRetriever
Uses an LLM to convert natural language questions into Cypher queries.

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
results = retriever.search(query_text="What products does Acme Corp sell?")
```

**When to use:** Questions that are better answered by structured graph queries than similarity search.

### The GraphRAG Class

The `GraphRAG` class orchestrates the full RAG pipeline:

```python
from neo4j_graphrag.generation import GraphRAG

rag = GraphRAG(
    retriever=retriever,
    llm=llm
)

# Ask a question - retrieves context and generates answer
response = rag.search(
    query_text="What are the main risk factors?",
    retriever_config={"top_k": 5}
)

print(response.answer)           # The LLM-generated answer
print(response.retriever_result) # The retrieved context
```

### Embedder and LLM Interfaces

The library uses a plugin architecture for embedders and LLMs:

```python
# AWS Bedrock (used in this lab)
from neo4j_graphrag.embeddings import BedrockEmbedder
from neo4j_graphrag.llm import BedrockLLM

embedder = BedrockEmbedder(model_id="amazon.titan-embed-text-v2:0")
llm = BedrockLLM(model_id="us.anthropic.claude-3-sonnet-20240229-v1:0")

# OpenAI
from neo4j_graphrag.embeddings import OpenAIEmbeddings
from neo4j_graphrag.llm import OpenAILLM

embedder = OpenAIEmbeddings(model="text-embedding-3-large")
llm = OpenAILLM(model_name="gpt-4o")
```

Supported providers:
- **AWS Bedrock** - Claude, Titan, and other Bedrock models
- **OpenAI** - GPT-4, GPT-3.5, embeddings
- **Anthropic** - Claude models directly
- **Google Vertex AI** - Gemini and PaLM models
- **Cohere** - Command and Embed models
- **Ollama** - Local open-source models
- **Sentence Transformers** - Local embedding models

### Knowledge Graph Construction (Experimental)

Build knowledge graphs from unstructured text:

```python
from neo4j_graphrag.experimental.pipeline.kg_builder import SimpleKGPipeline

kg_builder = SimpleKGPipeline(
    llm=llm,
    driver=driver,
    embedder=embedder,
    schema={
        "node_types": ["Person", "Company", "Product"],
        "relationship_types": ["WORKS_FOR", "PRODUCES"],
        "patterns": [
            ("Person", "WORKS_FOR", "Company"),
            ("Company", "PRODUCES", "Product")
        ]
    }
)

# Extract entities and relationships from text
await kg_builder.run_async(text="John Smith is CEO of Acme Corp, which makes widgets.")
```

## Lab Notebooks

### 01_data_loading.ipynb - Understanding Graph Structure
Learn the conceptual foundation:
- Document → Chunk graph model
- NEXT_CHUNK relationships for sequential context
- Why graph structure matters for RAG

### 02_embeddings.ipynb - Creating Vector-Enabled Data
Build the foundation for semantic search:
- Use `FixedSizeSplitter` to chunk text
- Generate embeddings with Amazon Titan
- Create Neo4j vector indexes
- Perform raw similarity searches

### 03_vector_retriever.ipynb - Basic GraphRAG
Implement your first GraphRAG pipeline:
- Configure `VectorRetriever`
- Use `GraphRAG` for question answering
- Understand retrieval results and LLM generation

### 04_vector_cypher_retriever.ipynb - Graph-Enhanced Retrieval
Leverage graph structure for richer context:
- Write custom Cypher retrieval queries
- Include adjacent chunks for expanded context
- Compare results with and without graph traversal

## Prerequisites

- **Lab 1** completed (Neo4j Aura database running)
- **Lab 4** completed (SageMaker with `CONFIG.txt` configured)
- AWS credentials with Bedrock access

## Installation

```bash
cd Lab_6_Knowledge_Graph/src
pip install -e .
```

## Configuration

Ensure `CONFIG.txt` in the project root contains:

```ini
# AWS Bedrock
MODEL_ID=us.anthropic.claude-3-sonnet-20240229-v1:0
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

## Retriever Selection Guide

| Scenario | Recommended Retriever |
|----------|----------------------|
| Simple Q&A over documents | `VectorRetriever` |
| Need surrounding context | `VectorCypherRetriever` |
| Technical terms, codes, names | `HybridRetriever` |
| Complex questions about entities | `Text2CypherRetriever` |
| Best of both worlds | `HybridCypherRetriever` |

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

After completing this lab, continue to **Lab 8** to learn how to expose your GraphRAG pipeline as an API using Neo4j Aura Agents.

## Additional Resources

- [neo4j-graphrag Documentation](https://neo4j.com/docs/neo4j-graphrag-python/)
- [GraphRAG Manifesto](https://neo4j.com/blog/graphrag-manifesto/)
- [Neo4j Vector Index Documentation](https://neo4j.com/docs/cypher-manual/current/indexes-for-vector-search/)
