# Defining Tools

## What is a Tool?

A function the LLM can call to interact with external systems.

## Creating Tools with @tool

```python
from langchain_core.tools import tool
from datetime import datetime

@tool
def get_current_time() -> str:
    """Get the current date and time.

    Use this when the user asks about the current time
    or needs a timestamp.
    """
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
```

## Key Elements

| Element | Purpose |
|---------|---------|
| **@tool decorator** | Converts function to tool |
| **Docstring** | Becomes tool description (critical!) |
| **Type hints** | Define parameter types |
| **Return type** | What the tool returns |

---

[← Previous](08-building-graph.md) | [Next: Tool Descriptions →](10-tool-descriptions.md)
