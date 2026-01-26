# Adding Tools

## Step 3: Add Cypher Template Tools

**Tool 1: get_company_overview**
```cypher
MATCH (c:Company {name: $company_name})
OPTIONAL MATCH (c)-[:FACES_RISK]->(r:RiskFactor)
OPTIONAL MATCH (am:AssetManager)-[:OWNS]->(c)
RETURN c.name, collect(DISTINCT r.name)[0..10] AS risks,
       collect(DISTINCT am.managerName)[0..10] AS owners
```

**Tool 2: find_shared_risks**
```cypher
MATCH (c1:Company)-[:FACES_RISK]->(r)<-[:FACES_RISK]-(c2:Company)
WHERE c1.name = $company1 AND c2.name = $company2
RETURN collect(DISTINCT r.name) AS shared_risks
```

## Step 4: Add Similarity Search

- Index: `chunkEmbeddings`
- Model: `text-embedding-ada-002`

## Step 5: Add Text2Cypher

For flexible, ad-hoc queries.

---

[← Previous](08-lab-steps.md) | [Next: Testing Your Agent →](10-testing.md)
