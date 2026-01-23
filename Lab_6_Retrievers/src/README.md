# GraphRAG Retrievers

Standalone Python application demonstrating three Neo4j GraphRAG retriever patterns using AWS Bedrock and OpenAI embeddings.

## Prerequisites

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) package manager
- AWS account with Bedrock access (Claude Sonnet 4.5)
- OpenAI API key (for embeddings)
- Neo4j Aura instance with data loaded

## Setup

1. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Create environment file**:
   ```bash
   cp .env.sample .env
   ```

3. **Edit `.env`** with your credentials:
   - `AWS_BEDROCK_INFERENCE_PROFILE_ID`: Claude Sonnet 4.5 inference profile (default: `us.anthropic.claude-sonnet-4-5-20250929-v1:0`)
   - `AWS_REGION`: AWS region (default: `us-west-2`)
   - `OPENAI_API_KEY`: Your OpenAI API key (for embeddings)
   - `NEO4J_URI`: Your Neo4j Aura connection URI
   - `NEO4J_PASSWORD`: Your Neo4j password

4. **Sync dependencies**:
   ```bash
   uv sync
   ```

## Usage

```bash
uv run python main.py 1    # Vector Retriever
uv run python main.py 2    # Vector Cypher Retriever
uv run python main.py 3    # Text2Cypher Retriever
```

### Options

```bash
uv run python main.py 1 -q "What products does Microsoft mention?"  # Custom query
uv run python main.py 2 -k 10                                        # Return 10 results
```

## Retrievers

### 1. Vector Retriever
Simple semantic search using vector embeddings.
- Finds text chunks most similar to your query
- Uses OpenAI `text-embedding-ada-002` (matching the index)
- Best for: General document search

### 2. Vector Cypher Retriever
Combines vector search with graph traversal for enriched context.
- Finds relevant chunks AND traverses relationships
- Returns company info and associated asset managers
- Best for: Questions requiring graph context

### 3. Text2Cypher Retriever
Converts natural language to Cypher queries using LLM.
- No embeddings needed - uses LLM to generate Cypher
- Queries the graph directly for specific facts
- Best for: Fact-based questions, counts, specific lookups

## Architecture

- **LLM**: AWS Bedrock Claude Sonnet 4.5 (via inference profile)
- **Embeddings**: OpenAI `text-embedding-ada-002` (matching existing vector index)
- **Graph Database**: Neo4j with vector search
- **Library**: [neo4j-graphrag-python](https://github.com/neo4j-partners/neo4j-graphrag-python) with Bedrock support
