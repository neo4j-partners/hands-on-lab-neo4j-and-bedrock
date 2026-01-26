# Neo4j MCP Server

## Available Tools

The Neo4j MCP Server provides two tools:

| Tool | Purpose |
|------|---------|
| `get-schema` | Retrieves node labels, relationships, properties |
| `read-cypher` | Executes read-only Cypher queries |

## Why Schema Matters

Graph databases are schema-flexible. The `get-schema` tool helps agents understand:

- What node types exist (Company, RiskFactor)
- How nodes connect (FACES_RISK, OWNS)
- What properties are available

This enables accurate Cypher generation.

## Example Flow

```
User: "What risks does Apple face?"
  ↓
Agent calls: get-schema
  ↓
Agent learns: Company -[:FACES_RISK]-> RiskFactor
  ↓
Agent calls: read-cypher with generated query
```

---

[← Previous](03-how-mcp-works.md) | [Next: Architecture →](05-architecture.md)
