# Using the Python Client

## Basic Usage

```python
client = AuraAgentClient(
    client_id="your-client-id",
    client_secret="your-client-secret",
    endpoint_url="https://api.neo4j.io/.../invoke"
)

# Ask a question
response = client.invoke("Tell me about Apple's risk factors")
print(response.text)
```

## Response Contents

| Property | Description |
|----------|-------------|
| `response.text` | The generated answer |
| `response.thinking` | Agent's reasoning process |
| `response.tool_uses` | Tools that were called |

## Sample Questions

- "Tell me about Apple Inc and their major investors"
- "What risks do Apple and Microsoft share?"
- "What do filings say about AI and machine learning?"

---

[← Previous](03-credentials.md) | [Next: Summary →](05-summary.md)
