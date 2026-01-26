# Defining Tools

## What is a Tool?

A function the LLM can call to interact with external systems.

## Creating Tools

```python
from langchain_core.tools import tool

@tool
def get_current_time() -> str:
    """Get the current date and time."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
```

**Key Elements:**
- **Function** - The actual code to execute
- **Docstring** - Becomes the tool description (important!)
- **Type hints** - Define parameter types

## Binding Tools to LLM

```python
llm_with_tools = llm.bind_tools([
    get_current_time,
    add_numbers
])
```

The LLM now knows about these tools and can call them.

---

[← Previous](04-langgraph.md) | [Next: Summary →](06-summary.md)
