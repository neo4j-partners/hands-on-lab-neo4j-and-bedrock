# Lab 7 - GraphRAG Agents

In this lab, you'll learn how to build intelligent agents that use your Neo4j knowledge graph as a tool. You'll start with a simple agent that can explore the graph schema, then progressively add more sophisticated tools including vector search with graph traversal and natural language to Cypher query generation.

## Prerequisites

Before starting, make sure you have:
- Completed **Lab 0** (AWS sign-in)
- Completed **Lab 1** (Neo4j Aura setup)
- Completed **Lab 4** (SageMaker setup with inference profile configured)
- Completed **Lab 6** (Understanding of GraphRAG retrievers)

## Lab Overview

This lab consists of three notebooks that build increasingly capable agents using LangGraph and AWS Bedrock:

### 01_simple_agent.ipynb - Simple Schema Agent
Build your first agent using LangGraph with AWS Bedrock:
- Connect to AWS Bedrock using `ChatBedrockConverse`
- Define tools as simple Python functions with the `@tool` decorator
- Create an agent that can retrieve and explain the graph schema
- Understand the ReAct pattern for agent reasoning

### 02_vector_graph_agent.ipynb - Vector + Graph Agent
Add semantic search capabilities with graph context:
- Create a `VectorCypherRetriever` tool for the agent
- Define retrieval queries that traverse graph relationships
- Combine vector search with structured graph data
- Let the agent choose between schema and document retrieval tools

### 03_text2cypher_agent.ipynb - Multi-Tool Agent with Text2Cypher
Build a powerful multi-tool agent:
- Add a Text2Cypher tool for natural language database queries
- Configure custom Cypher generation prompts
- Give the agent three tools: schema, semantic search, and database queries
- Watch the agent intelligently select tools based on question type

## Getting Started

1. Run the inference profile setup script (if not done already):
   ```bash
   ./setup-inference-profile.sh haiku
   ```
2. Open the first notebook: `01_simple_agent.ipynb`
3. Work through each notebook in order
4. Each notebook adds new tools to the agent

## Key Concepts

- **Agent**: An AI system that can use tools to accomplish tasks autonomously
- **Tools**: Python functions with docstrings that agents can invoke based on user queries
- **LangGraph**: A framework for building stateful, multi-step agent applications
- **ReAct Pattern**: Reasoning and Acting - the agent reasons about what tool to use and then acts
- **Tool Selection**: The agent reads tool names and descriptions to decide which tool to use

## When to Use Each Tool

| Tool | Best For |
|------|----------|
| **Schema Tool** | Understanding graph structure, planning queries |
| **Vector + Graph Tool** | Semantic questions requiring relationship context |
| **Text2Cypher Tool** | Specific facts, counts, and structured queries |

## Example Questions by Tool Type

**Schema queries:**
- "How does the graph model relate financial documents to risk factors?"
- "What questions can I answer using this graph database?"

**Semantic search queries:**
- "What are the main risk factors mentioned in Apple's documents?"
- "Summarize Microsoft's business strategy"

**Text2Cypher queries:**
- "Which company faces the most risk factors?"
- "What products does NVIDIA mention?"
- "How many risk factors does Apple face?"

## Next Steps

After completing this lab, you have learned how to:
- Build knowledge graphs from unstructured documents
- Implement multiple retrieval strategies (Vector, VectorCypher, Text2Cypher)
- Create intelligent agents that automatically choose the right tool for each question

**Congratulations!** You have completed the main workshop.
