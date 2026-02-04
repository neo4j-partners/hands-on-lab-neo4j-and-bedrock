# Response Parsing

## Content Types

The response `content` array contains different block types:

| Type | Description |
|------|-------------|
| `text` | The generated answer text |
| `thinking` | Agent's reasoning process |
| `tool_use` | Tool invocations made |
| `tool_result` | Results from tools |

## Extracting the Answer

```python
def extract_text(response):
    """Extract text content from response."""
    return "\n".join(
        block["text"]
        for block in response["content"]
        if block["type"] == "text"
    )
```

## Extracting Tool Usage

```python
def extract_tools(response):
    """Extract tool uses from response."""
    return [
        block for block in response["content"]
        if block["type"] == "tool_use"
    ]
```

---

[← Previous](05-calling-agent.md) | [Next: Python Client →](07-python-client.md)
