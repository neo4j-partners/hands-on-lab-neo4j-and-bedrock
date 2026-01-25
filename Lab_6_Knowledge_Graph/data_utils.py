"""Utilities for data loading, Neo4j operations, and AWS Bedrock AI services."""

import asyncio
from pathlib import Path

from dotenv import load_dotenv
from neo4j import GraphDatabase
from neo4j_graphrag.embeddings import BedrockEmbeddings
from neo4j_graphrag.experimental.components.text_splitters.fixed_size_splitter import FixedSizeSplitter
from neo4j_graphrag.llm import BedrockLLM
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

# Load configuration from project root
_config_file = Path(__file__).parent.parent / "CONFIG.txt"
load_dotenv(_config_file)


# =============================================================================
# Configuration Classes
# =============================================================================

class Neo4jConfig(BaseSettings):
    """Neo4j configuration loaded from environment variables."""

    model_config = SettingsConfigDict(env_prefix="", extra="ignore")

    uri: str = Field(validation_alias="NEO4J_URI")
    username: str = Field(validation_alias="NEO4J_USERNAME")
    password: str = Field(validation_alias="NEO4J_PASSWORD")


class BedrockConfig(BaseSettings):
    """AWS Bedrock configuration loaded from environment variables."""

    model_config = SettingsConfigDict(env_prefix="", extra="ignore")

    model_id: str = Field(
        default="us.anthropic.claude-3-sonnet-20240229-v1:0",
        validation_alias="MODEL_ID"
    )
    embedding_model_id: str = Field(
        default="amazon.titan-embed-text-v2:0",
        validation_alias="EMBEDDING_MODEL_ID"
    )
    region: str = Field(default="us-west-2", validation_alias="REGION")


# =============================================================================
# AI Services
# =============================================================================

def get_embedder() -> BedrockEmbeddings:
    """Get embedder using AWS Bedrock's Titan Embeddings."""
    config = BedrockConfig()

    return BedrockEmbeddings(
        model_id=config.embedding_model_id,
        region_name=config.region,
    )


def get_llm() -> BedrockLLM:
    """Get LLM using AWS Bedrock."""
    config = BedrockConfig()

    return BedrockLLM(
        model_id=config.model_id,
        region_name=config.region,
    )


# =============================================================================
# Neo4j Connection
# =============================================================================

class Neo4jConnection:
    """Manages Neo4j database connection."""

    def __init__(self):
        """Initialize and connect to Neo4j using environment configuration."""
        self.config = Neo4jConfig()
        self.driver = GraphDatabase.driver(
            self.config.uri,
            auth=(self.config.username, self.config.password)
        )

    def verify(self):
        """Verify the connection is working."""
        self.driver.verify_connectivity()
        print("Connected to Neo4j successfully!")
        return self

    def clear_graph(self):
        """Remove all Document and Chunk nodes."""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (n) WHERE n:Document OR n:Chunk
                DETACH DELETE n
                RETURN count(n) as deleted
            """)
            count = result.single()["deleted"]
            print(f"Deleted {count} nodes")
        return self

    def close(self):
        """Close the database connection."""
        self.driver.close()
        print("Connection closed.")


# =============================================================================
# Data Loading
# =============================================================================

class DataLoader:
    """Handles loading text data from files."""

    def __init__(self, file_path: str):
        """Initialize with path to data file."""
        self.file_path = Path(file_path)
        self._text = None

    @property
    def text(self) -> str:
        """Load and return the text content from the file."""
        if self._text is None:
            self._text = self.file_path.read_text().strip()
        return self._text

    def get_metadata(self) -> dict:
        """Return metadata about the loaded file."""
        return {
            "path": str(self.file_path),
            "name": self.file_path.name,
            "size": len(self.text)
        }


# =============================================================================
# Text Splitting
# =============================================================================

def split_text(text: str, chunk_size: int = 500, chunk_overlap: int = 50) -> list[str]:
    """Split text into chunks using FixedSizeSplitter.

    Args:
        text: Text to split
        chunk_size: Maximum characters per chunk
        chunk_overlap: Characters to overlap between chunks

    Returns:
        List of chunk text strings
    """
    splitter = FixedSizeSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        approximate=True
    )

    # Handle both Jupyter (running event loop) and regular Python
    try:
        loop = asyncio.get_running_loop()
    except RuntimeError:
        loop = None

    if loop is not None:
        # Running in Jupyter or async context - use nest_asyncio
        import nest_asyncio
        nest_asyncio.apply()
        result = asyncio.run(splitter.run(text))
    else:
        # Regular Python - use asyncio.run directly
        result = asyncio.run(splitter.run(text))

    return [chunk.text for chunk in result.chunks]
