"""
Neo4j GraphRAG Retrievers

Run different retriever examples:
    uv run python main.py 1  # Vector Retriever
    uv run python main.py 2  # Vector Cypher Retriever
    uv run python main.py 3  # Text2Cypher Retriever
"""

import argparse
import os
import sys

from dotenv import load_dotenv
from neo4j import GraphDatabase
from neo4j_graphrag.retrievers import VectorRetriever, VectorCypherRetriever, Text2CypherRetriever
from neo4j_graphrag.generation import GraphRAG
from neo4j_graphrag.schema import get_schema
from neo4j_graphrag.llm import BedrockLLM
from neo4j_graphrag.embeddings import OpenAIEmbeddings


# ============================================================
# Cypher Queries for VectorCypherRetriever
# ============================================================

ASSET_MANAGER_QUERY = """
MATCH (node)-[:FROM_DOCUMENT]-(doc:Document)-[:FILED]-(company:Company)
WITH node, company, COLLECT {
  MATCH (company)-[:OWNS]-(manager:AssetManager)
  RETURN manager.managerName
  LIMIT 5
} AS managers
RETURN company.name AS company, managers AS AssetManagersWithSharesInCompany, node.text AS context
"""

# ============================================================
# Prompt for Text2CypherRetriever
# ============================================================

TEXT2CYPHER_PROMPT = """Task: Generate a Cypher statement to query a graph database.

Instructions:
- Use only the provided relationship types and properties in the schema.
- Do not use any other relationship types or properties that are not provided.
- Only filter by name when a specific entity name is mentioned in the question.
  When filtering by name, use case-insensitive matching:
  `WHERE toLower(node.name) CONTAINS toLower('ActualEntityName')`
- Do NOT add name filters if no specific entity name is mentioned in the question.
- Always add LIMIT 20 to the end of your query to restrict results.

Modern Cypher Requirements:
- Use `elementId(node)` instead of `id(node)` (id() is removed in Neo4j 5+).
- Use `count{{pattern}}` instead of `size((pattern))` for counting patterns.
- Use `EXISTS {{MATCH pattern}}` instead of `exists((pattern))` for existence checks.
- When using ORDER BY, filter NULL values first: `WHERE property IS NOT NULL ORDER BY property`.
- Use explicit grouping with WITH clauses for aggregations.
- Limit collected results when appropriate: `collect(item)[0..20]`.

Schema:
{schema}

Note: Do not include any explanations or apologies in your responses.
Do not respond to any questions that might ask anything else than for you to construct a Cypher statement.
Do not include any text except the generated Cypher statement.

The question is:
{query_text}"""


def load_config() -> dict:
    """Load configuration from environment variables."""
    load_dotenv()

    config = {
        "inference_profile_id": os.getenv("AWS_BEDROCK_INFERENCE_PROFILE_ID", "us.anthropic.claude-sonnet-4-5-20250929-v1:0"),
        "region": os.getenv("AWS_REGION", "us-west-2"),
        "openai_api_key": os.getenv("OPENAI_API_KEY"),
        "neo4j_uri": os.getenv("NEO4J_URI"),
        "neo4j_username": os.getenv("NEO4J_USERNAME", "neo4j"),
        "neo4j_password": os.getenv("NEO4J_PASSWORD"),
    }

    return config


def validate_config(config: dict, need_openai: bool = True):
    """Validate configuration and exit if incomplete."""
    errors = []
    if not config["inference_profile_id"]:
        errors.append("AWS_BEDROCK_INFERENCE_PROFILE_ID is required")
    if need_openai and not config["openai_api_key"]:
        errors.append("OPENAI_API_KEY is required")
    if not config["neo4j_uri"]:
        errors.append("NEO4J_URI is required")
    if not config["neo4j_password"]:
        errors.append("NEO4J_PASSWORD is required")

    if errors:
        print("ERROR: Configuration incomplete!")
        for e in errors:
            print(f"  - {e}")
        print("\nCopy .env.sample to .env and fill in your values.")
        sys.exit(1)

    # Display configuration
    print(f"Inference Profile: {config['inference_profile_id']}")
    print(f"Region: {config['region']}")


def connect_neo4j(config: dict):
    """Connect to Neo4j database."""
    driver = GraphDatabase.driver(
        config["neo4j_uri"],
        auth=(config["neo4j_username"], config["neo4j_password"])
    )
    driver.verify_connectivity()
    print("Connected to Neo4j successfully!")
    return driver


def create_llm(config: dict) -> BedrockLLM:
    """Create AWS Bedrock LLM using inference profile."""
    return BedrockLLM(
        inference_profile_id=config["inference_profile_id"],
        region_name=config["region"],
    )


def create_embedder(config: dict) -> OpenAIEmbeddings:
    """Create OpenAI embedder (matching the vector index)."""
    return OpenAIEmbeddings(
        api_key=config["openai_api_key"],
        model="text-embedding-ada-002",
    )


def run_search(rag: GraphRAG, query: str, top_k: int = 5, use_top_k: bool = True):
    """Run a GraphRAG search and display results."""
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    print('='*60)

    # Text2Cypher doesn't use top_k - result limiting is in the Cypher prompt
    if use_top_k:
        response = rag.search(query, retriever_config={"top_k": top_k}, return_context=True)
    else:
        response = rag.search(query, return_context=True)

    print(f"\nResults: {len(response.retriever_result.items)}")
    print("-"*60)
    print(response.answer)


def interactive_loop(rag: GraphRAG, sample_queries: list, top_k: int = 5, use_top_k: bool = True):
    """Run interactive query loop."""
    print("\n" + "="*60)
    print("Sample queries:")
    for i, q in enumerate(sample_queries, 1):
        print(f"  {i}. {q}")
    print("="*60)

    while True:
        try:
            user_input = input("\nEnter query (or 'quit'): ").strip()
            if user_input.lower() in ('quit', 'exit', 'q'):
                break
            if user_input:
                run_search(rag, user_input, top_k, use_top_k)
        except KeyboardInterrupt:
            print("\n")
            break


# ============================================================
# Retriever 1: Vector Retriever
# ============================================================

def run_vector_retriever(config: dict, query: str, top_k: int):
    """Run the Vector Retriever example."""
    print("\n" + "="*60)
    print("RETRIEVER 1: Vector Retriever")
    print("="*60)
    print("Uses semantic similarity to find relevant text chunks.")

    validate_config(config, need_openai=True)
    driver = connect_neo4j(config)

    try:
        llm = create_llm(config)
        embedder = create_embedder(config)
        print("LLM and Embedder initialized!")

        retriever = VectorRetriever(
            driver=driver,
            index_name='chunkEmbeddings',
            embedder=embedder,
            return_properties=['text']
        )
        print("Vector Retriever ready!")

        rag = GraphRAG(llm=llm, retriever=retriever)
        run_search(rag, query, top_k)

        interactive_loop(rag, [
            "What products does Microsoft reference?",
            "What warnings have Nvidia given?",
            "What companies mention AI in their filings?",
        ], top_k)

    finally:
        driver.close()
        print("Connection closed.")


# ============================================================
# Retriever 2: Vector Cypher Retriever
# ============================================================

def run_vector_cypher_retriever(config: dict, query: str, top_k: int):
    """Run the Vector Cypher Retriever example."""
    print("\n" + "="*60)
    print("RETRIEVER 2: Vector Cypher Retriever")
    print("="*60)
    print("Combines vector search with graph traversal for richer context.")

    validate_config(config, need_openai=True)
    driver = connect_neo4j(config)

    try:
        llm = create_llm(config)
        embedder = create_embedder(config)
        print("LLM and Embedder initialized!")

        retriever = VectorCypherRetriever(
            driver=driver,
            index_name='chunkEmbeddings',
            embedder=embedder,
            retrieval_query=ASSET_MANAGER_QUERY
        )
        print("VectorCypher Retriever ready!")

        rag = GraphRAG(llm=llm, retriever=retriever)
        run_search(rag, query, top_k)

        interactive_loop(rag, [
            "Which asset managers have the most diverse portfolios?",
            "What financial institutions invest in Apple?",
            "Who invests in technology companies?",
        ], top_k)

    finally:
        driver.close()
        print("Connection closed.")


# ============================================================
# Retriever 3: Text2Cypher Retriever
# ============================================================

def run_text2cypher_retriever(config: dict, query: str, top_k: int):
    """Run the Text2Cypher Retriever example."""
    print("\n" + "="*60)
    print("RETRIEVER 3: Text2Cypher Retriever")
    print("="*60)
    print("Converts natural language to Cypher queries using LLM.")

    validate_config(config, need_openai=False)  # No embeddings needed
    driver = connect_neo4j(config)

    try:
        llm = create_llm(config)
        print("LLM initialized!")

        schema = get_schema(driver)
        print("Schema retrieved!")

        retriever = Text2CypherRetriever(
            driver=driver,
            llm=llm,
            neo4j_schema=schema,
            custom_prompt=TEXT2CYPHER_PROMPT
        )
        print("Text2Cypher Retriever ready!")

        rag = GraphRAG(llm=llm, retriever=retriever)
        run_search(rag, query, top_k, use_top_k=False)

        interactive_loop(rag, [
            "What companies are in the database?",
            "How many risk factors does Apple face?",
            "What products does NVIDIA mention?",
            "Which company faces the most risk factors?",
        ], top_k, use_top_k=False)

    finally:
        driver.close()
        print("Connection closed.")


# ============================================================
# Main
# ============================================================

DEFAULT_QUERIES = {
    1: "What are the risks that Apple faces?",
    2: "Who are the asset managers most affected by banking regulations?",
    3: "What companies are in the database?",
}

RETRIEVER_NAMES = {
    1: "Vector Retriever",
    2: "Vector Cypher Retriever",
    3: "Text2Cypher Retriever",
}


def main():
    parser = argparse.ArgumentParser(
        description="Run Neo4j GraphRAG Retriever examples",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  uv run python main.py 1                    # Vector Retriever
  uv run python main.py 2                    # Vector Cypher Retriever
  uv run python main.py 3                    # Text2Cypher Retriever
  uv run python main.py 1 -q "My question"   # Custom query
  uv run python main.py 2 -k 10              # Return 10 results
        """
    )
    parser.add_argument(
        "retriever",
        type=int,
        choices=[1, 2, 3],
        help="Retriever to run: 1=Vector, 2=VectorCypher, 3=Text2Cypher"
    )
    parser.add_argument(
        "-q", "--query",
        type=str,
        default=None,
        help="Query to search for (default varies by retriever)"
    )
    parser.add_argument(
        "-k", "--top-k",
        type=int,
        default=5,
        help="Number of results to return (default: 5)"
    )
    args = parser.parse_args()

    config = load_config()
    query = args.query or DEFAULT_QUERIES[args.retriever]

    if args.retriever == 1:
        run_vector_retriever(config, query, args.top_k)
    elif args.retriever == 2:
        run_vector_cypher_retriever(config, query, args.top_k)
    elif args.retriever == 3:
        run_text2cypher_retriever(config, query, args.top_k)


if __name__ == "__main__":
    main()
