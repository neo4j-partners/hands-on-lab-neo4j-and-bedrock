# MCP Interaction Pattern

## The Five-Step Dance

```
1. DISCOVERY
   Agent connects and requests available tools

2. SELECTION
   LLM decides which tool fits the question

3. INVOCATION
   Agent sends tool call with parameters

4. RESPONSE
   MCP server executes and returns results

5. SYNTHESIS
   LLM incorporates results into response
```

## Example

```python
# 1. Agent discovers tools
tools = mcp_client.list_tools()
# → [{"name": "read-cypher", ...}]

# 2-4. Agent invokes tool
result = mcp_client.call_tool("read-cypher", {
    "query": "MATCH (c:Company) RETURN count(c)"
})

# 5. LLM synthesizes
# "There are 8 companies in the database."
```

---

[← Previous](03-what-is-mcp.md) | [Next: Transport Options →](05-transport.md)
