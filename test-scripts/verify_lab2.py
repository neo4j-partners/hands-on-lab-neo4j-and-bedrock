#!/usr/bin/env python3
"""
Neo4j Lab 2 Verification Script

This script connects to the Neo4j database and verifies that the schema
and data match the Lab 2 Aura Agents instructions.
"""

import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from neo4j import GraphDatabase

# Load .env from parent directory
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(env_path)

NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_USERNAME = os.getenv("NEO4J_USERNAME")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")
NEO4J_DATABASE = os.getenv("NEO4J_DATABASE", "neo4j")


def print_section(title: str) -> None:
    """Print a section header."""
    print(f"\n{'='*60}")
    print(f" {title}")
    print(f"{'='*60}")


def print_subsection(title: str) -> None:
    """Print a subsection header."""
    print(f"\n--- {title} ---")


def verify_connection(driver) -> bool:
    """Verify database connection."""
    print_section("CONNECTION TEST")
    try:
        driver.verify_connectivity()
        print(f"[OK] Connected to {NEO4J_URI}")
        return True
    except Exception as e:
        print(f"[FAIL] Connection failed: {e}")
        return False


def explore_schema(driver) -> dict:
    """Explore and report on the database schema."""
    print_section("DATABASE SCHEMA")
    schema_info = {"labels": [], "relationships": [], "indexes": []}

    with driver.session(database=NEO4J_DATABASE) as session:
        # Get node labels and counts
        print_subsection("Node Labels")
        result = session.run("""
            CALL db.labels() YIELD label
            CALL apoc.cypher.run('MATCH (n:`' + label + '`) RETURN count(n) as count', {})
            YIELD value
            RETURN label, value.count as count
            ORDER BY count DESC
        """)
        try:
            for record in result:
                schema_info["labels"].append(
                    {"label": record["label"], "count": record["count"]}
                )
                print(f"  - {record['label']}: {record['count']} nodes")
        except Exception:
            # APOC might not be available, use simpler query
            result = session.run("CALL db.labels() YIELD label RETURN label")
            labels = [record["label"] for record in result]
            for label in labels:
                count_result = session.run(
                    f"MATCH (n:`{label}`) RETURN count(n) as count"
                )
                count = count_result.single()["count"]
                schema_info["labels"].append({"label": label, "count": count})
                print(f"  - {label}: {count} nodes")

        # Get relationship types
        print_subsection("Relationship Types")
        result = session.run("""
            CALL db.relationshipTypes() YIELD relationshipType
            RETURN relationshipType
        """)
        rel_types = [record["relationshipType"] for record in result]
        for rel_type in rel_types:
            count_result = session.run(
                f"MATCH ()-[r:`{rel_type}`]->() RETURN count(r) as count"
            )
            count = count_result.single()["count"]
            schema_info["relationships"].append({"type": rel_type, "count": count})
            print(f"  - {rel_type}: {count} relationships")

        # Get indexes
        print_subsection("Indexes")
        result = session.run("SHOW INDEXES")
        for record in result:
            index_info = {
                "name": record.get("name"),
                "type": record.get("type"),
                "labelsOrTypes": record.get("labelsOrTypes"),
                "properties": record.get("properties"),
                "state": record.get("state"),
            }
            schema_info["indexes"].append(index_info)
            print(
                f"  - {index_info['name']} ({index_info['type']}): "
                f"{index_info['labelsOrTypes']} {index_info['properties']} [{index_info['state']}]"
            )

    return schema_info


def verify_lab2_schema(schema_info: dict) -> dict:
    """Verify that expected Lab 2 schema elements exist."""
    print_section("LAB 2 SCHEMA VERIFICATION")

    expected_labels = ["Company", "Document", "RiskFactor", "AssetManager"]
    expected_relationships = ["FILED", "FACES_RISK", "OWNS"]
    expected_vector_index = "chunkEmbeddings"

    results = {"labels": {}, "relationships": {}, "indexes": {}}

    print_subsection("Expected Node Labels")
    actual_labels = [l["label"] for l in schema_info["labels"]]
    for label in expected_labels:
        found = label in actual_labels
        results["labels"][label] = found
        status = "[OK]" if found else "[MISSING]"
        print(f"  {status} {label}")

    # Check for additional mentioned labels
    optional_labels = ["Executive", "Product", "Chunk"]
    print_subsection("Optional/Additional Labels (mentioned in lab)")
    for label in optional_labels:
        found = label in actual_labels
        results["labels"][label] = found
        status = "[OK]" if found else "[NOT FOUND]"
        print(f"  {status} {label}")

    print_subsection("Expected Relationship Types")
    actual_rels = [r["type"] for r in schema_info["relationships"]]
    for rel_type in expected_relationships:
        found = rel_type in actual_rels
        results["relationships"][rel_type] = found
        status = "[OK]" if found else "[MISSING]"
        print(f"  {status} {rel_type}")

    print_subsection("Vector Index")
    actual_indexes = [i["name"] for i in schema_info["indexes"]]
    found = expected_vector_index in actual_indexes
    results["indexes"][expected_vector_index] = found
    status = "[OK]" if found else "[MISSING]"
    print(f"  {status} {expected_vector_index}")

    return results


def test_cypher_queries(driver) -> dict:
    """Test the Cypher queries from Lab 2 instructions."""
    print_section("CYPHER QUERY VERIFICATION")
    query_results = {}

    with driver.session(database=NEO4J_DATABASE) as session:
        # Test 1: Get Company Overview
        print_subsection("Tool 1: get_company_overview")
        try:
            # First find a company name to test with
            company_result = session.run(
                "MATCH (c:Company) RETURN c.name as name LIMIT 1"
            )
            company_record = company_result.single()
            if company_record:
                company_name = company_record["name"]
                print(f"  Testing with company: {company_name}")

                result = session.run(
                    """
                    MATCH (c:Company {name: $company_name})
                    OPTIONAL MATCH (c)-[:FILED]->(d:Document)
                    OPTIONAL MATCH (c)-[:FACES_RISK]->(r:RiskFactor)
                    OPTIONAL MATCH (am:AssetManager)-[:OWNS]->(c)
                    WITH c, d,
                         collect(DISTINCT r.name)[0..10] AS risks,
                         collect(DISTINCT am.managerName)[0..10] AS owners
                    RETURN
                        c.name AS company,
                        c.ticker AS ticker,
                        d.path AS filing_path,
                        risks AS top_risk_factors,
                        owners AS major_asset_managers
                    """,
                    company_name=company_name,
                )
                record = result.single()
                if record:
                    print(f"  [OK] Query executed successfully")
                    print(f"      Company: {record['company']}")
                    print(f"      Ticker: {record['ticker']}")
                    print(f"      Filing: {record['filing_path']}")
                    print(f"      Risk factors: {len(record['top_risk_factors'])} found")
                    print(f"      Asset managers: {len(record['major_asset_managers'])} found")
                    query_results["get_company_overview"] = True
                else:
                    print(f"  [WARN] No results returned")
                    query_results["get_company_overview"] = False
            else:
                print(f"  [FAIL] No companies found in database")
                query_results["get_company_overview"] = False
        except Exception as e:
            print(f"  [FAIL] Query error: {e}")
            query_results["get_company_overview"] = False

        # Test 2: Find Shared Risks
        print_subsection("Tool 2: find_shared_risks")
        try:
            # Get two company names
            companies_result = session.run(
                "MATCH (c:Company) RETURN c.name as name LIMIT 2"
            )
            companies = [r["name"] for r in companies_result]
            if len(companies) >= 2:
                company1, company2 = companies[0], companies[1]
                print(f"  Testing with: {company1} vs {company2}")

                result = session.run(
                    """
                    MATCH (c1:Company)-[:FACES_RISK]->(r:RiskFactor)<-[:FACES_RISK]-(c2:Company)
                    WHERE c1.name = $company1 AND c2.name = $company2
                    WITH c1, c2, collect(DISTINCT r.name) AS shared_risks
                    RETURN
                        c1.name AS company_1,
                        c2.name AS company_2,
                        shared_risks,
                        size(shared_risks) AS num_shared_risks
                    """,
                    company1=company1,
                    company2=company2,
                )
                record = result.single()
                if record:
                    print(f"  [OK] Query executed successfully")
                    print(f"      Shared risks: {record['num_shared_risks']}")
                    query_results["find_shared_risks"] = True
                else:
                    print(f"  [WARN] No shared risks found (query works but no data)")
                    query_results["find_shared_risks"] = True
            else:
                print(f"  [FAIL] Need at least 2 companies")
                query_results["find_shared_risks"] = False
        except Exception as e:
            print(f"  [FAIL] Query error: {e}")
            query_results["find_shared_risks"] = False

        # Test 3: Get Asset Manager Portfolio
        print_subsection("Future Tool: get_manager_portfolio")
        try:
            manager_result = session.run(
                "MATCH (am:AssetManager) RETURN am.managerName as name LIMIT 1"
            )
            manager_record = manager_result.single()
            if manager_record:
                manager_name = manager_record["name"]
                print(f"  Testing with manager: {manager_name}")

                result = session.run(
                    """
                    MATCH (am:AssetManager {managerName: $manager_name})-[o:OWNS]->(c:Company)
                    OPTIONAL MATCH (c)-[:FACES_RISK]->(r:RiskFactor)
                    WITH am, c, o, collect(DISTINCT r.name)[0..5] AS company_risks
                    RETURN
                        am.managerName AS asset_manager,
                        collect({
                            company: c.name,
                            ticker: c.ticker,
                            position_status: o.position_status,
                            key_risks: company_risks
                        }) AS portfolio
                    """,
                    manager_name=manager_name,
                )
                record = result.single()
                if record:
                    print(f"  [OK] Query executed successfully")
                    print(f"      Manager: {record['asset_manager']}")
                    print(f"      Portfolio size: {len(record['portfolio'])} companies")
                    query_results["get_manager_portfolio"] = True
                else:
                    print(f"  [WARN] No results returned")
                    query_results["get_manager_portfolio"] = False
            else:
                print(f"  [FAIL] No asset managers found")
                query_results["get_manager_portfolio"] = False
        except Exception as e:
            print(f"  [FAIL] Query error: {e}")
            query_results["get_manager_portfolio"] = False

        # Test 4: List All Companies
        print_subsection("Future Tool: list_companies")
        try:
            result = session.run(
                """
                MATCH (c:Company)
                OPTIONAL MATCH (c)-[:FACES_RISK]->(r:RiskFactor)
                WITH c, count(r) AS risk_count
                RETURN c.name AS company, c.ticker AS ticker, risk_count
                ORDER BY risk_count DESC
                LIMIT 20
                """
            )
            records = list(result)
            if records:
                print(f"  [OK] Query executed successfully")
                print(f"      Found {len(records)} companies")
                print(f"      Sample: {records[0]['company']} ({records[0]['ticker']}) - {records[0]['risk_count']} risks")
                query_results["list_companies"] = True
            else:
                print(f"  [WARN] No companies found")
                query_results["list_companies"] = False
        except Exception as e:
            print(f"  [FAIL] Query error: {e}")
            query_results["list_companies"] = False

    return query_results


def explore_sample_data(driver) -> None:
    """Explore sample data from the database."""
    print_section("SAMPLE DATA EXPLORATION")

    with driver.session(database=NEO4J_DATABASE) as session:
        # Sample companies
        print_subsection("Sample Companies")
        result = session.run(
            "MATCH (c:Company) RETURN c.name as name, c.ticker as ticker LIMIT 10"
        )
        for record in result:
            print(f"  - {record['name']} ({record['ticker']})")

        # Sample risk factors
        print_subsection("Sample Risk Factors")
        result = session.run(
            "MATCH (r:RiskFactor) RETURN r.name as name LIMIT 10"
        )
        for record in result:
            name = record["name"]
            if name and len(name) > 60:
                name = name[:60] + "..."
            print(f"  - {name}")

        # Sample asset managers
        print_subsection("Sample Asset Managers")
        result = session.run(
            "MATCH (am:AssetManager) RETURN am.managerName as name LIMIT 10"
        )
        for record in result:
            print(f"  - {record['name']}")

        # Check for chunks (for vector search)
        print_subsection("Chunk Nodes (for vector search)")
        result = session.run(
            "MATCH (c:Chunk) RETURN count(c) as count"
        )
        record = result.single()
        if record and record["count"] > 0:
            print(f"  Found {record['count']} Chunk nodes")
            # Check for embeddings
            result = session.run(
                "MATCH (c:Chunk) WHERE c.embedding IS NOT NULL RETURN count(c) as count"
            )
            embed_count = result.single()["count"]
            print(f"  Chunks with embeddings: {embed_count}")
        else:
            print(f"  No Chunk nodes found")

        # Check all node properties
        print_subsection("Node Property Keys")
        for label in ["Company", "Document", "RiskFactor", "AssetManager", "Chunk"]:
            try:
                result = session.run(
                    f"MATCH (n:{label}) WITH keys(n) as k UNWIND k as key "
                    f"RETURN DISTINCT key ORDER BY key"
                )
                keys = [r["key"] for r in result]
                if keys:
                    print(f"  {label}: {', '.join(keys)}")
            except Exception:
                pass


def generate_summary(schema_verification: dict, query_results: dict) -> None:
    """Generate a summary of verification results."""
    print_section("VERIFICATION SUMMARY")

    # Count results
    labels_ok = sum(
        1 for k, v in schema_verification["labels"].items() if v and k in ["Company", "Document", "RiskFactor", "AssetManager"]
    )
    labels_total = 4

    rels_ok = sum(1 for v in schema_verification["relationships"].values() if v)
    rels_total = len(schema_verification["relationships"])

    indexes_ok = sum(1 for v in schema_verification["indexes"].values() if v)
    indexes_total = len(schema_verification["indexes"])

    queries_ok = sum(1 for v in query_results.values() if v)
    queries_total = len(query_results)

    print(f"\nSchema Elements:")
    print(f"  Node Labels:    {labels_ok}/{labels_total} required labels found")
    print(f"  Relationships:  {rels_ok}/{rels_total} relationship types found")
    print(f"  Indexes:        {indexes_ok}/{indexes_total} expected indexes found")

    print(f"\nCypher Queries:")
    print(f"  Queries tested: {queries_ok}/{queries_total} working")

    # Overall assessment
    print(f"\n{'='*60}")
    if labels_ok == labels_total and rels_ok == rels_total:
        print(" [PASS] Lab 2 instructions appear ACCURATE")
        print("        Database schema matches expected structure.")
    else:
        print(" [PARTIAL] Lab 2 instructions need review")
        print("           Some expected schema elements are missing.")
    print(f"{'='*60}")


def main():
    """Main entry point."""
    print("\nNeo4j Lab 2 Verification Script")
    print("================================")
    print(f"URI: {NEO4J_URI}")
    print(f"Database: {NEO4J_DATABASE}")

    if not all([NEO4J_URI, NEO4J_USERNAME, NEO4J_PASSWORD]):
        print("\n[ERROR] Missing required environment variables.")
        print("Please ensure .env file contains NEO4J_URI, NEO4J_USERNAME, NEO4J_PASSWORD")
        sys.exit(1)

    driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USERNAME, NEO4J_PASSWORD))

    try:
        if not verify_connection(driver):
            sys.exit(1)

        schema_info = explore_schema(driver)
        schema_verification = verify_lab2_schema(schema_info)
        query_results = test_cypher_queries(driver)
        explore_sample_data(driver)
        generate_summary(schema_verification, query_results)

    finally:
        driver.close()


if __name__ == "__main__":
    main()
