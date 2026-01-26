# Binding Tools to the LLM

## Making Tools Available

```python
# Define your tools
tools = [get_current_time, add_numbers]

# Bind tools to the LLM
llm_with_tools = llm.bind_tools(tools)
```

## What Binding Does

1. **Converts tools** to a format the LLM understands
2. **Includes descriptions** in the system prompt
3. **Enables tool calls** in LLM responses

## The Agent Node

```python
def call_model(state: MessagesState):
    response = llm_with_tools.invoke(state["messages"])
    return {"messages": [response]}
```

The agent receives messages, calls the LLM (with tools bound), and returns the response.

---

[← Previous](10-tool-descriptions.md) | [Next: Summary →](12-summary.md)
