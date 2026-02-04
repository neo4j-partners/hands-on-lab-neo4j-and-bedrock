# Neo4j GenAI Hands-On Lab with AWS Program Template, 2026

## Program Name

Build Generative AI & GraphRAG Agents with Neo4j and Amazon Bedrock

## Workshop Overview

This workshop equips participants with practical skills to combine Neo4j's graph database platform with Amazon Bedrock to build explainable, context-aware AI applications using GraphRAG and agentic patterns.

Participants will work with a real-world dataset—SEC 10-K financial filings—to experience how knowledge graphs enhance AI applications with structured context and relationship-aware retrieval.

Through a series of guided exercises, attendees will:

- Deploy and explore Neo4j Aura, the fully managed cloud graph platform
- Build no-code AI agents with Neo4j Aura Agents
- Understand foundational GenAI and retrieval strategies
- Build GraphRAG pipelines using Amazon Bedrock
- Invoke Aura Agents programmatically via REST API
- Build custom agents using the Neo4j MCP server

---

## Lab Agenda

### Part 1 – No-Code Getting Started with Neo4j Aura (Beginner Friendly)

Get hands-on with Neo4j Aura without writing any code. You'll provision a fully managed graph database, explore a pre-built knowledge graph, and create your first AI agent using Neo4j's visual agent builder.

#### Introductions & Lecture — Introduction to Neo4j Aura and Aura Agents

- Neo4j Aura: A fully managed, cloud-native graph database platform
- Neo4j Aura on AWS: Native deployment via AWS Marketplace with seamless integration
- Aura Agents: Build, test, and deploy AI agents grounded in your graph data without writing code

#### Labs

| Lab | Description |
|-----|-------------|
| **Lab 0 – Sign In** | Sign into AWS Console and workshop environment |
| **Lab 1 – Neo4j Aura Setup** | Provision Neo4j Aura via AWS Marketplace, restore a pre-built SEC 10-K knowledge graph, and explore relationships using the visual browser |
| **Lab 2 – Aura Agents** | Create a no-code AI agent using Neo4j Aura Agents, configure semantic search and Text2Cypher tools to enable natural language queries against your graph |

---

### Part 2 – Intro to Amazon Bedrock & GraphRAG (Intermediate)

Dive into code-based development with Amazon Bedrock and Neo4j. You'll build AI agents using LangGraph, generate vector embeddings, and construct GraphRAG pipelines that combine semantic search with graph traversal for more accurate and explainable retrieval.

#### Lecture — Neo4j + Generative AI Concepts

- GraphRAG (Graph Retrieval-Augmented Generation): What it is and why graphs matter for AI
- Patterns for semantic search, hybrid retrieval, and context-aware generation

#### Labs

| Lab | Description |
|-----|-------------|
| **Lab 4 – Intro to Amazon Bedrock and Agents** | Launch AWS SageMaker Studio, configure Bedrock access, and build your first LangGraph AI agent powered by Amazon Bedrock foundation models |
| **Lab 5 – GraphRAG with Neo4j** | Generate vector embeddings with Amazon Titan, create vector indexes in Neo4j, and build GraphRAG pipelines that combine semantic search with graph traversal for richer, more accurate retrieval |

---

### Part 3 – Advanced Agents with Neo4j MCP Server and Aura Agents Integration (Advanced)

Take your skills to the next level with production-ready integration patterns. You'll build agents using the Model Context Protocol (MCP) for standards-based graph access and learn to programmatically invoke Aura Agents via REST API for application integration.

> **Optional Section:** This part of the workshop is designed for all-day sessions or as advanced material that participants can take home and complete on their own infrastructure. It builds on the skills from Parts 1 and 2 and is ideal for those who want to dive deeper into production integration patterns.

#### What You'll Learn

- Build custom agents using the Neo4j MCP server for flexible, standards-based graph access
- Integrate Aura Agents into your applications via REST API with OAuth2 authentication

#### Labs

| Lab | Description |
|-----|-------------|
| **Lab 6 – Neo4j MCP Agent** | Build a LangGraph agent that connects to Neo4j through the Model Context Protocol (MCP), enabling natural language interaction with your knowledge graph |
| **Lab 7 – Aura Agents API** | Programmatically invoke your Aura Agent from external applications using REST APIs with OAuth2 authentication |
