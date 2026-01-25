# Lab 7 - Building AI Agents with MCP and Neo4j

This lab introduces two key concepts: how AI agents interact with external tools using the **Model Context Protocol (MCP)**, and how the **Neo4j MCP Server** enables natural language querying of graph databases.

## What is the Model Context Protocol (MCP)?

MCP is an open standard that defines how AI assistants connect to external data sources and tools. Think of it as a universal adapter—instead of building custom integrations for every tool, MCP provides a consistent interface that any AI agent can use.

### The Problem MCP Solves

Without MCP, connecting an AI agent to external tools requires:
- Custom code for each integration
- Handling authentication differently per service
- Parsing tool-specific response formats
- Managing connection lifecycle manually

MCP standardizes all of this into a simple protocol:

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   AI Agent   │◀──MCP──▶│  MCP Server  │◀───────▶│  Data Source │
│              │         │              │         │  (Neo4j, etc)│
└──────────────┘         └──────────────┘         └──────────────┘
```

### How Agents Call MCP Servers

An MCP server exposes **tools** that agents can discover and invoke. The interaction follows this pattern:

1. **Discovery**: The agent connects and requests the list of available tools
2. **Tool Selection**: The LLM decides which tool(s) to call based on the user's question
3. **Invocation**: The agent sends a tool call request with parameters
4. **Response**: The MCP server executes the tool and returns results
5. **Synthesis**: The LLM incorporates results into its response

Here's a simplified example of what happens under the hood:

```python
# 1. Agent discovers available tools
tools = mcp_client.list_tools()
# Returns: [{"name": "get-schema", ...}, {"name": "read-cypher", ...}]

# 2. LLM selects a tool based on user question
# User asks: "How many companies are there?"
# LLM decides: I need to run a Cypher query

# 3. Agent invokes the tool
result = mcp_client.call_tool(
    name="read-cypher",
    arguments={"query": "MATCH (c:Company) RETURN count(c) AS count"}
)

# 4. MCP server returns results
# {"count": 8}

# 5. LLM synthesizes response
# "There are 8 companies in the database."
```

### MCP Transport Options

MCP supports multiple transport mechanisms:

| Transport | Use Case |
|-----------|----------|
| **stdio** | Local processes (CLI tools, desktop apps) |
| **HTTP/SSE** | Remote servers, cloud deployments |
| **WebSocket** | Real-time bidirectional communication |

In this lab, we use HTTP transport to connect to a remote MCP server.

## The Neo4j MCP Server

The [Neo4j MCP Server](https://github.com/neo4j/mcp) exposes Neo4j graph databases through the MCP protocol. This enables AI agents to:

- Understand database structure through schema introspection
- Execute Cypher queries using natural language
- Retrieve graph data without manual query writing

### Available Tools

The Neo4j MCP Server provides two primary tools:

| Tool | Purpose | Example Use |
|------|---------|-------------|
| `get-schema` | Retrieves node labels, relationship types, and properties | Understanding what data exists |
| `read-cypher` | Executes read-only Cypher queries | Fetching actual data |

### Why Schema Matters

Graph databases are schema-flexible, meaning structure emerges from the data. The `get-schema` tool helps agents understand:

- What types of nodes exist (e.g., `Company`, `RiskFactor`)
- How nodes connect via relationships (e.g., `(:Company)-[:HAS_RISK]->(:RiskFactor)`)
- What properties each node type has

This context enables the LLM to generate accurate Cypher queries.

## How the Agent Works

When you ask a question, here's what happens:

```
┌─────────────────────────────────────────────────────────────────────┐
│  User: "What risk factors does Apple face?"                         │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LLM: Analyzes question, decides to first understand the schema     │
│       Calls: get-schema                                             │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  MCP Server: Returns schema                                         │
│  - Nodes: Company, RiskFactor, AssetManager                         │
│  - Relationships: HAS_RISK, OWNS                                    │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LLM: Formulates Cypher query based on schema                       │
│       MATCH (c:Company {name: 'Apple'})-[:HAS_RISK]->(r:RiskFactor) │
│       RETURN r.description                                          │
│       Calls: read-cypher                                            │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  MCP Server: Executes query, returns risk factors                   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LLM: Synthesizes human-readable response                           │
│  "Apple faces the following risk factors: ..."                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Architecture

This lab uses a pre-deployed Neo4j MCP Server running on Amazon Bedrock AgentCore:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Your Notebook  │────▶│    AgentCore    │────▶│   Neo4j MCP     │────▶│   Neo4j Aura    │
│  (Agent Code)   │     │    Gateway      │     │    Server       │     │   Database      │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
        │
        │ Bedrock API
        ▼
┌─────────────────┐
│  Claude LLM     │
│  (Reasoning)    │
└─────────────────┘
```

## Choose Your Framework

Two notebooks demonstrate the same concepts using different agent frameworks:

| Framework | Notebook | Description |
|-----------|----------|-------------|
| **LangGraph** | `neo4j_langgraph_mcp_agent.ipynb` | Uses LangChain's graph-based agent framework |
| **Strands Agents** | `neo4j_strands_mcp_agent.ipynb` | Uses AWS's lightweight agent SDK |

Both produce equivalent results—choose based on your preferred ecosystem.

## Sample Queries

Once connected, try these natural language queries:

```python
# Explore the data model
query("What is the database schema?")

# Simple counts
query("How many companies are in the database?")

# Relationship traversal
query("What companies does BlackRock own?")
query("What risk factors does Apple face?")

# Comparative analysis
query("Which company has the most risk factors?")
query("What risks do Apple and Microsoft share?")
```

## Key Takeaways

1. **MCP standardizes tool integration** - One protocol for connecting AI agents to any data source
2. **Schema-first approach** - Understanding data structure enables accurate query generation
3. **Natural language to Cypher** - LLMs can translate questions into graph queries
4. **Separation of concerns** - The MCP server handles database access; the agent handles reasoning

## Next Steps

**Congratulations!** You have completed all labs in the workshop.

You now have hands-on experience with:
- Building no-code AI agents with Neo4j Aura Agents
- Building GraphRAG pipelines with the neo4j-graphrag library
- Calling Aura Agents programmatically via REST API
- Connecting LLM agents to Neo4j via the Model Context Protocol

## Resources

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Neo4j MCP Server](https://github.com/neo4j/mcp)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Strands Agents](https://github.com/awslabs/strands-agents)
- [Amazon Bedrock AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/)
