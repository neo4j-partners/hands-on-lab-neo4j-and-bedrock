# Amazon Bedrock

## What is Bedrock?

Amazon Bedrock provides access to foundation models from leading AI companies through a unified API.

**Available Models:**
- Anthropic Claude
- Meta Llama
- Amazon Titan
- Cohere, AI21, and more

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Model ID** | Identifies the specific model |
| **Inference Profile** | Cross-region routing for availability |
| **Converse API** | Unified interface for chat models |

## In This Lab

```python
from langchain_aws import ChatBedrockConverse

llm = ChatBedrockConverse(
    model="us.anthropic.claude-sonnet-4-20250514-v1:0",
    region_name="us-west-2"
)
```

---

[← Previous](01-intro.md) | [Next: What is an Agent? →](03-what-is-agent.md)
