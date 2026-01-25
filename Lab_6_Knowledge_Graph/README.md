# Lab 6 - Building a Knowledge Graph

In this lab, you'll learn how to build a knowledge graph in Neo4j for GraphRAG (Graph Retrieval-Augmented Generation) applications. You'll start with the fundamentals of loading text data, then progress through adding embeddings for semantic search, and finally use various retrievers to query your graph.

## Prerequisites

Before starting, make sure you have:
- Completed **Lab 1** (Neo4j Aura setup)
- Completed **Lab 4** (SageMaker setup with environment variables configured in `CONFIG.txt`)
- AWS credentials configured with access to Bedrock (Claude and Titan models)

## Lab Overview

This lab consists of four notebooks that build on each other:

### 01_data_loading.ipynb - Data Loading Fundamentals
Learn the core concepts of loading text data into Neo4j:
- Understand the Document → Chunk graph structure
- Connect to Neo4j from a Jupyter notebook
- Create Document and Chunk nodes
- Link chunks together with NEXT_CHUNK relationships

> **Note:** This notebook teaches concepts. Notebook 02 is self-contained and creates its own data.

### 02_embeddings.ipynb - Embeddings and Vector Search
Add semantic search capabilities to your graph:
- Understand what embeddings are and why they matter
- Use `FixedSizeSplitter` to automatically chunk text
- Generate embeddings using AWS Bedrock (Amazon Titan)
- Create a vector index in Neo4j
- Perform similarity search to find relevant chunks

> **Important:** This is the foundation notebook - complete this before notebooks 03 and 04.

### 03_vector_retriever.ipynb - Vector Retriever
Learn the fundamentals of semantic search with vector retrieval:
- Set up a VectorRetriever using Neo4j's vector index
- Perform semantic similarity searches on your knowledge graph
- Use GraphRAG to combine vector search with LLM-generated answers
- Understand how vector search finds contextually similar content

### 04_vector_cypher_retriever.ipynb - Vector Cypher Retriever
Combine vector search with custom Cypher queries for enhanced context:
- Create custom Cypher retrieval queries to traverse graph relationships
- Return additional context from adjacent chunks
- Expand context windows for richer LLM responses
- Compare standard vs graph-enhanced retrieval

## Getting Started

### Install Dependencies

This lab uses the `neo4j-graphrag` library with Bedrock support. Install from the `src` directory:

```bash
cd Lab_6_Knowledge_Graph/src
pip install -e .
```

Or if using uv:

```bash
cd Lab_6_Knowledge_Graph/src
uv pip install -e .
```

### Configuration

Make sure your `CONFIG.txt` in the project root has the following configured:

```ini
# AWS Bedrock Settings
MODEL_ID=us.anthropic.claude-3-sonnet-20240229-v1:0
EMBEDDING_MODEL_ID=amazon.titan-embed-text-v2:0
REGION=us-west-2

# Neo4j Aura Database
NEO4J_URI=neo4j+s://xxxxxxxx.databases.neo4j.io
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password_here
```

### Recommended Path

1. **Review** `01_data_loading.ipynb` to understand the graph structure concepts
2. **Complete** `02_embeddings.ipynb` to create data with embeddings and vector index
3. **Complete** `03_vector_retriever.ipynb` to learn basic GraphRAG
4. **Complete** `04_vector_cypher_retriever.ipynb` for advanced graph-enhanced retrieval

## Key Concepts

- **Chunks**: Smaller pieces of text split from documents for efficient retrieval
- **Embeddings**: Numerical vectors that capture semantic meaning of text (1024 dimensions for Titan V2)
- **Vector Index**: Enables fast similarity search across embeddings
- **VectorRetriever**: Basic semantic search using vector embeddings
- **VectorCypherRetriever**: Combines vector search with custom Cypher for graph context
- **GraphRAG**: Combines retrieval with LLM generation for intelligent answers

## AWS Bedrock Models Used

| Model Type | Default Model ID | Description |
|------------|-----------------|-------------|
| LLM | `us.anthropic.claude-3-sonnet-20240229-v1:0` | Claude 3 Sonnet for text generation |
| Embeddings | `amazon.titan-embed-text-v2:0` | Titan V2 produces 1024-dimensional vectors |

## Project Structure

```
Lab_6_Knowledge_Graph/
├── 01_data_loading.ipynb          # Data loading fundamentals (concepts)
├── 02_embeddings.ipynb            # Embeddings and vector search (foundation)
├── 03_vector_retriever.ipynb      # Basic vector retrieval
├── 04_vector_cypher_retriever.ipynb  # Advanced graph-enhanced retrieval
├── company_data.txt               # Sample data (SEC 10-K excerpt)
├── data_utils.py                  # Utility functions for Neo4j and Bedrock
├── README.md                      # This file
└── src/
    └── pyproject.toml             # Python dependencies
```

## Troubleshooting

### "Could not import boto3"
Install the bedrock extras: `pip install "neo4j-graphrag[bedrock]"`

### AWS Credentials Error
Ensure your AWS credentials are configured:
- Via environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Via AWS CLI (`aws configure`)
- Via IAM role (if running on AWS)

### Neo4j Connection Error
Verify your `CONFIG.txt` has the correct:
- `NEO4J_URI` (should start with `neo4j+s://`)
- `NEO4J_USERNAME` (usually `neo4j`)
- `NEO4J_PASSWORD` (the password from Aura setup)
