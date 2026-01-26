# The Problem Agents Solve

## Users Don't Know Cypher

Your knowledge graph is powerful, but querying it requires Cypher:

```cypher
MATCH (c:Company)-[:FACES_RISK]->(r:RiskFactor)
WHERE c.name = 'APPLE INC'
RETURN r.name
```

**Most users can't write this.**

## Users Don't Know Retriever Types

You have different retrieval patterns:
- Vector search for semantic content
- Text2Cypher for precise facts
- Graph traversal for relationships

**Users just want to ask questions.**

## The Solution

An agent that **understands questions** and **chooses the right approach** automatically.

---

[← Previous](01-intro.md) | [Next: What is an Aura Agent? →](03-what-is-aura-agent.md)
