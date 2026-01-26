# Sample Queries

## Try These Natural Language Questions

**Explore the data model:**
```python
query("What is the database schema?")
```

**Simple counts:**
```python
query("How many companies are in the database?")
```

**Relationship traversal:**
```python
query("What companies does BlackRock own?")
query("What risk factors does Apple face?")
```

**Comparative analysis:**
```python
query("Which company has the most risk factors?")
query("What risks do Apple and Microsoft share?")
```

## What Happens

1. LLM analyzes question
2. Calls `get-schema` to understand structure
3. Generates Cypher query
4. Calls `read-cypher` to execute
5. Synthesizes human-readable response

---

[← Previous](05-architecture.md) | [Next: Summary →](07-summary.md)
