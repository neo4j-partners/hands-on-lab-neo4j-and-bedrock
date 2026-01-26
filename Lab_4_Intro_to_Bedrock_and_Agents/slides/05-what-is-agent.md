# What is an AI Agent?

## Beyond Simple Chat

Regular chat is one-shot:
```
User → LLM → Response
```

Agents can **take actions** and **iterate**:
```
User → LLM → Tool → Observe → LLM → Tool → ... → Response
```

## Agent Capabilities

| Capability | Example |
|------------|---------|
| **Tool Use** | Query a database, call an API |
| **Iteration** | Try multiple approaches |
| **Memory** | Remember conversation context |
| **Reasoning** | Decide what to do next |

## Why Agents Matter

Complex tasks often require:
- Breaking the problem into steps
- Gathering information from multiple sources
- Adapting based on results

---

[← Previous](04-bedrock-python.md) | [Next: The ReAct Pattern →](06-react-pattern.md)
