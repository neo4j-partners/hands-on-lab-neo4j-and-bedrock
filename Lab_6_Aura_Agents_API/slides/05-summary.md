# Summary

## What You Learned

- **OAuth2 Client Credentials** for API authentication
- **Bearer Tokens** and automatic refresh
- **Python client** for calling Aura Agents
- **Response parsing** for text, thinking, and tool usage

## Key Concepts

| Concept | Description |
|---------|-------------|
| OAuth2 | Authentication for machine-to-machine access |
| Bearer Token | Access token in request headers |
| Token Caching | Reuse tokens until expiry |
| Pydantic Models | Type-safe API response handling |

## Architecture

```
Your App → OAuth Token → Agent API → Aura Agent → Neo4j → Response
```

## Next Up

**Lab 7: Neo4j MCP Agent**

Build an AI agent that queries your Neo4j database using the Model Context Protocol - an open standard for connecting LLMs to external tools.

---

[← Previous](04-using-client.md) | [Back to Lab](../README.md)
