# Agent Tool Types

## Three Retrieval Patterns

| Tool Type | Purpose | Best For |
|-----------|---------|----------|
| **Cypher Templates** | Controlled, precise queries | Specific lookups, comparisons |
| **Similarity Search** | Semantic retrieval | Finding content by meaning |
| **Text2Cypher** | Flexible natural language | Ad-hoc questions about data |

## Cypher Templates

Pre-defined queries with parameters:
- `get_company_overview($company_name)`
- `find_shared_risks($company1, $company2)`

## Similarity Search

Vector-based semantic search:
- Uses embeddings to find related content
- "What do filings say about AI?" finds relevant passages

## Text2Cypher

LLM translates questions to Cypher:
- "Which company has the most risk factors?"
- Flexible but less predictable

---

[← Previous](02-what-is-aura-agent.md) | [Next: Lab Steps →](04-lab-steps.md)
