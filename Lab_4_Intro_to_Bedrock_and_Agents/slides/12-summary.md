# Summary

## What You Learned

- **Amazon Bedrock** provides unified access to foundation models
- **AI Agents** can take actions and iterate, not just generate text
- **ReAct pattern** combines reasoning and acting in a loop
- **LangGraph** orchestrates agents as graphs of nodes and edges
- **Tools** let LLMs interact with external systems
- **Docstrings** guide tool selection

## The Agent Pattern

```
User Question
    ↓
LLM reasons about what to do
    ↓
Calls appropriate tool(s)
    ↓
Observes results
    ↓
Continues or responds
```

## Next Up

**Lab 5: GraphRAG with Neo4j**

Build retrieval pipelines that combine vector search with graph traversal for richer, more accurate AI responses.

---

[← Previous](11-binding-tools.md) | [Back to Lab](../README.md)
