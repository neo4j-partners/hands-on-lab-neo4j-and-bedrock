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

## Your Notebook's Role

1. Create the LangGraph/Strands agent
2. Connect to MCP server via AgentCore
3. Handle user questions
4. Display responses

---

[← Previous](08-agent-flow.md) | [Next: Framework Options →](10-frameworks.md)
