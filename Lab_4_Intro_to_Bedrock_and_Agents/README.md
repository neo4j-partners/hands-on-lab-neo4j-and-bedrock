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

## Sagemaker Studio Setup

1 - Change your region to US West (Oregon) in the AWS Management Console.
2 - Open SageMaker AI in the AWS Management Console.  CAUTION BE SURE TO OPEN SAGEMAKER AI NOT SAGEMAKER.
IMAGE: 01-naviagte-to-sagemaker-ai.png

3 - Be sure you are in Amazon SageMaker AI and not Amazon SageMaker!!!!
4 - Click on Setup up for single user
IMAGE: 02_sagemaker_setup.png

5 - Click on Open Studio
IMAGE: 03_Amazon_SageMaker_Studio.png

6 - Click on JupyterLab
IMAGE: 04_Open_JupyterLab.png

7 - Click on the Quick start -> Launch now
IMAGE: 05_Quick_Start_Launch_Now.png

8 - Wait for the Status of the Space to be Running
9 - Click on the Name - quickstart-default to open it
IMAGE: 06_Click_Quick_start_space.png

10 - Click on Create Folder and Create a folder named labs
IMAGE: 08_create_folder.png

11 - Click on the labs folder to open it

12 - Click on Clone Git Repository and Clone the repository ...
IMAGE: 08_Clone_Git_Repository.png

## LangGraph Agent Architecture

The notebook demonstrates a minimal ReAct-style agent with two nodes:

```
START -> agent -> (tools -> agent) | END
```

1. **Agent Node**: Calls the LLM with the current message history
2. **Tools Node**: Executes any tool calls the LLM requests
3. **Conditional Edge**: Routes back to tools if the LLM made tool calls, otherwise ends

This pattern allows the agent to reason about what tools to use, execute them, observe results, and continue until it has a final answer.

## Import from GitHub to SageMaker Studio

For the rest of the labs, we're going to be working with notebooks in SageMaker Studio. To load them into Studio, we're going to pull them from GitHub using Studio's git integration.

Click on the git icon in the upper left of Studio. It's below the folder icon on the extreme left of the menu.

![](images/15.png)

Now click "Clone a Repository."

![](images/16.png)

In the dialog, enter the address of the git repo:

    https://github.com/neo4j-partners/hands-on-lab-neo4j-and-bedrock.git

Then click "Clone."

![](images/17.png)

When complete, it will open the README.md for this repo. In the file explorer on the left, double click on "Lab_4_Intro_to_Bedrock_and_Agents."

![](images/18.png)

## Run the Agent Notebook

1. Open `basic_langgraph_agent.ipynb` in this lab folder
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
