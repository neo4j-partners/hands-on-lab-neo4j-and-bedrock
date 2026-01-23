# Lab 5 - Neo4j MCP Agent

In this lab, you'll build an AI agent that queries your Neo4j knowledge graph using the **Model Context Protocol (MCP)**. The agent uses natural language to interact with the database, automatically generating and executing Cypher queries.

## Overview

The Model Context Protocol (MCP) is an open standard that enables AI assistants to securely connect to external data sources and tools. In this lab, you'll connect to a **pre-deployed Neo4j MCP Server** running on **Amazon Bedrock AgentCore**.

### What You'll Build

An AI agent that can:
- Retrieve the database schema from Neo4j
- Answer natural language questions about the SEC filings knowledge graph
- Generate and execute Cypher queries automatically
- Format results in human-readable responses

### Choose Your Framework

You can build the agent using either:

| Framework | Notebook | Best For |
|-----------|----------|----------|
| **LangGraph** | `neo4j_langgraph_mcp_agent.ipynb` | LangChain ecosystem users |
| **Strands Agents** | `neo4j_strands_mcp_agent.ipynb` | AWS-native development |

Both notebooks connect to the same MCP server and produce equivalent results.

## Prerequisites

- Completed **Lab 4** (SageMaker setup with repo cloned)
- **MCP Gateway credentials** (provided by workshop facilitator)
- **Inference Profile ARN** (created in Lab 4 optional step, or create now)

## Architecture

The Neo4j MCP Server has been pre-deployed to Amazon Bedrock AgentCore. Here's how the architecture works:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Your Notebook  │────▶│    AgentCore    │────▶│   Neo4j MCP     │────▶│   Neo4j Aura    │
│  (SageMaker)    │ JWT │    Gateway      │OAuth│    Server       │     │   Database      │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │
        │ Bedrock API           │ Validates JWT
        ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  Claude LLM     │     │ Amazon Cognito  │
│  (Bedrock)      │     │ (OAuth2 Tokens) │
└─────────────────┘     └─────────────────┘
```

### Component Overview

| Component | Description |
|-----------|-------------|
| **AgentCore Gateway** | Entry point for MCP requests with JWT authentication |
| **AgentCore Runtime** | Runs the Neo4j MCP Server in isolated MicroVMs |
| **Neo4j MCP Server** | Exposes Neo4j as MCP tools (schema retrieval, Cypher execution) |
| **Amazon Cognito** | Provides OAuth2 tokens for M2M authentication |
| **AWS Bedrock** | Hosts Claude LLM for agent reasoning |

### MCP Tools Available

When you connect to the Gateway, you'll have access to these tools:

| Tool | Description |
|------|-------------|
| `neo4j-mcp-server-target___get-schema` | Retrieves the database schema (labels, relationships, properties) |
| `neo4j-mcp-server-target___read-cypher` | Executes read-only Cypher queries |

> **Note:** Tool names are prefixed with the Gateway target name (`neo4j-mcp-server-target___`). The notebooks handle this automatically.

### Why AgentCore?

The MCP server runs on AgentCore (not Lambda or Fargate) because:

- **Session Isolation**: Each session runs in a dedicated MicroVM with complete isolation
- **Long-Running Sessions**: Supports sessions up to 8 hours (vs Lambda's 15-minute limit)
- **Built-in Observability**: Automatic tracing of agent reasoning and tool calls
- **Unified Gateway**: Single endpoint with authentication for multiple MCP servers

## Configuration

### Step 1: Get Your Credentials

Your workshop facilitator will provide a `.mcp-credentials.json` file or the values directly. You need:

| Field | Description | Example |
|-------|-------------|---------|
| `gateway_url` | AgentCore Gateway endpoint | `https://xxx.execute-api.us-west-2.amazonaws.com/mcp` |
| `access_token` | JWT bearer token for authentication | `eyJ...` |

### Step 2: Create an Inference Profile (If Not Done)

If you skipped the optional step in Lab 4, create an inference profile now:

1. Open a terminal in SageMaker Studio
2. Navigate to the lab folder:
   ```bash
   cd hands-on-lab-neo4j-and-bedrock/Lab_5_Neo4j_MCP_Agent
   ```
3. Run the setup script:
   ```bash
   ./setup-inference-profile.sh haiku
   ```
4. Copy the ARN output - you'll paste this in the notebook

> **Tip:** Use `haiku` for testing (fast & cheap) or `sonnet` for better quality responses.

## Running the Notebooks

### Option A: LangGraph Agent

1. In SageMaker Studio, navigate to `Lab_5_Neo4j_MCP_Agent`
2. Open `neo4j_langgraph_mcp_agent.ipynb`
3. In the **Configuration** cell, paste your values:
   ```python
   INFERENCE_PROFILE_ARN = "arn:aws:bedrock:us-west-2:..."  # From setup script
   GATEWAY_URL = "https://..."  # From credentials
   ACCESS_TOKEN = "eyJ..."  # From credentials
   ```
4. Run all cells to:
   - Install dependencies
   - Connect to the MCP server
   - Query the Neo4j knowledge graph

### Option B: Strands Agent

1. In SageMaker Studio, navigate to `Lab_5_Neo4j_MCP_Agent`
2. Open `neo4j_strands_mcp_agent.ipynb`
3. In the **Configuration** cell, paste your values:
   ```python
   INFERENCE_PROFILE_ARN = "arn:aws:bedrock:us-west-2:..."
   GATEWAY_URL = "https://..."
   ACCESS_TOKEN = "eyJ..."
   ```
4. Run all cells

### Sample Questions to Try

Once the agent is running, try asking questions about the SEC filings knowledge graph:

```python
# Schema exploration
query("What is the database schema?")

# Count queries
query("How many companies are in the database?")
query("How many risk factors are there?")

# Relationship queries
query("What companies does BlackRock own?")
query("What risk factors does Apple face?")

# Comparative analysis
query("Which company has the most risk factors?")
query("What risks do Apple and Microsoft share?")
```

## How It Works

1. **You ask a question** in natural language
2. **The LLM analyzes** the question and decides which MCP tool to call
3. **First tool call**: Usually `get-schema` to understand the database structure
4. **Second tool call**: `read-cypher` with a generated Cypher query
5. **The LLM synthesizes** the results into a human-readable response

Example flow for "How many companies are in the database?":

```
User: "How many companies are in the database?"
    ↓
LLM: Calls get-schema to understand the data model
    ↓
MCP Server: Returns schema with Company, RiskFactor, AssetManager labels
    ↓
LLM: Formulates Cypher query: MATCH (c:Company) RETURN count(c)
    ↓
LLM: Calls read-cypher with the query
    ↓
MCP Server: Executes query, returns [{"count(c)": 8}]
    ↓
LLM: "There are 8 companies in the database."
```

## Troubleshooting

### Token Expired

If you see authentication errors, your access token may have expired (tokens last ~1 hour). Ask your facilitator for a fresh token.

### Connection Timeout

If connections time out:
- Verify the `GATEWAY_URL` is correct
- Check that you're connected to the internet
- Try running the test connection cell again

### Model Access Denied

If you see "AccessDeniedException":
- Verify your inference profile ARN is correct
- Ensure the profile was created with the `setup-inference-profile.sh` script
- Check that the profile has the `AmazonBedrockManaged=true` tag

### No Results Returned

If queries return empty results:
- First run the schema query to see available labels
- Check that your Cypher patterns match the actual schema
- Remember the database was populated from SEC 10-K filings

## Summary

You've built an AI agent that:
- Connects to Neo4j via the Model Context Protocol
- Uses Claude (via AWS Bedrock) for natural language understanding
- Automatically generates Cypher queries
- Retrieves and formats data from the SEC filings knowledge graph

This demonstrates how MCP enables **secure, standardized connections** between AI agents and enterprise data sources.

## Going Further

To learn more about the MCP server deployment:
- [Neo4j MCP Server Repository](https://github.com/neo4j/mcp)
- [Amazon Bedrock AgentCore Documentation](https://docs.aws.amazon.com/bedrock-agentcore/)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Strands Agents Documentation](https://github.com/awslabs/strands-agents)
