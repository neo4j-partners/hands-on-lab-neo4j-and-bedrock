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
- **No-Code Track Only (1 hour):** Complete Part 1 (Labs 0-2) to explore Neo4j and AI agents without coding
- **Full Workshop (3 hours):** Complete both Part 1 and Part 2 for the full development experience
- **Skip to Coding:** If you already have your AWS account and Aura credentials, go straight to [Lab 4 - SageMaker Setup](Lab_4_SageMaker_Setup)

## Duration

3 hours (full workshop) or 1 hour (no-code track only).

## Prerequisites

You'll need a laptop with a web browser. Your browser will need to be able to access the AWS Console and the Neo4j Aura Console. If your laptop has a firewall you can't control, you may want to bring your personal laptop.

## Agenda

### Part 1 - No-Code Getting Started

*This section requires no coding. You'll use visual tools and pre-built interfaces to explore Neo4j and AI agents.*

* Introductions
* Lecture - Introduction to Neo4j (10 min)
    * What is Neo4j?
    * How is it deployed and managed on AWS?
* [Lab 0 - Sign In](Lab_0_Sign_In) (5 min)
    * Improving the Labs
    * Sign into AWS
* [Lab 1 - Neo4j Aura Setup](Lab_1_Aura_Setup) (15 min)
    * Signing up for Neo4j Aura through AWS Marketplace
    * Restoring the pre-built knowledge graph
    * Visual exploration with Neo4j Explore
* [Lab 2 - Aura Agents](Lab_2_Aura_Agents) (20 min)
    * Building AI agents using Neo4j Aura Agent (no-code)
    * Creating Cypher template tools
    * Adding semantic search and Text2Cypher capabilities
* Break (5 min)

---

### Part 2 - Coding and MCP Development

*This section involves Python programming using Jupyter notebooks in Amazon SageMaker.*

* Lecture - Neo4j and Generative AI (15 min)
    * Generating Knowledge Graphs
    * Retrieval Augmented Generation
    * Model Context Protocol
* [Lab 4 - SageMaker Setup](Lab_4_SageMaker_Setup) (15 min)
    * Launch SageMaker Studio
    * Clone the workshop repository
    * Configure inference profiles for Bedrock
* [Lab 5 - Neo4j MCP Agent](Lab_5_Neo4j_MCP_Agent) (30 min)
    * Connect to Neo4j via AgentCore Gateway
    * Build LangGraph or Strands agent
    * Query the knowledge graph with natural language
* [Lab 8 - Aura Agents API](Lab_8_Aura_Agents_API) (20 min)
    * Call your Lab 2 Aura Agent programmatically
    * OAuth2 authentication with client credentials
    * Build a reusable Python client for application integration
* Questions and Next Steps (10 min)

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              YOUR AGENTS                                     │
├─────────────────────────────────┬───────────────────────────────────────────┤
│         No-Code (Labs 0-2)      │           Coding (Labs 4-8)               │
│  ┌───────────────────────────┐  │  ┌─────────────────────────────────────┐  │
│  │      Aura Agents          │  │  │   LangGraph / Strands Agents        │  │
│  │  • Cypher Templates       │  │  │   • MCP Protocol                    │  │
│  │  • Similarity Search      │  │  │   • AgentCore Gateway               │  │
│  │  • Text2Cypher            │  │  │   • Claude via Bedrock              │  │
│  └───────────────────────────┘  │  │   • Aura Agents REST API (Lab 8)    │  │
│                                 │  └─────────────────────────────────────┘  │
└─────────────────────────────────┴───────────────────────────────────────────┘
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
| `Chunk` | Text segment from document | `text`, `index`, `embedding` (1536-dim vector) |
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
- [Amazon Bedrock](https://aws.amazon.com/bedrock/)
- [Amazon Bedrock AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [LangGraph](https://langchain-ai.github.io/langgraph/)
