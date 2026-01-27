# Lab 4 - Building AI Agents with Amazon Bedrock and SageMaker

This lab introduces you to building AI agents using Amazon Bedrock within SageMaker Studio notebooks. You'll learn how LangGraph orchestrates LLM interactions and tool usage through a hands-on example.

## What You'll Learn

- How to configure and invoke Amazon Bedrock models from SageMaker notebooks
- The basics of LangGraph agent architecture (nodes, edges, and state)
- How to define tools that an LLM can call
- The ReAct pattern: reasoning and acting in a loop

## Amazon Bedrock Overview

Amazon Bedrock provides access to foundation models from Anthropic, Meta, and others through a unified API. In this lab, we use Claude via cross-region inference profiles, which route requests to available capacity across AWS regions.

Key concepts:
- **Model ID**: Identifies the specific model (e.g., `us.anthropic.claude-sonnet-4-20250514-v1:0`)
- **Inference Profile**: Enables cross-region routing for better availability
- **ChatBedrockConverse**: LangChain's interface to Bedrock's Converse API

## SageMaker Studio Setup

### Step 1: Navigate to SageMaker AI

1. In the AWS Management Console, click the **region selector** in the upper right corner and select **US West (Oregon)** / `us-west-2`
2. In the search bar at the top, type `SageMaker`
3. **Important:** Select **Amazon SageMaker AI** from the results (not "Amazon SageMaker" - they are different services!)

![Navigate to SageMaker AI](images/01-naviagte-to-sagemaker-ai.png)

### Step 2: Set up a Domain

1. Verify you see **Amazon SageMaker AI** in the left sidebar (not just "Amazon SageMaker")
2. In the left panel under "Environment configuration", click on **Domains**, then click the **Create domain** button in the top right corner.

   ![SageMaker AI Domains page showing Domains menu and Create domain button](images/A1-Create-Domain.png)

3. Select **Set up for single user (Quick setup)** on the left, then click the **Set up** button. This creates a domain with default settings perfect for getting started.

   ![Set up SageMaker Domain page showing Set up for single user option](images/A2-Setup-Single-User.png)

### Step 3: Open SageMaker Studio

1. Wait while your environment is being set up (this takes 1-2 minutes)
2. You'll see progress indicators for IAM role creation, internet access, encryption, and storage
3. Once setup completes, click **Open Studio** at the bottom of the page

![Open Studio](images/03_Amazon_SageMaker_Studio.png)

### Step 4: Launch JupyterLab

1. In SageMaker Studio Home, you'll see the Overview tab with different workflow options
2. Click on the **JupyterLab** card - this lets you create and run Jupyter notebooks in a dedicated environment

![Open JupyterLab](images/04_Open_JupyterLab.png)

### Step 5: Create a JupyterLab Space

1. Under **Space templates**, find the **Quick start** option (ml.t3.medium • 5 GB • 4 GiB RAM)
2. Click **Launch now** to create a lightweight development environment perfect for this lab

![Quick Start Launch](images/05_Quick_Start_Launch_Now.png)

### Step 6: Open Your Space

1. Wait for the **Status** column to show **Running** (this may take 1-2 minutes)
2. Once running, click on the space name (e.g., **quickstart-default-t...**) in the Name column to open JupyterLab

![JupyterLab spaces list showing Running status and space name to click](images/06_Click_Quick_start_space.png)

### Step 7: Create a Labs Folder

1. In the JupyterLab file browser on the left, click the **Create New Folder** icon (folder with a + sign)
2. Name the folder `labs` and press Enter
3. Double-click the **labs** folder to open it

![Create Folder](images/08_create_folder.png)

### Step 8: Clone the Git Repository

1. With the `labs` folder open, click on the **Git icon** in the left sidebar (it looks like a diamond/branch symbol)
2. Click **Clone a Repository** button
3. In the "Clone Git Repository" dialog, enter the repository URL:
   ```
   https://github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock.git
   ```
4. Leave "Open README files" checked and click **Clone** to download the lab materials

![Clone Git Repository](images/09_clone_git_repository.png)

## Introduction to Agents

In this section, we'll run the notebook [basic_langgraph_agent.ipynb](basic_langgraph_agent.ipynb) which demonstrates how to build a basic AI agent using LangGraph and Amazon Bedrock. This hands-on example shows the fundamental concepts of agent architecture - how an LLM can reason about problems, decide which tools to use, and iterate until it reaches a solution.

AI agents extend beyond simple chat interactions by giving LLMs the ability to take actions. Instead of just generating text responses, agents can call functions (tools), observe the results, and continue reasoning. This creates a powerful loop where the model can break down complex tasks into steps and execute them autonomously.

### LangGraph Agent Architecture

The notebook demonstrates a minimal ReAct-style agent with two nodes:

```
START -> agent -> (tools -> agent) | END
```

1. **Agent Node**: Calls the LLM with the current message history
2. **Tools Node**: Executes any tool calls the LLM requests
3. **Conditional Edge**: Routes back to tools if the LLM made tool calls, otherwise ends

This pattern allows the agent to reason about what tools to use, execute them, observe results, and continue until it has a final answer.

## Run the Agent Notebook

1. Open [basic_langgraph_agent.ipynb](basic_langgraph_agent.ipynb) in this lab folder
2. The notebook loads configuration from `../CONFIG.txt` (MODEL_ID and REGION)
3. Run through the cells to:
   - Install required packages
   - Define simple tools (get_current_time, add_numbers)
   - Build and compile the LangGraph agent
   - Test the agent with sample queries

This confirms that LangGraph and Bedrock are working correctly before you add Neo4j and MCP in Lab 5.

## Key Code Patterns

### Defining Tools

```python
@tool
def get_current_time() -> str:
    """Get the current date and time."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
```

The `@tool` decorator converts a Python function into a tool the LLM can call. The docstring becomes the tool description.

### Binding Tools to the LLM

```python
llm = ChatBedrockConverse(model=MODEL_ID, region_name=REGION)
llm_with_tools = llm.bind_tools(tools)
```

### Building the Graph

```python
graph = StateGraph(MessagesState)
graph.add_node("agent", call_model)
graph.add_node("tools", ToolNode(tools))
graph.add_edge(START, "agent")
graph.add_conditional_edges("agent", should_continue)
graph.add_edge("tools", "agent")
agent = graph.compile()
```

## Next Steps

Continue to [Lab 5 - GraphRAG with Neo4j](../Lab_5_GraphRAG) to learn how to build GraphRAG pipelines using the neo4j-graphrag library with Amazon Titan embeddings.
