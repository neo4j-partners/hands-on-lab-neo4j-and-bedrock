# Calling the Agent

## Make the Request

```http
POST {agent_endpoint}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "input": "Tell me about Apple's risk factors"
}
```

## Response Structure

```json
{
  "status": "completed",
  "content": [
    {
      "type": "text",
      "text": "Apple Inc faces several key risk factors..."
    },
    {
      "type": "tool_use",
      "name": "get_company_overview",
      "input": {"company_name": "APPLE INC"}
    }
  ],
  "usage": {
    "input_tokens": 150,
    "output_tokens": 350
  }
}
```

---

[← Previous](04-credentials.md) | [Next: Response Parsing →](06-parsing.md)
