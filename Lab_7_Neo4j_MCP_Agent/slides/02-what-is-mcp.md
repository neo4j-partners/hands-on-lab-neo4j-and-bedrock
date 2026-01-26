# What is MCP?

## Model Context Protocol

An open standard defining how AI assistants connect to external data sources and tools.

## The Problem MCP Solves

Without MCP:
- Custom code for each integration
- Different authentication per service
- Tool-specific response formats
- Manual connection management

## With MCP

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   AI Agent   │◀──MCP──▶│  MCP Server  │◀───────▶│  Data Source │
└──────────────┘         └──────────────┘         └──────────────┘
```

One protocol for any data source - Neo4j, files, APIs, databases, etc.

---

[← Previous](01-intro.md) | [Next: How MCP Works →](03-how-mcp-works.md)
