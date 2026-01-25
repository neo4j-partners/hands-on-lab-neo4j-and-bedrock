# Lab 6 - GraphRAG Retrievers

In this lab, you'll learn how to implement Graph Retrieval-Augmented Generation (GraphRAG) using different retriever strategies with the Neo4j GraphRAG Python package and AWS Bedrock. You'll explore vector search, combine vector search with Cypher queries for richer context, and use natural language to generate Cypher queries automatically.

## Prerequisites

Before starting, make sure you have:
- Completed **Lab 0** (AWS sign-in)
- Completed **Lab 1** (Neo4j Aura setup)
- Completed **Lab 4** (SageMaker setup with inference profile configured)
- A Neo4j database with embeddings (the `chunkEmbeddings` vector index)
- An OpenAI API key (the vector index was created with `text-embedding-ada-002`)

## Lab Overview

This lab consists of three notebooks that demonstrate different retrieval strategies:

### 01_vector_retriever.ipynb - Vector Retriever
Learn the fundamentals of semantic search with vector retrieval:
- Set up a VectorRetriever using Neo4j's vector index
- Perform semantic similarity searches on your knowledge graph
- Use GraphRAG to combine vector search with LLM-generated answers
- Understand how vector search finds contextually similar content

### 02_vector_cypher_retriever.ipynb - Vector Cypher Retriever
Combine vector search with custom Cypher queries for enhanced context:
- Create custom Cypher retrieval queries to traverse graph relationships
- Return additional context like companies and asset managers alongside text chunks
- Discover shared risks among companies using graph traversal
- Compare results with and without graph-enhanced context

### 03_text2cypher_retriever.ipynb - Text2Cypher Retriever
Use natural language to query your graph directly:
- Automatically convert natural language questions to Cypher queries
- Query specific nodes, relationships, and properties without writing Cypher
- Understand the graph schema and how it guides query generation
- Build accessible natural language interfaces to your knowledge graph

## Getting Started

1. Create an inference profile using the Lab 4 setup script:
   ```bash
   cd ../Lab_4_SageMaker_Setup
   ./setup-inference-profile.sh haiku
   ```
2. Copy the `MODEL` and `INFERENCE_PROFILE_ARN` values to each notebook
3. Add your OpenAI API key (for embeddings)
4. Add your Neo4j connection details
5. Open the first notebook: `01_vector_retriever.ipynb`
6. Work through each notebook in order

## Key Concepts

- **Vector Retriever**: Uses semantic similarity to find relevant text chunks based on meaning, not just keywords
- **Vector Cypher Retriever**: Combines vector search with Cypher graph traversal to return richer, relationship-aware context
- **Text2Cypher Retriever**: Converts natural language questions into Cypher queries for precise, fact-based answers
- **GraphRAG**: A pipeline that combines retrievers with LLMs to generate contextual answers grounded in your knowledge graph
- **Retrieval Context**: The data returned by retrievers that grounds LLM responses in your actual data

## When to Use Each Retriever

| Retriever | Best For |
|-----------|----------|
| **Vector** | Semantic questions where meaning matters more than exact matches |
| **Vector Cypher** | Questions requiring both semantic similarity and graph relationships |
| **Text2Cypher** | Fact-based questions about specific entities, counts, or relationships |

## Model Configuration

Model references differ between notebooks (SageMaker) and local Python due to environment constraints. See [Lab 4 README](../Lab_4_SageMaker_Setup/README.md) for detailed explanation.

### Notebooks (SageMaker)

Notebooks use application inference profile ARNs created by the setup script:

```python
MODEL = "haiku"
INFERENCE_PROFILE_ARN = "arn:aws:bedrock:us-west-2:ACCOUNT:application-inference-profile/ID"

# For neo4j-graphrag (BedrockLLM)
llm = BedrockLLM(
    model_id=INFERENCE_PROFILE_ARN,
    region_name="us-west-2",
)
```

### Local Python (src/)

Local Python can use cross-region inference profile IDs directly:

```python
AWS_BEDROCK_INFERENCE_PROFILE_ID = "us.anthropic.claude-sonnet-4-5-20250929-v1:0"

llm = BedrockLLM(
    inference_profile_id=AWS_BEDROCK_INFERENCE_PROFILE_ID,
    region_name="us-west-2",
)
```

## Standalone Python Version

A standalone Python version is available in `src/` for running outside of notebooks:

```bash
cd src
cp .env.sample .env  # Edit with your credentials
uv sync
uv run python main.py 1  # Vector Retriever
uv run python main.py 2  # Vector Cypher Retriever
uv run python main.py 3  # Text2Cypher Retriever
```

See [src/README.md](src/README.md) for details.

## Next Steps

After completing this lab, continue to [Lab 7 - GraphRAG Agents](../Lab_7_Agents) to learn how to build intelligent agents that can automatically select the right retriever based on the question.
