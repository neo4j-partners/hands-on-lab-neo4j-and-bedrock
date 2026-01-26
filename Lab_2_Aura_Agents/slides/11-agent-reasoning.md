# Agent Reasoning

## Understanding Tool Selection

The agent shows its reasoning process:

```
Question: "Tell me about Apple Inc"

Reasoning: This question asks for company overview information.
           The get_company_overview tool is designed for this.
           Parameter: company_name = "APPLE INC"

Action: Calling get_company_overview with company_name="APPLE INC"

Result: Company data with risks and investors

Response: "Apple Inc is a technology company that faces
          several key risk factors including..."
```

## Why Reasoning Matters

- **Transparency** - Understand why the agent chose its approach
- **Debugging** - Identify when tools are misselected
- **Trust** - Users can verify the agent's logic

---

[← Previous](10-testing.md) | [Next: Summary →](12-summary.md)
