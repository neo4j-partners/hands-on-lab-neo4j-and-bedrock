# Tool Descriptions Matter

## The LLM Reads Your Docstrings

Tool selection is guided by descriptions:

```python
@tool
def add_numbers(a: int, b: int) -> int:
    """Add two numbers together.

    Use this tool when the user asks to add, sum,
    or calculate the total of two numbers.

    Args:
        a: The first number
        b: The second number

    Returns:
        The sum of a and b
    """
    return a + b
```

## Best Practices

| Practice | Why |
|----------|-----|
| Be specific | Helps LLM choose correctly |
| Include examples | "When the user asks..." |
| Describe parameters | Clear input expectations |
| Explain returns | What the tool provides |

---

[← Previous](09-defining-tools.md) | [Next: Binding Tools →](11-binding-tools.md)
