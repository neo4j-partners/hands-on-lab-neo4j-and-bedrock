# hands-on-lab-neo4j-and-sagemaker
Neo4j is the [leading graph database](https://neo4j.com/whitepapers/forrester-wave-graph-data-platforms/) vendor.  We’ve worked closely with AWS Engineering for years.  Our products, Neo4j Graph Database, Graph Data Science and Bloom are offered in the [AWS Marketplace](https://aws.amazon.com/marketplace/seller-profile?id=23ec694a-d2af-4641-b4d3-b7201ab2f5f9).

In this hands on lab, you’ll get to learn about Neo4j and AWS SageMaker.  The lab is intended for data scientists and data engineers.  We’ll walk through deploying Neo4j and SageMaker on AWS in your own AWS account.  Then we’ll get hands on with a real world dataset, building a machine learning pipeline that takes advantage of features generated using Neo4j Graph Data Science to improve prediction in AWS SageMaker.  You’ll come out of this lab with enough knowledge to apply graph feature engineering to your own datasets.

We’re going to analyze the quarterly filings of asset managers with $100m+ assets under management (AUM).  These are regulatory filings made to the Securities and Exchange Commission’s (SEC) EDGAR system.  We’re going to show how to load that data from an AWS S3 bucket into Neo4j.  We’ll then explore the relationships of different asset managers and their holdings using the Neo4j Browser and Neo4j’s Cypher query language.

Finally, we’ll use Neo4j Graph Data Science to create a graph embedding from our data, export that out, and run supervised learning algorithms in AWS SageMaker.  We’ll try to predict what holdings asset managers will maintain or enlarge in the next quarter.  

If you’re in the capital markets space, we think you’ll be interested in potential applications of this approach to creating new features for algorithmic trading, understanding tail risk, securities master data management and so on.  If you’re not in the capital markets space, this session will still be useful to learn about building machine learning pipelines with Neo4j and AWS SageMaker.

## Venue
These workshops are organized onsite in an AWS office.

## Duration
3 hours.

## Prerequisites
You'll need a laptop with a web browser. Your browser will need to be able to access the AWS Console and port 7474 on a Neo4j deployment running in AWS.  If your laptop has a firewall you can't control on it, you may want to bring your personal laptop.

If you have an AWS account with permissions that allow you to deploy a SageMaker domain and deploy from Marketplace, then you can use that.  If not, we'll walk you through creating an AWS account.

## Agenda

### Part 1
* Introductions
* Lecture - [Introduction to Neo4j](https://docs.google.com/presentation/d/1Cue3uBcDnQ6e7w7wocOGqoKd7U8TQFZD7JohbgTrV90/edit?usp=sharing) (10 min)
    * What is Neo4j?
    * Customer use cases
    * How is it deployed and managed on AWS?
* [Lab 0 - Signup for Amazon](Lab%200%20-%20Signup%20for%20Amazon) (15 min)
    * Improving the Labs
    * Signup for Amazon Web Services
    * Apply AWS Credits
* [Lab 1 - Deploy Neo4j](Lab%201%20-%20Deploy%20Neo4j) (15 min)
    * Deploying Neo4j Enterprise Edition through the Marketplace
* [Lab 2 - Connect to Neo4j](Lab%202%20-%20Connect%20to%20Neo4j/README.md) (15 min)
    * Neo4j Browser
    * Neo4j Bloom
    * Interacting via Shell
* Break (10 min)

### Part 2
* [Lecture - Moving Data](https://docs.google.com/presentation/d/1iAMN6o-aMNtg2WAZzHORbckV--JXa2wiY5YLBNDRN3w/edit?usp=sharing) (10 min)
    * LOAD CSV
    * Amazon Elastic Map Reduce (EMR)
    * Amazon Managed Streaming for Kafka
* [Lab 3 - Moving Data](Lab%203%20-%20Moving%20Data/README.md) (15 min)
    * A Day of Data
    * A Year of Data
* [Lab 4 - Exploring Data](Lab%204%20-%20Exploring%20Data/README.md) 15 min)
    * Pandas
    * Cypher Queries
    * Vizualization with Neo4j Bloom
* Break (10 min)

### Part 3
* [Lecture - Graph Data Science](https://docs.google.com/presentation/d/1dx5ve401iHlUseznhdbHE-h-Uk97ENheS_d6tEVIcOc/edit?usp=sharing) (10 min)
    * Why Graph Data Science
    * Neo4j GDS Library and Catalog
    * Algorithm Families and Examples
    * Similarity
    * Centrality
    * Community Detection
    * Graph Machine Learning
* Lecture - SageMaker (15 min)
    * What is SageMaker?
    * Using SageMaker with Neo4j
* [Lab 5 - Graph Data Science](Lab%205%20-%20Graph%20Data%20Science/README.md) (15 min)
    * Creating a Graph Embedding
    * Exporting to pandas
    * Writing to AWS S3
* [Lab 6 - SageMaker](Lab%206%20-%20SageMaker) (20 min)
    * Raw Data
    * Data with Embedding
* [Lab 7 - Cleanup](Lab%207%20-%20Cleanup) (15 min)
* [Discussion - Questions and Next Steps](Discussion%20-%20Questions%20and%20Next%20Steps.md) (10 min)
