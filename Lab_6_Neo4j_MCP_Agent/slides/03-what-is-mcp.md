# What is MCP?

## Model Context Protocol

An **open standard** defining how AI assistants connect to external data sources and tools.

## The Architecture

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   AI Agent   │◀──MCP──▶│  MCP Server  │◀───────▶│  Data Source │
│  (Claude,    │         │  (Neo4j,     │         │  (Database,  │
│   GPT, etc)  │         │   Files)     │         │   API, etc)  │
└──────────────┘         └──────────────┘         └──────────────┘
```

## Benefits

- **Universal adapter** - One protocol for any tool
- **Discovery** - Agents learn available capabilities
- **Standardized** - Consistent interface across tools
- **Secure** - Built-in authentication patterns

---

[← Previous](02-integration-problem.md) | [Next: MCP Interaction Pattern →](04-mcp-interaction.md)
