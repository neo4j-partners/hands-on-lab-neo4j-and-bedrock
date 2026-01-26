# Using Bedrock in Python

## LangChain Integration

LangChain provides the `ChatBedrockConverse` class:

```python
from langchain_aws import ChatBedrockConverse

llm = ChatBedrockConverse(
    model="us.anthropic.claude-sonnet-4-20250514-v1:0",
    region_name="us-west-2"
)

response = llm.invoke("What is a knowledge graph?")
print(response.content)
```

## Cross-Region Inference

The `us.` prefix enables cross-region routing:
- Better availability
- Automatic failover
- Same API interface

## Model Selection

For this workshop, we use **Claude Sonnet** - a good balance of capability and cost.

---

[← Previous](03-amazon-bedrock.md) | [Next: What is an Agent? →](05-what-is-agent.md)
