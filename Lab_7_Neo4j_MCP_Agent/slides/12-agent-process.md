# What the Agent Does

## Behind the Scenes

When you ask: **"What risks does Apple face?"**

### Step 1: Schema Discovery
```
Agent → get-schema
← Learns: Company, RiskFactor, FACES_RISK
```

### Step 2: Query Generation
```
Agent thinks: "I need to find Apple and traverse FACES_RISK"
Generates:
  MATCH (c:Company)-[:FACES_RISK]->(r:RiskFactor)
  WHERE c.name CONTAINS 'APPLE'
  RETURN r.name
```

### Step 3: Execution
```
Agent → read-cypher(query)
← Results: ["Cybersecurity", "Supply Chain", "Regulatory"]
```

### Step 4: Synthesis
```
"Apple Inc faces several key risk factors including
cybersecurity threats, supply chain dependencies, and
regulatory challenges."
```

---

[← Previous](11-sample-queries.md) | [Next: Key Takeaways →](13-takeaways.md)
