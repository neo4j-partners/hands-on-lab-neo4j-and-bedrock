# How MCP Works

## The Interaction Pattern

1. **Discovery** - Agent connects, requests available tools
2. **Selection** - LLM decides which tool to call
3. **Invocation** - Agent sends tool call with parameters
4. **Response** - MCP server executes and returns results
5. **Synthesis** - LLM incorporates results into response

## Transport Options

| Transport | Use Case |
|-----------|----------|
| **stdio** | Local processes, CLI tools |
| **HTTP/SSE** | Remote servers, cloud |
| **WebSocket** | Real-time communication |

## Key Benefit

AI agents can work with any MCP-compatible data source without custom integration code.

---

[← Previous](02-what-is-mcp.md) | [Next: Neo4j MCP Server →](04-neo4j-mcp.md)
