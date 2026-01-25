# Lab 1: Neo4j Aura Setup and Exploration

In this lab, you will set up your Neo4j Aura database on Azure Marketplace, restore the knowledge graph from a backup, and explore your graph visually.

## Prerequisites

- Completed **Lab 0** (Azure sign-in)
- Access to Azure Portal

## Part 1: Neo4j Aura Signup

Follow the instructions in [Neo4j_Aura_Signup.md](Neo4j_Aura_Signup.md) to:

1. Subscribe to Neo4j Aura through Azure Marketplace
2. Create your Neo4j Aura account
3. Configure and provision your database instance
4. Save your connection credentials

## Part 2: Restore the Backup

After your Aura instance is running, restore the pre-built knowledge graph:

1. Go to your instance in the [Aura Console](https://console.neo4j.io)
2. Click the **...** menu on your instance and select **Backup & restore**

![](images/backup_restore.png)

3. Click **Upload backup** to open the upload dialog, then drag the backup file into the dialog:

   ![](images/restore_drag.png)

   **Use the pre-built backup file**
   - Drag the file `finance_data.backup` from the `data/` folder in this lab

4. Wait for the restore to complete - your instance will restart with the SEC 10-K filings knowledge graph

The backup contains:
- SEC 10-K filing documents from major companies (Apple, Microsoft, NVIDIA, etc.)
- Extracted entities: Companies, Risk Factors, Products, Executives, Financial Metrics
- Asset manager ownership data
- Text chunks with vector embeddings for semantic search

## Part 3: Explore the Knowledge Graph

Follow [EXPLORE.md](EXPLORE.md) to:

1. Use Neo4j Explore to visually navigate your graph
2. Search for patterns between asset managers, companies, and risk factors
3. Apply graph algorithms like Degree Centrality
4. Identify key entities through visual analysis

## Part 4: Save Your Credentials

Save your Neo4j credentials for use in later labs:

1. Open the file `CONFIG.txt` in the root of this repository
2. Replace the placeholder values with your actual credentials from the downloaded file:
   - `NEO4J_URI` - Your connection URI (e.g., `neo4j+s://xxxxxxxx.databases.neo4j.io`)
   - `NEO4J_USERNAME` - Usually `neo4j`
   - `NEO4J_PASSWORD` - Your database password
3. Save the file

### CONFIG.txt Reference

The `CONFIG.txt` file contains all settings for the workshop. Here's when each setting is used:

| Setting | Used In | Description |
|---------|---------|-------------|
| `MODEL_ID` | Lab 4+ | AWS Bedrock model ID (pre-configured) |
| `BASE_MODEL_ID` | Lab 4+ | AWS Bedrock base model ID (pre-configured) |
| `REGION` | Lab 4+ | AWS region (pre-configured: us-west-2) |
| `NEO4J_URI` | Lab 5+ | **Fill in after Lab 1** - Your Aura connection URI |
| `NEO4J_USERNAME` | Lab 5+ | **Fill in after Lab 1** - Usually `neo4j` |
| `NEO4J_PASSWORD` | Lab 5+ | **Fill in after Lab 1** - Your database password |
| `MCP_GATEWAY_URL` | Lab 5 | Fill in after AgentCore Gateway setup |
| `MCP_ACCESS_TOKEN` | Lab 5 | Fill in after AgentCore Gateway setup |
| `NEO4J_CLIENT_ID` | Lab 6 | Fill in after creating Aura Agent API key |
| `NEO4J_CLIENT_SECRET` | Lab 6 | Fill in after creating Aura Agent API key |
| `NEO4J_AGENT_ENDPOINT` | Lab 6 | Fill in after creating Aura Agent |

All notebooks load their configuration from this single file using `python-dotenv`.

## Next Steps

After completing this lab, continue to [Lab 2 - Aura Agents](../Lab_2_Aura_Agents) to build an AI-powered agent using the Neo4j Aura Agent no-code platform.
