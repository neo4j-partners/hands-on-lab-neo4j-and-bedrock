# The GraphRAG Class

## Orchestrating Retrieval + Generation

The `GraphRAG` class combines your retriever with an LLM:

```python
from neo4j_graphrag.generation import GraphRAG
from neo4j_graphrag.llm import BedrockLLM

llm = BedrockLLM(model_id="us.anthropic.claude-sonnet-4-20250514-v1:0")

rag = GraphRAG(
    retriever=retriever,
    llm=llm
)

# Ask a question
response = rag.search(
    query_text="What are the main risk factors?",
    retriever_config={"top_k": 5},
    return_context=True
)

print(response.answer)           # LLM-generated answer
print(response.retriever_result) # Retrieved context
```

---

[← Previous](14-expanded-context.md) | [Next: Summary →](16-summary.md)
