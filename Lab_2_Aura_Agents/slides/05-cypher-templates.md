# Cypher Template Tools

## Controlled, Precise Queries

Cypher templates are pre-defined queries with parameters:

```cypher
MATCH (c:Company {name: $company_name})
OPTIONAL MATCH (c)-[:FACES_RISK]->(r:RiskFactor)
RETURN c.name, collect(r.name) AS risks
```

## Why Use Templates?

| Benefit | Description |
|---------|-------------|
| **Predictable** | Same query every time |
| **Optimized** | You control the query structure |
| **Secure** | No arbitrary query generation |
| **Fast** | No LLM query generation overhead |

## Templates You'll Create

- `get_company_overview` - Company info + risks + investors
- `find_shared_risks` - Risks two companies have in common

---

[← Previous](04-tools-overview.md) | [Next: Similarity Search →](06-similarity-search.md)
