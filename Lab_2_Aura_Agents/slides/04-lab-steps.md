# Lab Steps

## Step 1: Create the Agent

- Go to console.neo4j.io
- Select **Agents** → **Create Agent**
- Name: `sec-filings-analyst`
- Connect to your Aura instance

## Step 2: Add Cypher Template Tools

**Tool 1:** `get_company_overview`
- Get company info, risk factors, and major investors

**Tool 2:** `find_shared_risks`
- Find risk factors two companies have in common

## Step 3: Add Similarity Search Tool

- Tool name: `search_filing_content`
- Uses the `chunkEmbeddings` vector index
- Finds semantically relevant passages

## Step 4: Add Text2Cypher Tool

- Tool name: `query_database`
- Translates natural language to Cypher
- For ad-hoc questions

---

[← Previous](03-tool-types.md) | [Next: Testing →](05-testing.md)
