# Exploring the Knowledge Graph

In this section, you will use Neo4j Explore to visually navigate and analyze your knowledge graph. You'll learn how to search for patterns, visualize relationships, and apply graph algorithms to gain insights from your data.

## Step 1: Access the Aura Console

Go back to the Neo4j Aura console at [console.neo4j.io](https://console.neo4j.io).

## Step 2: Open Explore

In the left sidebar, click on **Explore** under the Tools section. This opens Neo4j's visual graph exploration tool.

![](images/Explore.png)

Click **Connect to instance** to connect to your database.

![](images/Connect_instance.png)

## Step 3: Search for Asset Manager Relationships

In the search bar, build a pattern to explore the relationships between asset managers, companies, and risk factors. Type `AssetManager`, then select the **OWNS** relationship, followed by **Company**, then **FACES_RISK**, and finally **RiskFactor`.

This creates the pattern: `AssetManager — OWNS → Company — FACES_RISK → RiskFactor`

![](images/asset_manager_owns.png)

## Step 4: Visualize the Knowledge Graph

After executing the search, you'll see a visual representation of the knowledge graph. The graph shows AssetManager nodes (orange) connected to Company nodes (pink) through OWNS relationships, and Company nodes connected to RiskFactor nodes (yellow) through FACES_RISK relationships. The visualization reveals how different asset managers are exposed to various risk factors through the companies they own.

![](images/company_graph.png)

**Tips for Exploring:**

*Zoom and Pan*
- **Zoom**: Scroll wheel or pinch gesture
- **Pan**: Click and drag the canvas
- **Center**: Double-click on empty space

*Inspect Nodes and Relationships*
- Click on a node to see its properties
- Click on a relationship to see its type
- Expand nodes to see more connections

## Step 5: Access Graph Data Science

To analyze the graph structure, click on the **Graph Data Science** button in the left toolbar. This opens the data science panel where you can apply graph algorithms.

![](images/graph_data_science.png)

## Step 6: Apply Degree Centrality Algorithm

Click **Add algorithm** and select **Degree Centrality** from the dropdown. This algorithm measures the number of incoming and outgoing relationships for each node, helping identify the most connected nodes in your graph.

Click **Apply algorithm** to run the analysis.

![](images/degree_centrality.png)

## Step 7: Size Nodes Based on Scores

After the algorithm completes, you'll see a notification showing how many scores were added. Click **Size nodes based on scores** to visually represent the centrality - nodes with more connections will appear larger.

![](images/size_nodes.png)

## Step 8: Analyze the Results

The graph now displays nodes sized according to their degree centrality scores. Asset managers (pink/salmon nodes) that own more companies appear larger, making it easy to visually identify the most significant institutional investors in your dataset.

![](images/degree_centality_graph.png)
