# Text2Cypher Tool

## Natural Language to Database Queries

Text2Cypher uses an LLM to convert questions into Cypher:

```
"Which company has the most risk factors?"
    ↓
MATCH (c:Company)-[:FACES_RISK]->(r:RiskFactor)
RETURN c.name, count(r) AS riskCount
ORDER BY riskCount DESC
LIMIT 1
```

## When to Use

| Question Pattern | Example |
|------------------|---------|
| Counts | "How many products does Apple mention?" |
| Lists | "List all companies in the database" |
| Comparisons | "Which company has the most executives?" |
| Specific facts | "What is NVIDIA's ticker symbol?" |

## Trade-offs

- **Flexible** - Can answer any structured question
- **Less predictable** - LLM may generate different queries
- **Requires good schema understanding** - LLM needs to know your model

---

[← Previous](06-similarity-search.md) | [Next: Lab Steps →](08-lab-steps.md)
