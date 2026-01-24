#!/usr/bin/env python3
"""
Export Neo4j Aura database to CSV files for S3 upload.

This script connects to a Neo4j Aura instance, exports all node labels
and relationship types to separate CSV files, and optionally uploads
them to an S3 bucket.

Usage:
    cp .env.example .env
    # Edit .env with your credentials
    uv sync
    uv run python export_aura.py
"""

import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from neo4j import GraphDatabase


def load_config() -> dict:
    """Load configuration from .env file."""
    load_dotenv()

    config = {
        "neo4j_uri": os.getenv("NEO4J_URI"),
        "neo4j_database": os.getenv("NEO4J_DATABASE", "neo4j"),
        "neo4j_username": os.getenv("NEO4J_USERNAME", "neo4j"),
        "neo4j_password": os.getenv("NEO4J_PASSWORD"),
        "aws_access_key_id": os.getenv("AWS_ACCESS_KEY_ID"),
        "aws_secret_access_key": os.getenv("AWS_SECRET_ACCESS_KEY"),
        "aws_region": os.getenv("AWS_REGION", "us-east-1"),
        "s3_bucket": os.getenv("S3_BUCKET"),
        "s3_prefix": os.getenv("S3_PREFIX", "neo4j-export/"),
    }

    if not config["neo4j_uri"]:
        print("Error: NEO4J_URI is required in .env file")
        sys.exit(1)
    if not config["neo4j_password"]:
        print("Error: NEO4J_PASSWORD is required in .env file")
        sys.exit(1)

    return config


def get_node_labels(driver, database: str) -> list[str]:
    """Get all node labels from the database."""
    with driver.session(database=database) as session:
        result = session.run("CALL db.labels()")
        return [record["label"] for record in result]


def get_relationship_types(driver, database: str) -> list[str]:
    """Get all relationship types from the database."""
    with driver.session(database=database) as session:
        result = session.run("CALL db.relationshipTypes()")
        return [record["relationshipType"] for record in result]


def export_nodes_to_csv(driver, database: str, label: str) -> str | None:
    """Export nodes with given label to CSV using APOC streaming."""
    query = f"""
    CALL apoc.export.csv.query(
        'MATCH (n:`{label}`) RETURN n',
        null,
        {{stream: true}}
    )
    YIELD data
    RETURN data
    """

    with driver.session(database=database) as session:
        result = session.run(query)
        record = result.single()
        if record:
            return record["data"]
    return None


def export_relationships_to_csv(driver, database: str, rel_type: str) -> str | None:
    """Export relationships of given type to CSV using APOC streaming."""
    query = f"""
    CALL apoc.export.csv.query(
        'MATCH ()-[r:`{rel_type}`]->() RETURN r',
        null,
        {{stream: true}}
    )
    YIELD data
    RETURN data
    """

    with driver.session(database=database) as session:
        result = session.run(query)
        record = result.single()
        if record:
            return record["data"]
    return None


def upload_to_s3(config: dict, export_dir: Path) -> None:
    """Upload all CSV files to S3."""
    if not config["s3_bucket"]:
        print("S3_BUCKET not configured, skipping upload")
        return

    import boto3

    # Create S3 client
    s3_kwargs = {"region_name": config["aws_region"]}
    if config["aws_access_key_id"] and config["aws_secret_access_key"]:
        s3_kwargs["aws_access_key_id"] = config["aws_access_key_id"]
        s3_kwargs["aws_secret_access_key"] = config["aws_secret_access_key"]

    s3 = boto3.client("s3", **s3_kwargs)
    bucket = config["s3_bucket"]
    prefix = config["s3_prefix"].rstrip("/")

    print(f"\nUploading to s3://{bucket}/{prefix}/")

    for csv_file in export_dir.glob("*.csv"):
        s3_key = f"{prefix}/{csv_file.name}"
        print(f"  Uploading {csv_file.name} -> {s3_key}")
        s3.upload_file(str(csv_file), bucket, s3_key)

    print(f"\nUpload complete! Files available at:")
    print(f"  s3://{bucket}/{prefix}/")


def main():
    print("Neo4j Aura Export Tool")
    print("=" * 50)

    # Load configuration
    config = load_config()
    print(f"Connecting to: {config['neo4j_uri']}")
    print(f"Database: {config['neo4j_database']}")

    # Create export directory
    export_dir = Path(__file__).parent / "export"
    export_dir.mkdir(exist_ok=True)
    print(f"Export directory: {export_dir}")

    # Connect to Neo4j
    driver = GraphDatabase.driver(
        config["neo4j_uri"],
        auth=(config["neo4j_username"], config["neo4j_password"])
    )

    try:
        # Verify connection
        driver.verify_connectivity()
        print("Connected successfully!")

        # Get schema
        print("\nDiscovering schema...")
        labels = get_node_labels(driver, config["neo4j_database"])
        rel_types = get_relationship_types(driver, config["neo4j_database"])

        print(f"  Found {len(labels)} node labels: {', '.join(labels)}")
        print(f"  Found {len(rel_types)} relationship types: {', '.join(rel_types)}")

        # Export nodes
        print("\nExporting nodes...")
        for label in labels:
            print(f"  Exporting nodes with label: {label}")
            csv_data = export_nodes_to_csv(driver, config["neo4j_database"], label)
            if csv_data:
                output_file = export_dir / f"nodes_{label}.csv"
                output_file.write_text(csv_data)
                print(f"    -> {output_file.name}")
            else:
                print(f"    -> No data or export failed")

        # Export relationships
        print("\nExporting relationships...")
        for rel_type in rel_types:
            print(f"  Exporting relationships of type: {rel_type}")
            csv_data = export_relationships_to_csv(driver, config["neo4j_database"], rel_type)
            if csv_data:
                output_file = export_dir / f"rels_{rel_type}.csv"
                output_file.write_text(csv_data)
                print(f"    -> {output_file.name}")
            else:
                print(f"    -> No data or export failed")

        print("\nLocal export complete!")
        print(f"Files saved to: {export_dir}")

        # Upload to S3
        upload_to_s3(config, export_dir)

    finally:
        driver.close()

    print("\nDone!")


if __name__ == "__main__":
    main()
