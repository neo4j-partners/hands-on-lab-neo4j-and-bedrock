# hands-on-lab-neo4j-and-sagemaker
Neo4j is the [leading graph database](https://neo4j.com/whitepapers/forrester-wave-graph-data-platforms/) vendor.  We’ve worked closely with AWS Engineering for years.  Our products, Neo4j Graph Database, Graph Data Science and Bloom are offered in the [AWS Marketplace](https://aws.amazon.com/marketplace/seller-profile?id=23ec694a-d2af-4641-b4d3-b7201ab2f5f9).

This workshop is a hands of lab with Neo4j and SageMaker.  The goal of this workshop is to give tangible experience working with both products on AWS.  The data set we'll be using is from the SEC EDGAR database.  Specifically, the public filings of asset manages with $100m or more under management.  We'll use Neo4j to explore their holdings.  Then we'll use SageMaker to predict which holdings they'll have next quarter.

## Venue
These workshops are organized onsite in an AWS office.

## Duration
3 hours.

15+20+15+10+10+20+20+15+15+15+20+10

## Agenda
* Introductions
* Lecture - Introduction to Neo4j (15 min)
    * What is Neo4j?
    * Customer use cases
    * How is it deployed and managed on AWS?
* [Lab 1 - Deploy Neo4j](Lab%201%20-%20Deploy%20Neo4j/README.md) (20 min)
    * Sign up for AWS
    * Apply AWS Credits
    * Pick a Region
    * Create a Key Pair
    * Configure VPC
    * Deploying Neo4j Enterprise Edition through the Marketplace
    * Cloud Formation Template
* [Lab 2 - Connect to Neo4j](Lab%202%20-%20Connect%20to%20Neo4j/README.md) (15 min)
    * Neo4j Browser
    * Neo4j Bloom
    * Interacting via Shell
* Break (10 min)
* Lecture - Moving Data (10 min)
    * LOAD CSV
    * Data Importer
    * Kafka
    * Spark
    * Glue
* [Lab 3 - Moving Data](Lab%203%20-%20Moving%20Data/README.md) (20 min)
    * LOAD CSV
    * Data Importer
* Break (10 min)
* Lecture - Graph Data Science (15 min)
    * Why Graph Data Science
    * Neo4j GDS Library and Catalog
    * Algorithm Families and Examples
    * Similarity
    * Centrality
    * Community Detection
    * Graph Machine Learning
* [Lab 4 - Exploring Data](Lab%204%20-%20Exploring%20Data/README.md) 15 min)
    * Cypher Queries
    * Vizualization with Bloom
* [Lab 5 - Graph Data Science](Lab%205%20-%20Graph%20Data%20Science/README.md) (15 min)
    * Creating a graph embedding
    * Exporting to pandas
    * Writing to AWS S3
* Lecture - SageMaker (15 min)
    * What is SageMaker?
    * Using SageMaker with Neo4j
* [Lab 6 - SageMaker](Lab%206%20-%20SageMaker/README.md) (20 min)
    * Create a SageMaker Domain
    * SageMaker Studio
    * Importing to SageMaker
    * Training a model
* [Discussion - Questions and Next Steps](Discussion%20-%20Questions%20and%20Next%20Steps.md) (10 min)
