# Agent Flow

## What Happens When You Ask a Question

```
User: "What risk factors does Apple face?"
         │
         ▼
┌─────────────────────────────────────────┐
│  LLM: Analyzes question, decides to     │
│       first understand the schema       │
│       → Calls: get-schema               │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  MCP Server: Returns schema             │
│  - Nodes: Company, RiskFactor...        │
│  - Rels: FACES_RISK, OWNS...            │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  LLM: Formulates Cypher query           │
│       → Calls: read-cypher              │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  MCP Server: Executes, returns results  │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  LLM: Synthesizes human response        │
│  "Apple faces the following risks..."   │
└─────────────────────────────────────────┘
```

---

[← Previous](07-schema-matters.md) | [Next: Lab Architecture →](09-architecture.md)
