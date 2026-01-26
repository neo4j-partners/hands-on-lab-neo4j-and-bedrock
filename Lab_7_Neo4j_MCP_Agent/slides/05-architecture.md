# Lab Architecture

## Component Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Your Notebook  │────▶│   AgentCore     │────▶│   Neo4j MCP     │
│  (Agent Code)   │     │   Gateway       │     │    Server       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                                               │
        │ Bedrock API                                   │
        ▼                                               ▼
┌─────────────────┐                           ┌─────────────────┐
│   Claude LLM    │                           │   Neo4j Aura    │
│   (Reasoning)   │                           │    Database     │
└─────────────────┘                           └─────────────────┘
```

## Framework Options

| Framework | Notebook |
|-----------|----------|
| **LangGraph** | `neo4j_langgraph_mcp_agent.ipynb` |
| **Strands Agents** | `neo4j_strands_mcp_agent.ipynb` |

Both produce equivalent results.

---

[← Previous](04-neo4j-mcp.md) | [Next: Sample Queries →](06-sample-queries.md)
