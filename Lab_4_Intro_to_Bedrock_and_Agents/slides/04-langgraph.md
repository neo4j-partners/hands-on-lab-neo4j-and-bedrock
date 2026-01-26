# LangGraph Architecture

## Graph-Based Agents

LangGraph represents agents as a graph of nodes and edges:

```
START → agent → (tools → agent) | END
```

## Components

| Component | Purpose |
|-----------|---------|
| **Nodes** | Functions that process state |
| **Edges** | Connections between nodes |
| **State** | Shared data (message history) |
| **Conditional Edges** | Route based on conditions |

## Minimal Agent Structure

```python
graph = StateGraph(MessagesState)
graph.add_node("agent", call_model)
graph.add_node("tools", ToolNode(tools))
graph.add_edge(START, "agent")
graph.add_conditional_edges("agent", should_continue)
graph.add_edge("tools", "agent")
```

---

[← Previous](03-what-is-agent.md) | [Next: Defining Tools →](05-tools.md)
