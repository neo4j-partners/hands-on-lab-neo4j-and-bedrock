# Using the Client

## Basic Usage

```python
client = AuraAgentClient(
    client_id="your-client-id",
    client_secret="your-client-secret",
    endpoint_url="https://api.neo4j.io/.../invoke"
)

# Ask a question
response = client.invoke("Tell me about Apple's risk factors")

# Get the answer
print(response.text)

# See agent reasoning
print(response.thinking)

# Check which tools were used
for tool in response.tool_uses:
    print(f"Used: {tool.name}")
```

## Benefits

- **Token caching** handled automatically
- **Type-safe responses** with Pydantic models
- **Clean interface** for your applications

---

[← Previous](07-python-client.md) | [Next: Sample Questions →](09-sample-questions.md)
