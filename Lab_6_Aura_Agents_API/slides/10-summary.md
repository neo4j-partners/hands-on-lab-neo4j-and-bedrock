# Summary

## What You Learned

- **OAuth2 Client Credentials** for machine-to-machine auth
- **Bearer Tokens** with automatic caching and refresh
- **REST API calls** to invoke your Aura Agent
- **Response parsing** for text, thinking, and tool usage
- **Python client** pattern for clean integration

## Key Concepts

| Concept | Description |
|---------|-------------|
| Client Credentials | OAuth2 flow for services |
| Bearer Token | Access token in headers |
| Token Caching | Reuse until expiry |
| Pydantic Models | Type-safe responses |

## Architecture

```
Your App → OAuth Token → Agent API → Aura Agent → Neo4j → Response
```

## Next Up

**Lab 7: Neo4j MCP Agent**

Build an agent that queries Neo4j using the **Model Context Protocol** - an open standard for connecting LLMs to external tools.

---

[← Previous](09-sample-questions.md) | [Back to Lab](../README.md)
