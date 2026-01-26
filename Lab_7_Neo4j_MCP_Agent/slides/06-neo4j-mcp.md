# Neo4j MCP Server

## Tools Provided

The Neo4j MCP Server exposes two tools:

| Tool | Purpose |
|------|---------|
| `get-schema` | Retrieves node labels, relationship types, properties |
| `read-cypher` | Executes read-only Cypher queries |

## Why Two Tools?

**Schema First:** Before generating queries, the agent needs to understand your data model.

```
1. Agent calls: get-schema
2. Learns: Company, RiskFactor, FACES_RISK, OWNS...
3. Now can generate accurate Cypher
```

**Read-Only:** The `read-cypher` tool only allows read operations - safe for exploration.

---

[← Previous](05-transport.md) | [Next: Why Schema Matters →](07-schema-matters.md)
