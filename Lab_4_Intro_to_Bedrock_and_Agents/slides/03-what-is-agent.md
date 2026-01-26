# What is an AI Agent?

## Beyond Chat

AI agents extend beyond simple chat by giving LLMs the ability to **take actions**.

**Regular Chat:**
```
User → LLM → Response
```

**Agent:**
```
User → LLM → Tool Call → Observe → LLM → Tool Call → ... → Response
```

## The ReAct Pattern

**Re**asoning + **Act**ing in a loop:

1. **Reason** about the task
2. **Act** by calling a tool
3. **Observe** the result
4. **Repeat** until done

## Why Agents Matter

- Break complex tasks into steps
- Access external data and services
- Execute autonomously

---

[← Previous](02-amazon-bedrock.md) | [Next: LangGraph Architecture →](04-langgraph.md)
