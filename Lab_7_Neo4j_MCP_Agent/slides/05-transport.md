# Transport Options

## How Agents Talk to MCP Servers

MCP supports multiple transport mechanisms:

| Transport | Use Case |
|-----------|----------|
| **stdio** | Local processes, CLI tools, desktop apps |
| **HTTP/SSE** | Remote servers, cloud deployments |
| **WebSocket** | Real-time bidirectional communication |

## In This Lab

We use **HTTP transport** to connect to a remote MCP server running on Amazon Bedrock AgentCore:

```
Your Notebook → AgentCore Gateway → Neo4j MCP Server → Neo4j Aura
```

## Why Remote?

- **Managed infrastructure** - No local server needed
- **Scalable** - Handles multiple connections
- **Secure** - Enterprise-grade security

---

[← Previous](04-mcp-interaction.md) | [Next: Neo4j MCP Server →](06-neo4j-mcp.md)
