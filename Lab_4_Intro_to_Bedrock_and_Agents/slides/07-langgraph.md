# LangGraph Architecture

## Graph-Based Agents

LangGraph represents agents as a **graph** of nodes and edges:

```
START → agent → (tools → agent) | END
```

## Core Components

| Component | Purpose |
|-----------|---------|
| **Nodes** | Functions that process state |
| **Edges** | Connections between nodes |
| **State** | Shared data (message history) |
| **Conditional Edges** | Route based on conditions |

## Why Graphs?

- **Flexible** - Add nodes for new capabilities
- **Debuggable** - Visualize the flow
- **Composable** - Build complex from simple
- **Stateful** - Track conversation history

---

[← Previous](06-react-pattern.md) | [Next: Building the Graph →](08-building-graph.md)
