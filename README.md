# hands-on-lab-neo4j-and-bedrock
Neo4j is the [leading graph database](https://db-engines.com/en/ranking/graph+dbms) vendor.  We’ve worked closely with AWS engineering for years.  Our products, AuraDB and AuraDS are offered as managed services.  These are available on AWS through the [AWS Marketplace](https://aws.amazon.com/marketplace/seller-profile?id=23ec694a-d2af-4641-b4d3-b7201ab2f5f9).

In this hands on lab, you’ll get to learn about Neo4j, Amazon Bedrock, Anthropic Claude and Amazon SageMaker.  The lab is intended for data scientists and data engineers.  We’ll walk through deploying Neo4j and SageMaker on AWS in an AWS account.  Then we’ll get hands on with a real world dataset.  First we'll use generative AI to parse and load data.  Then we'll show how to layer a chatbot powered by generative AI with LangChain over the knowledge graph.  We'll even use the new vector search and index functionality in Neo4j with Bedrock for semantic search.  You’ll come out of this lab with enough knowledge to apply graph generative AI to your own datasets.

We’re going to analyze the quarterly filings of asset managers with $100m+ assets under management (AUM).  These are regulatory filings made to the Securities and Exchange Commission’s (SEC) EDGAR system.  We’re going to show how to load that data from an S3 bucket into Neo4j.  We’ll then explore the relationships of different asset managers and their holdings using the Neo4j Browser and Neo4j’s Cypher query language.

If you’re in the capital markets space, we think you’ll be interested in potential applications of this approach to creating new features for algorithmic trading, understanding tail risk, securities master data management and so on.  If you’re not in the capital markets space, this session will still be useful to learn about building machine learning pipelines with Neo4j and Amazon Bedrock.

## Venue
These workshops are organized onsite in an AWS office.

## Duration
3 hours.

## Prerequisites
You'll need a laptop with a web browser.  Your browser will need to be able to access the AWS Console and port 7687 on a Neo4j deployment running on AWS.  If your laptop has a firewall you can't control on it, you may want to bring your personal laptop.

## Agenda
### Part 1
* Introductions
* [Lecture - Introduction to Neo4j](https://docs.google.com/presentation/d/1-wrPfSdyx-5qvFKX29BvpN-K-uWAOYEqYzz6J4LA30U/edit?usp=sharing) (10 min)
    * What is Neo4j?
    * How is it deployed and managed on AWS?
* [Lab 0 - Sign In](Lab%200%20-%20Sign%20In) (5 min)
    * Improving the Labs
    * Sign into AWS
* [Lab 1 - Deploy Neo4j](Lab%201%20-%20Deploy%20Neo4j) (15 min)
    * Deploying Neo4j AuraDS Professional
* [Lab 2 - Connect to Neo4j](Lab%202%20-%20Connect%20to%20Neo4j/README.md) (10 min)
* Break (5 min)

### Part 2
* [Lecture - Moving Data](https://docs.google.com/presentation/d/1vVCqNHYs-hLcIhBiN3UbmUU8M76anrqG_NzphZKQuW8/edit?usp=sharing) (10 min)
    * LOAD CSV
    * Amazon Elastic Map Reduce (EMR)
    * Amazon Managed Streaming for Kafka
* [Lab 3 - Moving Data](Lab%203%20-%20Moving%20Data/README.md) (15 min)
    * Simple Load Statement
    * More Performant Load
* [Lab 4 - Exploration](Lab%204%20-%20Exploration/README.md) (10 min)
    * Exploration with Neo4j Bloom
* Break (5 min)

### Part 3
* [Lecture - Amazon Bedrock](https://docs.google.com/presentation/d/1s1iGIH9lBvVw2S32iZW-9gogFWT63Je-qw7Wz5YSKXw/edit?usp=sharing) (15 min)
    * What is Bedrock?
    * Generative AI
* [Lecture - Neo4j and Generative AI](https://docs.google.com/presentation/d/1DE2X8N3ufbEQPiyb2I5muOw0riC7wE9kW5iVe2QzR28/edit?usp=sharing) (15 min)
    * Generating Knowledge Graphs
    * Retrieval Augmented Generation
    * Semantic Search
    * Using Bedrock with Neo4j
* [Lab 5 - Parsing Data](Lab%205%20-%20Parsing%20Data/README.md) (20 min)
    * Setup SageMaker Studio
    * Parsing Data
* [Lab 6 - Chatbot](Lab%206%20-%20Chatbot/README.md) (20 min)
    * Prompt Engineering 
    * Few Shot Learning
    * Using the Chatbot
* [Lab 7 - Semantic Search](Lab%207%20-%20Semantic%20Search/README.md) (20 min)
    * Text Embedding
    * Vector Search
    * Graph Traversal
    * Graph Algorithms for Similairty
* [Questions and Next Steps](Questions%20and%20Next%20Steps.md) (5 min)
