# Hands-On Lab: Neo4j and Amazon Bedrock

Build Generative AI and GraphRAG Agents with Neo4j and AWS.

## Overview

In this hands-on lab, you'll learn how to build AI agents that query knowledge graphs using Neo4j, Amazon Bedrock, and the Model Context Protocol (MCP). The lab is designed for data scientists, data engineers, and developers interested in applying graph-powered AI to real-world datasets.

You'll work with a knowledge graph built from SEC 10-K filings - regulatory documents filed by publicly traded companies. The graph contains companies, their risk factors, asset manager ownership data, and extracted entities. By the end of this lab, you'll be able to ask natural language questions about complex financial relationships and get accurate, grounded answers.

### What You'll Learn

- **Neo4j Aura**: Deploy and manage a cloud-hosted graph database
- **Knowledge Graphs**: Explore relationships between companies, risks, and investors
- **Aura Agents**: Build no-code AI agents with semantic search and graph traversal
- **Model Context Protocol**: Connect AI agents to enterprise data sources securely
- **LangGraph/Strands**: Build production-ready AI agents with Python

## Workshop Structure

The workshop is divided into two tracks:

### Part 1: No-Code Track (Labs 0-2)

Build AI agents without writing code using Neo4j Aura's built-in tools.

| Lab | Title | Description |
|-----|-------|-------------|
| [Lab 0](Lab_0_Sign_In) | Sign In | Access AWS and Neo4j accounts |
| [Lab 1](Lab_1_Aura_Setup) | Aura Setup | Create Neo4j Aura database, restore knowledge graph |
| [Lab 2](Lab_2_Aura_Agents) | Aura Agents | Build AI agent with Cypher templates, semantic search, and Text2Cypher |

### Part 2: Coding Track (Labs 4-5)

Build AI agents programmatically using Python, LangGraph, and MCP.

| Lab | Title | Description |
|-----|-------|-------------|
| [Lab 4](Lab_4_SageMaker_Setup) | SageMaker Setup | Set up development environment in Amazon SageMaker |
| [Lab 5](Lab_5_Neo4j_MCP_Agent) | Neo4j MCP Agent | Build LangGraph/Strands agent with Model Context Protocol |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              YOUR AGENTS                                     │
├─────────────────────────────────┬───────────────────────────────────────────┤
│         No-Code (Labs 0-2)      │           Coding (Labs 4-5)               │
│  ┌───────────────────────────┐  │  ┌─────────────────────────────────────┐  │
│  │      Aura Agents          │  │  │   LangGraph / Strands Agents        │  │
│  │  • Cypher Templates       │  │  │   • MCP Protocol                    │  │
│  │  • Similarity Search      │  │  │   • AgentCore Gateway               │  │
│  │  • Text2Cypher            │  │  │   • Claude via Bedrock              │  │
│  └───────────────────────────┘  │  └─────────────────────────────────────┘  │
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

## Prerequisites

- Laptop with a web browser
- Access to AWS Console (provided during workshop)
- Access to Neo4j Aura (provided during workshop)

## Venue

These workshops are organized onsite at AWS and Neo4j partner events.

## Duration

3 hours total:
- Part 1 (No-Code): ~1 hour
- Part 2 (Coding): ~2 hours

## Agenda

### Part 1: No-Code Track

| Time | Activity |
|------|----------|
| 10 min | Introduction to Neo4j and Knowledge Graphs |
| 5 min | [Lab 0](Lab_0_Sign_In) - Sign In to AWS |
| 15 min | [Lab 1](Lab_1_Aura_Setup) - Neo4j Aura Setup |
| 20 min | [Lab 2](Lab_2_Aura_Agents) - Build Aura Agent |
| 5 min | Break |

### Part 2: Coding Track

| Time | Activity |
|------|----------|
| 15 min | Introduction to MCP and AgentCore |
| 15 min | [Lab 4](Lab_4_SageMaker_Setup) - SageMaker Setup |
| 30 min | [Lab 5](Lab_5_Neo4j_MCP_Agent) - Build MCP Agent |
| 15 min | Q&A and Next Steps |

## The Dataset

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

## Improving the Labs

We'd appreciate your feedback! Open an issue at [github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock/issues](https://github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock/issues).

## Resources

- [Neo4j Aura](https://neo4j.com/cloud/aura/)
- [Neo4j MCP Server](https://github.com/neo4j/mcp)
- [Amazon Bedrock](https://aws.amazon.com/bedrock/)
- [Amazon Bedrock AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [LangGraph](https://langchain-ai.github.io/langgraph/)
