# hands-on-lab-neo4j-and-sagemaker
Neo4j is the [leading graph database](https://neo4j.com/whitepapers/forrester-wave-graph-data-platforms/) vendor.  We’ve worked closely with AWS Engineering for years.  Our products, Neo4j Graph Database, Graph Data Science and Bloom are offered in the AWS Marketplace.

This workshop is a hands of lab with Neo4j and Vertex AI.  The goal of this workshop is to give tangible experience working with both products on AWS.  The data set we'll be using is from the SEC EDGAR database.  Specifically, the public filings of asset manages with $100m or more under management.  We'll use Neo4j to explore their holdings.  Then we'll use SageMaker to predict which holdings they'll have next quarter.

## Venue
These workshops are organized onsite in an AWS office.

## Duration
3 hours.

## Agenda
* Lecture - Introduction to Neo4j (20 min)
    * What is Neo4j?
    * Customer use cases
    * How is it deployed and managed on AWS?
* [Lab 1 - Deploy Neo4j](Lab%201%20-%20Deploy%20Neo4j.md) (20 min)
    * Deploying Neo4j Enterprise through the Marketplace
    * Cloud Formation Template
    * Graph Database
    * Graph Data Science
    * Bloom
* Break (10 min)
* Lecture - Neo4j and AWS (20 min)
    * Partnership overview
    * Integration points
* [Lab 2 - Moving Data](Lab%202%20-%20Moving%20Data.md) (20 min)
    * Import data into Neo4j
* [Lab 3 - Exploring Data](Lab%203%20-%20Exploring%20Data.md) (20 min)
    * Cypher Queries
    * Visualization with Bloom
* Break (10 min)
* [Lab 4 - Graph Data Science](Lab%204%20-%20Graph%20Data%20Science.md) (30 min)
    * Why Graph Data Science
    * Neo4j GDS Library and Catalog
    * Algorithm Families and Examples
    * Similarity
    * Centrality
    * Community Detection
    * Graph Machine Learning
* Lab 4 - Graph Data Science (30 min)
    * Creating a graph embedding
    * Exporting to pandas
    * Importing to SageMaker
    * Training a model
* Discussion - Questions and Next Steps (10 min)