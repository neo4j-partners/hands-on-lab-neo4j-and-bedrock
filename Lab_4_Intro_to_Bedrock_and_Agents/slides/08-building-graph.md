# Building the Graph

## Minimal Agent Structure

```python
from langgraph.graph import StateGraph, START
from langgraph.prebuilt import ToolNode

# Create the graph
graph = StateGraph(MessagesState)

# Add nodes
graph.add_node("agent", call_model)
graph.add_node("tools", ToolNode(tools))

# Add edges
graph.add_edge(START, "agent")
graph.add_conditional_edges("agent", should_continue)
graph.add_edge("tools", "agent")

# Compile
agent = graph.compile()
```

## The Flow

1. **START** → Call the agent (LLM)
2. **Agent** → Decide: use tools or respond?
3. **Tools** (if needed) → Execute tool, return to agent
4. **END** → Return final response

---

[← Previous](07-langgraph.md) | [Next: Defining Tools →](09-defining-tools.md)
