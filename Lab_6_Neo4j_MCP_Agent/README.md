# Lab 6 - Building AI Agents with MCP and Neo4j

This lab introduces two key concepts: how AI agents interact with external tools using the **Model Context Protocol (MCP)**, and how the **Neo4j MCP Server** enables natural language querying of graph databases.

> **Prerequisites**: Before running this lab, you must configure the MCP connection settings in `CONFIG.txt`. You can either:
> 1. Obtain the credentials from your workshop host, or
> 2. Deploy the Neo4j MCP Server to AWS yourself using [aws-starter](https://github.com/neo4j-partners/aws-starter)
>
> See [Deploying the Neo4j MCP Server to AWS](#deploying-the-neo4j-mcp-server-to-aws) below for deployment details.

## What is the Model Context Protocol (MCP)?

MCP is an open standard that defines how AI assistants connect to external data sources and tools. Think of it as a universal adapter—instead of building custom integrations for every tool, MCP provides a consistent interface that any AI agent can use.

### The Problem MCP Solves

Without MCP, connecting an AI agent to external tools requires:
- Custom code for each integration
- Handling authentication differently per service
- Parsing tool-specific response formats
- Managing connection lifecycle manually

With MCP, you write the integration once and any MCP-compatible agent can use it. This is similar to how USB standardized peripheral connections—before USB, every device needed a custom port; now any USB device works with any USB port.

MCP standardizes all of this into a simple protocol:

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   AI Agent   │◀──MCP──▶│  MCP Server  │◀───────▶│  Data Source │
│              │         │              │         │  (Neo4j, etc)│
└──────────────┘         └──────────────┘         └──────────────┘
```

### How Agents Call MCP Servers

An MCP server exposes **tools** that agents can discover and invoke. Tools are essentially functions with defined inputs and outputs that the LLM can choose to call. The interaction follows this pattern:

1. **Discovery**: The agent connects and requests the list of available tools. Each tool includes a name, description, and input schema that helps the LLM understand when and how to use it.
2. **Tool Selection**: The LLM analyzes the user's question and decides which tool(s) to call. This decision is based on the tool descriptions and the LLM's reasoning about what information is needed.
3. **Invocation**: The agent sends a tool call request with parameters. The MCP protocol ensures the request format is consistent regardless of what the tool does.
4. **Response**: The MCP server executes the tool and returns results in a standardized format.
5. **Synthesis**: The LLM incorporates the results into its response, potentially calling additional tools if needed.

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

MCP supports multiple transport mechanisms, allowing flexibility in how agents communicate with servers:

| Transport | Use Case | Pros |
|-----------|----------|------|
| **stdio** | Local processes (CLI tools, desktop apps) | Simple setup, no network required |
| **HTTP/SSE** | Remote servers, cloud deployments | Scalable, works across networks, firewall-friendly |
| **WebSocket** | Real-time bidirectional communication | Low latency, persistent connections |

In this lab, we use **Streamable HTTP** transport (the modern replacement for HTTP/SSE) to connect to a remote MCP server hosted on AWS. This transport is ideal for cloud deployments because it works through standard HTTPS, supports authentication headers, and can be load-balanced across multiple server instances.

## The Neo4j MCP Server

The [Neo4j MCP Server](https://github.com/neo4j/mcp) exposes Neo4j graph databases through the MCP protocol. This is a game-changer for building AI applications with graph data because it enables AI agents to:

- **Understand database structure** through schema introspection—the agent learns what nodes and relationships exist
- **Execute Cypher queries** using natural language—users don't need to know Cypher syntax
- **Retrieve graph data** without manual query writing—the LLM generates appropriate queries automatically
- **Explore connected data** by following relationships—perfect for questions like "what's related to X?"

The server acts as a secure intermediary, ensuring that only read operations are performed and that the LLM never sees raw database credentials.

### Available Tools

The Neo4j MCP Server provides two primary tools that work together:

| Tool | Purpose | When the LLM Uses It |
|------|---------|---------------------|
| `get-schema` | Retrieves node labels, relationship types, and properties | First call—to understand what data exists before querying |
| `read-cypher` | Executes read-only Cypher queries | After understanding schema—to fetch actual data |

The **schema-first pattern** is critical: the LLM calls `get-schema` to learn the database structure, then uses that knowledge to construct accurate Cypher queries. Without schema context, the LLM would have to guess at node labels and relationship types, leading to failed queries.

### Deploying the Neo4j MCP Server to AWS

The Neo4j MCP Server can be deployed to AWS using [Amazon Bedrock AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/), which provides a managed infrastructure for hosting MCP servers. The [aws-starter](https://github.com/neo4j-partners/aws-starter) repository automates this deployment.

**How the deployment works:**

1. **AgentCore Gateway**: Acts as a secure entry point that handles authentication, rate limiting, and routing of MCP requests. Your agent connects to this gateway endpoint.

2. **MCP Server Runtime**: AgentCore hosts the Neo4j MCP Server as a containerized service. The server maintains the connection pool to Neo4j and exposes the MCP tools.

3. **Neo4j Connection**: The MCP server connects to your Neo4j Aura (or self-hosted) instance using credentials stored securely in AWS Secrets Manager.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AWS Account                                        │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐     │
│  │  AgentCore       │     │  Neo4j MCP       │     │  Secrets         │     │
│  │  Gateway         │────▶│  Server          │────▶│  Manager         │     │
│  │  (HTTPS endpoint)│     │  (Container)     │     │  (Credentials)   │     │
│  └──────────────────┘     └──────────────────┘     └──────────────────┘     │
│           │                        │                                         │
└───────────│────────────────────────│─────────────────────────────────────────┘
            │                        │
            ▼                        ▼
    ┌──────────────┐         ┌──────────────┐
    │  Your Agent  │         │  Neo4j Aura  │
    │  (Notebook)  │         │  Database    │
    └──────────────┘         └──────────────┘
```

**Deployment steps** (via aws-starter):

1. Clone the repository and configure your Neo4j connection details
2. Run the deployment script to provision AgentCore resources
3. Copy the gateway endpoint URL and API key to your `CONFIG.txt`

This approach provides enterprise-grade security, scalability, and monitoring without managing infrastructure directly.

### Why Schema Matters

Graph databases are schema-flexible, meaning structure emerges from the data rather than being predefined. This flexibility is powerful but creates a challenge: how does an AI agent know what to query?

The `get-schema` tool solves this by helping agents understand:

- **Node labels**: What types of entities exist (e.g., `Company`, `RiskFactor`, `AssetManager`)
- **Relationship types**: How entities connect (e.g., `(:Company)-[:HAS_RISK]->(:RiskFactor)`)
- **Properties**: What attributes each node type has (e.g., `Company.name`, `Company.ticker`)
- **Cardinality**: Rough counts that help the LLM understand data distribution

This context enables the LLM to generate accurate Cypher queries. For example, if a user asks "What risks does Apple face?", the LLM needs to know:
1. Companies are stored as `(:Company)` nodes with a `name` property
2. Risks connect via `[:HAS_RISK]` relationships
3. Risk details are in `(:RiskFactor)` nodes

Without this schema context, the LLM might guess wrong (e.g., using `RISK` instead of `HAS_RISK`) and return empty results.

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

Two notebooks demonstrate the same concepts using different agent frameworks. Both connect to the same Neo4j MCP Server and produce equivalent results—the difference is in the programming model and ecosystem:

| Framework | Notebook | Best For |
|-----------|----------|----------|
| **LangGraph** | `neo4j_langgraph_mcp_agent.ipynb` | Teams already using LangChain; complex multi-step workflows |
| **Strands Agents** | `neo4j_strands_mcp_agent.ipynb` | AWS-native development; simpler API; lightweight deployments |

**LangGraph** is part of the LangChain ecosystem and uses a graph-based execution model where you define nodes (actions) and edges (transitions). It's powerful for complex agent workflows but has more concepts to learn.

**Strands Agents** is AWS's lightweight agent SDK designed for simplicity. It uses a straightforward `Agent` class that you configure with a model and tools. The API is minimal, making it easy to get started and debug.

Choose based on your team's existing stack and complexity needs. For this lab, both approaches work identically.

## Sample Queries

Once connected, try these natural language queries. Notice how the complexity increases—the agent handles everything from simple lookups to multi-hop graph traversals:

```python
# Explore the data model (agent calls get-schema)
query("What is the database schema?")

# Simple counts (single MATCH with aggregation)
query("How many companies are in the database?")

# Relationship traversal (follows one relationship type)
query("What companies does BlackRock own?")
query("What risk factors does Apple face?")

# Comparative analysis (requires multiple queries or complex patterns)
query("Which company has the most risk factors?")
query("What risks do Apple and Microsoft share?")

# Multi-hop queries (traverses multiple relationships)
query("What asset managers own companies with supply chain risks?")
```

**What's happening behind the scenes**: For each query, the agent typically makes 2+ tool calls—first `get-schema` to understand the data model, then one or more `read-cypher` calls to fetch results. You can observe this in the notebook output.

## Key Takeaways

1. **MCP standardizes tool integration** - One protocol for connecting AI agents to any data source. Write the integration once, use it from any MCP-compatible agent framework.

2. **Schema-first approach** - Understanding data structure enables accurate query generation. The `get-schema` → `read-cypher` pattern ensures the LLM knows what to query before attempting it.

3. **Natural language to Cypher** - LLMs can translate questions into graph queries without users knowing Cypher syntax. This democratizes access to graph data.

4. **Separation of concerns** - The MCP server handles database access (connection pooling, query execution, security); the agent handles reasoning (understanding questions, generating queries, synthesizing responses). This modularity makes systems easier to build and maintain.

5. **Graph databases excel at connected queries** - Questions involving relationships ("what's connected to X?", "what do A and B have in common?") are natural fits for graph databases and hard to answer with traditional SQL.

## Next Steps

Continue to [Lab 7 - Aura Agents API](../Lab_7_Aura_Agents_API) to learn how to programmatically invoke your Aura Agent via REST API with OAuth2 authentication.

## Resources

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Neo4j MCP Server](https://github.com/neo4j/mcp)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Strands Agents](https://github.com/awslabs/strands-agents)
- [Amazon Bedrock AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/)
