# Why Schema Matters

## Graph Databases Are Schema-Flexible

Unlike relational databases, graphs don't require predefined tables.

**This means:** The LLM needs to discover what exists.

## What get-schema Reveals

| Component | Examples |
|-----------|----------|
| Node labels | `Company`, `RiskFactor`, `Product` |
| Relationship types | `FACES_RISK`, `OWNS`, `MENTIONS` |
| Properties | `name`, `ticker`, `description` |

## Better Queries

With schema knowledge:

```cypher
-- LLM knows Company has 'name' property
-- LLM knows FACES_RISK connects Company to RiskFactor
MATCH (c:Company {name: 'APPLE INC'})-[:FACES_RISK]->(r:RiskFactor)
RETURN r.name
```

Without schema: The LLM guesses and often fails.

---

[← Previous](06-neo4j-mcp.md) | [Next: Agent Flow →](08-agent-flow.md)
