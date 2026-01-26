# Lab Steps

## Step 1: Create the Agent

1. Go to [console.neo4j.io](https://console.neo4j.io)
2. Select **Agents** → **Create Agent**
3. Configure:
   - **Name:** `sec-filings-analyst`
   - **Target Instance:** Your Aura database
   - **External Endpoint:** Enabled

## Step 2: Write Agent Instructions

```
You are an expert financial analyst assistant specializing
in SEC 10-K filings analysis. You help users understand:
- Company risk factors and comparisons
- Asset manager ownership patterns
- Financial metrics and products
- Relationships between entities
```

Good instructions guide the agent's tone and focus.

---

[← Previous](07-text2cypher.md) | [Next: Adding Tools →](09-adding-tools.md)
