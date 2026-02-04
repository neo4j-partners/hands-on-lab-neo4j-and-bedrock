# Hands-On Lab: Neo4j and Amazon Bedrock

Build Generative AI and GraphRAG Agents with Neo4j and AWS.

Neo4j is the [leading graph database](https://db-engines.com/en/ranking/graph+dbms) vendor. We've worked closely with AWS engineering for years. Our products, AuraDB and AuraDS, are offered as managed services available on AWS through the [AWS Marketplace](https://aws.amazon.com/marketplace/seller-profile?id=23ec694a-d2af-4641-b4d3-b7201ab2f5f9).

## Overview

In this hands-on lab, you'll learn about Neo4j, Amazon Bedrock, and the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/). The lab is designed for data scientists, data engineers, and AI developers who want to master GraphRAG (Graph Retrieval-Augmented Generation) techniques and build production-ready agentic AI applications.

In today's landscape, organizations need AI systems that can extract deep insights from unstructured documents, understand complex entity relationships, and build intelligent systems that can autonomously reason over vast information networks. This hands-on lab addresses this need directly by providing mastery in the most powerful pattern available for complex document intelligence: Graph Retrieval-Augmented Generation (GraphRAG).

You'll work with a real-world dataset of SEC 10-K company filings to learn fundamental GraphRAG patterns. We'll start with a pre-built knowledge graph containing extracted entities from unstructured text. Then you'll implement multiple retrieval strategies: vector similarity search for semantic retrieval, graph-enhanced retrievers that leverage entity relationships, and natural language to Cypher query generation. Finally, you'll build intelligent agents using LangGraph and Strands that can autonomously reason over your knowledge graph to answer complex questions.

By the end of this lab, you'll have hands-on experience with:
- Exploring knowledge graphs built from unstructured documents
- Implementing semantic search with vector embeddings
- Creating graph-enhanced retrieval patterns for richer context
- Building no-code AI agents with Neo4j Aura Agents
- Developing agentic AI systems using the Model Context Protocol
- Calling Aura Agents programmatically via REST API
- Deploying GraphRAG applications on AWS infrastructure

These techniques apply to any domain where you need to extract insights from documents, understand entity relationships, and build AI systems that can reason over complex information networks.

## Starting the Lab

To get started, follow the labs in the agenda below in order.

**Quick Start Options:**
- **No-Code Track Only:** Complete Part 1 (Labs 0-2) to explore Neo4j and AI agents without coding
- **Intro to Agents and GraphRAG:** Complete Parts 1 and 2 (Labs 0-5) to learn GraphRAG fundamentals
- **Full Workshop:** Complete all three parts for the complete GraphRAG development experience

## Prerequisites

You'll need a laptop with a web browser. Your browser will need to be able to access the AWS Console and the Neo4j Aura Console. If your laptop has a firewall you can't control, you may want to bring your personal laptop.

---

## Agenda

### Part 1 - No-Code Getting Started

*This section requires no coding. You'll use visual tools and pre-built interfaces to explore Neo4j and AI agents.*

* Introductions
* Lecture - Introduction to Neo4j
    * What is Neo4j?
    * How is it deployed and managed on AWS?
* [Lab 0 - Sign In](Lab_0_Sign_In)
    * Improving the Labs
    * Sign into AWS
* [Lab 1 - Neo4j Aura Setup](Lab_1_Aura_Setup)
    * Signing up for Neo4j Aura through AWS Marketplace
    * Restoring the pre-built knowledge graph
    * Visual exploration with Neo4j Explore
* [Lab 2 - Aura Agents](Lab_2_Aura_Agents)
    * Building AI agents using Neo4j Aura Agent (no-code)
    * Creating Cypher template tools
    * Adding semantic search and Text2Cypher capabilities
* Break

---

### Part 2 - Introduction to Agents and GraphRAG with Neo4j

*This section introduces you to building AI agents with Python and the fundamentals of GraphRAG (Graph Retrieval-Augmented Generation) using the official neo4j-graphrag library.*

**What You'll Learn:**
- How AI agents use tools to interact with external systems
- The neo4j-graphrag library architecture and components
- Multiple retrieval strategies (Vector, VectorCypher, Hybrid, Text2Cypher)
- Building complete RAG pipelines with the GraphRAG class

**Key Technologies:**
- **LangGraph**: Framework for building stateful, multi-step AI agents
- **neo4j-graphrag**: Neo4j's official Python library for GraphRAG applications
- **VectorRetriever**: Semantic similarity search using embeddings
- **VectorCypherRetriever**: Vector search enhanced with graph traversal
- **GraphRAG**: Orchestration class combining retrieval with LLM generation

* Lecture - Neo4j and Generative AI
    * Generating Knowledge Graphs
    * Retrieval Augmented Generation
    * GraphRAG Patterns
* [Lab 4 - Intro to Bedrock and Agents](Lab_4_Intro_to_Bedrock_and_Agents)
    * Launch SageMaker Studio
    * Clone the workshop repository
    * Configure inference profiles for Bedrock
    * Build a basic LangGraph agent with tool calling

**Important Note:** The pre-built knowledge graph uses OpenAI embeddings (1536 dimensions), which are not compatible with Amazon Titan embeddings (1024 dimensions). AWS Bedrock embedding models do not provide an OpenAI-compatible API. Therefore, in Lab 5 we reset the database and rebuild the vector index using Amazon Titan embeddings. This demonstrates a real-world scenario where you need to match embedding dimensions between your index and query embeddings.

* [Lab 5 - GraphRAG with Neo4j](Lab_5_GraphRAG)
    * Load data and create embeddings with Amazon Titan
    * Build vector indexes in Neo4j
    * Implement VectorRetriever for semantic search
    * Use VectorCypherRetriever for graph-enhanced context
    * Build complete GraphRAG pipelines

---

### Part 3 - Advanced Agents and API Integration

*This section covers advanced topics including programmatic access to Aura Agents and building AI agents that query Neo4j using the Model Context Protocol (MCP).*

**What You'll Learn:**
- Calling Aura Agents via REST API for application integration
- The Model Context Protocol (MCP) standard for tool integration
- Building LangGraph agents that can query knowledge graphs
- Using the Neo4j MCP Server via AgentCore Gateway

**Key Technologies:**
- **Neo4j Aura Agents API**: REST API for invoking your no-code agents programmatically
- **Model Context Protocol (MCP)**: Open standard for connecting AI models to data sources
- **Neo4j MCP Server**: Official Neo4j tool server exposing Cypher query capabilities
- **AgentCore Gateway**: AWS service for hosting and managing MCP servers

* [Lab 6 - Neo4j MCP Agent](Lab_6_Neo4j_MCP_Agent)
    * Connect to Neo4j via AgentCore Gateway
    * Build a LangGraph agent with MCP tools
    * Query the knowledge graph with natural language
* [Lab 7 - Aura Agents API](Lab_7_Aura_Agents_API)
    * Call your Lab 2 Aura Agent programmatically
    * OAuth2 authentication with client credentials
    * Build a reusable Python client for application integration
* Questions and Next Steps

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              YOUR AGENTS                                     │
├───────────────────┬─────────────────────────┬───────────────────────────────┤
│   Part 1 (No-Code) │     Part 2 (GraphRAG)   │      Part 3 (Advanced)        │
│  ┌───────────────┐ │  ┌─────────────────────┐ │  ┌─────────────────────────┐  │
│  │ Aura Agents   │ │  │   neo4j-graphrag    │ │  │   Aura Agents API       │  │
│  │ • Templates   │ │  │   • VectorRetriever │ │  │   • REST API Access     │  │
│  │ • Similarity  │ │  │   • VectorCypherR.  │ │  │   • OAuth2 Auth         │  │
│  │ • Text2Cypher │ │  │   • GraphRAG Class  │ │  │   LangGraph + MCP       │  │
│  └───────────────┘ │  └─────────────────────┘ │  │   • Neo4j MCP Server    │  │
│                    │                          │  └─────────────────────────┘  │
└───────────────────┴─────────────────────────┴───────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │        Neo4j Aura             │
                    │   SEC 10-K Knowledge Graph    │
                    │  • Companies & Risk Factors   │
                    │  • Asset Manager Ownership    │
                    │  • Vector Embeddings          │
                    └───────────────────────────────┘
```

## Knowledge Graph Data Model

The knowledge graph contains SEC 10-K filings from major technology companies:

- **Companies**: Apple, Microsoft, NVIDIA, and more
- **Risk Factors**: Extracted risk disclosures from SEC filings
- **Asset Managers**: Institutional investors and their holdings
- **Financial Metrics**: Key financial data mentioned in filings
- **Vector Embeddings**: Pre-computed embeddings for semantic search

Example questions you can answer:
- "What risk factors do Apple and Microsoft share?"
- "Which asset managers have the largest tech portfolios?"
- "What do companies say about AI and machine learning in their filings?"

The workshop uses a hybrid knowledge graph that combines **lexical structure** (documents and chunks) with **semantic knowledge** (entities and relationships extracted by LLM). This architecture enables multiple retrieval strategies.

### Graph Structure

```
                      NEXT_CHUNK
                 ┌──────────────────┐
                 │                  │
                 v                  │
┌──────────┐       ┌──────────┐       ┌──────────┐
│  Chunk   │──────>│  Chunk   │──────>│  Chunk   │
│          │       │          │       │          │
│ text     │       │ text     │       │ text     │
│ embedding│       │ embedding│       │ embedding│
└──────────┘       └──────────┘       └──────────┘
     │                  │                  │
     │ FROM_DOCUMENT    │                  │
     v                  v                  v
┌─────────────────────────────────────────────────┐
│                    Document                      │
│                                                  │
│  path: "sec-10k-filings/apple-10k.pdf"          │
└─────────────────────────────────────────────────┘

     ^                  ^                  ^
     │ FROM_CHUNK       │                  │
     │                  │                  │
┌──────────┐       ┌──────────┐       ┌──────────┐
│ Company  │       │ Product  │       │RiskFactor│
│          │       │          │       │          │
│ Apple    │       │ iPhone   │       │ Supply   │
│ Inc.     │       │          │       │ Chain    │
└──────────┘       └──────────┘       └──────────┘
     │                                      ^
     │ FACES_RISK                           │
     └──────────────────────────────────────┘
```

### Node Types

| Node Label | Description | Key Properties |
|------------|-------------|----------------|
| `Document` | Source PDF file | `path`, `createdAt` |
| `Chunk` | Text segment from document | `text`, `index`, `embedding` |
| `Company` | Extracted company entity | `name`, `ticker` |
| `Product` | Products/services mentioned | `name` |
| `RiskFactor` | Business risks identified | `name` |
| `Executive` | Key personnel | `name`, `title` |
| `FinancialMetric` | Financial data points | `name`, `value` |
| `AssetManager` | Institutional investors | `managerName` |

### Relationship Types

| Relationship | Direction | Description |
|--------------|-----------|-------------|
| `FROM_DOCUMENT` | `(Chunk)->(Document)` | Links chunk to source document |
| `NEXT_CHUNK` | `(Chunk)->(Chunk)` | Sequential chunk ordering |
| `FROM_CHUNK` | `(Entity)->(Chunk)` | Provenance: where entity was extracted |
| `FACES_RISK` | `(Company)->(RiskFactor)` | Company faces this risk |
| `OFFERS` | `(Company)->(Product)` | Company offers this product |
| `HAS_EXECUTIVE` | `(Company)->(Executive)` | Company has this executive |
| `REPORTS` | `(Company)->(FinancialMetric)` | Company reports this metric |
| `OWNS` | `(AssetManager)->(Company)` | Investor owns shares in company |

### Search Indexes

The knowledge graph includes indexes to support different retrieval strategies:

| Index Name | Type | Target | Purpose |
|------------|------|--------|---------|
| `chunkEmbeddings` | Vector | `Chunk.embedding` | Semantic similarity search |
| `chunkText` | Fulltext | `Chunk.text` | Keyword search for hybrid retrieval |
| `search_entities` | Fulltext | Entity `.name` properties | Entity lookup by name |

### Retrieval Strategies

**1. Vector Search** - Find semantically similar content using embeddings:
```cypher
CALL db.index.vector.queryNodes('chunkEmbeddings', 5, $embedding)
YIELD node, score
RETURN node.text, score
```

**2. Graph-Enhanced Retrieval** - Combine vector search with graph traversal:
```cypher
-- Find chunks, then traverse to related entities
CALL db.index.vector.queryNodes('chunkEmbeddings', 5, $embedding)
YIELD node AS chunk, score
MATCH (company:Company)-[:FROM_CHUNK]->(chunk)
OPTIONAL MATCH (company)-[:FACES_RISK]->(risk:RiskFactor)
RETURN chunk.text, company.name, collect(risk.name) AS risks
```

**3. Hybrid Search** - Combine keyword and semantic search:
```cypher
-- Uses both chunkEmbeddings (vector) and chunkText (fulltext) indexes
-- Alpha parameter controls the balance: 1.0 = pure vector, 0.0 = pure keyword
```

**4. Text2Cypher** - Natural language to Cypher query generation using LLM.

This hybrid architecture enables rich, context-aware retrieval that leverages both the semantic understanding from embeddings and the structural relationships in the knowledge graph.

## Improving the Labs

We'd appreciate your feedback! Open an issue at [github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock/issues](https://github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock/issues).

## Resources

- [Neo4j Aura](https://neo4j.com/cloud/aura/)
- [Neo4j MCP Server](https://github.com/neo4j/mcp)
- [neo4j-graphrag Python Library](https://neo4j.com/docs/neo4j-graphrag-python/)
- [Amazon Bedrock](https://aws.amazon.com/bedrock/)
- [Amazon Bedrock AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [LangGraph](https://langchain-ai.github.io/langgraph/)
