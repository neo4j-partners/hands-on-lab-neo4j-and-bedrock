# Aura Agent Verification Report

**Date:** 2026-01-25
**Database:** neo4j+s://d809f4ca.databases.neo4j.io
**Instance:** finance_demo (d809f4ca)
**Status:** PASS

---

## Executive Summary

The Lab 2 Aura Agents instructions have been verified against the live Neo4j database. All expected schema elements are present, and all Cypher queries execute successfully. The database contains SEC 10-K filing data for 12 companies with associated risk factors, asset manager ownership data, and vector embeddings for semantic search.

---

## Connection Test

| Property | Value |
|----------|-------|
| URI | `neo4j+s://d809f4ca.databases.neo4j.io` |
| Database | `neo4j` |
| Connection | **SUCCESS** |

---

## Database Schema

### Node Labels

| Label | Count | Status |
|-------|-------|--------|
| RiskFactor | 820 | Required |
| FinancialMetric | 470 | Additional |
| Chunk | 390 | Required (for vector search) |
| Product | 241 | Optional |
| TimePeriod | 102 | Additional |
| Transaction | 46 | Additional |
| Executive | 29 | Optional |
| AssetManager | 15 | Required |
| Company | 12 | Required |
| Document | 11 | Required |
| StockType | 9 | Additional |

### Relationship Types

| Type | Count | Status |
|------|-------|--------|
| FROM_DOCUMENT | 390 | Chunk linkage |
| NEXT_CHUNK | 381 | Chunk ordering |
| FROM_CHUNK | 2,414 | Entity extraction |
| FILED | 10 | Required |
| MENTIONS | 378 | Entity mentions |
| HAS_METRIC | 526 | Financial metrics |
| FACES_RISK | 836 | Required |
| ISSUED_STOCK | 17 | Stock issuance |
| OWNS | 118 | Required |

### Indexes

| Name | Type | Labels | Properties | State |
|------|------|--------|------------|-------|
| chunkEmbeddings | VECTOR | Chunk | embedding | ONLINE |
| managerName_AssetManager_uniq | RANGE | AssetManager | managerName | ONLINE |
| name_Company_uniq | RANGE | Company | name | ONLINE |
| path_Document_uniq | RANGE | Document | path | ONLINE |
| search_chunks | FULLTEXT | Chunk | text | ONLINE |
| search_entities | FULLTEXT | Company, Product, RiskFactor | name | ONLINE |

---

## Lab 2 Schema Verification

### Required Node Labels

| Label | Expected | Found | Status |
|-------|----------|-------|--------|
| Company | Yes | Yes | PASS |
| Document | Yes | Yes | PASS |
| RiskFactor | Yes | Yes | PASS |
| AssetManager | Yes | Yes | PASS |

### Optional Labels (Mentioned in Lab)

| Label | Found | Status |
|-------|-------|--------|
| Executive | Yes | PASS |
| Product | Yes | PASS |
| Chunk | Yes | PASS |

### Required Relationship Types

| Type | Expected | Found | Status |
|------|----------|-------|--------|
| FILED | Yes | Yes | PASS |
| FACES_RISK | Yes | Yes | PASS |
| OWNS | Yes | Yes | PASS |

### Vector Index

| Index | Expected | Found | Status |
|-------|----------|-------|--------|
| chunkEmbeddings | Yes | Yes (ONLINE) | PASS |

---

## Cypher Query Verification

### Tool 1: get_company_overview

**Status:** PASS

**Test Parameters:**
- Company: APPLE INC

**Query:**
```cypher
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
```

**Results:**
| Field | Value |
|-------|-------|
| Company | APPLE INC |
| Ticker | AAPL |
| Filing Path | data/form10k-sample/0000320193-23-000106.pdf |
| Risk Factors | 10 found |
| Asset Managers | 10 found |

---

### Tool 2: find_shared_risks

**Status:** PASS (query syntax valid)

**Test Parameters:**
- Company 1: APPLE INC
- Company 2: MICROSOFT CORP

**Query:**
```cypher
MATCH (c1:Company)-[:FACES_RISK]->(r:RiskFactor)<-[:FACES_RISK]-(c2:Company)
WHERE c1.name = $company1 AND c2.name = $company2
WITH c1, c2, collect(DISTINCT r.name) AS shared_risks
RETURN
    c1.name AS company_1,
    c2.name AS company_2,
    shared_risks,
    size(shared_risks) AS num_shared_risks
```

**Note:** Query executes successfully. No shared risks found between APPLE INC and MICROSOFT CORP in current dataset (risk factors may be company-specific in this sample).

---

### Tool 3: get_manager_portfolio (Future Tool)

**Status:** PASS

**Test Parameters:**
- Manager: ALLIANCEBERNSTEIN L.P.

**Query:**
```cypher
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
```

**Results:**
| Field | Value |
|-------|-------|
| Asset Manager | ALLIANCEBERNSTEIN L.P. |
| Portfolio Size | 8 companies |

---

### Tool 4: list_companies (Future Tool)

**Status:** PASS

**Query:**
```cypher
MATCH (c:Company)
OPTIONAL MATCH (c)-[:FACES_RISK]->(r:RiskFactor)
WITH c, count(r) AS risk_count
RETURN c.name AS company, c.ticker AS ticker, risk_count
ORDER BY risk_count DESC
LIMIT 20
```

**Results:**
| Company | Ticker | Risk Count |
|---------|--------|------------|
| PG&E CORP | PCG | 202 |
| APPLE INC | AAPL | 101 |
| MICROSOFT CORP | MSFT | 96 |
| AMAZON | AMZN | 89 |
| INTEL CORP | INTC | 85 |
| NVIDIA CORPORATION | NVDA | 79 |
| MCDONALDS CORP | MCD | 62 |
| AMERICAN INTL GROUP | AIG | 56 |
| And 4 more... | | |

---

## Sample Data

### Companies in Database

| Company | Ticker |
|---------|--------|
| APPLE INC | AAPL |
| MICROSOFT CORP | MSFT |
| AMAZON | AMZN |
| INTEL CORP | INTC |
| PG&E CORP | PCG |
| Activision Blizzard, Inc. | - |
| NVIDIA CORPORATION | NVDA |
| MCDONALDS CORP | MCD |
| AMERICAN INTL GROUP | AIG |
| PAYPAL | - |
| And 2 more... | |

### Asset Managers

| Manager Name |
|--------------|
| ALLIANCEBERNSTEIN L.P. |
| AMERIPRISE FINANCIAL INC |
| AMUNDI |
| BANK OF AMERICA CORP /DE/ |
| Bank of New York Mellon Corp |
| Berkshire Hathaway Inc |
| BlackRock Inc. |
| Capital World Investors |
| FMR LLC |
| GEODE CAPITAL MANAGEMENT, LLC |
| And 5 more... |

### Sample Risk Factors

- Geography
- Aggressive price competition
- Frequent introduction of new products
- Short product life cycles
- Evolving industry standards
- Commodity pricing fluctuations
- Industry-wide shortage and significant commodity pricing fluctuations
- Initial capacity constraints when new technologies are used
- Availability of components at acceptable prices
- Ability to extend or renew component supply agreements

### Vector Search Capability

| Metric | Value |
|--------|-------|
| Total Chunks | 390 |
| Chunks with Embeddings | 390 |
| Embedding Coverage | 100% |

---

## Node Property Keys

| Label | Properties |
|-------|------------|
| Company | :ID, name, ticker |
| Document | :ID, path |
| RiskFactor | :ID, name |
| AssetManager | :ID, managerName |
| Chunk | :ID, embedding, text |

---

## Verification Summary

| Category | Expected | Found | Status |
|----------|----------|-------|--------|
| Required Node Labels | 4 | 4 | PASS |
| Required Relationships | 3 | 3 | PASS |
| Vector Index | 1 | 1 | PASS |
| Cypher Queries | 4 | 4 | PASS |

---

## Conclusion

**VERIFICATION STATUS: PASS**

The Lab 2 Aura Agents instructions are **accurate** and correctly describe the database schema. All Cypher template queries execute successfully against the live database. The vector index `chunkEmbeddings` is online and ready for similarity search operations.

### Recommendations

1. The `find_shared_risks` query works correctly but returns no results for APPLE/MICROSOFT. Consider testing with companies that have overlapping risk factors (e.g., INTEL and NVIDIA for semiconductor-related risks).

2. All 390 chunks have embeddings, enabling the similarity search tool described in Step 4.

3. The Text2Cypher tool (Step 5) will have access to a rich schema with multiple node types and relationships for flexible querying.

---

*Report generated by verify_lab2.py*
