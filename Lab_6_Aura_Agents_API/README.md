# Lab 6 - Aura Agents API

In this lab, you'll learn how to call the Neo4j Aura Agent you created in Lab 2 programmatically using Python. This enables you to integrate your no-code Aura Agent into applications, scripts, and automated workflows.

## Prerequisites

Before starting, make sure you have:
- Completed **Lab 0** (AWS sign-in)
- Completed **Lab 1** (Neo4j Aura setup)
- Completed **Lab 2** (Built an Aura Agent with tools)
- Completed **Lab 4** (SageMaker setup)

## Lab Overview

In Lab 2, you built a powerful GraphRAG agent using Neo4j's visual agent builder. That agent can:
- Answer questions about SEC 10-K filings
- Use Cypher template tools to query company data
- Perform semantic similarity searches
- Generate Cypher queries from natural language

Now you'll learn to call that same agent via a REST API, enabling:
- **Application Integration**: Embed the agent in web apps, mobile apps, or microservices
- **Automation**: Include agent calls in data pipelines and workflows
- **Batch Processing**: Ask multiple questions programmatically
- **Custom UIs**: Build your own chat interfaces

## What You'll Learn

1. **OAuth2 Authentication**: How to authenticate with the Neo4j API
2. **API Invocation**: How to call your Aura Agent's REST endpoint
3. **Response Parsing**: How to extract text, thinking, and tool usage from responses
4. **Token Management**: How to cache and refresh access tokens automatically
5. **Async Patterns**: How to make concurrent requests for better performance

## Getting Your API Credentials

### Step 1: Get Your API Key

1. Log in to [Neo4j Aura Console](https://console.neo4j.io/)
2. Click your **profile icon** in the top right corner
3. Go to **Settings**
4. Select the **API keys** tab
5. Click **Create API Key**
6. Copy and save both the **Client ID** and **Client Secret**

> **Important**: The Client Secret is only shown once. Save it securely!

### Step 2: Get Your Agent Endpoint

1. In the Aura Console, navigate to your agent
2. Click on your agent to open its details
3. Click the **Copy endpoint** button
4. The URL will look like: `https://api.neo4j.io/v2beta1/organizations/.../projects/.../agents/.../invoke`

### Step 3: Enable External Access (if not already done)

Your agent must have **External** visibility to be called via API:
1. Open your agent's settings
2. Ensure **External endpoint** is enabled

## Lab Notebook

This lab contains one comprehensive notebook:

### aura_agent_client.ipynb - Python Client for Aura Agents

Build and use a complete Python client to call your Aura Agent:
- Understand OAuth2 client credentials flow
- Create type-safe response models with Pydantic
- Build a reusable client class
- Test with sample questions about your SEC filing data
- Explore agent thinking and tool usage
- Make concurrent async requests

## Getting Started

1. Open the notebook: `aura_agent_client.ipynb`
2. Paste your credentials in the Configuration section:
   - `NEO4J_CLIENT_ID` - Your API key Client ID
   - `NEO4J_CLIENT_SECRET` - Your API key Client Secret
   - `NEO4J_AGENT_ENDPOINT` - Your agent's endpoint URL
3. Run through the notebook cells

## Authentication Flow

The client handles authentication automatically:

```
1. Request Token
   POST https://api.neo4j.io/oauth/token
   - Basic Auth: client_id:client_secret
   - Body: grant_type=client_credentials
   → Response: { access_token, expires_in: 3600 }

2. Invoke Agent
   POST {agent_endpoint}/invoke
   - Authorization: Bearer {access_token}
   - Body: { input: "your question" }
   → Response: { content, status, usage }
```

Tokens are cached for 1 hour and automatically refreshed when expired.

## Example Usage

After completing the notebook, you can call your agent like this:

```python
# Create client
client = AuraAgentClient(
    client_id="your-client-id",
    client_secret="your-client-secret",
    endpoint_url="https://api.neo4j.io/.../invoke"
)

# Ask a question
response = client.invoke("Tell me about Apple's risk factors")
print(response.text)

# View agent reasoning
print(response.thinking)

# Check tool usage
for tool in response.tool_uses:
    print(f"Used tool: {tool.type}")
```

## Sample Questions

Try these questions with your agent (same as Lab 2):

**Company Overview:**
- "Tell me about Apple Inc and their major investors"
- "What is NVIDIA's business and what risks do they face?"

**Comparative Analysis:**
- "What risks do Apple and Microsoft share?"
- "Compare the risk factors between tech companies"

**Semantic Search:**
- "What do the filings say about AI and machine learning?"
- "Find mentions of supply chain challenges"

**Structured Queries:**
- "Which company has the most risk factors?"
- "List all the products mentioned for Microsoft"

## Key Concepts

| Concept | Description |
|---------|-------------|
| **OAuth2 Client Credentials** | Authentication flow for machine-to-machine API access |
| **Bearer Token** | Access token included in API request headers |
| **Token Caching** | Reusing tokens until they expire (1 hour) |
| **Pydantic Models** | Type-safe data validation for API responses |
| **Async/Await** | Python pattern for concurrent, non-blocking operations |

## Next Steps

Continue to [Lab 7 - Neo4j MCP Agent](../Lab_7_Neo4j_MCP_Agent) to build an AI agent that queries your Neo4j knowledge graph using the Model Context Protocol.

## Resources

- [Neo4j Aura Agents Documentation](https://neo4j.com/developer/genai-ecosystem/aura-agent/)
- [Neo4j API Authentication](https://neo4j.com/docs/aura/platform/api/authentication/)
- [Build a GraphRAG Agent in Minutes](https://neo4j.com/blog/genai/build-context-aware-graphrag-agent/)
