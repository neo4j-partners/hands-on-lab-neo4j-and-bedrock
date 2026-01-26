# What You'll Build

## The Knowledge Graph

Your database will contain SEC 10-K filings from major tech companies:

| Entity Type | Examples |
|-------------|----------|
| **Companies** | Apple, Microsoft, NVIDIA, Meta |
| **Risk Factors** | Cybersecurity, supply chain, regulatory |
| **Products** | iPhone, Azure, GPUs, advertising |
| **Executives** | CEOs, CFOs, board members |
| **Asset Managers** | BlackRock, Vanguard, Berkshire Hathaway |

## Relationships

```
(BlackRock)-[:OWNS]->(Apple)
(Apple)-[:FACES_RISK]->(Cybersecurity Threats)
(Apple)-[:MENTIONS]->(iPhone)
```

---

[← Previous](01-intro.md) | [Next: Why Graph Databases? →](03-why-graphs.md)
