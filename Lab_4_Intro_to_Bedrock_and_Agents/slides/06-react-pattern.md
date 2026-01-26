# The ReAct Pattern

## Reasoning + Acting

**ReAct** (Reason + Act) is a fundamental agent pattern:

```
1. Receive question
2. REASON: "I need to find the current time"
3. ACT: Call get_current_time tool
4. OBSERVE: "2024-01-15 10:30:00"
5. REASON: "Now I can answer the question"
6. RESPOND: "The current time is 10:30 AM"
```

## The Loop

```
        ┌─────────────────────────┐
        │                         │
        ▼                         │
    [Reason] ──▶ [Act] ──▶ [Observe]
        │
        ▼
    [Respond]
```

For complex questions, the agent may loop multiple times.

---

[← Previous](05-what-is-agent.md) | [Next: LangGraph Architecture →](07-langgraph.md)
