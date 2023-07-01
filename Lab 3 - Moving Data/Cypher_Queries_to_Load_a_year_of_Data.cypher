//First, let's create constraints, essentially a primary key, for the company and manager node types.
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Company) REQUIRE (p.cusip) IS NODE KEY;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Manager) REQUIRE (p.filingManager) IS NODE KEY;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Holding) REQUIRE (p.filingManager, p.cusip, p.reportCalendarOrQuarter) IS NODE KEY;
//Let's load the companies first
LOAD CSV WITH HEADERS FROM 'https://neo4j-dataset.s3.amazonaws.com/form13/2021.csv' AS row
MERGE (c:Company {cusip:row.cusip})
ON CREATE SET
    c.nameOfIssuer=row.nameOfIssuer;
//Now let's load the Managers:
LOAD CSV WITH HEADERS FROM 'https://neo4j-dataset.s3.amazonaws.com/form13/2021.csv' AS row
MERGE (m:Manager {filingManager:row.filingManager});
//And now we can load our Holdings:
LOAD CSV WITH HEADERS FROM 'https://neo4j-dataset.s3.amazonaws.com/form13/2021.csv' AS row
MERGE (h:Holding {filingManager:row.filingManager, cusip:row.cusip, reportCalendarOrQuarter:row.reportCalendarOrQuarter})
ON CREATE SET
    h.value=toInteger(row.value), 
    h.shares=toInteger(row.shares),
    h.target=toBoolean(row.target),
    h.nameOfIssuer=row.nameOfIssuer;
//So, let's put together the owns relationship first.
LOAD CSV WITH HEADERS FROM 'https://neo4j-dataset.s3.amazonaws.com/form13/2021.csv' AS row
MATCH (m:Manager {filingManager:row.filingManager})
MATCH (h:Holding {filingManager:row.filingManager, cusip:row.cusip, reportCalendarOrQuarter:row.reportCalendarOrQuarter})
MERGE (m)-[r:OWNS]->(h);
//And, now we can create the PARTOF relationships:
LOAD CSV WITH HEADERS FROM 'https://neo4j-dataset.s3.amazonaws.com/form13/2021.csv' AS row
MATCH (h:Holding {filingManager:row.filingManager, cusip:row.cusip, reportCalendarOrQuarter:row.reportCalendarOrQuarter})
MATCH (c:Company {cusip:row.cusip})
MERGE (h)-[r:PARTOF]->(c);
//Done with loading 1 years of data. Please allow atleast 3-5 minutes to load this 1/2 million records. If it fails, please retry.
