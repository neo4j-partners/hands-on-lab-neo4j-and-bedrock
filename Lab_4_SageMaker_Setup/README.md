# Lab 4 - SageMaker Setup

In this lab, you'll set up Amazon SageMaker Studio and clone the workshop repository. This prepares your development environment for building AI agents that connect to Neo4j using the Model Context Protocol (MCP).

## Create a SageMaker Domain

Open the AWS console at [console.aws.amazon.com](https://console.aws.amazon.com/). In the search bar, type "sagemaker."

![](images/01.png)

From the search results, click on "SageMaker Studio" under "Amazon SageMaker AI."

![](images/02.png)

A SageMaker Domain is a container for notebooks and other artifacts deployed within SageMaker. It can be deployed to be shared across an entire data science department. However, for our uses, we only need a single user.

Click "Set up for single user."

![](images/03.png)

Click on the button with orange background - "JupyterLab".

![](images/08.png)

From the top right, click on "Create JupyterLab Space" button.

![](images/09.png)

Provide a name for your JupyterLab space, perhaps "neo4j-mcp-agent."

![](images/10.png)

Click "Create Space"

![](images/11.png)

You will land on the page below. Wait for a few seconds to see the "Run space" button enabled.

Click the "Run space" button.

![](images/12.png)

After a couple of minutes, you will see the space created and the "Open JupyterLab" button enabled. Click that button which will open a new window.

![](images/13.png)

When the window is loaded, you'll land in SageMaker Studio. This is Amazon's hosted notebook environment.

![](images/14.png)

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

When complete, it will open the README.md for this repo. In the file explorer on the left, double click on "Lab_4_SageMaker_Setup."

![](images/18.png)

## Test LangGraph with Bedrock (Optional)

If you want to verify your SageMaker environment is working correctly with AWS Bedrock, you can run the minimal agent notebook:

1. Open `minimal_langgraph_agent.ipynb` in this lab folder
2. Follow the instructions to create an inference profile
3. Run through the cells to test a simple LangGraph agent

This optional step confirms that LangGraph and Bedrock are working before you add the MCP complexity in Lab 5.

## Next Steps

Continue to [Lab 5 - Neo4j MCP Agent](../Lab_5_Neo4j_MCP_Agent) to build an AI agent that queries your Neo4j knowledge graph using the Model Context Protocol.
