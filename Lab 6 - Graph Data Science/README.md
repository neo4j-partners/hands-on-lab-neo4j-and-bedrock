# Lab 6 - Graph Data Science
In this lab, we're going to work with anoter notebook.  We're going to generate a graph embedding using Neo4j Graph Data Science (GDS).  This will be an additional feature we can use to train our machine learning model later.

# Create a Graph Embedding
So, let's get started!  As before, navigate to the notebook at "/hands-on-lab-neo4j-and-sagemaker/Lab 6 - Graph Data Science/1_create_embedding.ipynb," fire up a kernel and run through it.

## Autopilot on Embeddings
Now we're going to train a binary classifier on the full dataset, with the graph embeddings.  We'll use SageMaker Autopilot.  Navigate to the notebook at "/hands-on-lab-neo4j-and-sagemaker/Lab 6 - Graph Data Science/2_autopilot_embedding.ipynb."  Then run that.

## Autopilot on Raw Data
To compare, we'll train a binary classifier on the original dataset, without the graph embeddings.  We'll use SageMaker Autopilot.  Navigate to the notebook at "/hands-on-lab-neo4j-and-sagemaker/Lab 6 - Graph Data Science/3_autopilot_raw.ipynb."  Then run that.